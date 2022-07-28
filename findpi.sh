#!/bin/bash

#nmap -Pn -p22 --open 10.10.10.100-254
#nmap -Pn -p T:22,8080,1997 --open 10.10.10.150-155
#nmap -Pn -p T:22,8080,1997 --open 10.10.10.100-130
#nmap -Pn -p8080 --open 10.10.10.150-155
#nmap -Pn -p1997 --open 10.10.10.100-130
#nmap -Pn -p1997 --open 10.10.10.150-155

_find()
{
for i in $(seq $1 $2); do
    OUT=$(echo "" | netcat -w1 $3.$i 22 2>&1)
    echo -n "."
    if [[ $? -eq 0 ]] && [[ $OUT == *"Rasp"* ]]
    then
	netcat -z -w1 $3.$i 1997 > /dev/null
	if [ $? -eq 0 ]
	then  
	    MSG="\ncam: $3.$i" 
	    HWI=$(wget -qO- $3.$i:1997/hwinfo)
	    SWI=$(wget -qO- $3.$i:1997/version)
		
		if [ -n "$SWI" ] && [ "$SWI" != "\n" ]; then
		    MSG="$MSG $SWI"
	        fi
	    if [ -n "$HWI" ] && [ "$HWI" != "\n" ]; then
	    	MSG="$MSG $HWI"
	    fi
   	    echo -ne "$MSG"
	else
	    netcat -z -w1 $3.$i 8080 > /dev/null
	    if [ $? -eq 0 ] 
	    then	    
		MSG="\nins: $3.$i" 
		HWI=$(wget -qO- $3.$i:8080/hwinfo)
		SWI=$(wget -qO- $3.$i:8080/version)
		
		if [ -n "$SWI" ] && [ "$SWI" != "\n" ]; then
		    MSG="$MSG $SWI"
	        fi
	    	if [ -n "$HWI" ] && [ "$HWI" != "\n" ]; then
		    MSG="$MSG $HWI"
	        fi
	        echo -ne "$MSG"
	    else
		echo -ne "\npi: $3.$i"
	    fi
	fi
    fi
done
}

#
if [ -z "$1" ]
then
	IP="10.10.10"
else
	IP="$1"	
fi 

echo -n "searching $IP.."
_find 150 155 $IP
_find 100 130 $IP
_find 131 149 $IP
_find 156 254 $IP
_find 2 99 $IP
echo -e "\ndone"


