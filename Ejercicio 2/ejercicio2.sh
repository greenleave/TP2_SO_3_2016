#!/bin/bash

# *******************************COMIENZA EL BLOQUE DE FUNCIONES
# ACLARACIONES ·$1 ES EL PRIMER PARAMETRO QUE SE PASA, SEA A LA FUNCION O A LA LLAMADA DEL ARCHIVO BASH
# ·LA VARIABLE ESPECIAL $# CONTIENE LA CANTIDAD DE PARAMETROS QUE SE LE PASO AL LLAMAR AL BASH
# ·Se puede poner clear para limpiar la pantalla
# -r si se puede leer... comprobar eso.
scriptErrorParametro(){

echo "Debe ingresar aunque sea un parametro. Para mas informacion, utilice el help."
echo "Por ejemplo"
echo "bash ejercicio2.sh -h"
echo "bash ejercicio2.sh -help"
echo "bash ejercicio2.sh -?"
}
ofrecerAyuda(){

echo "Debe pasarse como parametro el nombre del directorio de entrada y el de salida. Debe escapearse los espacios de la siguiente forma: '\ '"
echo "Para ejecutar correctamente, debe ingresar con el siguiente formato"
echo "bash script.sh [archivo de entrada] [-i o -ni]"
echo ""
echo ""
echo ""
echo "Ejemplos:"
echo "bash ejercicio2.sh archivito.txt -i"
echo "en este caso, se ignora si es mayuscula o minuscula"
echo ""
echo ""
echo ""
echo "bash ejercicio2.sh archivito.txt -ni"
echo "en este caso, no ignora si es mayuscula o minuscula. Por defecto no se ignoran si son mayusculas o minusculas"
exit 0
}

comprobarAyuda(){
if [ "$1" = "-help" -o "$1" = "-?" -o "$1" = "-h" ]
then
ofrecerAyuda
fi
return
}


validarFormato(){
	OIFS='$IFS'
	IFS=' '
	nombreJugador=""
	read -a lineaParseada <<< "{$1}"
	echo "${#lineaParseada[@]}"
	for (( i = 1; i < "${#lineaParseada[@]}"-1; i++ )); 
	do
		nombreJugador="$nombreJugador ${lineaParseada[$i]}"
	done
	echo "Esto era un ejemplo"
	echo $nombreJugador
	IFS="$OIFS"
}


trabajarArchivo(){

#Declaro un array asociativo
declare -a lineaParseada
declare -A jugadoresYGoles
nombreJugador
IFS="°"
while read linea
do
	echo $linea
	validarFormato $linea
#	if [ "${array[$linea]}" = "" ]
#	then
#	array["$linea"]="0"
#	fi
#	((array["$linea"]=${array[$linea]}+1))
done < "$1"
}

ordenar(){
	declare -i posMax
	longitud=${#arrayNumerico[@]}
	auxiliarNumero=0
	auxiliarPalabra=""
	for((i=0;i<longitud;i++))
	do
		posMax=$i
		for((j=i;j<longitud;j++))
		do
			if [ ${arrayNumerico[$j]} -gt ${arrayNumerico[$posMax]} ]
			then
				posMax=$j
			fi
			if [ ${arrayNumerico[$j]} -eq ${arrayNumerico[$posMax]} ]
			then
				if [ "${arrayPalabras[$j]}" \< "${arrayPalabras[$posMax]}" ]
				then
					posMax=$j
				fi
			fi
		done
		auxiliarNumero=${arrayNumerico["$i"]}
		auxiliarPalabra=${arrayPalabras["$i"]}
		arrayNumerico["$i"]=${arrayNumerico["$posMax"]}
		arrayPalabras["$i"]=${arrayPalabras["$posMax"]}
		arrayNumerico["$posMax"]=$auxiliarNumero
		arrayPalabras["$posMax"]=$auxiliarPalabra
	done
}
verificarPermisosDeLectura(){
	if [ ! -r $1 ]
	then 
	echo "$1 no tiene permisos de lectura, por favor verifique los permisos y cambielos en caso de que sea deseado ser procesado ese archivo"
	exit
	fi
}

# *******************************FINALIZA EL BLOQUE DE FUNCIONES
# *******************************COMIENZA EL BLOQUE DEL PROGRAMA
#PREGUNTO SI SE PASO MINIMAMENTE UN PARAMETRO
case $# in
1)
	comprobarAyuda "$1"
	verificarPermisosDeLectura "$1"
	trabajarArchivo "$1"
	;;
2)
	case "$2" in
	"-i") 	verificarPermisosDeLectura "$1"
			verificarPermisosDeLectura "$2"
			pathSalida=$2
			trabajarArchivo "$1"
	;;
*)
	mensajeError "Error en el segundo parametro utilice el help [-h]"
	;;
esac
;;
*)
scriptErrorParametro
;;
esac