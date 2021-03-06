#!/bin/bash

#trap a control-c to cleanly exit
trap ctrl_c INT

ports="21,22,25,80"
fileprefix="hkscan"

function ctrl_c {
	echo "Trapping ctrl-c to cleanly exit"
	quit
}

function usage {
	echo ""
	echo "A centralised control panel for using hit-kit"
	echo ""
	echo " Usage: $0 [-h] [-p <port-list>]"
	echo ""
	echo "  -c               Clean run. Delete all files that match <file-prefix>*.txt"
	echo "  -f <prefix>      File prefix to use on all scan files"
	echo "  -h               Help"
	echo "  -n <workers>     Set the number of workers on each port. Default is 1"
	echo "  -p <port-list>   List of ports to scan. Default is $ports"
	echo "  -v <version>     Grep the version against the string supplied."
}

function menu {
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

function create_display {
	cmd="$HITKIT_HOME/control-display.sh "$ports" "$fileprefix" &"
	eval $cmd
	displaypid=$!
}

function create_versioner {
	cmd='$HITKIT_HOME/versioner.sh "$1" "$2" "$3" &'
	eval $cmd
	pid=$!
	pids=("${pids[@]}" "$pid")
}


function quit {
	if [ -n "$displaypid" ]; then
		kill $displaypid
		echo "Killed display process $displaypid"
	fi
	for pid in "${pids[@]}"; do
		echo "Killing process $pid"
		kill $pid
	done

	#try and clean up terminal
	reset
	
	exit 0
}

workers=1

while getopts :cf:hn:p:v: opt; do
        case $opt in
		c)
			cleanrun=Y
			;;
		f)
			fileprefix=$OPTARG
			;;
                h)
                        usage
                        exit 0
                        ;;
		n)
			workers=$OPTARG
			;;
		p)
			ports=$OPTARG
			;;
		v)
			vsearch=$OPTARG
			;;
                \?)
                        echo "Unknown option: ${opt}, use -h for help."
                        exit 1
                        ;;
        esac

done

shift "$(($OPTIND-1))"

if [ -z "$HITKIT_HOME" ]; then
	echo "HITKIT_HOME is not set. This is required for proper functioning"
	echo "This script is being run from: $BASH_SOURCE which may or may not be the correct location"
	exit 1
fi
source HITKIT_HOME/colours.sh

pids=()

if [ -n "$cleanrun" ]; then
	rm ${fileprefix}*.txt
	rm .${fileprefix}*.txt
fi

echo "HITKIT_HOME=$HITKIT_HOME"
echo "fileprefix=$fileprefix"
echo "ports=$ports"
echo "cleanrun=$cleanrun"
echo "workers=$workers"
echo "vsearch=$vsearch"
echo ""
echo "Press any key to start"
read -n 1 foo
for port in $(echo "$ports" | tr "," "\n"); do
	echo "Starting portfinder for port ${port}"
	cmd="$HITKIT_HOME/portfinder.sh -q -n .$fileprefix-open-count-$port.txt ${port} >> $fileprefix-open-port-$port.txt &"
	echo " executing $cmd"
	
	for i in $(eval echo "{1..$workers}"); do
		eval "$cmd"
		pid=$!
		pids=("${pids[@]}" "$pid")
	done
	
	create_versioner "$port" "$fileprefix" "$vsearch"
done

#echo "Initialised system. Press any key to continue"
#read -n 1 foo
create_display
menu




