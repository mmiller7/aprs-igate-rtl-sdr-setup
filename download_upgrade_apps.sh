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
make install
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
make install



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
make install




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
