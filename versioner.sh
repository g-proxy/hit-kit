#!/bin/bash

refresh_rate=4


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
	echo "scanning ip: $ip"
	cmd="proxychains nmap -sV -p${port} --open ${ip}"
	echo "cmd=$cmd"
	result=$(${cmd})
	echo "$result"
	open=$(echo "$result" |grep open)
	if [ -z "$open" ]; then
		echo $ip "No longer open"
	else
		version=$(echo "$open" |tr -s " " |cut -d" " -f4-)
		if [ -z "$version" ]; then
			echo "No version detected"
		else
			record_version $ip "$version"
		fi
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

touch_file=".$fileprefix-version-touch-port-$port.txt"
open_file="$fileprefix-open-port-$port.txt"
version_file="$fileprefix-version-port-$port.txt"

touch $version_file
touch $touch_file

if [ -z "$(cat $touch_file)" ]; then
	echo "0" > $touch_file
fi

while :
do

	next=$(check_new_ip)
	if [ -z "$next" ]; then
		sleep $refresh_rate
	else
		version_scan $next
	fi
done
