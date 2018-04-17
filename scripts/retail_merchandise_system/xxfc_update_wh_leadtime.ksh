#!/bin/ksh
#
# Script: xxfc_update_wh_leadtime.sh
# Description: Update table REPL_ITEM_LOC 
#              with new WH Lead Time.
# Revision: 2
# Author: Pablo Almaguer
# Creation date: 2017-04-07
# Modification: 
# ---------------------------------------------
# Pablo Almaguer | 2018-03-28 | Shell script
###############################################

SCRIPT_NAME="$(basename $0 .ksh)"

###########################################
# Utilities functions
###########################################
. xxfc_sia_lib.ksh

###########################################
# Script
###########################################
_message "Program started ..."

_sqlplus "
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE 1000000
DECLARE
   ln_dia                      NUMBER(1,0);
    
   TYPE t_n10 IS TABLE OF NUMBER(10,0);
   TYPE t_n2  IS TABLE OF NUMBER(2,0);
    
   ln_cedis                    t_n10;
   ln_supplier                 t_n10;
   ln_leadtime                 t_n2;
BEGIN
   DBMS_APPLICATION_INFO.SET_MODULE(module_name=>'MODULE_NAME', action_name=>'UPDATE_TABLE' );

   --Instrucciones para que el día de la semana corresponda con los días de generación
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TERRITORY=AMERICA';
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE=AMERICAN';

   --ln_dia almacena el día de la semana a actualizar ---
   ln_dia := TO_NUMBER(TO_CHAR(SYSDATE,'D'));

   --Se almacenan las combinaciones de CEDIS, SUPPLIER a actualizar en la RIL
   SELECT cedis
         ,supplier
         ,leadtime 
     BULK COLLECT INTO 
          ln_cedis
         ,ln_supplier
         ,ln_leadtime
     FROM schema.table_in_system
    WHERE diasemana = ln_dia;

   --Con todas las combinaciones consultadas se realiza la actualización
   FORALL j IN 1..ln_leadtime.LAST
      UPDATE schema.table_in_system
         SET pickup_lead_time = ln_leadtime(j)
            ,last_update_datetime = SYSDATE
            ,last_update_id = USER
      WHERE loc_type = 'W'
        AND location = ln_cedis(j)
        AND primary_repl_supplier = ln_supplier(j);

   COMMIT;
END;
/
exit
"
_message "Program completed successfully"
exit 0
