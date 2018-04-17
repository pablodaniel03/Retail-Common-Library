#!/bin/ksh
#
# Script: xxfc_aip_pdf.ksh
# Description: Generación y envio de ordenes
#              de compra para AIP.
# Revision: 1
# Author: Pablo Almaguer
# Creation date: 2018-02-15
###########################################

SCRIPT_NAME="$(basename $0 .ksh)"

###########################################
# Utilities functions
###########################################
. xxfc_sia_lib.ksh

###########################################
# Script
###########################################
MMHOME="/path/to/mmhome"
PDF_OUTPUT="/path/to/pdf/files"
SQLPLUS_LOGON="/@RMS_DBNAME"
CONNECT_STRING="/@RMS_DBNAME"
ACTION=

function _usage {
  print "Usage: $SCRIPT_NAME [-g] [-s] [-a]"
  print "  -g  Generate purchase orders."
  print "  -s  Send purchase orders."
  print "  -a  Run complete process."
  exit 2
}

function _process_arguments {
  while getopts ":gsa:" OPT
  do
    case $OPT in
      g) ACTION="GENERATION";;
      s) ACTION="SEND";;
      a) ACTION="ALL";;
      *) _usage;;
    esac
  done

  [ -z $ACTION ] && _usage
}

########
# Generación de nombres de archivo
# PDF para las ordenes de compra
function _get_pdf_names {
  _sql_fetch "
   select distinct (regexp_replace(mc.order_no||':'||mc.process_user||'_'||mc.order_no||'_FA'||mc.supplier||'_'||TO_CHAR(mc.process_date,'DDMMYYYY')||'_'||replace(su.sup_name,' ','_'), '[^A-Za-z0-9:_]', '')||'.pdf')
   from siaprd.xxfc_stg_aip_purch_orders mc
   inner join sups su on (su.supplier = mc.supplier)
   where mc.process_phase = 'SUCCESS'
     and mc.process_pdf is null
     and mc.loc_type = 'W';" PDF_LOG

  [ -z ${PDF_LOG} ] && _warning "There are no purchase orders"; exit 0

  return ${PDF_LOG}
}

########
# Actualiza el estatus de la orden de
# compra generada
function _update_po_status {
  typeset order_no=$1

  message "Updating purchase orders status"
  _sqlplus "
    begin
    update siaprd.xxfc_stg_aip_purch_orders
       set process_pdf   = 'Y'
     where process_pdf is null
       and process_phase = 'SUCCESS'
       and loc_type      = 'W'
       and order_no      = '${order_no}';    
    commit;
    end;
  /"
}

########
# Respaldo y purga de ordenes de compra
function _purge_po {
  _sql_fetch "select trunc(sysdate) - trunc((add_months(sysdate,-5)),'mon') from dual;" PURGE_TIME
  
  message "Backing purchase orders"
  _exec find ${PDF_OUTPUT}/OC_HIST -name '*.pdf' -mtime +${PURGE_TIME} -exec rm -f {} \; _verify
  
  message "Purging purchase orders"
  _exec find ${PDF_OUTPUT}/OC -name '*.pdf' -mtime +1 -exec mv -f '{}' ${PDF_OUTPUT}/OC_HIST \; _verify
  _exec find ${PDF_OUTPUT}/OC -name '*'+$(TZ=EST+24 date +%Y%m%d)+'*.pdf' -exec mv -f '{}' ${PDF_OUTPUT}/OC_HIST \; _verify
}

########
# Ejecución de oracle reports para la
# generación del arhivo PDF
function _run_report {
  typeset order_no=$1
  typeset pdf_file=$2

  echo _exec rwrun60 userid=${CONNECT_STRING} report=${MMHOME}/reports/bin/ord_det.rep background=no destype=file desname=${PDF_OUTPUT}/OC/${pdf_file} PARAMFORM=NO pm_order_no=${order_no} printer=default.ppd batch=yes desformat=pdf
}

########
# Proceso principal de generación de 
# ordenes de compra
function _generate_purchase_orders {
  
  message "Generation of purchase orders started..."
  PDF_FILES=$(_get_pdf_names)


  IFS=":"; while read ORDER_NO PDF_FILE; do
    message "    File \"${PDF_FILE}\" for purchase order \"${ORDER_NO}\""

    _exec _run_report ${ORDER_NO} ${PDF_FILE}
    _exec _update_po_status ${ORDER_NO}
  done <<< "${PDF_FILES}"

  message "Generation of purchase orders completed"

  _exec _purge_po
}

function _send_purchase_orders {
  _sqlplus "begin siaprd.xxfc_aip_compras.envia_correos; end; commit;"
}

message "Program started..."

_process_arguments $@

if [[ $ACTION == "GENERATION" ]]; then
  _exec _generate_purchase_orders
elif [[ $ACTION == "SEND" ]]; then
  _exec _send_purchase_orders
elif [[ $ACTION == "ALL" ]]; then
  _exec _generate_purchase_orders
  _exec _send_purchase_orders
fi

message "Program completed successfully"
exit 0