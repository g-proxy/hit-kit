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

	menu
}

function headers {
	text 5 1 0 "${bold}${blue}Ports${der}"
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

while :
do
	refresh
	sleep 0.5
done
