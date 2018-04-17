#!/bin/ksh
#
# Script: fem_sia_build_item_loc.ksh
# Description: 
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
SET SERVEROUTPUT ON
DECLARE
   O_ERROR_MESSAGE VARCHAR2(2000);
   v_Return        BOOLEAN;
BEGIN
   DBMS_APPLICATION_INFO.SET_MODULE(module_name=>'MODULE_NAME', action_name=>'BUILD_TABLE');
   v_Return := SCHEMA.PACKAGE.PROCEDURE(O_ERROR_MESSAGE => O_ERROR_MESSAGE);
   DBMS_OUTPUT.PUT_LINE(O_ERROR_MESSAGE);
END;
/
exit
"

_message "Program completed successfully"
exit 0