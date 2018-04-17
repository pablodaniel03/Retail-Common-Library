#!/bin/ksh

##############################################################################
# Module:        AIP
# Author:        Pedro Alán Hernández Treviño
# Creation Date: 07/Mar/2016
# Version:       1.0
# Description:   The rmse_aip_wh.ksh program extracts RMS warehouse information 
#                and places this data into rmse_aip_wh.dat, rmse_aip_wh.txt and
#                rmse_aip_wh_type.txt flat files to be accessed
#                by AIP data transformation programs.
# 					      
# Inputs:        None
# Output:        rmse_aip_wh.dat, rmse_aip_wh.txt,
#                rmse_aip_wh_type.txt
# Called by:     
# Calls:
# Modifyed by		               Date	      Description
# -------------------------------------------------------------------------
# Pedro Alán Hernández Treviño     07/Mar/2016      Initial Creation
###############################################################################


################## PROGRAM DEFINES #####################
########## (must be the first set of defines) ##########

export PROGRAM_NAME="rmse_aip_wh"

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINES) ####

. ${AIP_HOME}/rfx/etc/rmse_aip_config.env
. ${LIB_DIR}/rmse_aip_lib.ksh

##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########

export OUTPUT_FILE="${DATA_DIR}/${PROGRAM_NAME}.dat"
export OUTPUT_SCHEMA="${SCHEMA_DIR}/${PROGRAM_NAME}_dat.schema"
export AIP_OUTPUT_FILE1="${DATA_DIR}/rmse_aip_wh.txt"
export AIP_OUTPUT_SCHEMA1="${SCHEMA_DIR}/rmse_aip_wh.schema"
export AIP_OUTPUT_FILE2="${DATA_DIR}/rmse_aip_wh_type.txt"
export AIP_OUTPUT_SCHEMA2="${SCHEMA_DIR}/rmse_aip_wh_type.schema"

message "Program started ..."

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"  
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
   ${DBREAD[RMS]}
      <PROPERTY name = "arraysize" value = "4000"/>
	  <PROPERTY name = "query">
         <![CDATA[
            SELECT TO_CHAR(  ) as WH, RTRIM(W   E) as W   AME, FORECAS     ND, STOCKHOLDI     D, 'XD  S' as W    PE
            FROM TABLE_1
			where COLUMN = 'MX' 
         ]]>
      </PROPERTY>

      <OPERATOR type="convert">
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="WH_NAME" sourcefield="WH_NAME">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
				  <CONVERT destfield="WH" sourcefield="WH">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
               </CONVERTSPECS>
            ]]>
         </PROPERTY>
         <OPERATOR  type="copy">
            <OUTPUT name="rms_copy.v"/>
            <OUTPUT name="aip_copy.v"/>
         </OPERATOR>
      </OPERATOR>
   </OPERATOR>

   <OPERATOR  type="fieldmod">
      <INPUT     name="aip_copy.v"/>
      <PROPERTY  name="rename" value="WAREHOUSE=WH"/>
      <PROPERTY  name="rename" value="WAREHOUSE_DESCRIPTION=WH_NAME"/>
      <OPERATOR  type="copy">
         <OUTPUT name="copy1.v"/>
         <OUTPUT name="copy2.v"/>
      </OPERATOR>
   </OPERATOR>

   <OPERATOR type="filter">
      <INPUT name="copy1.v"/>
      <PROPERTY  name="filter" value="STOCKHOLDING_IND EQ 'Y'"/>
      <OPERATOR  type="fieldmod">
         <PROPERTY name="duplicate" value="WAREHOUSE_CHAMBER=WAREHOUSE"/>
         <PROPERTY name="duplicate" value="WAREHOUSE_CHAMBER_DESCRIPTION=WAREHOUSE_DESCRIPTION"/>
         <OPERATOR type="convert">
            <PROPERTY name="convertspec">
               <![CDATA[
                  <CONVERTSPECS>
                     <CONVERT destfield="WAREHOUSE_CHAMBER" sourcefield="WAREHOUSE_CHAMBER" newtype="string" >
                     <CONVERTFUNCTION name="string_from_int64" />
                     </CONVERT>
                  </CONVERTSPECS>
               ]]>
            </PROPERTY>
            <OPERATOR type="export">
               <PROPERTY  name="schemafile" value="${AIP_OUTPUT_SCHEMA1}"/>
          <PROPERTY  name="outputfile" value="${AIP_OUTPUT_FILE1}"/>
            </OPERATOR>
         </OPERATOR>
      </OPERATOR>
   </OPERATOR>
   
   <OPERATOR type="filter">
      <INPUT name="copy2.v"/>
      <PROPERTY  name="filter" value="STOCKHOLDING_IND EQ 'Y'"/>
      <OPERATOR type="export">
         <PROPERTY  name="schemafile" value="${AIP_OUTPUT_SCHEMA2}"/>
         <PROPERTY  name="outputfile" value="${AIP_OUTPUT_FILE2}"/>
      </OPERATOR>
   </OPERATOR>

   <OPERATOR type="export">
      <INPUT    name="rms_copy.v"/>
      <PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
      <PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
   </OPERATOR>
</FLOW>
EOF

###############################################
#  Execute the RETL flow that had previously
#  been copied into rmse_aip_wh.xml:
###############################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}.xml

message "Program completed successfully"

# cleanup and exit rmse_terminate 0
exit 0