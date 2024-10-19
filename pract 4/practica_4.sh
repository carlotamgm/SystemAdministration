#!/bin/bash
#839841, Moncasi Gosá, Carlota, M, 3, A
#843710, Soriano Sánchez, Paula, M, 3, A

#añadir usuario
anadirUser() {
	IFS=,
	while read user passw name
	do
		if [ "$user" = "" -o "$passw" = "" -o "$name" = "" ]
		then
			echo "Campo invalido"
			exit 1
		fi
		sudo useradd -c "$name" "$user" -m -U -k /etc/skel -K UID_MIN=1815 &> /dev/null
		if [ $? -eq 0 ]
		then
			echo "$user:$passw" | sudo chpasswd
			sudo usermod "$user" -f 30
			echo "$name ha sido creado"
		else
			echo "El usuario $user ya existe"
		fi
	done < $1
}

borrarUser() {
	sudo mkdir /extra/backup &> /dev/null
	IFS=,
	while read -r user rest
	do
		if [ -n "$user" ]
		then
			dirHome=$(grep "$user" /etc/passwd | cut -d: -f6)
			tar -cf "$user".tar "$dirHome" &> /dev/null
			if [ $? -eq 0 ]
			then
				sudo mv "$user".tar /extra/backup
				sudo userdel -r "$user" &> /dev/null
			fi
		fi
	done < $1
}

if [ $# -eq 3 ]
then
	if [ $1 = "-a" ]
	then
		while read ip
		do
			ssh -i $HOME/.ssh/id_as_ed25519 -n as@$ip
			if [ $? -eq 0 ]
			then
				anadirUser $2
				exit
			else
				echo "$ip no es accesible"
			fi
		done < $3
	elif [ $1 = "-s" ]
	then
		while read ip
		do
			ssh -i $HOME/.ssh/id_as_ed25519 -n as@$ip
			if [ $? -eq 0 ]
			then
				borrarUser $2
				exit
			else
				echo "$ip no es accesible"
			fi
		done < $3
	else
		echo "Opcion invalida" >&2
	fi
else
	echo "Numero incorrecto de parametros"
fi
