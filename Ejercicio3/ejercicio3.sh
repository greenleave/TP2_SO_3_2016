#! /bin/bash

# TP2-EJ3.sh
#
#Trabajo Practico 2 - Ejercicio 3
#
#Bogado, Sebastian Emanuel Enrique 	38256096	
#Gómez, Jorge Aníbal			31698426
#Mansilla, Rodrigo José			36954840
#Regojo, Ary Daniel			36077406
#Rey, Juan Cruz  
#
# Entrega

MostrarAyuda()
{
	echo "Este script informa los alumnos que fueron creados en una fecha determinada, ordenados por comisión"
	echo "Uso del script: $0 <archivo de usuario> [fecha]"
	echo "<archivo de usuario>: directorio donde se encuentra el archivo con los usuarios de laboratorio"
	echo "[fecha](opcional): Fecha en la que se crearon los usuarios. Si no se ingresa, se informarán los alumnos creados en el dìa de hoy. Puede utilizar el formato dd/MM/yyyy o dd/MM/yy"
	exit
}


comprobarAyuda(){
	if [[ "$1" == "-help" && "$1" == "-h" && "$1" == "-?" ]]
	then 
		MostrarAyuda
	fi
}

scriptErrorParametro(){
	echo "Debe ingresar un parametro. Para mas informacion, utilice el help."
	echo "Por ejemplo"
	echo "bash ejercicio3.sh -h"
	echo "bash ejercicio3.sh -help"
	echo "bash ejercicio3.sh -?"
	exit
}

verificarFecha(){
		IFS='/' read -ra ADDR <<< "$1"

		if [[ ${#ADDR[@]} != 3 ]]; then 
			echo "Error de formato de fecha. Vea la ayuda"
			MostrarAyuda
		else
			if [[ ${ADDR[0]} =~ ^[0-9][0-9]$ ]]; then
				fecha+="${ADDR[0]}/"
			else
				echo "Error de formato de fecha. Vea la ayuda"
				MostrarAyuda
			fi
			if [[ ${ADDR[1]} =~ ^[0-9][0-9]$ && ${ADDR[1]} ]]; then
				fecha+="${ADDR[1]}/"
			else
				echo "Error de formato de fecha. Vea la ayuda"
				MostrarAyuda
			fi
			if [[ ${ADDR[2]} =~ ^[0-9][0-9]$ ]]; then
				fecha+="20${ADDR[2]}/"
			else
				if [[ ${ADDR[2]} =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
					fecha+="${ADDR[2]}"
				else
					echo "Error de formato de fecha. Vea la ayuda"
					MostrarAyuda
				fi
			fi
		fi
}


llamadoAWK(){
	echo "$(awk -F : -v fecha="$fecha" '
	BEGIN { cant = 1; alumnos[1]="" }
	$8 ~ /^[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$/ { 
			split($8,f,"/")
			split(fecha, f2, "/")
			if( f[1] == f2[1] && f[2] == f2[2] && f[3] == substr(f2[3],3) )
			{
				split($6, c, "/")
				alumnos[cant] = c[4]"|"$5"|"$1
				cant++
			}
		}
	$8 ~ /^[0-9][0-9]\-[0-9][0-9]\-[0-9][0-9][0-9][0-9]/ {
			split($8,f,"-")
			split(fecha, f2, "/")
			if( f[1] == f2[1] && f[2] == f2[2] && substr(f[3],1,4) == f2[3] )
			{
				split($6, c, "/")
				alumnos[cant] = c[4]"|"$5"|"$1
				cant++
			}
		}
	$8 ~ /^[0-9][0-9] de [0-9][0-9] de [0-9][0-9][0-9][0-9]$/ { 
			split($8,f," de ")
			split(fecha, f2, "/")
			if( f[1] == f2[1] && f[2] == f2[2] && f[3] == f2[3] )
			{
				split($6, c, "/")
				alumnos[cant] = c[4]"|"$5"|"$1
				cant++
			}
		}
	END { 
			if(cant == 1){
				print "No se encontraron Alumnos."			
			}
			else {
				command = "sort -k1"
				print "Comision|Apellido y Nombre|Usuario"; 
				for(i=1;i<cant;i++)print alumnos[i] | command
			}
		}' $1 )" | column -t -s "|" 
}

verificarArchivo(){
	if [ ! -f "$1" ]
	then 
		echo "$1 no es un archivo regular."
		exit
	fi

	if [ ! -r "$1" ]
	then 
		echo "No tengo permisos de lectura sobre $1, por favor verifique los permisos y cambielos en caso de que sea deseado ser procesado este archivo"
		exit
	fi
}

fecha=""
case $# in
	1)
		comprobarAyuda "$1"
		fecha=`date +%d/%m/%Y`
		verificarArchivo "$1"
		llamadoAWK "$1"
	;;

	2)
		verificarArchivo "$1"
		verificarFecha "$2"
		llamadoAWK "$1"
	;;

	*)
		echo "Error en la cantidad de paramentros. Por favor ejecute la ayuda. script.sh -h"
	;;
esac