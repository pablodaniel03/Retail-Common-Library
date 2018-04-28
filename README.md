# Sistema Integral de Abasto Library #
SIA Library es un portable desarrollo en KornShell Script creado para los scripts de extracción de información en los sistemas de abasto.

```
#!/bin/ksh
#
# Script: test_script.ksh
# Description: description of the script
# Revision: 1.0.2
# Author: Pablo Almaguer
# Creation date: 2018-04-16
###########################################

export PROGRAM_NAME="test_script"

# Utilities
. xxfc_sia_lib.ksh

# Script
message "Program started ..."

_sqlplus "select value from table" variable
print $variable 

message "Program completed successfully"
exit 0
```

## Problema
La implementación y el desarrollo de Shell Script en los sistemas empresariales tiene un gran potencial, es utilizado por las grandes empresas de los ERP's.
Sin emargo, cuando no se tiene un conocimiento intermedio - avanzado, frecuentemente se encuentran problemas como:

- Terminación de script correcto cuando falló un binario o un script anidado.
- Archivos de log con muy poca información y sin hacer mención del tipo de log que se imprime.
- Código redundante.
- Pobre administración del ambiente de desarrollo para los scripts.
- No se tiene un control de cambios incluido en el IDE.

## Arquitectura

SIA Library provee una estructura y funcionalidades de ayuda para el contenido y manejo de las
configuraciones del ambiente de Shell, manejo de errores y funciones de ayuda para la integración de bases de datos Oracle.

Los siguientes scripts estan incluidos:
* `/etc/xxfc_aip_config.env`

	Provee las configuraciones de ambiente (Paths, Environment Variables, RETL variables) para 
	los scripts del sistema integral de abasto, puede estar cargado en el "profile" del usuario
	o en el ambiente local del script para especializar cada instalación.
	Este script fue creado para utilizarse sin configuración previa (Valores predeterminados del negocio),
	o bien puede modificarse según sea la necesidad.

* `/lib/xxfc_sia_lib.ksh`

	Contiene funciones de utilidad para:
	* Mejora de información y errores manejados de forma manual o automatica en el logging.
	* Funcionalidad para mejorar el control y manejo de errors de los procesos ejecutados en paralelo.
	* Mejora en la verificación de ejecuciones scripts y binarios de linux.
	* Extracción valores, asignación de valores en variables de linux y ejecución de stored procedures,
		funciones y packages en bases de datos Oracle.

* `/lib/translate_lib.ksh`

	Genera una concatenación de funciones para eliminar caracteres especiales en consulta o extracción de
	información en bases de datos Oracle.

* `/lib/delta_lib.ksh`

	Mejora la escritura de código RETL en el uso del operador Changecapture para la extracción de información delta.


## Requerimientos
Para un correcto funcionamiento y provechamiento de las mejoras en seguridad y manejo de credenciales, la librería `xxfc_sia_lib.ksh` requiere de versiones Oracle 11g o más reciente 
para hacer uso de [Oracle Wallet]. No obstante en la versión [1.0.2](https://bitbucket.org/pablodaniel03/proyecto_femsa/src/?at=v1.0.2) se agregó un manejo de excepción para utilizar las credenciales convencionales mediante variables de ambiente.

```
#!/bin/ksh
# función __sql_fetch

typeset dbalias=${4:-${ORACLE_SID:-DEFAULTALIAS}}
typeset conection_string=${_CONNEC_STRING:-"/"}
```
La librería utiliza la variable de ambiente `${ORACLE_SID}`, la cual es declarada en la [configuración del ambiente para los sistemas linux](https://docs.oracle.com/database/121/ADMQS/GUID-EC18C4A6-3BA5-4C14-9D76-B0DD62FEFFF2.htm#ADMQS12369).
Si está variable no se encuentra declarada, se puede declarar un SID predeterminado en el lugar de "DEFAULTALIAS".
La variable interna `$conection_string` controlará el uso de Wallets en caso de que la variable `${_CONNEC_STRING}` se haya descomentado y configurado.



## Implementación
Uso en scripts del Sistema Integral de Abasto:
* Copiar el contenido de `lib`,  `etc` en las carpetas correspondientes.

Uso en otros scripts:
* Copiar el archivo `/lib/xxfc_sia_lib.ksh` a la carpeta correspondiente.

Si las las carpetas se encuentran incluidas en la variable `$PATH`:
* Importar los scripts de la siguiente forma:
	* `source xxfc_aip_config.env` ó `. xxfc_aip_config.env` 
	* `source xxfc_sia_lib.ksh` ó `. xxfc_sia_lib.ksh`

Si se encuentra declarada una variable de ambiente con la ruta absoluta de los archivos:
* Importar los scripts de la siguiente forma:
	* `source ${ENV_VARIABLE}/xxfc_aip_config.env` o `. ${ENV_VARIABLE}/xxfc_aip_config.env` 
	* `source ${LIB_DIR}/xxfc_sia_lib.ksh` o `. ${LIB_DIR}/xxfc_sia_lib.ksh` 



## Uso

### xxfc_aip_config.env

#### Configuración AIP
```
####   
# AIP_OC_FILTER_MODE variable is needed for purchase 
# orders AIP extraction
#  G -> Geografia (default mode)
#  C -> Categoria
#  S -> Proveedores
export AIP_OC_FILTER_MODE="'C'"
```
Esta configuración solo es necesaria para los scripts del sistema AIP.

#### Configuración Oracle
```
####
# Oracle settings
#  Some of these variables must be declared in user's profile.
#  Values can be modified in case of tests.
export LC_ALL=C
export NLS_NUMERIC_CHARACTERS=".,"
export ORACLE_HOME=${ORACLE_HOME:-/u01/cliente/client_1}
export TNS_ADMIN=${TNS_ADMIN:-${ORACLE_HOME}/network/admin}
```

Estas variables deben de ser declaradas en el profile del usuario, sin embargo, si no se han
declarado, se tomará el valor declarado despues de `:-`. 

Ejemplo. Si `ORACLE_HOME` no se encuentre declarada en el profile, el script de configuración le 
asignará el valor `/u01/cliente/client_1`

#### Configuración Java
```
## Java environment
set -f
unset JAVA_ARGS
# Declare JAVA_ARGS bellow


if [[ -r "/dev/urandom" ]]; then
   # Improving performance using fake urandom
   export JAVA_ARGS="${JAVA_ARGS} -Djava.security.egd=file:/dev/./urandom"
fi
```
Es necesario que durante la ejecución de los scripts con RETL solo se utilicen los argumentos de java necesarios. Para ello utilzamos `unset JAVA_ARGS`.
El uso de `-Djava.security.egd=file:/dev/./urandom` mejora el performance en la ejecución de Java.

#### Configuración RETL
```
## Retail Extract, Transform and Load Environment    # Default value
export RETL_INIT_HEAP_SIZE="6144M"                   # 2048M
export RETL_MAX_HEAP_SIZE="6144M"                    # 2048M
export RETL_ENABLE_64BIT_JVM=1                       # 0 (Disable)

export RFX_HOME=${RFX_HOME:-/u01/rfxinstall1325}
export RFX_OPTIONS="-c ${RFX_HOME}/etc/rfx.conf"
export RFX_EXE="rfx"
export RETL_OPTIONS="${RFX_OPTIONS}"
export RETL_EXE="${RFX_EXE}"						 # retl (alias must be created )
```
RETL utiliza 2400 megabytes en la memoria de java de forma predeterminada, debido a la gran cantidad de información que es trabajada
con este ETL, se cambia el valor predeterminado a 6144 megabytes y se habilita el uso de la arquitectura de 64bits.

#### Configuración de directorios
```
export DATA_DIR=${AIP_HOME}/data
export DATA_TMP=${DATA_DIR}/temp
export REJ_DIR=${DATA_DIR}
export LOG_DIR=${AIP_HOME}/log
export ERR_DIR=${AIP_HOME}/error
export RSC_DIR=${AIP_HOME}/rfx/include
export SCHEMA_DIR=${AIP_HOME}/rfx/schema
export BIN_DIR=${AIP_HOME}/rfx/bin
export LIB_DIR=${AIP_HOME}/rfx/lib
export ETC_DIR=${AIP_HOME}/rfx/etc
export SRC_DIR=${AIP_HOME}/rfx/src
export BKM_DIR=${AIP_HOME}/rfx/bookmark
export TEMP_DIR=/tmp
```
El sistema AIP cuenta con la variable `AIP_HOME` declara en su profile como parte de su arquitectura, en caso de implementarse en otro sistema es necesario cambiar el valor de estas variables.

#### Configuración del log
```
export FILE_DATE=$(date +"%Y%m%d%H%M%S")
export LOG_FILE=${LOG_DIR}/$(date +"%Y%m%d").log
export ERR_FILE=${ERR_DIR}/${PROGRAM_NAME}.${FILE_DATE}
export REJ_FILE=${REJ_DIR}/${PROGRAM_NAME}.rej.${FILE_DATE}
export STATUS_FILE=${ERR_DIR}/${PROGRAM_NAME}.status.${FILE_DATE}
export BOOKMARK_FILE=${BKM_DIR}/${PROGRAM_NAME}.bkm.${FILE_DATE}
export LOG=$(date +"%Y%m%d").log # Created for integration library
```
Este script establece una estructura para los archivos de log para poder utilizarse de forma independiante al script `xxfc_sia_lib.ksh`.

La variable `$PROGRAM_NAME` debe estar declarada en cada script que utilice este ambiente.

El archivo log de cada script se crea dentro de `$ERR_DIR` y es llamado `<PROGRAM_NAME>.<timestamp>`. 
Adicionalmente se crea un archivo log general en `$LOG_DIR` con el nombre `<timestamp>`.log

El formato del timestamp de los archivos de `$ERR_DIR` es `date +"%Y%m%d%H%M%S"` [año, mes, día, hora, minuto, segundo] y 
el formato del archivo de log general es `date +"%Y%m%d"` [año, mes, día].

#### Configuración de variables ETC
```
while IFS=: read envar file; do
   if [[ -s ${ETC_DIR}/${file} ]]; then
      val=$(cat ${ETC_DIR}/${file})
      eval ${envar}='${val}'
   else
      print "${PROGRAM_NAME} ${FILE_DATE}: ${file} doesn't exist under ${ETC_DIR}"
      exit 1
   fi
done <<EOF
VDATE:vdate.txt
NEXT_VDATE:next_vdate.txt
EOF
```
Las variables ETC son variables cuyo valor es el de un archivo de control almacenado en `$ETC_DIR`. Esta parte de código 
genera de forma dinámica estas varibales.

Para generar más variables ETC se debe seguir lo siguiente:
* El archivo que contendrá el valor de la variable debe de estar almacenado en `$ETC_DIR`.
* Sintxis:
	* Dentro de la sección `EOF` se debe declarar el nombre de la variable (regularmente en mayúsculas)
		seguido del nombre del archivo a importar. Se deben de utilizar `:` como delimitador de estos valores.
		
		Ejemplo. `VARIABLE:archivo.dat`


#### Configuración conexiones Oracle Database

RETL se conecta a distintas bases de datos para extraer la información 
mediante el operador `<OPERATOR type="oraread">`. Este operador necesita de ciertas propiedades con valores
	especificos de cada base de datos, ejemplo:
```
<OPERATOR type="oraread">
   <PROPERTY name="dbname" value=""/>
   <PROPERTY name="dbuseralias" value=""/>
   <PROPERTY name="maxdescriptors" value=""/>
   <PROPERTY name="datetotimestamp" value=""/>
   <PROPERTY name="port" value=""/>
   <PROPERTY name="hostname" value=""/>
   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=)(TDU=)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=)(PORT=)))(CONNECT_DATA=(server=dedicated)(SID=)))"/>
<!--
   <PROPERTY ...
   <PROPERTY ...
   <PROPERTY ...
-->
</OPERATOR>
```

Adicional a este operador, otros comparten estructuras similares como:

* `<OPERATOR type="orawrite">`
	
	```
	<OPERATOR type="orawrite">
	   <PROPERTY name="dbname" value=""/>
	   <PROPERTY name="dbuseralias" value=""/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="method" value=""/>
	   <PROPERTY name="port" value=""/>
	   <PROPERTY name="hostname" value=""/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=)(TDU=)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=)(PORT=)))(CONNECT_DATA=(server=dedicated)(SID=)))"/>
	<!--
	   <PROPERTY ...
	   <PROPERTY ...
	   <PROPERTY ...
	-->
	</OPERATOR>
	```

* `<OPERATOR type="orawrite">` [Tabla Temporal]

	```
	<OPERATOR type="orawrite">
	   <PROPERTY name="dbname" value=""/>
	   <PROPERTY name="dbuseralias" value=""/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="method" value=""/>
	   <PROPERTY name="mode" value="truncate"/>
	   <PROPERTY name="schemaowner"  value=""/>
	   <PROPERTY name="createtablemode"   value="recreate"/>
	   <PROPERTY name="port" value=""/>
	   <PROPERTY name="hostname" value=""/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=)(TDU=)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=)(PORT=)))(CONNECT_DATA=(server=dedicated)(SID=)))"/>
	<!--
	   <PROPERTY ...
	   <PROPERTY ...
	   <PROPERTY ...
	-->
	</OPERATOR>
	```

* `<OPERATOR type="preparedstatement">`

	```
	<OPERATOR type="preparedstatement">
	   <PROPERTY name="dbname" value=""/>
	   <PROPERTY name="dbuseralias" value=""/>
	   <PROPERTY name="schemaowner"  value=""/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="port" value=""/>
	   <PROPERTY name="hostname" value=""/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=)(TDU=)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=)(PORT=)))(CONNECT_DATA=(server=dedicated)(SID=)))"/>
	<!--
	   <PROPERTY ...
	   <PROPERTY ...
	   <PROPERTY ...
	-->
	</OPERATOR>
	```

Anteriormente, se utilizaba una variable para cada operador y base de datos, esto generaba que el ambiente tuviera mucho código redundante y problemas con la administración y generalización de estas variables.

Como parte de la mejora en el ambiente, se modificó la declaración de estas variables a una forma dinamica, teniendo que 
declarar el siguiente grupo de arrays para cada conexión:
* `DBNAME[]` - Alias de la base de datos.
* `DB_OWNER[]` - Schema a conectar.
* `BA_OWNER[]` - Schema temporal.
* `DBHOST[]` - Hostname o dirección IP de la base de datos.
* `DBPORT[]` - Puerto configurado para la base de datos.
* `LOAD_TYPE[]` - Tipo de carga, usado en el operador orawrite. Ver [Oracle Loads Doc] para más información.
* `RETL_WALLET_ALIAS[]` - Alias asignado durante la creación de la wallet para RETL.
* `ORACLE_WALLET_ALIAS[]` - Alias asignado en el archivo tnsnames.ora.
* `SQLPLUS_LOGON[]` - Conexión para SQL\*plus. De no contar con wallet, se especificar usuario y contraseña.
* `SDU_TDU[]` - Tamaño del conjunto de paquetes a enviar por red. Ver [SDU y TDU Post] para más información.

Se escribe, en forma de comentario, el nombre del sistema al que se creará la conexión. Estas variables son arrays de shell script, dentro de los `[]` se decalra el alias de la base de datos como índice del array.

```
### Retail Merchandise System Connection
DBNAME[RMS]="RMS_DBNAME"
DB_OWNER[RMS]="RMS_DBOWNER"
BA_OWNER[RMS]="RMS_BAOWNER"
DBHOST[RMS]="RMS_DBHOST"
DBPORT[RMS]="RMS_DBPORT"
LOAD_TYPE[RMS]="RMS_LOAD_TYPE"
RETL_WALLET_ALIAS[RMS]="RMS_RETL_WALLET_ALIAS"
ORACLE_WALLET_ALIAS[RMS]="RMS_ORACLE_WALLET_ALIAS"
SQLPLUS_LOGON[RMS]="/@${ORACLE_WALLET_ALIAS[RMS]}"
SDU_TDU[RMS]="RMS_SDU_TDU"
```


Las siguentes variables contendrán el código RETL según su operador, estas se crean de forma dinamica una vez declaradas las variables anteriores.
* `DBREAD[]`
	
	```
	<OPERATOR type="oraread">
	   <PROPERTY name="dbname" value="${DBNAME[$db]}"/>
	   <PROPERTY name="dbuseralias" value="${RETL_WALLET_ALIAS[$db]}"/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="datetotimestamp" value="false"/>
	   <PROPERTY name="port" value="${DBPORT[$db]}"/>
	   <PROPERTY name="hostname" value="${DBHOST[$db]}"/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=${SDU_TDU[$db]})(TDU=${SDU_TDU[$db]})(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${DBHOST[$db]})(PORT=${DBPORT[$db]})))(CONNECT_DATA=(server=dedicated)(SID=${DBNAME[$db]})))"/>
	```

* `DBWRITE[]`

	```
	<OPERATOR type="orawrite">
	   <PROPERTY name="dbname" value="${DBNAME[$db]}"/>
	   <PROPERTY name="dbuseralias" value="${RETL_WALLET_ALIAS[$db]}"/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="method" value="${LOAD_TYPE[$db]}"/>
	   <PROPERTY name="port" value="${DBPORT[$db]}"/>
	   <PROPERTY name="hostname" value="${DBHOST[$db]}"/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=${SDU_TDU[$db]})(TDU=${SDU_TDU[$db]})(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${DBHOST[$db]})(PORT=${DBPORT[$db]})))(CONNECT_DATA=(server=dedicated)(SID=${DBNAME[$db]})))"/>"
	```

* `DBWRITE_TEMP[]`

	```
	<OPERATOR type="orawrite">
	   <PROPERTY name="dbname" value="${DBNAME[$db]}"/>
	   <PROPERTY name="dbuseralias" value="${RETL_WALLET_ALIAS[$db]}"/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="method" value="${LOAD_TYPE[$db]}"/>
	   <PROPERTY name="mode" value="truncate"/>
	   <PROPERTY name="schemaowner"  value="${BA_OWNER[$db]}"/>
	   <PROPERTY name="createtablemode"   value="recreate"/>
	   <PROPERTY name="port" value="${DBPORT[$db]}"/>
	   <PROPERTY name="hostname" value="${DBHOST[$db]}"/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=${SDU_TDU[$db]})(TDU=${SDU_TDU[$db]})(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${DBHOST[$db]})(PORT=${DBPORT[$db]})))(CONNECT_DATA=(server=dedicated)(SID=${DBNAME[$db]})))"/>"
	```

* `DBPREPSTMT[]`

	```
	<OPERATOR type="preparedstatement">
	   <PROPERTY name="dbname" value="${DBNAME[$db]}"/>
	   <PROPERTY name="dbuseralias" value="${RETL_WALLET_ALIAS[$db]}"/>
	   <PROPERTY name="schemaowner"  value="${BA_OWNER[$db]}"/>
	   <PROPERTY name="maxdescriptors" value="100"/>
	   <PROPERTY name="port" value="${DBPORT[$db]}"/>
	   <PROPERTY name="hostname" value="${DBHOST[$db]}"/>
	   <PROPERTY name="jdbcconnectionstring" value="jdbc:oracle:thin:@(DESCRIPTION=(SDU=${SDU_TDU[$db]})(TDU=${SDU_TDU[$db]})(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${DBHOST[$db]})(PORT=${DBPORT[$db]})))(CONNECT_DATA=(server=dedicated)(SID=${DBNAME[$db]})))"/>"
	```

#### Ejemplo de uso

```
#!/bin/ksh
########################################################
# Script Name: rmse_item_master.ksh
# Description: extract list of company items.
#
# Author:      Pablo Almaguer    
# Creation:    10/Apr/2018
########################################################

export PROGRAM_NAME="rmse_aip_item_retail"

. ${AIP_HOME}/rfx/etc/xxfc_aip_config.env

export OUTPUT_FILE="${DATA_DIR}/${PROGRAM_NAME}.dat"
export OUTPUT_SCHEMA="${SCHEMA_DIR}/${PROGRAM_NAME}.schema"

FLOW_FILE="${LOG_DIR}/${PROGRAM_NAME}.xml"
cat > ${FLOW_FILE} << EOF
<FLOW name = "${PROGRAM_NAME}.flw">
  ${DBREAD[RMS]}
    <PROPERTY name = "arraysize" value = "1000"/>
    <PROPERTY name = "query">
      <![CDATA[
        select item, item_desc
        from table
      ]]>
    </PROPERTY>
    <OPERATOR type="export">
      <PROPERTY name="outputfile" value="${OUTPUT_FILE}"/>
      <PROPERTY name="schemafile" value="${OUTPUT_SCHEMA}"/>
    </OPERATOR>
  </OPERATOR>
</FLOW>

${RETL_EXE} ${RETL_OPTIONS} -f ${FLOW_FILE}

exit $?
```


### xxfc_sia_lib.ksh
Todas las funciones internas escriben su acción en los archivos log, y contienen dos `_` como prefijo en su nombre.
Estas funciones cuentan con alias, donde este prefijo cambia o se elimina y se añade algunos paramtros necesarios como la variable `$LINENO`.

#### Configuración variables
```
# Private variables
_SCRIPT_NAME="${SCRIPT_NAME:-${PROGRAM_NAME:-$0.$$}}"
_LOG_DIR="${LOG_DIR:-$TMP}"
_ERR_DIR="${ERR_DIR:-$TMP}"
_LOG_FILE="${LOG_FILE:-${_LOG_DIR}/${_SCRIPT_NAME}.$(__get_timestamp).log}"
_ERR_FILE="${ERR_FILE:-${_ERR_DIR}/${_SCRIPT_NAME}.$(__get_timestamp)}"

# Oracle Database Configuration
# ORACLE_HOME=""                                 #Directorio base de la instalación de la base de datos o cliente SQL*Plus
# ORACLE_SID=""                                  #Identificador de la base de datos
# TNS_ADMIN=""                                   #Ruta para archivo tnsnames.ora
# _CONNECT_STRING="user/password"                #Descomentar para no utilizar wallets
```
Para el correcto funcionamiento de log en los scripts que utilzan `xxfc_aip_config.env`, es necesario que se declarara la variable `$PROGRAM_NAME`. 

La librería esta diseñada para integrarse con los scripts que utilizan el ambiente `xxfc_aip_config.env`. Tomará como referencia los valores de las variables:
* `$PROGRAM_NAME`
* `$LOG_DIR`
* `$ERR_DIR`
* `$LOG_FILE`
* `$ERR_FILE`

En caso de que no se declaren estas variables o se esté utilizando sin el ambiente, la librería 
obtendrá el nombre del script mediente la variable `$0` y almacenará los archivos log en `$TMP` (/tmp).

#### \_\_get_timestamp
```
function __get_timestamp {
  print $(date +"%Y%m%d%H%M%S")
}
alias _get_timestamp='__get_timestamp'
```
Función utilizada para obtener un timestamp, su formato es `YYYYMMDDhhmmss`, ejemplo: `20180302150353`. 

#### \_\_message
Utilizada para imprimir mensajes en el archivo log/error.
Esta función requiere los siguientes parámetros:
1. Número de línea.
2. Nivel de loggin.
3. Mensaje entre comillas dobles.

Los alias listados cuentan con los algunos parámetros, `$LINENO` y el nivel de log.
* `_message` - Es necesario que reciba el nivel de log .
* `_warning` - Contiene el nivel de log en Warning por defecto.
* `_error` - Contiene el nivel de log en Error por defecto.
* `message` - Contiene el nivel de log en Information por defecto

```
# Ejemplo sin uso de alias
__message ${LINENO} INFORMATION "Inicio de script..."

# Ejemplo con alias
_message "DEBUG" "Creando archivos control..."
_warning "La variable no está declarada."
_error "El archivo o directorio no existe."
message "Inicio de script..."
```


.
#### \_\_terminate
Utilizada para finalizar la ejecución del script. 
Esta función requiere los siguientes parámetros:
1. Número de línea.
2. Código de salida.

Si no se especifica el código de salida, tomará el valor de `$?`.
La función cuenta con el alias `exit` para que los scripts que utilzen la palabra reservada `exit` no tengan que sufrir cambios.
```
# Ejemplo sin uso de alias
__terminate ${LINENO} 0

# Ejemplo con alias
exit 
exit 2

```

#### \_\_exec
Utilzada para redirigír el `stderr` y `stdout` al archivo de log.
Esta función requiere los siguientes parámetros:
1. Número de linea.
2. Script o binario a ejecutar.

```
# Ejemplo sin uso de alias
__exec ${LINENO} mv /path/to/file /path/to/file_2

# Ejemplo con alias
_exec mv /path/to/file /path/to/file_2		#Ejecución de binario
_exec script.sh 													#Ejecución de script

```

#### \_\_verify
Utilizada después de la ejecución de un binario o script, verifica si existieron errores en la ejecución.
Esta función requiere los siguientes parámetros:
1. Código de salida
2. Número de línea
3. Mensaje, en caso de error.

```
# Ejemplo sin uso de alias
script.sh
__verify $? ${LINENO} "script.sh terminó con errores."


# Ejemplo con alias
script.sh
_verify

ls /path/to/file.txt > /dev/null
_verify "El archivo no existe o no se encuentra en la ruta."
```


#### \_\_verify_log
Utilizada cuando se ejecutan scripts o binarios en paralelo. Verifica que no existan mensajes de error en el archivo log.
Esta función requiere los siguientes parámetros:
1. Número de línea

```
while read parametro; do
	script.sh $parametro &
done < parametros.control

wait

__verify_log ${LINENO}		# Ejemplo sin uso de alias
_verify_log								# Ejemplo con alias
```
.
#### \_\_check
Utilizada para verificar si un archivo o directorio existen. En caso de ser un archivo y esté tenga un peso de 0 bytes escribe un mensaje de warning.

Esta función requiere los siguientes parámetros:
1. Número de línea

```
export DATAFILE="path/to/data/file.dat"
export OUTPUT_DIR="path/to/output"
export OUTPUT_FILE="${OUTPUT_DIR}/new_file.dat"

__check ${LINENO} ${OUTPUT_FILE} 	# Ejemplo sin uso de alias
_check ${OUTPUT_DIR} 							# Ejemplo con alias
```

.
#### \_\_sql_fetch
Utilizada para extraer información de bases las bases de datos.
Esta función requiere los siguientes parámetros:
1. Número de línea.
2. Sentencia SQL.
3. Variable de salida.
4. Alias de la base de datos (Opcional).

La función cuenta con el alias `_sqlplus` y es utilizado para ejecutar stored procedures, 
funciones y packages en bases de datos Oracle.
En caso de no especificar 4° parámetro, se estará tomando en cuenta la variable de ambiente `${ORACLE_SID}`.

```
#!/bin/ksh
# Ejemplo _sql_fetch

typeset version=""
_sql_fetch "select version from v$instance;" version
print $version 	#Imprime la versión de la base de datos

# Ejemplo _sqlplus

_sqlplus "BEGIN 
	DBMS_OUTPUT.PUT_LINE(DBMS_DB_VERSION.VERSION || '.' || DBMS_DB_VERSION.RELEASE); 
END;
/
"
```

## Licencia

La librería cuenta con una licencia bajo los terminos de GNU General Public License version
2 o superior. Mira el archivo [COPYING] para ver la Licencia.

## Contribuciones

Todo tipo de contribución o retroalimentación es bienvenidas.
Para más información consulta el archivo [CONTRIBUTING].

## Autor
La librería se creo el 15 de febrero de 2018 por [Pablo Almaguer] para el proyecto SIA.
Actualmente se encuentra en implmentación en los ambiente de pruebas.

Ver [GitHub] del autor.

[SDU y TDU Post]: http://www.dba-oracle.com/phys_sdu_tdu.htm
[Oracle Loads Doc]: https://docs.oracle.com/cd/B19306_01/server.102/b14215/ldr_modes.htm
[CONTRIBUTING]: https://github.com/chriscool/sharness/blob/master/CONTRIBUTING.md
[COPYING]: https://github.com/chriscool/sharness/blob/master/COPYING
[Pablo Almaguer]: https://bitbucket.org/pablodaniel03
[GitHub]: https://github.com/pablodaniel03
[Oracle Wallet]: https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dbimi/using-oracle-wallet-manager.html#GUID-D0AA8373-B0AC-4DD8-9FA9-403E345E5A71