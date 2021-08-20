#!/bin/bash
# Fabian Jesus Pizarro Miranda - 19.343.935-7

if [ -z $1 ];
then
	cat /proc/cpuinfo | grep "model name" | head -1 | awk -F ":" '{print "ModelName:"$2}'
	cat /proc/version | awk -F ")" '{print"KernelVersion: " $1")" }'
	cat /proc/meminfo | grep "MemTotal"  | awk '{print "Memory (kB): "$2}'
	cat /proc/uptime | awk '{printf "Uptime(Dias): %0.3f\n",$1/60/60/24}'
fi

case $1 in
-m)
	printf '%10s %10s\n' 'TOTAL' 'AVAILABLE'
	cat /proc/meminfo | grep "MemTotal"  | awk '{printf "%10.1f",$2/1024/1024}'
	cat /proc/meminfo | grep "MemAvailable"  | awk '{printf "%10.1f\n",$2/1024/1024}'
	;;
-ps)
	printf "%15s%15s%15s%15s%15s\n" "UID" "PID" "PPID" "STATUS" "CMD"
	for PID in /proc/*; do
		PID=${PID:6}
		if [[ "$PID" =~ ^[0-9]+$ ]];
		then
			user=$(cat /proc/$PID/status | grep "Uid" | head -1 | awk '{printf "%s" ,$2}')
			cat /etc/passwd | grep ":$user:" | head -1 | awk -F ":" '{printf "%15s",$1}'
			cat /proc/$PID/status | grep "Pid" | head -1 |  awk '{printf "%15s" ,$2}'
			cat /proc/$PID/status | grep "PPid" | head -1 |  awk '{printf "%15s" ,$2}'
			cat /proc/$PID/status | grep "State" | head -1 |  awk '{printf "%15s" ,$3}'
			cat /proc/$PID/cmdline | awk '{printf "\t%s" ,$0}'
			printf "\n"
		fi
	done 2> /dev/null
	printf "\n"
	;;
-psBlocked)
	printf "%8s%30s%10s\n" "PID" "NOMBRE PROCESO" "TIPO"

	for i in FLOCK POSIX;
	do
		cat /proc/locks | grep "$i" | while read -r linea ;
		do
			PID=$(echo $linea | awk '{printf "%s" ,$5}')

			printf "%8s" $PID
			cat /proc/$PID/status | grep "Name" | head -1 | awk '{printf "%30s" ,$2}'
			echo $linea | awk '{printf "%10s" ,$2}'

			echo
		done 2> /dev/null
	done 2> /dev/null
	;;
-tcp)
	printf "%25s%25s%25s\n" "Source:Port" "Destination:Port" "Status"
	cat /proc/net/tcp | grep "$a: " | while read -r linea ;
	do
		source=$(cat /proc/net/tcp | grep "$a: " | head -1 | awk '{printf "%s" ,$2}')
		ip_part=$(echo $source | awk -F ":" '{printf "%s",$1}')
		part1=$(( 16#$(echo $ip_part | awk '{print substr($0,7,2)}') ))
		part2=$(( 16#$(echo $ip_part | awk '{print substr($0,5,2)}') ))
		part3=$(( 16#$(echo $ip_part | awk '{print substr($0,3,2)}') ))
		part4=$(( 16#$(echo $ip_part | awk '{print substr($0,1,2)}') ))
		part5=$(( 16#$(echo $source | awk -F ":" '{printf "%s",$2}') ))
		printf "%25s" $(printf "%d.%d.%d.%d:%d" $part1 $part2 $part3 $part4 $part5)

		dest=$(cat /proc/net/tcp | grep "$a: " | head -1 | awk '{printf "%s" ,$3}')
		ip_part=$(echo $dest| awk -F ":" '{printf "%s",$1}')
		part1=$(( 16#$(echo $ip_part | awk '{print substr($0,7,2)}') ))
		part2=$(( 16#$(echo $ip_part | awk '{print substr($0,5,2)}') ))
		part3=$(( 16#$(echo $ip_part | awk '{print substr($0,3,2)}') ))
		part4=$(( 16#$(echo $ip_part | awk '{print substr($0,1,2)}') ))
		part5=$(( 16#$(echo $source | awk -F ":" '{printf "%s",$2}') ))
		printf "%25s" $(printf "%d.%d.%d.%d:%d" $part1 $part2 $part3 $part4 $part5)

		case $(cat /proc/net/tcp | grep "$a: " | head -1 | awk '{printf "%s" ,$4}') in
			01) printf "%25s" TCP_ESTABLISHED;;
			02) printf "%25s" TCP_SYN_SENT;;
			03) printf "%25s" TCP_SYN_RECV;;
			04) printf "%25s" TCP_FIN_WAIT1;;
			05) printf "%25s" TCP_FIN_WAIT2;;
			06) printf "%25s" TCP_TIME_WAIT;;
			07) printf "%25s" TCP_CLOSE;;
			08) printf "%25s" TCP_CLOSE_WAIT;;
			09) printf "%25s" TCP_LAST_ACK;;
			0A) printf "%25s" TCP_LISTEN;;
			0B) printf "%25s" TCP_CLOSING;;
			0C) printf "%25s" TCP_NEW_SYN_RECV;;
			*) ;;
		esac
		echo 
		a=$(( $a+1 ))
	done
	;;
-tcpStatus)
	printf "%25s%25s%25s\n" "Source:Port" "Destination:Port" "Status"

	for i in 01 02 03 04 05 06 07 08 09 0A 0B 0C;
	do
		cat /proc/net/tcp | grep " $i " | while read -r linea ;
		do
			source=$(echo $linea | awk '{printf "%s" ,$2}')
			ip_part=$(echo $source | awk -F ":" '{printf "%s",$1}')
			part1=$(( 16#$(echo $ip_part | awk '{print substr($0,7,2)}') ))
			part2=$(( 16#$(echo $ip_part | awk '{print substr($0,5,2)}') ))
			part3=$(( 16#$(echo $ip_part | awk '{print substr($0,3,2)}') ))
			part4=$(( 16#$(echo $ip_part | awk '{print substr($0,1,2)}') ))
			part5=$(( 16#$(echo $source | awk -F ":" '{printf "%s",$2}') ))
			printf "%25s" $(printf "%d.%d.%d.%d:%d" $part1 $part2 $part3 $part4 $part5)

			dest=$(echo $linea | awk '{printf "%s" ,$3}')
			ip_part=$(echo $dest| awk -F ":" '{printf "%s",$1}')
			part1=$(( 16#$(echo $ip_part | awk '{print substr($0,7,2)}') ))
			part2=$(( 16#$(echo $ip_part | awk '{print substr($0,5,2)}') ))
			part3=$(( 16#$(echo $ip_part | awk '{print substr($0,3,2)}') ))
			part4=$(( 16#$(echo $ip_part | awk '{print substr($0,1,2)}') ))
			part5=$(( 16#$(echo $source | awk -F ":" '{printf "%s",$2}') ))
			printf "%25s" $(printf "%d.%d.%d.%d:%d" $part1 $part2 $part3 $part4 $part5)

			case $(echo $linea | awk '{printf "%s" ,$4}') in
				01) printf "%25s" TCP_ESTABLISHED;;
				02) printf "%25s" TCP_SYN_SENT;;
				03) printf "%25s" TCP_SYN_RECV;;
				04) printf "%25s" TCP_FIN_WAIT1;;
				05) printf "%25s" TCP_FIN_WAIT2;;
				06) printf "%25s" TCP_TIME_WAIT;;
				07) printf "%25s" TCP_CLOSE;;
				08) printf "%25s" TCP_CLOSE_WAIT;;
				09) printf "%25s" TCP_LAST_ACK;;
				0A) printf "%25s" TCP_LISTEN;;
				0B) printf "%25s" TCP_CLOSING;;
				0C) printf "%25s" TCP_NEW_SYN_RECV;;
				*) ;;
			esac
			echo 
		done
	done
	;;
-help)
	echo "Los argumentos disponibles para este programa son:"
	echo
	echo "sin argumento : Muestra en pantalla el procesador, version del kernel, cantidad de memoria y la cantidad de dias que ha estado encendido el dispositivo"
	echo "-ps           : Muestra para todos los procesos su UID, PID, PPID, STATUS y CMD "
	echo "-psBlocked    : Muestra los procesos que tienen archivos bloqueados"
	echo "-m            : Muestra la cantidad total de memoria ram y la cantidad de memoria ram disponible (ambas en GB)"
	echo "-tcp          : Muestra informacion de las conexiones TCP (direccion IP origen,puerto origen, direccion IP destino, puerto destino y estado de la conexion)"
	echo "-tcpStatus    : Muestra las conexiones TCP agrupadas por Status."
	echo "-help         : Muestra este mensaje"
	;;

esac

