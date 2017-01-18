#!/bin/bash

red="$(tput setaf 1)"
green="$(tput setaf 2)"
blue="$(tput setaf 4)"
der="$(tput sgr0)"

ports="21,22,25,80"
fileprefix="hkscan"

function usage {
	echo ""
	echo "A centralised control panel for using hit-kit"
	echo ""
	echo " Usage: $0 [-h] [-p <port-list>]"
	echo ""
	echo "  -f <prefix>      File prefix to use on all scan files"
	echo "  -h               Help"
	echo "  -p <port-list>   List of ports to scan. Default is $ports"

}

function menu {
	echo ""
	echo "${red}Type ${green}q${red} to quit${der}"
	while :
	do
		read -n 1 opt
		case $opt in
			q)
				quit
				;;
		esac
	done
}


function quit {
	for pid in "${pids[@]}"; do
		echo "Killing process $pid"
		kill $pid
	done
	exit 0
}


while getopts :f:hp: opt; do
        case $opt in
		f)
			fileprefix=$OPTARG
			;;
                h)
                        usage
                        exit 0
                        ;;
		p)
			ports=$OPTARG
			;;
                \?)
                        echo "Unknown option: ${opt}, use -h for help."
                        exit 1
                        ;;
        esac

done

if [ -z "$HITKIT_HOME" ]; then
	echo "HITKIT_HOME is not set. This is required for proper functioning"
	echo "This script is being run from: $BASH_SOURCE which may or may not be the correct location"
	exit 1
fi

pids=()

echo "HITKIT_HOME=$HITKIT_HOME"
echo "fileprefix=$fileprefix"
echo "ports=$ports"
for port in $(echo "$ports" | tr "," "\n"); do
	echo "Starting portfinder for port ${port}"
	cmd="$HITKIT_HOME/portfinder.sh -q ${port} > $fileprefix-open-port-$port.txt &"
	echo " executing $cmd"
	eval "$cmd"
	pid=$!
	pids=("${pids[@]}" "$pid")
done

menu




