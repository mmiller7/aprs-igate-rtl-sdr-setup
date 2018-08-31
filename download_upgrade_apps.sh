#!/bin/bash
# Created by Matthew Miller
# 27OCT2015
# Downloads, builds, and installs software to build an APRS iGate using a RTL-SDR USB SDR

RTL_BUILD_DIR=~/rtl_build

set -e

if [ "$(whoami)" != "root" ]; then
  echo "ERROR: This script be run as root!"
  exit 1
fi

#(Re-)Create RTL-SDR directory
mkdir $RTL_BUILD_DIR || (rm -rf $RTL_BUILD_DIR && mkdir $RTL_BUILD_DIR)



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



#Done!
echo 'Install complete!'
echo 'Remember to run config script if neccesary. . .'
