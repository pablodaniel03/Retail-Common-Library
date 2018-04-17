#!/bin/ksh
########################################################
# Purpose:  Extracts RMS item, pack, supplier and
#           supplier pack size information
#
# Modifyed by       Date          Description
# ------------------------------------------------------
# Pablo Almaguer    07/Ene/2018   Mejora del nivel de log
########################################################

################## PROGRAM DEFINES #####################
########## (must be the first set of defines) ##########

export PROGRAM_NAME="rmse_aip_item_retail"

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINES) ####
. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh

##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########

export OUTPUT_FILE="${DATA_DIR}/${PROGRAM_NAME}.dat"
export OUTPUT_SCHEMA="${SCHEMA_DIR}/${PROGRAM_NAME}.schema"

message "Program started ..."

FLOW_FILE=${LOG_DIR}/${PROGRAM_NAME}.xml
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
   ${DBREAD[RMS]}
      <PROPERTY name = "arraysize" value = "500"/>
      <PROPERTY name = "query">
         <![CDATA[
            SELECT im.ITEM, im.ITEM as AIP_SKU, 
                lpad(to_char(im.SUBCLASS), 4, '0') as SUBCLASS, 
            



                   NVL(cd.CODE_DESC, 0) as SKU_TYPE_DESCRIPTION, '1' as ORDER_MULTIPLE, '0' as PACK_QUANTITY
            FROM xxfc_item_master_sia_vm im
            inner join ${RMS_OWNER}.UOM_CLASS ul on (ul.UOM = im.STANDARD_UOM)
            left join ${RMS_OWNER}.C



                     from ${RMS_OWNER}.ITEM_SUPP_COUNTRY isc
                    where isc.ITEM = im.


                                          TABLE isup
                                 where isup.item     = isc.ITEM
                                        and   isup.COLUMN = isc.COLUMN
                                        and   NVL(isup.COLUMN, get_vdate + 1) > get_vdate)
                   and   isc.COLUMN > 1)
         ]]>
      </PROPERTY>
      <OPERATOR type="convert">
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="ITEM" sourcefield="ITEM">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="AIP_SKU" sourcefield="AIP_SKU">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE">
                      <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="SUBCLASS" sourcefield="SUBCLASS">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="-1"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="CLASS" sourcefield="CLASS">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="-1"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="DEPT" sourcefield="DEPT">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="-1"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="STANDARD_UOM" sourcefield="STANDARD_UOM">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="STANDARD_UOM_DESCRIPTION" sourcefield="STANDARD_UOM_DESCRIPTION">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
               </CONVERTSPECS>
            ]]>
         </PROPERTY>
         <OPERATOR type="export">
            <PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
            <PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
         </OPERATOR>
      </OPERATOR>
   </OPERATOR>
</FLOW>
EOF

###############################################
#  Execute the RETL flow that had previously
#  been copied into rmse_aip_item_retail.xml:
###############################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

message "Program completed successfully"

# cleanup and exit rmse_terminate 0
exit 0