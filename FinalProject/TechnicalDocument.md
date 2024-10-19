TRABAJO PRÁCTICO FINAL

## Autoras: 

#### Paula Soriano Sánchez (843710)     
#### Carlota Moncasi Gosá (839841)
--------------

Para empezar creamos todas las máquinas del sistema pedido utilizando un disco multiconexión, tal y como se explicaba en el enunciado del trabajo y les cambiamos sus nombres modificando los ficheros /etc/hostname y etc/hosts donde pone as-base por sus respectivos nombres (debian1, debian2, ...) para distinguirlas mejor.

Una vez creadas, vamos a la configuración de los adaptadores de red de cada máquina y eliminamos la conexión NAT de todas ellas menos de debian1 y las configuramos de la siguiente manera:

        debian1 con 4 adaptadores: NAT, Host-only network y dos redes internas  que llamamos Red interna 1 y Red interna 2.

        debian2 con un adaptador a Red interna 1.

        debian3 con un solo adaptador a Red interna 2.

        debian4 con un solo adaptador a Red interna 2.

        debian5 con un adaptador a una red interna llamada Red interna 3.

        debian6 con dos adaptadores: Red interna 2 y Red interna 3.

A continuación establecemos IPs estáticas para todas las máquinas menos para debian3 y debian4. Para ello, ejecutamos “ip a” para conocer los interfaces de cada máquina y modificamos el fichero /etc/network/interfaces de cada una de ellas añadiendo lo siguiente:

En debian1:

        (NAT ya viene definido)
        (host-only network)
        auto enp0s8
        iface enp0s8 inet static
        address 192.168.56.2
        netmask 255.255.255.0

        (Red interna 1)
        auto enp0s9
        iface enp0s9 inet static
        address 192.168.1.1
        netmask 255.255.255.0

        (Red interna 2)
        auto enp0s10
        iface enp0s10 inet static
        address 192.168.2.1
        netmask 255.255.255.0

En debian2:

        (Red interna 1)
        auto enp0s3
        iface enp0s3 inet static
        address  192.168.1.2
        netmask 255.255.255.0

En debian3:

        (Red interna 2)
        auto enp0s3
        iface enp0s3 inet dhcp
En debian4:

        (Red interna 2)
        auto enp0s3
        iface enp0s3 inet dhcp

En debian5:

        (Red interna 3)
        auto enp0s3
        iface enp0s3 inet static
        address  192.168.3.2
        netmask 255.255.255.0

En debian6:

        (Red interna 2)
        auto enp0s3
        iface enp0s3 inet static
        address  192.168.2.2
        netmask 255.255.255.0
        gateway 192.168.2.1
        
        (Red interna 3)
        auto enp0s8
        iface enp0s8 inet static
        address  192.168.3.1
        netmask 255.255.255.0

Una vez modificado el fichero, relanzamos los servicios ejecutando “systemctl restart networking.service".

Por defecto, el forwarding está deshabilitado en Debian, por lo que hay que habilitarlo en las máquinas que actúen como router, en este caso debian1 y debian6.
Se debe permitir el paso de paquetes a través de Debian 6, así que realizamos estos pasos tanto en debian1 como en debian6: 

Descomentamos la siguiente línea del fichero

        /etc/sysctl.conf : #net.ipv4.ip_forward=1 --> net.ipv4.ip_forward=1

Ejecutamos el siguiente comando para aplicar los cambios:

        “sysctl -p”

Para comprobar la conexión de las máquinas debian1, debian2, debian5 y debian6 con sus respectivas subredes empleamos el comando “ping”.

-------------------

A continuación, hemos instalado y configurado un servidor DHCP para la “Red Interna 2” en la máquina debian1. Para ello, hemos descargado los paquetes del server DHCP actualizando con “apt update” y “apt upgrade” y ejecutando 

        “sudo apt install isc-dhcp-server" 

y, acto seguido, hemos configurado los adaptadores de red en el fichero /etc/dhcp/dhcpd.conf de la siguiente forma:

        subnet 192.168.2.0 netmask 255.255.255.0 {
                range 192.168.2.10 192.168.2.100;
                option routers 192.168.2.1;
                option broadcast-address 192.168.2.255;
        }
Después de descargar el servidor DHCP, hemos modificado el archivo /etc/default/isc-dhcp-server en debian1 para indicar qué interfaz de red se va a utilizar para DHCP. En este caso, el puerto enp0s10 (Red interna 2):

        INTERFACESv4=”enp0s10”


Una vez establecido esto, guardamos los cambios, ejecutando lo siguiente: 

        sudo systemctl restart isc-dhcp-server.service

Para configurar la máquina debian1 para actuar como router (con rutas estáticas), de forma que se pueda alcanzar la “Red interna 3” desde cualquier punto del sistema, modificamos el fichero /etc/network/interfaces de debian1 y añadimos la siguiente línea al final del fichero:

        up ip route add 192.168.3.0/24 via 192.168.2.2

Para comprobar que funciona realizamos ping a 192.168.3.1 y a 192.168.3.2 desde cualquier máquina.

En debian5 venía por defecto instalado el servidor ssh, pero si no hubiese sido ese el caso, habría que haber ejecutado 

        “sudo apt update” 
y luego ejecutar

         “sudo apt-get install openssh-server openssh-client”. 
Reiniciamos el servicio SSH para que los cambios surjan efecto ejecutando 

        “sudo systemctl restart ssh”. 
Para comprobar que funciona nos conectamos a debian5 ejecutando desde cualquier máquina: 

        “ssh 192.168.3.2”
        
Para instalar y configurar un servidor web (apache) en la máquina debian2, hemos ejecutado “sudo apt update” para posteriormente ejecutar

         “apt install apache2” 
y luego hemos identificado la dirección IP del servidor escribiendo en el fichero de configuración “/etc/apache2/apache2.conf”:
       
        “ServerName 192.168.1.2” 
        
Por último, hemos comprobado que el servidor está activo con 

        “sudo systemctl status apache2”.
----
Para configurar el firewall en debian1, hemos creado un script con todos los comandos iptables y hemos ejecutado 

        “sudo apt update” y “sudo apt install iptables-persistent” 

para que todo se ponga en funcionamiento automáticamente al rebotar las máquinas; es decir, que los servicios arranquen automáticamente, las reglas del firewall se apliquen en el arranque, las rutas estáticas ídem, etc.


# Script de firewall

Limpiamos las tablas anteriores

	sudo iptables -F
        sudo iptables -X
        sudo iptables -Z
        sudo iptables -t nat -F
        
Rechazamos todo por defecto

	sudo iptables -P INPUT DROP
        sudo iptables -P FORWARD DROP

Permite todo el tráfico intranet y todo el tráfico de salida
y los pings de la intranet pero no del host

        sudo iptables -A FORWARD -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
        sudo iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
        sudo iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
        sudo iptables -A FORWARD -i enp0s10 -p all -j ACCEPT
        sudo iptables -A INPUT -i enp0s8 -p icmp --icmp-type 0 -j DROP
        sudo iptables -A INPUT -i enp0s3 -p all -j ACCEPT
        sudo iptables -A INPUT -i enp0s9 -p all -j ACCEPT
        sudo iptables -A INPUT -i enp0s10 -p all -j ACCEPT

Permite el tráfico a debian2 y a debian5, respectivamente

	sudo iptables -A FORWARD -d 192.168.1.2 -p tcp --dport 80 -j ACCEPT
        sudo iptables -A FORWARD -d 192.168.3.2 -p tcp --dport 22 -j ACCEPT

Redirecciones al servidor web Apache de debian2 y al servidor SSH de debian5

        sudo iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 
        192.168.1.2
        sudo iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 
        192.168.3.2

Todo el tráfico hacia la extranet desde la intranet utiliza como IP origen la 
dirección pública del firewall con independencia del nodo de origen

        sudo iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to-source 192.168.56.2

Internet
        
        sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o enp0s3 -j MASQUERADE
        sudo iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o enp0s3 -j MASQUERADE
        sudo iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o enp0s3 -j MASQUERADE
Para guardar la configuración
	
        sudo sh -c  'iptables-save > /etc/iptables/rules.v4'