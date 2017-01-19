# hit-kit

Hit-Kit is a set of tools to provide random internet wide target selection for further
detailed examination.

The tool set can be started from control.sh

It is designed to be a slow long running scanner that filters out ports and services of
interest to provide some low hanging fruit.

Typical usage:
	control.sh -c -f myrun -p21,22,80,139,445,3306 

Runs a clean run, across the ports above, and saves results in files beginning with "myrun"
This display will show the number of scans and successes as it progresses.

This was all built to work on Kali (2016.2) so any debian system should be ok. Do set up 
proxychains though (it's for your own good).

Enjoy,

Gen. Proxy
