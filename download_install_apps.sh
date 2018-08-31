#!/bin/bash
# Created by Matthew Miller
# 12AUG2015
# Downloads, builds, and installs software to build an APRS iGate using a RTL-SDR USB SDR

RTL_BUILD_DIR=~/rtl_build

set -e

if [ "$(whoami)" != "root" ]; then
	echo "ERROR: This script be run as root!"
	exit 1
fi

# Based off of the following guide
#http://www.algissalys.com/index.php/amateur-radio/88-raspberry-pi-sdr-dongle-aprs-igate



#Install dependencies
echo '**** Installing dependencies ****'
apt-get -y install git build-essential cmake libusb-1.0-0-dev sox libtool autoconf automake libfftw3-dev qt4-qmake libpulse-dev libx11-dev python-pkg-resources bc checkinstall



#Configure blacklist
BLACKLIST_PATH=/etc/modprobe.d/blacklist.conf
if [ -a /etc/modprobe.d/raspi-blacklist.conf ]
then
    BLACKLIST_PATH=/etc/modprobe.d/raspi-blacklist.conf
fi
echo "**** Blacklisting TV tuner driver at $BLACKLIST_PATH ****"

echo 'blacklist dvb_usb_rtl28xxu
blacklist rtl_2832
blacklist rtl_2830' >> $BLACKLIST_PATH


#Create RTL-SDR directory
mkdir $RTL_BUILD_DIR

#Build new driver
echo '**** Fetching RTL-SDR driver module ****'
cd $RTL_BUILD_DIR
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr
mkdir build
cd build
echo '**** Building RTL-SDR driver module ****'
cmake .. -DINSTALL_UDEV_RULES=ON
make
echo '**** Installing RTL-SDR driver module ****'
version=`date '+%Y%m%d'`
echo "Attempting to build package rtl-sdr version $version"
checkinstall -D --pkgname rtl-sdr --pkggroup rtl-sdr --provides rtl-sdr --pkgversion $version -y && (
	echo "Installing newly built package"
	dpkg -i rtl-sdr_*.deb
) || (
	echo "Failed to build package for install, falling back to basic make-install"
	make install
)
ldconfig



#Install Kalibrate-RTL
echo '**** Fetching Kalibrate-RTL ****'
cd $RTL_BUILD_DIR
git clone https://github.com/asdil12/kalibrate-rtl.git
cd kalibrate-rtl
git checkout arm_memory
echo '**** Building Kalibrate-RTL ****'
./bootstrap
./configure
make
echo '**** Installing Kalibrate-RTL ****'
version=`src/kal -h | head -1 | awk '{ print $2 }' | sed 's/,//g;s/^v//g'`
echo "Attempting to build package multimon-ng version $version"
checkinstall -D --pkgname kalibrate-sdr --pkggroup kalibrate-sdr --provides kal --pkgversion $version -y && (
	echo "Installing newly built package"
	dpkg -i kalibrate-sdr_*.deb
) || (
	echo "Failed to build package for install, falling back to basic make-install"
	make install
)


#Install multimonNG decoder
echo '**** Fetching multimonNG decoder ****'
cd $RTL_BUILD_DIR
git clone https://github.com/EliasOenal/multimonNG.git
cd multimonNG
mkdir build
cd build
echo '**** Building multimonNG decoder ****'
qmake-qt4 ../multimon-ng.pro || qmake ../multimon-ng.pro
make
echo '**** Installing multimonNG decoder ****'
version=`./multimon-ng -h 2>&1 | head -1 | awk '{ print $2 }'`
echo "Attempting to build package multimon-ng version $version"
checkinstall -D --pkgname multimon-ng --pkggroup multimon-ng --provides multimon-ng --pkgversion $version -y && (
	echo "Installing newly built package"
	dpkg -i multimon-ng_*.deb
) || (
	echo "Failed to build package for install, falling back to basic make-install"
	make install
)


#Install APRS iGate software
echo '**** Fetching APRS iGate software ****'
cd $RTL_BUILD_DIR
git clone https://github.com/asdil12/pymultimonaprs.git
cd pymultimonaprs
echo '**** Building APRS iGate software ****'
python setup.py build
echo '**** Installing APRS iGate software ****'
python setup.py install



#Install init.d script template
echo '**** Fetching init.d script template ****'
cd $RTL_BUILD_DIR
git clone https://github.com/fhd/init-script-template.git
cd init-script-template
echo '**** Configuring pymultimonaprs init.d from template ****'
mkdir -p $RTL_BUILD_DIR/init.d
cp template $RTL_BUILD_DIR/init.d/pymultimonaprs
cd $RTL_BUILD_DIR/init.d
sed -i 's|cmd=""|cmd="/usr/local/bin/pymultimonaprs"|g' pymultimonaprs
sed -i 's/user=""/user="aprs"/g' pymultimonaprs
sed -i 's/# Provides:/# Provides: pymultimonaprs/g' pymultimonaprs
sed -i 's/# Description:       Enable service provided by daemon./# Description:       Starts pymultimonaprs APRS iGate daemon/g' pymultimonaprs
echo '**** Installing pymultimonaprs init.d ****'
cp pymultimonaprs /etc/init.d/
useradd -r -s /sbin/nologin -M aprs
echo '**** NOTE: pymultimonaprs init.d is set up but will not run'
echo '           on boot until you run configure script to enable it. ****'
# If you *REALLY* want to enable pymultimonaprs init.d before you configure
# it, just run `sudo update-rc.d pymultimonaprs defaults`.  Remember, you
# will first need to have configured the /etc/pymultimonaprs.conf first!



#Done!
echo 'Install complete!'
echo 'Please reboot and run config script . . .'
