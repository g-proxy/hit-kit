#!/bin/bash

if [ -z "$1" ]; then
	usage
	exit 1
fi


function usage {
	echo "Scans random IP addresses for the specified open port"
	echo ""
	echo " Usage: $0 [-q|h] <port>"
	echo ""
	echo "  -h         Help"
        echo "  -n <file>  Write numer of scans to file"
	echo "  -q         Quiet mode. Just reports found IPs"

}


function random_ip {
        if [[ "$1" == "ALL" ]]; then
                nout=$(nmap -n -iR 1 --exclude 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,224-255.-.-.- -sL)
	else
		nout="x x report for $1"
        fi
        ip=$(echo "${nout}" |grep "report for"| cut -d" " -f5)
        echo "${ip}"
}

function log {
	if [ -z "$quiet" ]; then
        	echo "${info_box} $1"
	fi
}

function warn {
        echo "${warning_box} $1"
}

function found {
	if [ -z "$quiet" ]; then
        	echo "${found_box} ${blue}$1${der}"
	else
		echo "$1"
	fi
}

red="$(tput setaf 1)"
green="$(tput setaf 2)"
blue="$(tput setaf 4)"
der="$(tput sgr0)"
info_box="[${green}*${der}]"
warning_box="[${red}*${der}]"
found_box="[${blue}*${der}]"

while getopts :hn:q opt; do
	case $opt in
		q)
			quiet=Y
			;;
		h)
			usage
			exit 0
			;;
		n)
			count_file=$OPTARG
			;;
		\?)
			echo "Unknown option: ${opt}, use -h for help."
			exit 1
			;;
	esac

done
shift "$((OPTIND-1))"

if [ -z "$quiet" ]; then
	echo "${green}Welcome to ${red}PortFinder${green} by ${blue}General Proxy${der}"
fi


port=$1

count=0;

while :
do
        if [ -n "$count_file" ]; then
                echo "$count" > $count_file
        fi

	ip=$(random_ip ALL)
	log "Scanning $ip"
	cmd="proxychains nmap -sT -Pn -p${port} $ip --open"
	log "Using command: $cmd"
	scan=$(${cmd})
	log "Scan: $scan"
	open=$(echo "$scan" |grep open)
	if [ -n "$open" ]; then
		log "Port open"
		tcpwrap=$(echo "$open" |grep -v tcpwrapped)
		if [ -n "$tcpwrap" ]; then
			found $ip
		else
			log "Port is tcpwrapped"
		fi
	else
		log "Port closed"
	fi
	count=$(($count+1))
done
