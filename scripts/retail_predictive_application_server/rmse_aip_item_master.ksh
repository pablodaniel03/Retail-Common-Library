#!/bin/ksh
########################################################
# Purpose:  Extracts RMS item, pack, supplier and
#           supplier pack size information
#
# Modifyed by        Date            Description
# ------------------------------------------------------
# Pablo Almaguer     02/Marzo/2018   Mejora del nivel de log
########################################################

################## PROGRAM DEFINES #####################
########## (must be the first set of defines) ##########

export PROGRAM_NAME="rmse_aip_item_master"

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINES) ####

. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh
. ${LIB_DIR}/translate_lib.ksh

##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########

export OUTPUT_FILE="${DATA_DIR}/${PROGRAM_NAME}.dat"
export OUTPUT_FILE_REJ="${DATA_DIR}/${PROGRAM_NAME}_rej.dat"
export OUTPUT_SCHEMA="${SCHEMA_DIR}/${PROGRAM_NAME}.schema"

export OUTPUT_PURGE_ITEM_FILE="${DATA_DIR}/file_to_generate.dat"
export OUTPUT_PURGE_ITEM_SCHEMA="${SCHEMA_DIR}/schema_for_file.schema"

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
_exec ora_translate "im.ITEM_DESC|ul.UOM_DESC|cd.CODE_DESC"

###############################################################################
#  Friendly (necessary?) start message
###############################################################################

message "Program started..."

###############################################################################
#  Create a disk-based flow file
###############################################################################

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"
cat > ${FLOW_FILE} << EOF
 <FLOW name = "${PROGRAM_NAME}.flw">
		${DBREAD[RMS]}
           <PROPERTY name = "arraysize" value = "125"/>
           <PROPERTY name = "query">
              <![CDATA[
				 SELECT im.ITEM, RTRIM(${TRANSLATE[1]}) as ITEM_DESC,
                        im.ITEM_PARENT, im.ITEM_GRANDPARENT,
                        NVL(p.ITEM, im.ITEM) as AIP_SKU, 
                        lpad(to_char(im.SUBCLASS), 4, '0') as SUBCLASS,
                        lpad(to_char(im.CLASS), 4, '0') as CLASS, 
                        lpad(to_char(im.DEPT), 4, '0') as DEPT, 
                        im.FORECAST_IND, isup.SUPPLIER, 
                        isup.PRIMARY_SUPP_IND, im.STANDARD_UOM,
                        RTRIM(${TRANSLATE[2]}) as STANDARD_UOM_DESCRIPTION,
                        NVL(im.HANDLING_TEMP, 0) as SKU_TYPE,
                        NVL(RTRIM(${TRANSLATE[3]}), 0) as SKU_TYPE_DESCRIPTION,
                        im.PACK_IND, im.SIMPLE_PACK_IND, p.PACK_QUANTITY,
                        case 
                        when length(p.PACK_QUANTITY) > 20 then '1'
                        else '0'
                        end as PACK_QUANTITY_REJ_FLAG,
                        im.ITEM_LEVEL, im.TRAN_LEVEL, im.RETAIL_LABEL_TYPE,
                        im.CATCH_WEIGHT_IND, im.SELLABLE_IND, im.ORDERABLE_IND,
                        cast(null as char(1)) as DEPOSIT_ITEM_TYPE
                 FROM MATERIALIZED_VIEW_1 im
                 INNER JOIN ${RMS_OWNER}.TABLE_1 isup on (isup.ITEM = im.ITEM)
                 INNER JOIN ${RMS_OWNER}.TABLE_2 ul       on (ul.UOM = im.STANDARD_UOM)
                 LEFT JOIN  ${RMS_OWNER}.TABLE_3 cd     on (cd.CODE = im.HANDLING_TEMP)
                 LEFT JOIN (SELECT ITEM, PACK_NO, to_char(nvl(QTY, 0)) as PACK_QUANTITY
                            FROM ${RMS_OWNER}.MATERIALIZED_VIEW_2) p on (p.PACK_NO = im.ITEM)
                 WHERE nvl(isup.SUPP_DISCONTINUE_DATE, get_vdate + 1) > get_vdate
              ]]>
       </PROPERTY>
       
       <OPERATOR type="convert">
					<PROPERTY name="convertspec">
						 <![CDATA[
								<CONVERTSPECS>
									 <CONVERT destfield="ITEM_DESC" sourcefield="ITEM_DESC">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
									 <CONVERT destfield="AIP_SKU" sourcefield="AIP_SKU">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
				 <CONVERT destfield="SUBCLASS" sourcefield="SUBCLASS">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
				 <CONVERT destfield="CLASS" sourcefield="CLASS">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
				 <CONVERT destfield="DEPT" sourcefield="DEPT">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
				 <CONVERT destfield="STANDARD_UOM_DESCRIPTION" sourcefield="STANDARD_UOM_DESCRIPTION">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
				 <CONVERT destfield="SKU_TYPE_DESCRIPTION" sourcefield="SKU_TYPE_DESCRIPTION">
											<CONVERTFUNCTION name="make_not_nullable">
												 <FUNCTIONARG name="nullvalue" value="NULL"/>
											</CONVERTFUNCTION>
									 </CONVERT>
								</CONVERTSPECS>
						 ]]>
					</PROPERTY>
					<OUTPUT name="query.v"/>
			</OPERATOR>
	</OPERATOR>
	<OPERATOR type="copy">
		<INPUT name = "query.v"/>
		<OUTPUT name="query_C1.v"/>
		<OUTPUT name="query_C2.v"/>
	</OPERATOR>
	 
	 <OPERATOR type="filter">
			<INPUT name = "query_C2.v"/>
			<PROPERTY name="filter" value="PACK_QUANTITY_REJ_FLAG EQ 1"/>
			<PROPERTY name="rejects" value="false"/>
			<OUTPUT name = "query_rej.v"/>
	 </OPERATOR>
	 
	 <OPERATOR type="export">
			<INPUT name = "query_C1.v"/>
			<PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
			<PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
	 </OPERATOR>
	 
	 <OPERATOR type="export">
			<INPUT name = "query_rej.v"/>
			<PROPERTY name="outputfile" value="${OUTPUT_FILE_REJ}"/>
			<PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
	 </OPERATOR>

     ${DBREAD[RMS]}
        <PROPERTY name = "query">
           <![CDATA[
				  select dp.KEY_VALUE as ITEM
              from ${RMS_OWNER}.DAILY_PURGE dp
              where dp.TABLE_NAME = 'TABLE_NAME'
              and   dp.KEY_VALUE  in (select im.ITEM
                                      from MATERIALIZED_VIEW_1 im
                                      where exists (select 1
                                                    from ${RMS_OWNER}.TABLE_1 isup 
                                                    where isup.ITEM = im.ITEM
                                                     and nvl(isup.SUPP_DISCONTINUE_DATE, get_vdate + 1) > get_vdate)
                                      and   exists (select 1
                                                    from ${RMS_OWNER}.TABLE_3 uc
                                                    where uc.UOM = im.STANDARD_UOM))
           ]]>
        </PROPERTY>
        <OPERATOR type="export">
           <PROPERTY name="outputfile" value="${OUTPUT_PURGE_ITEM_FILE}"/>
           <PROPERTY name="schemafile" value="${OUTPUT_PURGE_ITEM_SCHEMA}"/>
        </OPERATOR>
     </OPERATOR>
 </FLOW>
EOF

###############################################################################
#  Execute the flow
###############################################################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

###############################################################################
#  Handle RETL errors
###############################################################################
checkerror -e $? -m "Program failed - check ${ERR_FILE}"

message "Program completed successfully"

# cleanup and exit
exit 0