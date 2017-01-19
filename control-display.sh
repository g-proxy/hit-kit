#!/bin/bash

red="$(tput setaf 1)"
green="$(tput setaf 2)"
blue="$(tput setaf 4)"
der="$(tput sgr0)"
bold="$(tput bold)"

function cursor {
	tput cup $1 $2
}

function refresh {

	cols=$(tput cols)
	rows=$(tput lines)

	clear

	title

	headers

	data

	menu
}

function data {
	r=2
	for port in $(echo "$ports" | tr "," "\n"); do
		display_row $r
		r=$(($r+1))
	done
}

function display_row {
	open_count_file="$fileprefix-open-port-$port.txt"
	open_scan_file=".$fileprefix-open-count-$port.txt"
	version_file="$fileprefix-version-port-$port.txt"
	count_open=$(cat "$open_count_file" |wc -l)
	count_scan=$(cat "$open_scan_file")
	count_ver=$(cat "$version_file" |wc -l)
	count_open=$(colour_no $count_open)
	count_scan=$(colour_no $count_scan)
	count_ver=$(colour_no $count_ver)
	text 4 $r 0 "${blue}${port}${der}"
	text 5 $r 5 "$count_scan"
	text 4 $r 11 "$count_open"
	text 7 $r 16 "$count_ver"
}

function colour_no {
	if [[ "$1" == "0" ]]; then
		echo "${red}$1${der}"
	else
		echo "${green}$1${der}"
	fi
}

function headers {
	text 4 1 0 "${bold}${blue}Port"
	text 5 1 5 "Scans"
	text 4 1 11 "Open"
	text 7 1 16 "Version${der}"
}


function title {
	text 15 0 0 "${bold}${red}Hit-Kit Control${der}"
	text 16 0 16 "by ${blue}General Proxy${der}"
}


function text {
	width=$1
	row=$2
	col=$3
	str=$4

	endcol=$((${col}+${width}))
	if [ $endcol -gt $cols ]; then
		return 1
	fi
	cursor $row $col
	echo "$str"
}

function menu {
	cursor $(($(tput lines)-2))  0 
	echo "${red}Press ${green}q${red} to quit${der}"
}

if [ -z "$1" ]; then
	echo "Missing parameter passed to $0 ($1, the ports)"
	exit 1
fi

if [ -z "$2" ]; then
	echo "Missing parameter passed to $0 ($2, the file prefix)"
	exit 1
fi

ports=$1
fileprefix=$2
clear
while :
do
	refresh
	sleep 4
done
