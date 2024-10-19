# INFORME PRÁCTICA 4

839841, Moncasi Gosá, Carlota, M, 3, A\
843710, Soriano Sánchez, Paula, M, 3, A

En primer lugar, se han creado dos máquinas virtuales conectadas entre sí y a la máquina host mediante una red virtual. Para ello, se han seguido los pasos del enunciado de la práctica nombrando a las dos máquinas clonadas debian-as1 y debian-as2.
Una vez definidos los adaptadores de red para cada máquina, las hemos configurado para que en el arranque se conecten a los dos interfaces que tienen conectados.
Para ello se ha modificado el fichero /etc/network/interfaces de la máquina debian-as1:
```cc
auto enp0s8
iface enp0s8 inet static
address 192.168.56.11
netmask 255.255.255.0
```

Y también el fichero `/etc/network/interfaces` de la máquina debian-as2:
auto enp0s8
iface enp0s8 inet static
address 192.168.56.12
netmask 255.255.255.0

Lo único que cambia de una máquina a otra es el campo address.

Tras modificar el fichero, se ha ejecutado el siguiente comando para aplicar los cambios realizados:
"sudo systemctl restart networking.service"
Mediante el comando "ping" se ha comprobado que se pueden comunicar ambas máquinas entre sí y con el host.
Posteriormente, se ha configurado el servidor ssh, modificando el fichero /etc/ssh/sshd_config (descomentar línea "PermitRootLogin prohibit-password" y cambiarla por "PermitRootLogin no"), para que root no se pueda conectar en remoto a las máquinas debian-as1 y debian-as2 y se ha comprobado que el servidor ssh funciona correctamente en ambas máquinas virtuales.

Con el objetivo de configurar las claves, en el host se ha empleado el comando ssh-keygen que genera un par de clave pública (se crea archivo id_rsa.pub) y privada (se crea archivo id_rsa). 
Este comando ha sido utilizado con la opción -t para especificar el tipo de encriptación (ed25519) y -f para especificar el nombre de fichero de la clave privada (.ssh/id_as_ed25519). Así se crean los ficheros id_as_ed25519 y id_as_ed25519.pub en el directorio .ssh.

Para copiar la clave pública en las máquinas, se escribe la clave en el fichero autorized_keys mediante el comando ssh-copy-id -i id_as_ed25519.pub as@192.168.56.11 (y 192.168.56.12 para la máquina debian-as2).

Por último, para conectarnos desde el host a las máquinas sin necesidad de password, se ha empleado ssh as@192.168.56.12 con la opción -i para identificar el fichero en el que se encuentra la clave privada, el cual es .ssh/id_as_ed25519 (192.168.56.12 para la máquina debian-as2).