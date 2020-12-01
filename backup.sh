#!/bin/bash
# by Kaputt4 and Mikiped00
#

#
# Función checkMandates()
# Comprueba que estén instalados todos los mandatos necesarios para la ejecución del script
#

function checkCommands(){
	for mandate in "tree" "tar" "cat" "cut" "grep" "date" "wc"
	do
		if ! $mandate --version &> /dev/null
		then
			ERROR=2
			echo -e "\n Mandato $mandate no encontrado en el sistema. \n Ejecute sudo apt-get $mandate o actualice el sistema con sudo apt-get update && sudo apt-get upgrade"
		fi
	done
}
#
# Función copy()
# Recibe como parámetro un usuario, y se encarga de comprobar que
# exista /home y lo comprime en /tmp
#

function copy(){
	# Comprueba si el usuario tiene /home
	if test `cat /etc/passwd | cut -d: -f1,6 | grep -w -c ^$USERV:/home` -gt 0
	then
		if test `cat /etc/passwd | cut -d: -f1,7 | grep -c ^$USERV:.*/nologin` -eq 0
		then
			echo -e " \nSe va a realizar la copia del usuario $USERV"
			echo -e " \tSe van a comprimir: $(tree --noreport /home/$USERV | wc -l) ficheros y directorios"
			tar --exclude=".*" -czf /tmp/$USERV"_"$(date +%Y_%m_%d).tar.gz -C /home/ $USERV 2> /dev/null #Comprime el directorio /home
			# Comprueba si no ha dado ningún error a la hora de comprimir
			if test "${PIPESTATUS[0]}" -ne 2
			then
				((COUNT+=1))
				echo -e "\n\tEl archivo $USERV"_"$(date +%Y_%m_%d).tar.gz se ha creado correctamente con los permisos: `ls -l /tmp/$USERV"_"$(date +%Y_%m_%d).tar.gz | cut -d' ' -f1` "
			else
				# Envía error a stderr
				>&2 echo -e "\tError a la hora de comprimir los archivos."
				ERROR=1
			fi
		else
			# Envía error a stderr
			>&2 echo -e " \nEl usuario $USERV no puede ser utilizado para iniciar sesión, por lo que su directorio /home no existe"
		fi
	else
		echo -e " \nEl usuario $USERV no tiene directorio /home/$USERV"
	fi
}


# Imprime logo
echo -e "\n\n ____                _                  \n|  _ \              | |                 \n| |_) |  __ _   ___ | | __ _   _  _ __  \n|  _ <  / _\` | / __|| |/ /| | | || '_ \ \n| |_) || (_| || (__ |   < | |_| || |_) |\n|____/  \__,_| \___||_|\_\ \__,_|| .__/ \n                                 | |    \n                                 |_|    \n"
echo "Created by Kaputt4 and Mikiped00"

echo -e "\nEl usuario $USER va a realizar una copia de seguridad:"
echo -e "Fecha: `date`." 
echo -e "Versión bash: $BASH_VERSION "
ERROR=0 # Guarda valor de los errores
COUNT=0 # Cuenta archivos .tar.gz generados

# Comprueba la instalación de los mandatos necesarios y continúa si no ha habido errores
checkCommands
if test $ERROR -eq 0
then
	# Comprueba si tiene argumentos o no
	if test $# -ne 0
	then 
		re="^[a-zA-Z][-A-Za-z0-9_]*\$" # Almacena caracteres permitidos de argumentos
		# Comprueba parámetros. Si hay un argumento con sintaxis incorrecta, se aborta la ejecución
		for PARAM in $@ 
		do
			if ! [[ $PARAM =~ $re ]]
			then
				ERROR=2
			fi
		done
		if  test $ERROR -ne 2 
		then
			# Por cada argumento, se comprueba si existe y en el caso que exista, se llama la función copy() con el usuario como parámetro. Si no existe, devuelve 1, no se aborta la ejecución
			for USERV in $@
			do
				EXIST=`cat /etc/passwd | cut -d: -f1,6 | grep -w -c $USERV` 
				if test $EXIST -eq 1 ## if test -z $EXIST 
				then	
					copy $USERV					
				else
					ERROR=1
					# Envía error a stderr
					>&2 echo -e "\nEl usuario $USERV no está dado de alta en el sistema."
				fi
			done
		else
			# Envía error a stderr
			>&2 echo -e "\nHas introducido un argumento con sintaxis incorrecta."
		fi
	else
		# Busca todos los usuarios del fichero /etc/passwd
		for USERV in `cat /etc/passwd | cut -d: -f1`
		do 
			copy $USERV
		done 
	fi
fi
# Si no ha generado ningún archivo, el código de error es 2
if test $COUNT -eq 0; then ERROR=2; fi
echo -e "\nSe han creado $COUNT archivos comprimidos."
exit $ERROR
