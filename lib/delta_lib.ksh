#!/bin/ksh

##############################################################################
# Module:        AIP DELTA LIB
# Author:        Pablo Daniel Almaguer Alanis
# Creation Date: 26/May/2016
# Version:       2.5
# Description:   This script checks data delta files structures and creates changecapture RETL operator
#    			 Is necesary call this library after rmse enviroment and lib
# Inputs:        Arguments defined below functions
# Called by:     
# Calls:		 
# Modifyed by		               Date	            Description
# -------------------------------------------------------------------------
# Pablo Daniel Almaguer Alanis     26/May/2016      Initial Creation
# Pablo Daniel Almaguer Alanis     01/Jun/2016      Update
# Pablo Daniel Almaguer Alanis     10/Oct/2016      Update [deltas_backup function]
# Pablo Daniel Almaguer Alanis	  15/Nov/2016	    Update [Log]
# Pablo Daniel Almaguer Alanis	  30/Dic/2017	    Update functions
###############################################################################

#retl_changecapture "/u01/aip/rpas/scripts/integration/pablo/delta/data/datafile.dat" "/u01/aip/rpas/scripts/integration/pablo/delta/rfx/schema/schemafile.schema" "LLAVE1|LLAVE2|LLAVE3"
#retl_changecapture "/u01/aip/rpas/scripts/integration/pablo/delta/data/datafile2.dat" "/u01/aip/rpas/scripts/integration/pablo/delta/rfx/schema/schemafile.schema" "LLAVE1|LLAVE2|LLAVE3"

#print ${CHANGECAPTURE[1]}
#################
# USAGE
#------------
# DECLARE: use function retl_changecapture, give data file, schema file and retl changecapture keys by pipe delimited
# retl_changecapture "/path/to/data/file.dat" "/path/to/schema/file.schema" "key_1|key_2|key_3"
#
# USE: use variable TRANSLATE[n], where "n" is the column position in the declare section
# ${CHANGECAPTURE[1]} ==> Print the assembled RETL changecapture operator
# 
##################


function delta_str
{
	############################
	#  $1 - OUTPUT FILE NAME   #
	############################
	
	FILE_NAME=$(echo $1 | tr "|" "\n")
	n=0
	for FILE in $FILE_NAME; do
		DATA_FILE="/path/to/data/${FILE}"
		DELTA_FILE="/path/to/delta_data/${FILE}"

		#Get the data full from delta_data dir to data dir
		if [[ -s "${DELTA_FILE}.full" ]]; then
			_message "DELTA" "Getting data full from \$DELTA_DIR to \$DATA_DIR"
			cp "${DELTA_FILE}.full" "${DATA_FILE}.full"
		fi

		#if delta file exists
		if [[ -s "${DATA_FILE}" ]]; then
			_message "DELTA" "${FILE} exists in DATA_DIR"
			
			#if full file doesn't existls
			if [[ -s "${DATA_FILE}.full" ]]; then
				_message "DELTA" "Moving ${FILE}.full to ${FILE}.old"
				mv "${DATA_FILE}.full" "${DATA_FILE}.old"
			fi
		fi
		if [[ ! -s "${DATA_FILE}.old" ]]; then
			_message "DELTA" "Creating ${FILE}.old in \$DATA_DIR"
			touch "${DATA_FILE}.old"
		fi

		n=$(($n+1))
	done
}

function deltas_backup
{
	############################
	#  $1 - INPUT FILES NAME   #
	############################

	DELTA_DIR="/path/to/delta_data"
	DIRECTORY="${1}"
	FILES="${2}"
	
	LIST=`ls /path/to/data/*.full`

	for FILE in ${LIST}; do
		echo "Moving ${FILE} to ${DELTA_DIR}/${FILE##*/}"  
		mv ${FILE} ${DELTA_DIR}/${FILE##*/}
	done
}

########################################################
#  RETL CHANGECAPTURE
#  This function...
########################################################
NUMBER=1

function retl_changecapture
{
	####################################
	# $1 - OUTPUT FILE PATH            #
	# $2 - OUTPUT SCHEMA PATH          #
	# $3 - KEYS DELIMITED BY '|'       #
	####################################

	KEYS=$(echo $3 | tr "|" "\n")
	n=0
	for i in $KEYS; do
		propertykey[$n]="	<PROPERTY name=\"key\" value=\"$i\"/>"
		n=$(($n+1))
	done

	changecapture[0]="<OPERATOR type=\"copy\">
	<INPUT name=\"DELTA_${NUMBER}.v\"/>
	<OUTPUT name=\"NEW_FULL_${NUMBER}.v\"/>
	<OPERATOR type=\"sort\" >"
######################## propertykey[*] ########################
    changecapture[1]="	<PROPERTY name=\"order\" value=\"asc\"/>
	<OUTPUT name=\"NEW_DELTA_${NUMBER}.v\"/>
	</OPERATOR>
</OPERATOR>"

    changecapture[2]="<OPERATOR type=\"import\" >
	<PROPERTY name=\"inputfile\" value=\"${1}.old\"/>
	<PROPERTY name=\"schemafile\" value=\"${2}\"/>
	<OPERATOR type=\"sort\" >
               "
######################## propertykey[*] ########################
    changecapture[3]="	<PROPERTY name=\"order\" value=\"asc\"/>
	<OUTPUT name=\"OLD_FULL_${NUMBER}.v\"/>
	</OPERATOR>
</OPERATOR>"

    changecapture[4]="<OPERATOR type=\"changecapture\" >
		<INPUT name=\"OLD_FULL_${NUMBER}.v\"/>
	<INPUT name=\"NEW_DELTA_${NUMBER}.v\"/>
	<PROPERTY name=\"allvalues\" value=\"true\"/>
            "
######################## propertykey[*] ########################
    changecapture[5]="	<PROPERTY name=\"codefield\" value=\"CHANGE_CODE\"/>
	<PROPERTY name=\"copycode\" value=\"0\"/>
	<PROPERTY name=\"insertcode\" value=\"1\"/>
	<PROPERTY name=\"deletecode\" value=\"2\"/>
	<PROPERTY name=\"editcode\" value=\"3\"/>
	<PROPERTY name=\"dropcopy\" value=\"true\"/>
	<PROPERTY name=\"dropedit\" value=\"false\"/>
	<PROPERTY name=\"dropdelete\" value=\"true\"/>
	<PROPERTY name=\"dropinsert\" value=\"false\"/>
	<PROPERTY name=\"sortascending\" value=\"true\"/>
            
	<OPERATOR  type=\"fieldmod\">
		<PROPERTY  name=\"drop\" value=\"CHANGE_CODE\"/>
		<OPERATOR type=\"export\">
		<PROPERTY name=\"outputfile\" value=\"${1}\"/>
		<PROPERTY name=\"schemafile\" value=\"${2}\"/>
	</OPERATOR>
</OPERATOR>
</OPERATOR>
<OPERATOR type=\"export\">
	<INPUT name=\"NEW_FULL_${NUMBER}.v\"/>
	<PROPERTY name=\"outputfile\" value=\"${1}.full\"/>
	<PROPERTY name=\"schemafile\" value=\"${2}\"/>
</OPERATOR>"

	export CHANGECAPTURE[$NUMBER]="${changecapture[0]}${propertykey[*]}${changecapture[1]}${changecapture[2]}${propertykey[*]}${changecapture[3]}${changecapture[4]}${propertykey[*]}${changecapture[5]}"

	NUMBER=$(($NUMBER+1))
}