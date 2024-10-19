#!/bin/bash
#839841, Moncasi Gosá, Carlota, M, 3, B
#840091, Naranjo Ventura, Elizabeth Lilai, M, 3, B

#grupoVolumen,volumenLogico,tamaño,tipoSisFichero,dirMontaje

if [ $# -eq 5 ]
then
	dispositivo="/dev/$1/$2"

	if lsblk | grep -q "$2"
	then #volumen lógico ya existe
		lvextend -L "+$3" $dispositivo #lo extendemos
	else #volumen no existe
		lvcreate -n "$2" -L "+$3" "$1" #lo creamos
		#lo incluimos en /etc/fstab para permitir su montaje en el arranque
		echo '$dispositivo $5 $4 defaults 0 0' >> /etc/fstab
	fi

	if [ ! "$(sudo blkid -o value -s TYPE $dispositivo)" ] #no existe el sistema de ficheros
	then #creamos sistema de ficheros
		mkfs -t "$4" $dispositivo
	fi

	if [ ! -d "$5" ] #no existe el directorio de montaje
	then
		mkdir -p "$5" #creamos el directorio
	fi
	mount $dispositivo "$5" #montamos el volumen lógico en el punto de montaje

fi
