# Sistema Integral de Abasto Library #
SIA Library es un portable desarrollo en KornShell Script creado para los scripts de extracción de información en los sistemas de abasto.

```
#!/bin/ksh
#
# Script: scriptname.ksh
# Description: description of the script
# Revision: 1
# Author: Pablo Almaguer
# Creation date: 2018-04-16
###########################################

# Utilities
. xxfc_sia_lib.ksh

# Script
message "Program started ..."

_sqlplus "select value from table" variable
print $variable 

message "Program completed successfully"
exit 0
```

## Instalación

Primeramente, clona el repositorio con:
	 $ git clone https://pablodaniel03@bitbucket.org/pablodaniel03/proyecto_femsa.git

Despues, si se utilizara en los scripts del Sistema Integral de Abasto:
* Copiar el contenido de `lib`,  `etc` en las carpetas correspondientes.
* Si las las carpetas se encuentran incluidas en la variable `$PATH`:
	* Importar los scripts de la siguiente forma:
		* `source xxfc_aip_config.env` o `. xxfc_aip_config.env` 
		* `source xxfc_sia_lib.ksh` o `. xxfc_sia_lib.ksh` 
* Si se cuenta con una variable de ambiente con la ruta de los archivos:
	* Importar los scripts de la siguiente forma:
		* `source ${MODULE_HOME}/xxfc_aip_config.env` o `. ${MODULE_HOME}/xxfc_aip_config.env` 
		* `source ${LIB_DIR}/xxfc_sia_lib.ksh` o `. ${LIB_DIR}/xxfc_sia_lib.ksh` 

Si se utilizará en otros scripts solo es necesario importar el archivo `/lib/xxfc_sia_lib.ksh`.

## Uso

Los siguientes archivos son:
* `xxfc_aip_config.env` - Script de ambientación principal para los scripts del sistema integral de abasto.
* `xxfc_sia_lib.ksh` - Librería con funciones de ayuda para fácilitar la códificación y el log del script.
* `translate_lib.ksh` - Crea el código SQL para eliminar caracteres especiales y lo almacena en un Array.
* `delta_lib.ksh` - Ensabla mediante parametros el código RETL de operador changecapture, utilizado para generar archivos de información delta.

## Licencia

La librería cuenta con una licencia bajo los terminos de GNU General Public License version
2 o superior. Mira el archivo [COPYING] para ver la Licencia.

## Contribuciones

Las contribuciones son bienvenidas, mira el archivo [CONTRIBUTING] para más detalles.

## Authors
La librería se creo el 15 de febrero de 2018 por [Pablo Almaguer] para el proyecto SIA.
Actualmente se encuentra en implmentación en los ambiente de pruebas.

Ver [GitHub].

[CONTRIBUTING]: https://github.com/chriscool/sharness/blob/master/CONTRIBUTING.md
[COPYING]: https://github.com/chriscool/sharness/blob/master/COPYING
[Pablo Almaguer]: https://bitbucket.org/pablodaniel03
[GitHub]: https://github.com/pablodaniel03