#!/bin/ksh

##############################################################################
# Module:        AIP TRANSLATE LIB
# Author:        Pablo Daniel Almaguer Alanis
# Creation Date: 24/Jun/2016
# Version:       1.0
# Description:   This script checks data delta files structures 
#                and creates changecapture RETL operator
#    
# Inputs:        Arguments defined below functions
# Called by:     
# Calls:     
# Modifyed by                      Date             Description
# -------------------------------------------------------------------------
# Pablo Daniel Almaguer Alanis     24/Jun/2016      Initial Creation
# Pablo Daniel Almaguer Alanis     30/Dic/2017      Regex_replace function
###############################################################################

#################
# USAGE
#------------
# DECLARE: use function ora_translate, give table columns by pipe delimited
# ora_translate 'schema.COLUMN_1|schema.COLUMN_2'
#
# USE: use variable TRANSLATE[n], where "n" is the column position in the declare section
# ${TRANSLATE[1]} ==> COLUMN_1
# ${TRANSLATE[2]} ==> COLUMN_2
# 
##################

#########################################
# ASCII Code                            #
#########################################
#      9       Í  50061    î  50094     #
#  !  33       Î  50062    ï  50095     #
#  "  34       Ï  50063    ó  50099     #
#  #  35       Ó  50067    ò  50098     #
#  $  36       Ò  50066    ô  50100     #
#  %  37       Ô  50068    õ  50101     #
#  &  38       Õ  50069    ö  50102     #
#  '  39       Ö  50070    ø  50104     #
#  -  45       Ø  50072    ú  50106     #
#  ?  63       Ú  50074    ù  50105     #
#  @  64       Ù  50073    û  50107     #
#  [  91       Û  50075    ü  50108     #
#  ]  93       Ü  50076    ý  50109     #
#  _  95       Ý  50077    Þ  50078     #
#  `  96       þ  50110    ð  50096     #
#  {  123      Ð  50064    ñ  50097     #
#  |  124      Ñ  50065    ç  50087     #
#  }  125      Ç  50055    ÿ  50111     #
#  ~  126      ß  50079    ´  49844     #
#  Á  50049    à  50080    °  49840     #
#  À  50048    â  50082    ∞  14846110  #
#  Â  50050    ã  50083                 #
#  Ã  50051    ä  50084                 #
#  Ä  50052    å  50085                 #
#  Å  50053    æ  50086                 #
#  Æ  50054    é  50089                 #
#  É  50057    è  50088                 #
#  È  50056    ê  50090                 #
#  Ê  50058    ë  50091                 #
#  Ë  50059    ì  50092                 #
#  Ì  50060    í  50093                 #
#                                       #
#########################################


#SP_LOWER_CASE="áàâãäåæéèêëìíîïóòôõöøúùûüýÞðñçÿ"
#NR_LOWER_CASE="aaaaaaaeeeeiiiiooooo0uuuuybdncy"
#SP_UPPER_CASE="ÁÀÂÃÄÅÆÉÈÊËÌÍÎÏÓÒÔÕÖØÚÙÛÜÝþÐÑÇß"
#NR_UPPER_CASE="AAAAAAAEEEEIIIIOOOOO0UUUUYBDNCS"
SP_LOWER_CASE="chr(50080)||chr(50081)||chr(50082)||chr(50083)||chr(50084)||chr(50085)||chr(50086)||chr(50089)||chr(50088)||chr(50090)||chr(50091)||chr(50092)||chr(50093)||chr(50094)||chr(50095)||chr(50099)||chr(50098)||chr(50100)||chr(50101)||chr(50102)||chr(50104)||chr(50106)||chr(50105)||chr(50107)||chr(50108)||chr(50109)||chr(50078)||chr(50096)||chr(50097)||chr(50087)||chr(50111)"
NR_LOWER_CASE="aa     ee  ii  oo   0uu    dncy"
SP_UPPER_CASE="chr(50049)||chr(50048)||chr(50050)||chr(50051)||chr(50052)||chr(50053)||chr(50054)||chr(50057)||chr(50056)||chr(50058)||chr(50059)||chr(50060)||chr(50061)||chr(50062)||chr(50063)||chr(50067)||chr(50066)||chr(50068)||chr(50069)||chr(50070)||chr(50072)||chr(50074)||chr(50073)||chr(50075)||chr(50076)||chr(50077)||chr(50110)||chr(50064)||chr(50065)||chr(50055)||chr(50079)"
NR_UPPER_CASE="AA     EE  II  OO   0UU    DNCS"
SP_CHR="chr(49840)||chr(14846110)||chr(49844)||chr(33)||chr(34)||chr(35)||chr(36)||chr(37)||chr(38)||chr(63)||chr(64)||chr(45)||chr(93)||chr(95)||chr(96)||chr(123)||chr(124)||chr(125)||chr(126)||chr(91)||chr(9)"
#SP_CHR=!"#$%&'?@-]_`{|}~[ //Last chr is TAB
NR_CHR="    S Y q           "
SPN_SET="chr(39)"
NRN_SET="null"

export PAR_1="${SP_LOWER_CASE}||${SP_UPPER_CASE}||${SP_CHR}"
export PAR_2="'${NR_LOWER_CASE}${NR_UPPER_CASE}${NR_CHR}'"
export PAR_3="${SPN_SET}"
export PAR_4="${NRN_SET}"

########################################################
#  ora_translate
#  This function ...
########################################################

NUMBER=1
ora_translate(){
   ############################################
   #  $1 - COLUMNS DELIMITED BY '|'           #
   ############################################
   FIELDS=$(echo $1 | tr "|" "\n")
   n=1
   for FIELD in $FIELDS; do
      TRANSLATE[$n]="REGEXP_REPLACE(TRANSLATE(CONVERT(${FIELD}, 'US7ASCII', 'UTF8'),${PAR_1},${PAR_2}),${PAR_3},${PAR_4})"
      n=$(($n+1))
   done
}