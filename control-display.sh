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
	open_scan_file="$fileprefix-open-count-$port.txt"
	count_open=$(cat "$open_count_file" |wc -l)
	count_scan=$(cat "$open_scan_file")
	text 4 $r 0 "${blue}${port}${der}"
	text 5 $r 5 "$count_scan"
	text 4 $r 11 "$count_open"
}

function headers {
	text 4 1 0 "${bold}${blue}Port${der}"
	text 5 1 5 "${bold}${blue}Scans${der}"
	text 4 1 11 "${bold}${blue}Open${der}"
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

while :
do
	refresh
	sleep 1
done
