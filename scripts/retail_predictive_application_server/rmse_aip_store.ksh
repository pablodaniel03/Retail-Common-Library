#!/bin/ksh

###################################################################
#  The rmse_aip_store.ksh program extracts store information from RMS
#  and writes it into a flat file to be used by the AIP Transform
#  programs to build the files to be loaded into AIP.
#
# Modifyed by     Date          Description
# -----------------------------------------------------------------
# Pabo Almaguer   06/Ene/2018   Mejora del nivel de log
###################################################################

################## PROGRAM DEFINE #####################
########## (must be the first set of defines) ##########

export PROGRAM_NAME="rmse_aip_store"

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINE) ####
. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh
. ${LIB_DIR}/translate_lib.ksh


message "Program started ..."

# Obtener los chain values
n=0
for CHAIN in $(cat ${ETC_DIR}/store_hier_chain_values.txt); do
  n=$(($n+1))
  CHAIN_VAL[$n]="${CHAIN},"
done

CHAIN_VAL[$n]=${CHAIN_VAL[$n]%?}


##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########
export OUTPUT_FILE="${DATA_DIR}/${PROGRAM_NAME}.dat"
export OUTPUT_SCHEMA="${SCHEMA_DIR}/${PROGRAM_NAME}.schema"

########################################################
#  TRANSLATE LIB
#  ora_translate function sets TRANSLATE oracle sql function
#  Delimited by '|'
#  
#  ora_translate "FIELD1|FIELD2"
#  
#  TRANSLATE[FIELD'S POSITION]
#  
########################################################

_exec ora_translate "s.STORE_NAME|cd.CODE_DESC|sf.FORMAT_NAME"

###########################   ##################################
#  Copy the RETL flow to an xml file to be executed by rfx:
#############################################################

FLOW_FILE=${LOG_DIR}/${PROGRAM_NAME}.xml
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
   <!--  Read in the store data from the RMS tables:  -->
   ${DBREAD[RMS]}
      <PROPERTY name = "query">
	    <PROPERTY name = "arraysize" value = "500"/>
        <![CDATA[
            SELECT lpad(to_char(s.ST  E), 5, '0') as ST  E, RTRIM(${TRANSLATE[1]}) as ST   ME,

                   s.ST      S, ${TRANSLATE[2]} as STO        SCR   ION,
                   s.STO   ORMAT, RTRIM(${TRANSLATE[3]}) as FOR  T_NAME,

            FROM ${RMS_OWNER}.TABLE_1 s
            inner join ${RMS_OWNER}.TABLE_2 cd on (cd.CODE = s.STORE_CLASS)
			inner join ${RMS_OWNER}.TABLE_3 sth on (sth.STORE = s.STORE)


            WHERE s.COLUMN <> 9999
            AND   cd.COLUMN = 'CSTR'
            and   sth.COLUMN IN (${CHAIN_VAL[@]})
         ]]>
      </PROPERTY>
      <!--  Write out the store data to a flat file:  -->
      <OPERATOR type="convert">
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
			      <CONVERT destfield="STORE" sourcefield="STORE">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
				  <CONVERT destfield="DISTRICT" sourcefield="DISTRICT">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="STORE_NAME" sourcefield="STORE_NAME">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
				  <CONVERT destfield="STORE_CLASS_DESCRIPTION" sourcefield="STORE_CLASS_DESCRIPTION">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
				  <CONVERT destfield="REMERCH_IND" sourcefield="REMERCH_IND">
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
#  been copied into rmse_aip_store.xml:
###############################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

message "Program completed successfully"

# Clean up and exit rmse_terminate 0
exit 0