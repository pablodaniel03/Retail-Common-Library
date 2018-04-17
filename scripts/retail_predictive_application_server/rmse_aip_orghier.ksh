#!/bin/ksh

##############################################################################
# Module:        AIP
# Author:        Pablo Almaguer
# Creation Date: 07/Mar/2016
# Version:       1.0
# Description:   The rmse_aip_orghier.ksh program extracts organizational heirarchy data  
#                from the COMPHEAD, CHAIN, AREA, REGION and DISTRICT RMS tables and 
#                places this data into a flat file (rmse_aip_orghier.dat) to be accessed
#                by AIP data transformation programs.
#                 
# Inputs:        None
# Output:        rmse_aip_orghier.dat
# Called by:     
# Calls:
# Modifyed by            Date         Description
# -------------------------------------------------------------------------
# Pablo Almaguer         07/Mar/2016  Initial Creation
# Pablo Almaguer         06/Ene/2018  Mejora del nivel de log
##############################################################################

# Program define
export PROGRAM_NAME="rmse_aip_orghier"

# Includes
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


# Output defines
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
_exec ora_translate "a.AREA_NAME|r.REGION_NAME|d.DISTRICT_NAME|CO_NAME|CHAIN_NAME"

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
<!--  Read in the organizational heirarchy data from the RMS tables:  -->
   ${DBREAD[RMS]}
      <PROPERTY name = "arraysize" value = "1000"/>
    <PROPERTY name = "query">
         <![CDATA[
            SELECT ch.COMPANY, ch.COMPANY||' '||ch.CO_NAME as CO_NAME,
                   c.txtCHAIN as CHAIN, c.txtCHAIN||' '||c.CHAI          N_NAME,
                   lpa              A), 4, '0') as AREA,
           lpad(to_char(a.A  A), 4, '0')||' '||RTRIM(${TRANSLATE[1]}) as AR   AME,
                   lpad(to_ch                 ) as REGION,
           lpad(to_char(r.RE  ON), 4, '0')||' '||RTRIM(${TRANSLATE[2]}) as RE   N_NAME,
                   lpad(to_ch        ), 4, '0') as DISTRICT,
           lpad(to_char(d.  RICT), 4, '0')||' '||RTRIM(${TRANSLATE[3]}) as DIS   CT_NAME
            FROM (select lp                   , 4, '0') as COMPANY, 
                   RTRIM(${TRANSLATE[4]}) as CO_NAME
                  from ${RMS_OWNER}.TABLE_1
                where COLUMN = 1) ch
            cross join (select CHAIN, lpad(to_char(CHAIN), 4, '0') as txtCHAIN,
                         RTRIM(${TRANSLATE[5]}) as CHAIN_NAME
                  from ${RMS_OWNER}.TABLE_2
                        where COLUMN IN (${CHAIN_VAL[@]})) c
            inner join ${RMS_OWNER}.TABLE_3 a on (a.COLUMN_1 = c.COLUMN_1)
            inner join ${RMS_OWNER}.TABLE_4 r on (r.COLUMN_2 = a.COLUMN_2)
            inner join ${RMS_OWNER}.TABLE_5 d on (d.COLUMN_3 = r.COLUMN_3)
         ]]>
      </PROPERTY>
      <!--  Only Chain and Company data is specified as mandatory in the schema file  -->
      <OPERATOR type="convert">
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="COMPANY" sourcefield="COMPANY">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
          <CONVERT destfield="CHAIN_NAME" sourcefield="CHAIN_NAME">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NULL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  <CONVERT destfield="CO_NAME" sourcefield="CO_NAME">
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

# Execute the RETL flow
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

message "Program completed successfully."

# Cleanup and exit rmse_terminate 0
exit 0