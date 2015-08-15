#!/bin/bash
# Created by Matthew Miller
# 13AUG2015
# Script to automatically run Kalibrate-RTL to determine PPM

# Settings to use...GSM850 is probably right for North America
# See Kalibrate-RTL documentation for valid options
BAND=GSM850
GAIN=39
OPT=$1

#If successful, the ppm integer is exported to shell variable "ppm"

echo 'Scanning . . . this may take some time . . .'
#find chanel available
resp=$(kal -s $BAND -g $GAIN $OPT | grep chan -m1)
echo "$resp"
#get numeric part
chan=$(echo $resp | awk '{print $2}')
if ! [[ "$chan" =~ '^[0-9]+$' ]] ; then
   echo "Found base station on channel $chan.  Calibrating . . ."
   #channel was 128 for me
   resp=$(kal -c $chan -g $GAIN $OPT -v | grep "average absolute error" -m1)
   echo $resp
   #get numeric part
   ppm_f=$(echo $resp | awk '{print $4}')
   #round to integer
   ppm=$(echo "($ppm_f+0.5)/1" | bc)
   echo "rounded ppm = $ppm"
   #at this point, $ppm should be the correct integer ppm value
else
   echo "ERROR: Failed to get base channel!" >&2; exit 1
   ppm=0
fi

