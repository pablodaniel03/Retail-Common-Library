#!/bin/ksh
########################################################
# Purpose: extracts RMS on-order and in-transit transfer
#          quantities for AIP future delivery
#
# Modifyed by        Date            Description
# ------------------------------------------------------
# Pablo Almaguer     15/Marzo/2018   Mejora del nivel de log
########################################################
########################################################

################## PROGRAM DEFINES #####################
########## (must be the first set of defines) ##########
export PROGRAM_NAME='rmse_aip_future_delivery_tsf'

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINES) ####
. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh


##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########
export OUTPUT_FILE=${DATA_DIR}/${PROGRAM_NAME}.dat
export OUTPUT_SCHEMA=${SCHEMA_DIR}/${PROGRAM_NAME}.schema
export REJECT_ORD_MULT_FILE=${DATA_DIR}/${PROGRAM_NAME}_rej.txt

export SQL_STATEMENT1="WITH T_ITEMS AS (select im.item
                                        from ${RMS_OWNER}.TABLE_1 im
                                        where im.COLUMN_1 = 'A'
                                        AND   im.COLUMN_2 = im.COLUMN_6
                                        AND   im.COLUMN_3 = 'N'
                                        --AND im.COLUMN_4 = 'I'
                                        AND   im.COLUMN_5 = 'Y'),
                            TRAN_DATA AS (select 'WH' as ORIGIN_TYPE, v.ORIGIN, v.DESTINATION_TYPE,
                                                  v.DESTINATION, v.TRANSIT_TIME
                                          from (select td.cedis as ORIGIN, lc.DESTINATION_TYPE,
                                                       lc.loc as DESTINATION, td.LT as TRANSIT_TIME
                                                from (select wh as loc, 'WH' as DESTINATION_TYPE
                                                      from TABLE_2
                                                      union all
                                                      select s.store, 'ST'
                                                      from TABLE_3 s
                                                      where CONDICION) lc
                                                join (select e.LOC, e.cedis, 
                                                             ceil(SUM(CASE
                                                                      WHEN e.interv > 0 THEN e.interv - 1
                                                                      ELSE 6 + e.interv
                                                                      END) / count(1)) as LT
                                                      from (select dest_id as LOC, cedis, 
                                                                   (dia_fin_vent_entrega - dia_gen_ped) as interv
                                                            from TABLE_4
                                                            where dest_id     is not null








                              qf.TSF_QTY,
                              qf.IN_TRANSIT_TSF_QTY,
                              qf.ON_ORDER_TSF_QTY,
                              qf.LOC_TYPE, qf.TSF_TYPE,
                              case 
                              when length(qf.ORDER_MULTIPLE) > 20 then '1'
                              else '0'
                              end as ORDMULT_REJ_FLAG
                      from (SELECT x.TRANSACTION_NUM, x.DAY, x.LOC, x.ITEM,
                                   to_char(x.ORDER_MULTIPLE) as ORDER_MULTIPLE,











                                         end as LOC, t.ITEM,
                                         CASE il.STORE_ORD_MULT -- t.PRIMARY_CASE_SIZE 
                                         WHEN 'C' THEN q.SUPP_PACK_SIZE
                                         WHEN 'I' THEN q.INNER_PACK_SIZE
                                         WHEN 'P' THEN q.PALLET
                                         ELSE 1
                                         END ORDER_MULTIPLE,
                                         q.SUPPLIER,
                                         SUM(t.TSF_QTY) as TSF_QTY,
                                         SUM(t.IN_TRANSIT_TSF_QTY) as IN_TRANSIT_TSF_QTY,











                                               _CASE_SIZE, --isp.PRIMARY_CASE_SIZE,
                                               h.TO_LOC_TYPE as LOC_TYPE, h.TSF_TYPE,
                                               case h.TO_LOC_TYPE
                                               when 'W' then h.tsf_no
                                               else null
                                               end as TRANSACTION_NUM
                                        FROM TABLE td
                                        join ${RMS_OWNER}.TABLE h on (h.FROM_LOC = td.ORIGIN and
                                                                        h.TO_LOC   = td.DESTINATION)
                                        join ${RMS_OWNER}.TABLE d on (d.TSF_NO = h.TSF_NO)


















                                                                  0) ON_ORDER_TSF_QTY,
                                               --'C' as PRIMARY_CASE_SIZE, --isp.PRIMARY_CASE_SIZE,
                                               h.TO_LOC_TYPE as LOC_TYPE, h.TSF_TYPE,
                                               case h.TO_LOC_TYPE
                                               when 'W' then h.tsf_no
                                               else null
                                               end as TRANSACTION_NUM
                                        FROM ${RMS_OWNER}.TABLE h
                                        join ${RMS_OWNER}.TABLE d on (d.tsf_no = h.tsf_no)
                                        left join ${RMS_OWNER}.TABLE sif on (sif.ITEM   = d.ITEM and
                                                                                         sif.TSF_NO = d.TSF_NO)
                                        WHERE h.COLUMN_1  in ('S', 'W')
                                        AND   h.COLUMN_2  in ('A', 'S')
                                        AND   h.COLUMN_3  IS NOT NULL
                      











                      


                                                                             from ${RMS_OWNER}.ITEM_SUPPLIER isp
                                                                             where isp.PRIMARY_SUPP_IND = 'Y')
                                        and   isup.primary_country_ind = 'Y') q on (q.item     = il.item and
                                                                                    q.supplier = il.PRIMARY_SUPP)
                                  GROUP BY t.TRANSACTION_NUM, t.DAY, 
                                           case t.LOC_TYPE
                                           when 'W' then to_char(t.LOC)
                                           when 'S' then lpad(to_char(t.LOC), 5, '0')
                                           else to_char(t.LOC)
                                           end, t.ITEM,
                                           CASE il.STORE_ORD_MULT --t.PRIMARY_CASE_SIZE 
                                           WHEN 'C' THEN q.SUPP_PACK_SIZE
                                           WHEN 'I' THEN q.INNER_PACK_SIZE
                                           WHEN 'P' THEN q.PALLET
                                           ELSE 1
                                           END, q.SUPPLIER, t.LOC_TYPE, t.TSF_TYPE) x) qf"

export SQL_STATEMENT2="select qf.TRANSACTION_NUM,    /*+ PARALLEL(il 4)*/
                              qf.DAY,
               









                              case 
                              when length(qf.ORDER_MULTIPLE) > 20 then '1'
                              else '0'
                              end as ORDMULT_REJ_FLAG 
                       from (select x.TRANSACTION_NUM, x.DAY, x.LOC, x.ITEM,
                                    to_char(x.ORDER_MULTIPLE) as ORDER_MULTIPLE,
                                    x.SUPPLIER, 
                                    to_char(x.TSF_QTY) as TSF_QTY,
                                    to_char(x.IN_TRANSIT_TSF_QTY) as IN_TRANSIT_TSF_QTY,
                                    to_char(x.ON_ORDER_TSF_QTY) as ON_ORDER_TSF_QTY, x.LOC_TYPE, x.TSF_TYPE 
                             from (SELECT a.TRANSACTION_NUM, a.DAY, a.LOC, a.ITEM, a.ORDER_MULTIPLE, a.SUPPLIER,











                                                   'W' THEN
                                                 CASE
                                                 WHEN h.TSF_TYPE = 'EG' THEN to_char(sif.TO_LOC)
                                                 ELSE to_char(h.TO_LOC)
                                                 END
                                                ELSE
                                                 lpad(to_char(h.TO_LOC), 5, '0')
                                                END as LOC, im.ITEM, vpq.QTY as ORDER_MULTIPLE,
                                                isup.SUPPLIER,
                                                NVL(d.TSF_QTY, 0) - NVL(d.RECEIVED_QTY, 0) as TSF_QTY,
                                                NVL(d.SHIP_QTY, 0) - NVL(d.RECEIVED_QTY, 0) as IN_TRANSIT_TSF_QTY,
                                           








                                         FROM ${RMS_OWNER}.TABLE_1 im
                                         join ${RMS_OWNER}.TABLE_2 d on (d.ITEM = im.ITEM)
                                         join ${RMS_OWNER}.TABLE_3 h on (h.TSF_NO = d.TSF_NO)
                                         join ${RMS_OWNER}.TABLE_4 isup on (isup.ITEM = im.ITEM)
                                         left join ${RMS_OWNER}.TABLE_5 sif on (sif

















                                         AND   h.TO_LOC                 IS NOT NULL
                                         AND   isup.PRIMARY_SUPP_IND    = 'Y'
                                         AND   isup.primary_country_ind = 'Y'
                                         AND h.tsf_type                 != 'CO'
                                         AND NVL(h.DELIVERY_DATE, h.APPROVAL_DATE + 0) >= TO_DATE('${VDATE}','YYYYMMDD') - ${MAX_NOTAFTER_DAYS}
                                         UNION
                                         SELECT 'D'|| TO_CHAR(NVL(h.DELIVERY_DATE,h.APPROVAL_DATE),'YYYYMMDD') DAY,
                                                CASE h.TO_LOC_TYPE
                                                WHEN 'W' THEN
                                                 CASE
                                                 WHEN h.TSF_TYPE = 'EG' THEN to_char(sif.TO_LOC)
                                               















                                                else null
                                                end as TRANSACTION_NUM,
                                                vpq.QTY as PACK_QTY
                                         FROM ${RMS_OWNER}.TABLE_1 im
                                         join ${RMS_OWNER}.TABLE_2 d on (d.ITEM = im.ITEM)
                                         join ${RMS_OWNER}.TABLE_3 h on (h.TSF_NO = d.TSF_NO)
                                         join ${RMS_OWNER}.TABLE_4 isup on (isup.ITEM = im.ITEM)
                                         join ${RMS_OWNER}.TABLE_5 vpq on (vpq.item = im.item)
                                         left join ${RMS_OWNER}.TABLE_6 sif on (sif.TSF_NO = d.TSF_NO and
                                                                                          sif.ITEM   = d.ITEM)
                                         WHERE 1                  = 2
                                         AND   im.STATUS          = 'A'
                                         AND   im.ITEM_LEVEL      = im.TRAN_LEVEL
                                         AND   im.SIMPLE_PACK_IND = 'Y' 
                                         AND   isup.PRIMARY_SUPP_IND    = 'Y'
                                     


                                         AND   h.STATUS      in ('A', 'S')
                                         AND   h.TO_LOC_TYPE IN ('S','W')
                                         AND   h.TO_LOC      IS NOT NULL
                                         AND   h.tsf_type    != 'CO'
                                         AND   NVL(h.DELIVERY_DATE, h.APPROVAL_DATE) >=
                                                         TO_DATE('${VDATE}','YYYYMMDD') - ${MAX_NOTAFTER_DAYS}
                                         UNION
                                         /*When regular item then */
                                         SELECT DAY, LOC, ITEM, ORDER_MULTIPLE, SUPPLIER, TSF_QTY, IN_TRANSIT_TSF_QTY,

                                         FROM (SELECT DAY, LOC, I                                     _TRANSIT_TSF_QTY,
                                                      ON_ORDER_TSF_QTY, LOC_TYPE, TSF_TYPE, TRANSACTION_NUM, PACK_QTY,
                                                      SIZE_RANK, QTY_RANK,
                                                      RANK() OVER
                                                             (PARTITION BY             SIZE_RANK) PACK_RANK --To select one when multiple pack is found
                                               FROM (SELECT 'D'||TO_CHAR(NVL        ATE, h.APPROVAL_DATE), 'YYYYMMDD') as DAY,
                                                            CASE h.TO_LOC_TYPE
                                                            WHEN 'W' THEN
                                                             CASE
                                                             WHEN h.TSF_TYPE = 'EG' THEN
                                                              to_char(sif.TO_LOC)
                                                  























                                                            RANK() OVER
                                                                 (PARTITION BY im2.ITEM ORDER BY vpq.QTY) QTY_RANK --To select pack with smallest component quantity
                                                     FROM ${RMS_OWNER}.TABLE_1 im
                                                     join ${RMS_OWNER}.TABLE_2 d on (d.ITEM = im.ITEM)
                                                     join ${RMS_OWNER}.TABLE_3 h on (h.TSF_NO = d.TSF_NO)

                                                     join ${RMS_OWNER}.TABLE_4 im2 on (im2.ITEM = vpq.PACK_NO)
                                                     join ${RMS_OWNER}.TABLE_5 isup on (isup.ITEM = im2.ITEM)
                                                     left join ${RMS_OWNER}.TABLE_6 sif on (sif.TSF_NO = d.TSF_NO and
                                                                                                      sif.ITEM   = d.ITEM)                                                     WHERE 1                        = 2
                                                     AND   im.STATUS                = 'A'
                                                     AND   im.ITEM_LEVEL            = im.TRAN_LEVEL
                                                     AND   im.PACK_IND              = 'N' 
                                                     AND   im.FORECAST_IND          = 'Y'
                                                     AND   h.APPROVAL_DATE          IS NOT NULL
                                                     AND   NVL(d.TSF_QTY, 0) > NVL(d.RECEIVED_QTY, 0)
                                                     AND   h.STATUS                 in ('A', 'S')
                                                     AND   h.TO_LOC_TYPE            in ('S','W')
                                                     AND   h.TO_LOC                 IS NOT NULL





                                                     AND   NVL(h.DELIVERY_DATE, h.APPROVAL_DATE + 0) --NVL(t.TRANSIT_TIME,0))
                                                                       >= TO_DATE('${VDATE}','YYYYMMDD') - ${MAX_NOTAFTER_DAYS}
                                                     UNION
                                                     SELECT 'D'||TO_CHAR(NVL(h.DELIVERY_DATE, h.APPROVAL_DATE), 'YYYYMMDD') as DAY,
                                                            CASE h.TO_LOC_TYPE
                                                            WHEN 'W' THEN
                                                             CASE
                                                             WHEN h.TSF_TYPE = 'EG' THEN to_char(sif.TO_LOC)
                                                             ELSE to_char(h.TO_LOC)
                                                             END
                                                            ELSE lpad(to_char(h.TO_LOC), 5, '0')
                                                            END as LOC, im2.ITEM,
                                                            vpq.QTY as ORDER_MULTIPLE, isup.SUPPLIER,
                                                            NVL(d.TSF_QTY, 0) - NVL(d.RECEIVED_QTY, 0) as TSF_QTY,

                                                            NVL(d.TSF_QTY, 0) - NVL(d.SHIP_QTY, 0) as ON_ORDER_TSF_QTY,
                                                            h.TO_LOC_TYPE LOC_TYPE, h.TSF_TYPE,
                                                            case h.TO_LOC_TYPE



                                                            1 as PACK_QTY,
                                                            CASE
                                                            WHEN isup.SUPP_PACK_SIZE  = vpq.QTY THEN 1  --pack component qty = supplier pack size
                                                            WHEN isup.INNER_PACK_SIZE = vpq.QTY THEN 2  --component qty = item's inner size
                                                            ELSE 3
                                                            END as SIZE_RANK,
                                                            RANK() OVER
                                                                (PARTITION BY im2.ITEM ORDER BY vpq.QTY) QTY_RANK --To select pack with smallest component quantity
                                                     FROM ${RMS_OWNER}.TABLE_1 im
                                                     join ${RMS_OWNER}.TABLE_2 d on (d.ITEM = im.ITEM)
                                                     join ${RMS_OWNER}.TABLE_3 h on (h.TSF_NO = d.TSF_NO)
                                                     join ${RMS_OWNER}.TABLE_4 vpq on (vpq.item = im.item)
                                                     join ${RMS_OWNER}.TABLE_5 im2 on (im2.ITEM = vpq.PACK_NO)













                                                           isup.PRIMARY_SUPP_IND    = 'Y'
                                                     AND   isup.primary_country_ind = 'Y'
                                                     AND   h.APPROVAL_DATE          IS NOT NULL

                                                     AND   im2.SIMPLE_PACK_IND      = 'Y'
                                                     AND   NVL(d.TSF_QTY, 0) > NVL(d.RECEIVED_QTY, 0)
                                                     AND   h.STATUS                 in ('A', 'S')
                                                     AND   h.TO_LOC_TYPE            in ('S','W')

                                                     AND   h.tsf_type               != 'CO'
                                                     AND   NVL(h.DELIVERY_DATE, h.APPROVAL_DATE) >= TO_DATE('${VDATE}','YYYYMMDD') - ${MAX_NOTAFTER_DAYS}
                                                     )
                                             ) 
                                    WHERE 1         = 2
                                    and   PACK_RANK = 1
                                    and   (SIZE_RANK in (1, 2) OR (SIZE_RANK = 3 AND QTY_RANK  = 1))) a
                              GROUP BY a.TRANSACTION_NUM, a            EM, a.ORDER_MULTIPLE,
                                       a.SUPPLIER, a.LOC_TYPE, a.TSF_TYPE) x) qf"

message "Program started ..."

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
   ${DBREAD}
      <PROPERTY name = "query">
         <![CDATA[
            ${SQL_STATEMENT1}
         ]]>
      </PROPERTY>
      <OUTPUT name="future_delivery_tsf_nfp.v"/>
   </OPERATOR>
   
   <OPERATOR type="filter">
      <!--<INPUT    name="future_delivery_tsf_nfp1a.v"/>-->
	  <INPUT    name="future_delivery_tsf_nfp.v"/>
      <PROPERTY name="filter" value="ORDMULT_REJ_FLAG EQ 1"/>
      <PROPERTY name="rejects" value="true"/>
      <OUTPUT   name="future_delivery_tsf_nfp1af_rej.v"/>
      <OUTPUT   name="future_delivery_tsf_nfp1af.v"/>
   </OPERATOR>

   ${DBREAD}
      <PROPERTY name = "query">
         <![CDATA[
            ${SQL_STATEMENT2}
         ]]>
      </PROPERTY>
      <OUTPUT name="future_delivery_tsf_fp.v"/>
   </OPERATOR>
   
   <OPERATOR type="filter">
      <INPUT    name="future_delivery_tsf_fp.v"/>
      <PROPERTY name="filter" value="ORDMULT_REJ_FLAG EQ 1"/>
      <PROPERTY name="rejects" value="true"/>
      <OUTPUT   name="future_delivery_tsf_fpf_rej.v"/>
      <OUTPUT   name="future_delivery_tsf_fpf.v"/>
   </OPERATOR>

   <OPERATOR type = "funnel">
      <INPUT name = "future_delivery_tsf_nfp1af.v"/>
      <INPUT name = "future_delivery_tsf_fpf.v"/>
      <OUTPUT name = "future_delivery_tsf.v"/>
   </OPERATOR>

   <OPERATOR type="convert">
      <INPUT name="future_delivery_tsf.v" />
      <PROPERTY name="convertspec">
         <![CDATA[
            <CONVERTSPECS>
               <CONVERT destfield="TRANSACTION_NUM" sourcefield="TRANSACTION_NUM" newtype="int64">
                  <TYPEPROPERTY name="nullable" value="true"/>
               </CONVERT>
               <CONVERT destfield="DAY" sourcefield="DAY" newtype="string">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="LOC" sourcefield="LOC">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="ITEM" sourcefield="ITEM">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="TSF_TYPE" sourcefield="TSF_TYPE">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="LOC_TYPE" sourcefield="LOC_TYPE">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="TSF_QTY" sourcefield="TSF_QTY">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="IN_TRANSIT_TSF_QTY" sourcefield="IN_TRANSIT_TSF_QTY">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
                  </CONVERTFUNCTION>
               </CONVERT>
               <CONVERT destfield="ON_ORDER_TSF_QTY" sourcefield="ON_ORDER_TSF_QTY">
                  <CONVERTFUNCTION name="make_not_nullable">
                     <FUNCTIONARG name="nullvalue" value="0"/>
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
    
   <OPERATOR type="convert">
      <INPUT name="future_delivery_tsf_nfp1af_rej.v"/>
      <PROPERTY name="convertspec">
         <![CDATA[
            <CONVERTSPECS>
               <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE" newtype="string">
                  <CONVERTFUNCTION name="string_from_dfloat"/>
                  <TYPEPROPERTY name="nullable" value="false"/>
               </CONVERT>
            </CONVERTSPECS>
         ]]>
      </PROPERTY>
      <OUTPUT name="future_delivery_tsf_nfp1a_rej_not_null.v"/>
   </OPERATOR>

   <OPERATOR type="convert">
      <INPUT name="future_delivery_tsf_fpf_rej.v"/>
      <PROPERTY name="convertspec">
         <![CDATA[
            <CONVERTSPECS>
               <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE" newtype="string">
                  <CONVERTFUNCTION name="string_from_dfloat"/>
                  <TYPEPROPERTY name="nullable" value="false"/>
               </CONVERT>
            </CONVERTSPECS>
         ]]>
      </PROPERTY>
      <OUTPUT name="future_delivery_tsf_fpf_rej_not_null.v"/>
   </OPERATOR>

   <OPERATOR type="funnel">
      <INPUT name="future_delivery_tsf_nfp1a_rej_not_null.v"/>
      <INPUT name="future_delivery_tsf_fpf_rej_not_null.v"/>
      <OUTPUT name="reject_total.v"/>
   </OPERATOR>      

   <OPERATOR type="export">
       <INPUT name="reject_total.v"/>
       <PROPERTY name="outputfile" value="${REJECT_ORD_MULT_FILE}"/>
   </OPERATOR>

</FLOW>

EOF

###############################################################################
#  Execute the flow
###############################################################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}.xml

###############################################################################
#  Handle RETL errors
###############################################################################

message "String Modifier started..."
_exec cp ${OUTPUT_FILE} ${OUTPUT_FILE}.str_mod.tmp
_exec awk -F "|" -v outputfile="${OUTPUT_FILE}" '{printf("%-12s%-9s%-20s%-20s%-20s%-6s%-8s%-8s%-8s%-1s%-6s\n",$1,$2,$3,$4,$5,substr($6,0,6),substr($7,0,8),substr($8,0,8),substr($9,0,8),$10,$11) > outputfile;}' ${OUTPUT_FILE}.str_mod.tmp
_exec rm ${OUTPUT_FILE}.str_mod.tmp
message "String Modifier completed successfully..."

message "Program completed successfully"

# cleanup and exit
exit 0
