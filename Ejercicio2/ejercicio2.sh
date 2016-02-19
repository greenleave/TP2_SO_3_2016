	#!/bin/bash

# *******************************COMIENZA EL BLOQUE DE FUNCIONES
# ACLARACIONES ·$1 ES EL PRIMER PARAMETRO QUE SE PASA, SEA A LA FUNCION O A LA LLAMADA DEL ARCHIVO BASH
# ·LA VARIABLE ESPECIAL $# CONTIENE LA CANTIDAD DE PARAMETROS QUE SE LE PASO AL LLAMAR AL BASH
# ·Se puede poner clear para limpiar la pantalla
# -r si se puede leer... comprobar eso.
scriptErrorParametro(){

echo "$1 Para mas informacion, utilice el help."
echo "Por ejemplo"
echo "bash ejercicio2.sh -h"
echo "bash ejercicio2.sh -help"
echo "bash ejercicio2.sh -?"
}
ofrecerAyuda(){

echo "Debe pasarse como parametro el nombre del directorio de entrada y el de salida. Debe escapearse los espacios de la siguiente forma: '\ '"
echo "Para ejecutar correctamente, debe ingresar con el siguiente formato"
echo "bash script.sh [archivo de entrada] [path de salida] [nombre del archivo]"
echo ""
echo ""
echo ""
echo "Ejemplos:"
echo "bash ejercicio2.sh entrada.txt"
echo "en este caso, crea en la misma carpeta del script un archivo llamado JugadoresTorneo_salida.txt con la salida del Script"
echo ""
echo ""
echo ""
echo "bash ejercicio2.sh entrada.txt ~/Desktop salida.txt"
echo "en este caso, crea en la carpeta Desktop el archivo salida.txt con la salida del script, el separador seria el espacio dado que no se especifica ninguno"
echo ""
echo ""
echo ""
echo "bash ejercicio2.sh entrada.txt ~/Desktop salida.txt ;"
echo "en este caso, crea en la carpeta Desktop el archivo salida.txt con la salida del script, el separador seria ;"
exit 0
}

comprobarAyuda(){
if [ "$1" = "-help" -o "$1" = "--help" -o "$1" = "-?" -o "$1" = "-h" ]
then
ofrecerAyuda
fi
return
}



validarFormato(){
	#Cambio la variable ifs y lo pongo en una variable auxiliar
	OIFS="$IFS"
	IFS="$2"
	lineaParseada=(`echo "$1" | tr '.' "$2"`)
	echo $2
	echo "${lineaParseada[1]}"
	declare -i i=2
	for (( i=1 ; i < ${#lineaParseada[@]}-1; i++ )); 
	do
		nombreJugador="$nombreJugador ${lineaParseada[$i]}"
	done
	#El ultimo elemento, deberia ser goles
	((ultimoElemento=${#lineaParseada[@]}-1))
	goles=$ultimoElemento
	IFS="$OIFS"
}

# Le llega como parametro el path del archivo de entrada y el separador
trabajarArchivo(){
#Declaro un array comun
declare -a lineaParseada
#Declaro un array asociativo
declare -A jugadoresYGoles
#declaro un entero
declare -i goles
#declaro una bandera y la inicializo
declare -i bandera
bandera=0
#Cambio el IFS para que me tome la cadena completa y comienzo a leer el archivo
while read linea
do
	#Si la bandera esta en cero significa que todavia no se paso la linea del encabezado
	if [[ bandera -ne 0 ]]
	then	
		nombreJugador=""	
		#Validar el formato, hace un par de tareas iniciales
		validarFormato "$linea" "$2"
		echo "Este es el jugador: $nombreJugador"
		if [ "${jugadoresYGoles["$nombreJugador"]}" = "" ]
		then
			jugadoresYGoles["$nombreJugador"]="0"
		fi
		((jugadoresYGoles["$nombreJugador"]+=$goles))
	else
		bandera=1
	fi
done < "$1"
#Declaro array auxiliares.
declare -a arrayNumerico
declare -a arrayPalabras
i=0
#Empiezo a guardar los datos del array asociativo en array auxiliares.
	for k in "${!jugadoresYGoles[@]}"
	do
		arrayPalabras["$i"]=$k  
		((arrayNumerico["$i"]=${jugadoresYGoles["$k"]}))
		((i++))
	done
	declare -i longitud
	#Mando a ordenar el archivo
	ordenar
	if [ "$pathSalida" = "" ]
	then
		pathSalida="JugadoresTorneo_salida.txt"
	fi
	echo "Jugador                 Goles" > $pathSalida
	for((i=0;i<longitud;i++))
	do
		echo  ${arrayPalabras["$i"]} ${arrayNumerico["$i"]} >> $pathSalida
	done
}

#Hago un ordenamiento, no recibe parametros porque estan en las variables globales
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
verificarSiExisteArchivo(){
	if [ ! -f "$1" -a ! -d "$1"]
	then
		echo "No tengo permisos para escribir en $1"
			IFS="$OIFS"
		exit
	fi
	if [ ! -d "$1" ]
	then 
		echo "El archivo pasado es un directorio"
	fi
}

# *******************************FINALIZA EL BLOQUE DE FUNCIONES
# *******************************COMIENZA EL BLOQUE DEL PROGRAMA
#PREGUNTO SI SE PASO MINIMAMENTE UN PARAMETRO
case $# in
0)
	scriptErrorParametro "Por lo menos se le debe pasar un parametro al script para mas informacion consulte el help"
	exit
;;
1)

	comprobarAyuda "$1"
	verificarSiEsArchivoRegular "$1"
	verificarPermisosDeLectura "$1"
	OIFS="$IFS"
	IFS=";"
	verificarPermisosDeEscritura `pwd`
	IFS="$OIFS"
	trabajarArchivo "$1" " "
	;;
2)
	scriptErrorParametro "Por lo menos se le debe pasar un parametro más al script para más informacion consulte el help ejercicio2.sh -h --help o -?"
	exit
;;
3)
 	verificarPermisosDeLectura "$1"
	verificarPermisosDeEscritura "$2/"
	pathSalida="$2/$3"
	trabajarArchivo "$1" " "
;;

4)
	"Entra en el de 4 parametros"
	verificarPermisosDeLectura "$1"
	verificarPermisosDeEscritura "$2/"
	pathSalida="$2/$3"
	echo "$4"
	trabajarArchivo "$1" "$4"
;;
*)
scriptErrorParametro "Se han pasado mas de cuatro parametros"
;;
esac