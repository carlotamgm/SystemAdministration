#!/bin/bash
#839841, Moncasi Gosá, Carlota, M, 3, A
#843710, Soriano Sánchez, Paula, M, 3, A

# añadimos usuarios
anadirUser() {
	IFS=,
	while read user passw name
	do
		# comprobamos que ningún campo esté vacío para poder añadir el usuario
		if [ "$user" = "" -o "$passw" = "" -o "$name" = "" ]
		then
			echo "Campo invalido"
			exit 1
		fi
		useradd -c "$name" "$user" -m -k /etc/skel -U -K UID_MIN=1815 &> /dev/null
		# comprobamos si ya existe el usuario
		if [ $? -eq 0 ]
		then
			echo "$user:$passw" | chpasswd
			usermod "$user" -f 30
			echo "$name ha sido creado"
		else
			echo "El usuario $user ya existe"
		fi
	done < $1
}

# borramos usuarios
borrarUser() {
	# creamos el directorio /extra/backup
	mkdir /extra/backup &> /dev/null
	IFS=,
	while read -r user rest
	do
		# comprobamos que el primer campo leído no esté vacío
		if [ -n "$user" ]
		then
			# comprobamos cuál es el directorio home del usuario a borrar
			dirHome=$(grep "$user" /etc/passwd | cut -d: -f6)
			# realizamos el backup
			tar -cf "$user".tar "$dirHome" &> /dev/null
			if [ $? -eq 0 ]
			then
				mv "$user".tar /extra/backup
				userdel -r "$user" &> /dev/null
			fi
		fi
	done < $1
}

# PROGRAMA PRINCIPAL

# permitimos que el usuario as pueda emplear sudo sin password
echo "as ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# comprobamos que el usuario tenga privilegios de administracion
if [ $EUID -ne 0 ]
then
	echo "Este script necesita privilegios de administracion"
	exit 1
fi

# comprobamos que el numero de parámtros sea correcto
if [ $# -eq 2 ]
then
	# comprobamos que el primer parámetro sea valido
	if [ $1 = "-a" ]
	then
		anadirUser $2
	elif [ $1 = "-s" ]
	then
		borrarUser $2
	else
		echo "Opcion invalida" >&2
	fi
else
	echo "Numero incorrecto de parametros"
fi
