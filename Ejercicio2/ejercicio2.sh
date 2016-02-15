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
	read -a lineaParseada <<< "$1"
	nombreJugador="${lineaParseada[1]}"
	declare -i i=2
	for (( i ; i < ${#lineaParseada[@]}-1; i++ )); 
	do
		nombreJugador="$nombreJugador ${lineaParseada[$i]}"
	done
	((ultimoElemento=${#lineaParseada[@]}-1))
	goles="${lineaParseada[$i]}"
	IFS="$OIFS"
}


trabajarArchivo(){
declare -a lineaParseada
declare -A jugadoresYGoles
declare -i goles
declare -i bandera
bandera=0
IFS='_'
while read linea
do
	nombreJugador=""
	if [[ bandera -ne 0 ]]
	then
		validarFormato $linea
		if [ "${jugadoresYGoles["$nombreJugador"]}" = "" ]
		then
			jugadoresYGoles["$nombreJugador"]="0"
		fi
		((jugadoresYGoles["$nombreJugador"]+=$goles))
	else
		bandera=1
	fi
done < "$1"
declare -a arrayNumerico
declare -a arrayPalabras
i=0
	for k in "${!jugadoresYGoles[@]}"
	do
		arrayPalabras["$i"]=$k  
		((arrayNumerico["$i"]=${jugadoresYGoles["$k"]}))
		((i++))
	done
	declare -i longitud
	ordenar
	if [ "$pathSalida" = "" ]
	then
		pathSalida="JugadoresTorneo_salida.txt"
	fi
	echo "Jugador          Goles" > $pathSalida
	for((i=0;i<longitud;i++))
	do
		echo  ${arrayPalabras["$i"]} ${arrayNumerico["$i"]} >> $pathSalida
	done
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
	if [ ! -r "$1" ]
	then 
		echo "No tengo permisos de lectura sobre $1, por favor verifique los permisos y cambielos en caso de que sea deseado ser procesado este archivo"
		exit
	fi
}

verificarPermisosDeEscritura(){
if [ ! -w "$1" ]
then
	echo "No tengo permisos para escribir en $1"
	IFS="$OIFS"
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
	OIFS="$IFS"
	IFS=";"
	verificarPermisosDeEscritura `pwd`
	IFS="$OIFS"
	trabajarArchivo "$1"
	;;
3)
 	verificarPermisosDeLectura "$1"
	verificarPermisosDeEscritura "$2/"
	pathSalida=$2"/"$3
	trabajarArchivo "$1"
;;
*)
scriptErrorParametro
;;
esac