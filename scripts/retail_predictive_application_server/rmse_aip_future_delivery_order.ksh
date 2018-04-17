#!/bin/ksh
########################################################
# Purpose: extracts RMS on order data for AIP
#          future delivery
#
# Modifyed by      Date          Description
# ------------------------------------------------------
# Pablo Almaguer   06/Ene/2018   Mejora del nivel de log
########################################################

################## PROGRAM DEFINES #####################
########## (must be the first set of defines) ##########
export PROGRAM_NAME='rmse_aip_future_delivery_order'

####################### INCLUDES ########################
##### (this section must come after PROGRAM DEFINES) ####
. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env
. ${LIB_DIR}/xxfc_sia_lib.ksh

##################  OUTPUT DEFINES ######################
######## (this section must come after INCLUDES) ########
export OUTPUT_FILE=${DATA_DIR}/${PROGRAM_NAME}.dat
export OUTPUT_SCHEMA=${SCHEMA_DIR}/${PROGRAM_NAME}.schema
export REJECT_ORD_MULT_FILE=${DATA_DIR}/${PROGRAM_NAME}_rej.txt

export SQL_STATEMENT1="select v.TRANSACTION_NUM, v.DAY, v.SUPPLIER,
                              v.LOC, v.ITEM,
                             









                               q.PO_QTY, q.LOC_TYPE
                             from (SELECT p.TRANSACTION_NUM, p.DAY, p.SUPPLIER,
                                          case p.LOC_TYPE
                                          when 'S' then lpad(to_char(p.LOC), 5, '0')
                                          else to_char(p.LOC)
                                          end as LOC, p.ITEM,
                                          p.PO_QTY, p.LOC_TYPE
                                   FROM (select o.DAY, o.supplier, o.loc, o.item, o.TRANSACTION_NUM,
								                sum(o.PO_QTY) as PO_QTY, min(o.loc_type) as loc_type
								         from (SELECT h.DAY, h.supplier, l.location as loc, l.item,
													  case 
													  when l.loc_type = 'W' then l.qty_ordered - NVL(l.qty_received, 0)
													  when h.RCV_FLAG = 1 then 0
                                                      else l.qty_ordered
													  end as PO_QTY,
                                                      l.loc_type, --s.supp_pack_size,
                                                      case l.loc_type
                                                      when 'W' then l.order_no
                                                      else null






                                                                         where l2.order_no     = oh.order_no
                                                                         and   l2.qty_received > 0) then 1
															else 0
															end as RCV_FLAG
											         from ${RMS_OWNER}.TABLE oh
													 where oh.order_type != 'CO'
													 and   oh.not_after_date >= get_vdate - ${MAX_NOTAFTER_DAYS}
													 and   oh.status     = 'A') h
                                               join ${RMS_OWNER}.TABLE s on (s.order_no = h.order_no)
											   join ${RMS_OWNER}.TABLE l on (l.order_no = s.order_no and







    
                                                                       on (isc.item     = p.item AND
                                                                               isc.supplier = p.supplier)
                                   where (isc.item, isc.supplier) not in (SELECT isup.item, isup.supplier
                                                                          FROM ${RMS_OWNER}.TABLE isup
                                                                          where nvl(isup.supp_discontinue_date, get_vdate + 1) <= get_vdate)
                                   and   isc.PRIMARY_COUNTRY_IND = 'Y') q) v"

export SQL_STATEMENT2="SELECT TRANSACTION_NUM, DAY, SUPPLIER,
                              case LOC_TYPE
                              WHEN 'S' THEN lpad(to_char(LOC), 5, '0')
                              ELSE to_char(LOC)
                              END as LOC,
                              






                       FROM (/* When Simple Pack Ind = Y*/
                             Select 'D'||TO_CHAR(o.not_after_date,'YYYYMMDD') as DAY,
                                    case o.loc_type
                                    when 'W' then o.order_no
                                    else null
                                    end as TRANSACTION_NUM, o.supplier, o.location loc, im.item,
                                    CASE 
                                 







                                              L(o.qty_received, 0) as po_qty,
                                    vpq.qty pack_qty,
                                    o.loc_type
                             FROM xxfc_item_master_sia_vm im
                             join ${RMS_OWNER}.v_pack








                                   AND   h.status         = 'A'
                                   AND   h.not_after_date >= get_vdate - ${MAX_NOTAFTER_DAYS}
                                   AND   l.loc_type       IN ('S','W')) o on (o.item = im.item)
                             join ${RMS_OWNER}.TABLE isc on (isc.item     = o.item and
                                                                         isc.supplier = o.supplier)
                             WHERE 1 = 2
                             AND   im.item IN (SELECT pm.PACK_NO
                                               FROM ${RMS_OWNER}.TABLE pm
                                               WHERE 1 = 2
                                               and   pm.IT





                             AND EXISTS (SELECT 1
                                         FROM ${RMS_OWNER}.TABLE isup
                                         WHERE 1 = 2
										 AND   isup.item = isc.item
                                         AND   isup.supplier = isc.supplier
                                         AND   nvl(isup.supp_discontinue_date, get_vdate + 1) > get_vdate)
                             UNION
                             /* When regular item and other cases */
                             SELECT DAY, TRANSACTION_NUM, SUPPLIER, LOC, ITEM, ORDER_MULTIPLE,
                                    PO_QTY, PACK_QTY











                                                CASE o.loc_type
                                                WHEN 'S' THEN 1
                                                WHEN 'W' THEN
                                                 CASE
                                                 WHEN (o.qty_ordered - NVL(o.qty_received, 0)) < isc.supp_pack_size THEN 1
                                                 ELSE vpq.qty
                                                 END
                                                END as order_multiple,
                                                o.qty_ordered - NVL(o.qty_received, 0) as po_qty,
                                                1 as pack_qty, o.loc_type,
                                                CASE vpq.QTY
                                                WHEN isc.




                                                ,
                                                RANK() OVER (PARTITION BY vpq.ITEM ORDER BY vpq.QTY) QTY_RANK --To select pack with smallest component quantity
                                         FROM xxfc_item_master_sia_vm im
                                         join ${RMS_OWNER}.TABLE vpq on (vpq.ITEM = im.ITEM)
                                         join xxfc_item_master_sia_vm im2 on (im2.ITEM = vpq.PACK_NO)
                                         join (SELECT h.not_after_date, l.order_no, h.supplier, l.location, l.loc_type,
                                                      l.qty_ordered, l.qty_received, l.item
                                               FROM ${RMS_OWNER}.TABLE h
                                               join ${RMS_OWNER}.TABLE l on (l.order_no = h.order_no)
                                               WHERE 1             = 2




                                               AND   h.not_after_date >= get_vdate - ${MAX_NOTAFTER_DAYS}
                                               AND   l.loc_type       in ('S','W')) o on (o.item = im.item)
                                         join ${RMS_OWNER}.item_supp_country isc on (isc.item     = o.item and
                                                                                     isc.supplier = o.supplier)
                                         WHERE 1 = 2
                                         AND   im2.SIMPLE_PACK_IND     = 'Y'
                                         AND   isc.primary_country_ind = 'Y')
                                   where 1 = 2)





                             GROUP BY TRANSACTION_NUM, DAY, SUPPLIER, LOC, ITEM, LOC_TYPE"


message "Program started ..."

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"
cat > ${FLOW_FILE} << EOF
   <FLOW name = "${PROGRAM_NAME}.flw">
      ${DBREAD[RMS]}
	     <PROPERTY name="arraysize" value="2000"/>
         <PROPERTY name = "query">
            <![CDATA[
               ${SQL_STATEMENT1}
            ]]>
         </PROPERTY>
         <OUTPUT name="future_delivery_order_nfp1.v"/>
      </OPERATOR>

      <OPERATOR type="filter">
         <INPUT    name="future_delivery_order_nfp1.v"/>
         <PROPERTY name="filter" value="ORDMULT_REJ_FLAG EQ 1"/>
         <PROPERTY name="rejects" value="true"/>
         <OUTPUT   name="reject_ord_multiple_nf.v"/>
         <OUTPUT   name="future_delivery_order_nfp1f.v"/>
      </OPERATOR>

      <OPERATOR type = "hash">
         <INPUT name = "future_delivery_order_nfp1f.v"/>
         <PROPERTY name = "key" value = "TRANSACTION_NUM"/>
         <PROPERTY name = "key" value = "DAY"/>
         <PROPERTY name = "key" value = "SUPPLIER"/>
         <PROPERTY name = "key" value = "LOC"/>
         <PROPERTY name = "key" value = "ITEM"/>
         <PROPERTY name = "key" value = "ORDER_MULTIPLE"/>
         
         <OPERATOR type = "sort">
            <PROPERTY name = "key" value = "TRANSACTION_NUM"/>
            <PROPERTY name = "key" value = "DAY"/>
            <PROPERTY name = "key" value = "SUPPLIER"/>
            <PROPERTY name = "key" value = "LOC"/>
            <PROPERTY name = "key" value = "ITEM"/>
            <PROPERTY name = "key" value = "ORDER_MULTIPLE"/>
			<PROPERTY name="numsort" value="64"/>
            
            <OPERATOR type = "groupby">
               <PROPERTY name = "key"    value = "TRANSACTION_NUM"/>
               <PROPERTY name = "key"    value = "DAY"/>
               <PROPERTY name = "key"    value = "SUPPLIER"/>
               <PROPERTY name = "key"    value = "LOC"/>
               <PROPERTY name = "key"    value = "ITEM"/>
               <PROPERTY name = "key"    value = "ORDER_MULTIPLE"/>
               <PROPERTY name = "reduce" value = "PO_QTY"/>
               <PROPERTY name = "sum"    value = "PO_QTY"/>
               <PROPERTY name = "key"    value = "LOC_TYPE"/>
               <OUTPUT name = "future_deliver_order_nfp1a.v"/>
            </OPERATOR>
         </OPERATOR>
      </OPERATOR>

      ${DBREAD[RMS]}
         <PROPERTY name = "query">
            <![CDATA[
               ${SQL_STATEMENT2}
            ]]>
         </PROPERTY>
         <OUTPUT name="future_deliver_order_fp.v"/>
      </OPERATOR>

      <OPERATOR type="filter">
         <INPUT    name="future_deliver_order_fp.v"/>
         <PROPERTY name="filter" value="ORDMULT_REJ_FLAG EQ 1"/>
         <PROPERTY name="rejects" value="true"/>
         <OUTPUT   name="reject_ord_multiple_f.v"/>
         <OUTPUT   name="future_deliver_order_fpf.v"/>
      </OPERATOR>

      <OPERATOR type = "funnel">
         <INPUT name = "future_deliver_order_nfp1a.v"/>
         <INPUT name = "future_deliver_order_fpf.v"/>
         <OUTPUT name = "future_deliver_order.v"/>
      </OPERATOR>

      <OPERATOR type="convert">
         <INPUT name="future_deliver_order.v" />
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="TRANSACTION_NUM" sourcefield="TRANSACTION_NUM" newtype="int64">
                     <TYPEPROPERTY name="nullable" value="true"/>
                  </CONVERT>

                  <CONVERT destfield="DAY" sourcefield="DAY" newtype="string">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="x"/>
                     </CONVERTFUNCTION>
                  </CONVERT>

                  <CONVERT destfield="SUPPLIER" sourcefield="SUPPLIER" newtype="string">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="0"/>
                     </CONVERTFUNCTION>
                  </CONVERT>

                  <CONVERT destfield="LOC" sourcefield="LOC">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NLL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>

                  <CONVERT destfield="ITEM" sourcefield="ITEM">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="NLL"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  
                  <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE" newtype="string">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="'1'"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  
                  <CONVERT destfield="PO_QTY" sourcefield="PO_QTY" newtype="string">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="0"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
                  
                  <CONVERT destfield="LOC_TYPE" sourcefield="LOC_TYPE">
                     <CONVERTFUNCTION name="make_not_nullable">
                        <FUNCTIONARG name="nullvalue" value="x"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
               </CONVERTSPECS>
            ]]>
         </PROPERTY>
         <OUTPUT name="future_deliver_order1.v" />
      </OPERATOR>

      <OPERATOR type="export">
         <INPUT    name="future_deliver_order1.v"/>
         <PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
         <PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
      </OPERATOR>

      <OPERATOR type="convert">
         <INPUT name="reject_ord_multiple_nf.v"/>
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE">
                     <CONVERTFUNCTION name="make_nullable">
                        <FUNCTIONARG name="nullvalue" value="1"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
               </CONVERTSPECS> 
            ]]>
         </PROPERTY>
         
         <OUTPUT name="reject_ord_multiple_nf_cnv.v"/>
      </OPERATOR>

      <OPERATOR type="convert">
         <INPUT name="reject_ord_multiple_f.v"/>
         <PROPERTY name="convertspec">
            <![CDATA[
               <CONVERTSPECS>
                  <CONVERT destfield="ORDER_MULTIPLE" sourcefield="ORDER_MULTIPLE">
                     <CONVERTFUNCTION name="make_nullable">
                        <FUNCTIONARG name="nullvalue" value="1"/>
                     </CONVERTFUNCTION>
                  </CONVERT>
               </CONVERTSPECS>
            ]]>
         </PROPERTY>
            
         <OUTPUT name="reject_ord_multiple_f_cnv.v"/>
      </OPERATOR>

      <OPERATOR type="funnel">
         <INPUT name="reject_ord_multiple_nf_cnv.v"/>
         <INPUT name="reject_ord_multiple_f_cnv.v"/>
         
         <OPERATOR type="export">
            <PROPERTY name="outputfile" value="${REJECT_ORD_MULT_FILE}"/>
         </OPERATOR>
      </OPERATOR>
   </FLOW>
EOF

###############################################################################
#  Execute the flow
###############################################################################
_exec ${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

message "String Modifier started..."
_exec cp $OUTPUT_FILE $OUTPUT_FILE.str_mod.tmp
_exec awk -F "|" -v outputfile="$OUTPUT_FILE" '{printf("%-12s%-9s%-20s%-20s%-20s%-6s%-8s%-1s\n",$1,$2,$3,$4,$5,substr($6,0,6),substr($7,0,8),$8) > outputfile;}' $OUTPUT_FILE.str_mod.tmp
_exec rm $OUTPUT_FILE.str_mod.tmp
message "String Modifier completed successfully..."

message "Program completed successfully"

# cleanup and exit rmse_terminate 0
exit 0