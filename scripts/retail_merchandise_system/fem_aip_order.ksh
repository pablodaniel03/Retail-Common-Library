#!/bin/ksh
#
# Script: xxfc_aip_pdf.ksh
# Description: Generación y envio de ordenes
#              de compra para AIP.
# Revision: 1
# Author: Pablo Almaguer
# Creation date: 2018-03-28
###########################################

SCRIPT_NAME="$(basename $0 .ksh)"

###########################################
# Utilities functions
###########################################
. xxfc_sia_lib.ksh

###########################################
# Script
###########################################
THREAD=
NUM_THREAD=12
ALL_THREADS="FALSE"

function _usage {
  print "Usage: $SCRIPT_NAME [-t T] [-a]"
  print "  -t  Number of thread [1 to $NUM_THREAD]."
  print "  -a  Run all threads."
  exit 2
}

function _process_arguments {
	while getopts "t:a" OPT
	do
		case $OPT in
			t) THREAD="$OPTARG";;
			a) ALL_THREADS="TRUE";;
			*) _usage;;
		esac
	done
}

function _check_thread {
	# Validacion del thread
	if [[ $THREAD == +([0-9]) ]]; then
		if [[ ! $THREAD -ge 1 && $THREAD -le $NUM_THREAD ]]; then
			_error "Invalid thread." _usage
		fi
	else
		_error "Invalid parameter."; _usage
	fi
}

function _fem_aip_order {
	typeset thread=$1
	_sqlplus "begin schema.package.procedure (${thread}, ${NUM_THREAD}); commit; end;"
}

message "Program started ..."

_process_arguments $@

if [[ $ALL_THREADS == "TRUE" ]]; then
	for thread in {1..$NUM_THREAD}; do
		_exec _fem_aip_order $thread &
	done
	wait
else
	_check_thread
	_exec _fem_aip_order $THREAD
fi

message "Program completed successfully"
exit 0