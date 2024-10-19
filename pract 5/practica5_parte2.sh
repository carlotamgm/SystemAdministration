#!/bin/bash
#839841, Moncasi Gosá, Carlota, M, 3, B
#840091, Naranjo Ventura, Elizabeth Lilai, M, 3, B

if [ $# -ne 1 ]
then
	echo  "Faltan parámetros"
	exit 1
fi

echo "Discos duros disponibles y tamaños en bloques:"
ssh as@$1 "sudo sfdisk -s"

echo "Particiones y sus tamaños:"
ssh as@$1 "sudo sfdisk -l"

echo "Montaje de sistemas de ficheros, directorio de montaje, tamaño, espacio libre:"
ssh as@$1 "sudo df -hT -x tmpfs" # para ignorar información de tmpfs

