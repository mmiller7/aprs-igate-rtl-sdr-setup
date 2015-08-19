#!/bin/bash
# Created by Matthew Miller
# 14AUG2015
# Script to assist in configuring pymultimonaprs APRS iGate software
# Required data includes ppm, gain, callsign, aprsKey, lat, lon

RTL_BUILD_DIR=~/rtl_build
CONFIG_FILE="/etc/pymultimonaprs.json"
freq=144.39
default_gain=39
aprs_gateway="noam.aprs2.net"
aprs_gateway_port=14580
status_text="RTL-SDR on $(uname -m) $(uname -s) built with http://git.io/v3QXq configuration"

set -e

if [ "$(whoami)" != "root" ]; then
	echo "ERROR: This script be run as root!"
	exit 1
fi

echo ''

#get PPM value
read -p 'Do you know your RTL-SDR PPM calibration value? [y/N] ' userKnowsPPM
userKnowsPPM="${userKnowsPPM:=n}"
if [ "$userKnowsPPM" == "y" ] || [ "$userKnowsPPM" == "Y" ]
then
   read -p 'Please enter PPM value: ' ppm
   ppm="${ppm:=0}"
else
   echo 'In order to properly operate, you need to calibrate your'
   echo 'RTL-SDR so that it centers properly on specified frequencies.'
   echo 'This is done by entering an offset called a PPM.  It can be'
   echo 'performed automatically with the Kalibrate-RTL application.'
   echo 'which scans for GSM base stations and uses the sync-calibrate'
   echo 'signal from the base station to compute the correct PPM for'
   echo 'this specific RTL-SDR dongle.  This process can take several'
   echo 'minutes, to an hour depending on GSM signal strength and the'
   echo 'ambient temperature, how long the RTL-SDR has been plugged in'
   echo 'to reach operating temperature, etc.'
   echo ''
   read -p 'Do you want to begin the automatic PPM calibration now? [Y/n] ' doCalPPM
   doCalPPM="${doCalPPM:=y}"
   if [ "$doCalPPM" == "y" ] || [ "$doCalPPM" == "Y" ]
   then
      #Source the script so we will get the $ppm variable
      source ./find-ppm-kalibrate-rtl.sh
      echo "Config script has determined your PPM is $ppm for this RTL-SDR."
   else
      ppm=0
      echo 'Skipping PPM calibration, assuming 0 PPM correction.'
   fi
fi
echo ''



#get gain
read -p "Specify RTL-SDR gain in integer-format: (optional) [$default_gain] " gain
gain="${gain:=$default_gain}"
echo ''



#get callsign
read -p 'Enter your Amateur Radio license callsign: ' callsign
callsign="${callsign:=invalid}"
if [ "$callsign" == "invalid" ]
then
   echo 'ERROR: You did not specify a callsign!'
   exit 1
fi
callsign=${callsign^^}

#get aprsKey
read -p 'Do you have an APRS-IS key? (if unsure put "n") [y/N] ' userHasAprsKey
userHasAprsKey="${userHasAprsKey:=n}"
if [ "$userHasAprsKey" == "y" ] || [ "$userHasAprsKey" == "Y" ]
then
   aprsKey=0
   read -p 'Enter APRS-IS key: ' aprsKey
   aprsKey="${aprsKey:=0}"
else
   keygenResult=$(rtl_build/pymultimonaprs/keygen.py $callsign)
   echo "keygen.py - $keygenResult"
   aprsKey=$(echo $keygenResult | awk '{print $4}')
fi
echo ''



#callsign suffix
echo 'You should put a suffix for your iGate to differentiate it.'
echo 'This is a number which appears after your callsign on the'
echo "aprs.fi website.  For example, $callsign-1"
read -p "Input numeric suffix: ${callsign}-" callSuffix
callsign="${callsign}-$callSuffix"
callSuffix="${callSuffix:=1}"
echo ''



#get lat
echo 'Please sepcify latitude in decimal-degrees with negative'
echo 'value for "South" direction and 5 places past the decimal.'
echo 'Examples: 38.1  North -->  38.10000'
echo '          10.42 South --> -10.42000'
read -p 'Enter latitude: ' lat
lat="${lat:=0.00000}"
echo ''

#get lon
echo 'Please sepcify longitude in decimal-degrees with negative'
echo 'value for "West" direction and 5 places past the decimal.'
echo 'Examples: 10.1  East -->  10.10000'
echo '          77.42 West --> -77.42000'
read -p 'Enter longitude: ' lon
lon="${lon:=0.00000}"
echo ''



#enable init.d
read -p 'Enable init.d for pymultimonaprs iGate to run on boot? [Y/n] ' enable_init_d
enable_init_d="${enable_init_d:=y}"
echo ''



#print summary
echo 'The following settings have been configured:'
echo "RTL-SDR PPM  : $ppm"
echo "RTL-SDR Gain : $gain"
echo "iGate Call   : $callsign"
echo "APRS-IS Key  : $aprsKey"
echo "Latitude     : $lat"
echo "Longitude    : $lon"
echo "Boot script? : $enable_init_d"
echo ''



#apply configuration
echo 'Applying settings to /etc/pymultimonaprs.conf'
sed -i "s/\"callsign\": [^,]*,/\"callsign\": \"$callsign\",/g" $CONFIG_FILE
sed -i "s/\"passcode\": [^,]*,/\"passcode\": \"$aprsKey\",/g" $CONFIG_FILE
sed -i "s/\"gateway\": [^,]*,/\"gateway\": \"$aprs_gateway:$aprs_gateway_port\",/g" $CONFIG_FILE
sed -i "s/\"freq\": [^,]*,/\"freq\": $freq,/g" $CONFIG_FILE
sed -i "s/\"ppm\": [^,]*,/\"ppm\": $ppm,/g" $CONFIG_FILE
sed -i "s/\"gain\": [^,]*,/\"gain\": $gain,/g" $CONFIG_FILE
sed -i "s/\"lat\": [^,]*,/\"lat\": $lat,/g" $CONFIG_FILE
sed -i "s/\"lng\": [^,]*,/\"lng\": $lon,/g" $CONFIG_FILE
sed -i "s|\"text\": [^,]*,|\"text\": \"$status_text\",|g" $CONFIG_FILE

#apply start-up scripts
if [ "$enable_init_d" == "y" ] || [ "$enable_init_d" == "Y" ]
then
   echo 'Setting rc.d pymultimonaprs defaults'
   echo '********************************************************************'
   echo '* It is recommended you try `debug_pymultimonaprs.sh` and verify   *'
   echo '* packets are being received. If everything appears to be working, *'
   echo '* you can then run `sudo service pymultimonaprs start` or wait     *'
   echo '* until your next reboot to kick off the background service.       *'
   echo '********************************************************************'
   update-rc.d pymultimonaprs defaults
else
   echo 'Removing pymultimonaprs from rc.d'
   update-rc.d -f pymultimonaprs remove
   echo '********************************************************************'
   echo '* It is recommended you try `debug_pymultimonaprs.sh` and verify   *'
   echo '* packets are being received. Start-up is DISABLED, you will need  *'
   echo '* to MANUALLY run `sudo service pymultimonaprs start` EVERY TIME   *'
   echo '* you want to load the APRS iGate service.                         *'
   echo '********************************************************************'
fi



echo 'Done!'
