#!/bin/bash

refresh_rate=4

source $HITKIT_HOME/colours.sh

function record_version {
	echo "$1 $2" >> $version_file
}

function process_ip {
	line_no=$1
	ip=$(head -${line_no} ${open_file} |tail -1)
	echo "$ip"
	echo "$line_no" > $touch_file
}

function check_new_ip {
	lines=$(cat $open_file |wc -l)
	at=$(cat $touch_file)
	if [ "$lines" -gt "$at" ]; then
		process_ip $((${at}+1))
	fi
}

function version_scan {
	ip=$1
	#echo "scanning ip: $ip"
	cmd="proxychains nmap -sV -Pn -p${port} --open ${ip}"
	#echo "cmd=$cmd"
	result=$(${cmd})
	#echo "$result"
	open=$(echo "$result" |grep open)
	if [ -n "$open" ]; then
		version=$(echo "$open" |tr -s " " |cut -d" " -f4-)
		if [ -n "$version" ]; then
			record_version $ip "$version"
		fi
	fi
	echo "$version"
}


function check_vulns {
	version=$1
	for vuln in $(cat $HITKIT_HOME/version-vulns/$port); do
		check_vuln "$version" "$vuln" $2
	done 
}

function check_vuln {
	version=$1
	search=$2
        match=$(echo "$version" |grep "$search")
        if [ -n "$match" ]; then
                echo "$3 $version ${red}${search}${der}" >> $vuln_file
        fi
}


if [ -z "$1" ]; then
	echo "Missing parameter for $0 (port)"
	exit 1
fi


if [ -z "$2" ]; then
	echo "Missing parameter for $0 (fileprefix)"
	exit 1
fi

port=$1
fileprefix=$2
vsearch="$3"

echo "vsearch=$vsearch"

touch_file=".$fileprefix-version-touch-port-$port.txt"
open_file="$fileprefix-open-port-$port.txt"
version_file="$fileprefix-version-port-$port.txt"
vuln_file="$fileprefix-version-vuln-port-$port.txt"

touch $version_file
touch $touch_file
touch $vuln_file

if [ -f $HITKIT_HOME/version-vulns/$port ]; then
	vuln_file_exists=Y
fi

if [ -z "$(cat $touch_file)" ]; then
	echo "0" > $touch_file
fi

while :
do

	next=$(check_new_ip)
	if [ -z "$next" ]; then
		sleep $refresh_rate
	else
		version=$(version_scan $next)
		if [ -n "$vsearch" ]; then
			check_vuln "$version" "$vsearch" $next 
		elif [ -n "$vuln_file_exists" ]; then
			check_vulns "$version" $next
		fi
	fi
done
