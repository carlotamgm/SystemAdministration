#!/bin/bash
#839841, Moncasi Gosá, Carlota, M, 3, B
#840091, Naranjo Ventura, Elizabeth Lilai, M, 3, B

if [ $# -eq 0 ]
then
	echo "faltan parámetros"
else
	param1=$1
	shift #descartamos primer parámetro
	vgextend $param1 $@
		#extender el grupo volumen añadiendo particiones
fi
