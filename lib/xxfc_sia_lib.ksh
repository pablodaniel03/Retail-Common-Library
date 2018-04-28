###########################################
# xxfc_sia_lib.ksh - Custom library
# 
# Revision: 1
# Author: Pablo Almaguer
# Creation date: 2018-02-15
#
###########################################
# Function __get_timestamp
# ---------------------------------
# prints timestamp in YYYYMMDDhhmmss format
# example: 20180302150353
###########################################

function __get_timestamp {
  print $(date +"%Y%m%d%H%M%S")
}
alias _get_timestamp='__get_timestamp'

########
# Private variables
_SCRIPT_NAME="${SCRIPT_NAME:-${PROGRAM_NAME:-$0.$$}}"
_LOG_DIR="${LOG_DIR:-$TMP}"
_ERR_DIR="${ERR_DIR:-$TMP}"
_LOG_FILE="${LOG_FILE:-${_LOG_DIR}/${_SCRIPT_NAME}.$(__get_timestamp).log}"
_ERR_FILE="${ERR_FILE:-${_ERR_DIR}/${_SCRIPT_NAME}.$(__get_timestamp)}"

#_CONNECT_STRING="user/password" #Descomentar para no utilizar wallets


###########################################
# Function __message
# ---------------------------------
# privately called by _message, for log script.
#
# $1 - Line number
# $2 - Level "PROFILE" 
#            "DEBUG" 
#            "INFORMATION"
#            "WARNING"
#            "ERROR" 
#            "NONE"
# $3 - Double quoted message string
###########################################
function __message {
  typeset lineno=${1}
  typeset level=${2:-DEBUG}
  typeset msg="${3}"
  print "$(date +'%T') : ${level} : ${_SCRIPT_NAME}[${lineno}] - ${msg}" >> ${_ERR_FILE} 
}
alias _message='__message ${LINENO}'
alias _warning='__message ${LINENO} WARNING'      # Custom alias for WARNING message.
alias _error='__message ${LINENO} ERROR'          # Custom alias for ERROR message.
alias message='__message ${LINENO} INFORMATION'   # Custom alias for integration scripts.


###########################################
# Function __terminate
# ---------------------------------
# private function called by exit alias.
#
# $1 - Line number
# $2 - Return code
###########################################
function __terminate {
  typeset lineno=${1}
  typeset exit=${2:-$?}
  typeset loglevel=${3:-INFORMATION}

  __message ${lineno} ${loglevel} "Exiting script with code: ${exit}"

  trap "" EXIT
  exit "${exit}"
}
alias exit='__terminate ${LINENO}'

###########################################
# Function __exec
# ---------------------------------
# privately called by _exec redirects 
# stderr and stdout output to logfile.
#
# $1 - Line number
# $2 - Binary or script.
###########################################
function __exec {
  typeset -i lineno=$1
  shift
  __LAST_CALL="$*"
  __message ${lineno} DEBUG "_exec executing command '$*'"
  "$@" >> "${_ERR_FILE}" 2>&1
  typeset -i exit=$?
  __verify $? ${LINENO}
  __verify_log ${LINENO}
  __message ${lineno} DEBUG "_exec of command '$*' complete"
  #return ${exit}
}
alias _exec='__exec ${LINENO}'


###########################################
# Function __verify
# ---------------------------------
# privately called by _verify, checks the 
# return code returned from a binary.
#
# $1 - Return code
# $2 - Line number
# $3 - Custom error message
###########################################
function __verify {
  typeset exit=$1

  if [[ ${exit} -ne 0 ]]; then
    typeset -i lineno=$2
    
    typeset msg="$3"
    if [[ -z "$msg" ]]; then
      msg="${__LAST_CALL}"
    fi
    __message ${lineno} ERROR "${msg}"
    trap "trap '' INT EXIT" EXIT
    __terminate ${lineno} 1
  fi
}
alias _verify='__verify $? ${LINENO}'


###########################################
# Function __verify_log
# ---------------------------------
# privately called by _verify_log, checks 
# the log file for known errors.
#
# $1 - Line number
###########################################
function __verify_log {
  typeset egrep_strings="error|fatal|abort|^ora"
  typeset lineno=${1}

  if [[ $(egrep -ie "${egrep_strings}" ${_ERR_FILE}) ]]; then 
    __message ${lineno} ERROR "\"Error\" message found in log file."
    trap "trap '' INT EXIT" EXIT
    __terminate ${lineno} 1
  fi
}
alias _verify_log='__verify_log ${LINENO}'


###########################################
# Function __check
# ---------------------------------
# privately called by _check, checks if 
# directory or file exists. 
#
# $1 - Line number
# $2 - Directory or file
###########################################
function __check {
  typeset lineno=${1}
  typeset _tocheck=${2}

  for tocheck in ${_tocheck[@]}; do
    if [[ -d ${tocheck} ]]; then
      __message ${lineno} INFORMATION "\"${tocheck}\" directory exists."
    elif [[ -f ${tocheck}  ]]; then
      if [[ -s ${tocheck} ]]; then
        __message ${lineno} INFORMATION "\"${tocheck}\" file exists."
      else
        __message ${lineno} WARNING "\"${tocheck}\" has a zero size."
      fi
    else
      __message ${lineno} ERROR "No such file or directory."
      __message ${lineno} ERROR "\"${tocheck}\" not found."
      __terminate ${lineno} 1
    fi
  done
}
alias _check='__check ${LINENO}'


###########################################
# Function __sql_fetch
# ---------------------------------
# privately called by _sql_fetch, checks 
# the log file for known errors.
#
# $1 - Line number
# $2 - SQL command
# $3 - Output variable
# $4 - Database alias (optional)
###########################################
function __sql_fetch {
  typeset lineno=${1}
  typeset sql_command=${2}
  typeset outvar=${3:-SQL_OUT}
  typeset dbalias=${4:-${ORACLE_SID:-DEFAULTALIAS}}
  typeset conection_string=${_CONNEC_STRING:-"/"}

  fetched_value=`sqlplus -s ${conection_string}@${dbalias} << EOF
                  set pagesize 0
                  set serveroutput on size 1000000
                  set feedback off
                  set heading off
                  ${sql_command}
                  exit;
EOF`

  __message ${lineno} INFORMATION "_sql_fetch value returned: ${fetched_value}"
  
  eval ${outvar}='${fetched_value}'
  __verify $? ${lineno}
  __verify_log ${lineno}

  return 0
}
alias _sql_fetch='__sql_fetch ${LINENO}'
alias _sqlplus='__sql_fetch ${LINENO}'
