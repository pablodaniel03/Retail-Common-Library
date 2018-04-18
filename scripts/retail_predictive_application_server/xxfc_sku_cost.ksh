#!/bin/ksh

##############################################################################
# Module:                  AIP LEGACY INTERFACE
# Author:                  Pedro Alán Hernández Treviño
# Creation Date:           28/Mar/2016
# Version:                 1.1
# Description:             Script imports form ITEM_LOC file and ITEM_SUPP_COUNTRY_LOC_FILE for SKU Cost
#                    
# Inputs:                  None
# Output:                  sku_cost.dat
# Called by:     
# Calls:
# Modifyed by                      Date                  Description
# ---------------------------------------------------------------------------------------------------------------------------
# Pedro Alán Hernández Treviño     28/Mar/2016      Initial Creation
# Pablo Daniel Almaguer Alanis     12/Abr/2016      Environments, libraries and output files modified
# Pablo Daniel Almaguer Alanis     27/May/2016      Delta script
###############################################################################

########################################################
#  PROGRAM DEFINES
#  These must be the first set of defines
########################################################

export PROGRAM_NAME='xxfc_sku_cost'

########################################################
#  INCLUDES ########################
#  This section must come after PROGRAM DEFINES
########################################################
. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh

########################################################
#  OUTPUT DEFINES 
#  This section must come after INCLUDES
########################################################

ITEM_LOC_FILE=${DATA_DIR}/ITEM_LOC_LEGACY.dat
ITEM_LOC_SCHEMA=${SCHEMA_DIR}/ITEM_LOC_LEGACY.schema

export OUTPUT_FILE_NAME="sku_cost.dat"
export OUTPUT_FILE=${DATA_DIR}/${OUTPUT_FILE_NAME}
export OUTPUT_SCHEMA=${SCHEMA_DIR}/sku_cost.schema

###############################################################################
#  Friendly (necessary?) start message
###############################################################################

message "Program started ..."

###############################################################################
#  Create a disk-based flow file
###############################################################################  

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"

cat > ${FLOW_FILE} << EOF
   <FLOW name = "${PROGRAM_NAME}.flw">
      <OPERATOR type="import"> 
         <PROPERTY  name="schemafile" value="$ITEM_LOC_SCHEMA"/> 
         <PROPERTY  name="inputfile" value="$ITEM_LOC_FILE"/> 
         <PROPERTY  name="rejectfile" value="$(getRejectFile)"/>
            
         <OPERATOR type="fieldmod">
            <PROPERTY name="keep" value="AIP_SKU SUPPLIER_040 WAREHOUSE_040 SKU_COST_040 FLAG_040_046_047_048"/> 
			
			<OPERATOR type="filter"> 
               <PROPERTY name="filter" value="SKU_COST_040 GT 0"/>
               <OPERATOR type="filter"> 
                  <PROPERTY name="filter" value="FLAG_040_046_047_048 EQ 1"/>
                  <OUTPUT name="SKU_COST_FULL.v"/>
               </OPERATOR>
			</OPERATOR>   
         </OPERATOR>
      </OPERATOR>
     
      <OPERATOR type="export">
	     <INPUT name="SKU_COST_FULL.v"/>
         <PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
         <PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
      </OPERATOR>
   </FLOW>
EOF

###############################################################################
#  Execute the flow
###############################################################################
_exec ${RFX_EXE} ${RFX_OPTIONS} -f ${FLOW_FILE}

message "Program completed successfully"

###############################################################################
# cleanup and exit
###############################################################################
exit 0