#!/bin/bash
# Created by Matthew Miller
# 12AUG2015
# Plays live audio of APRS frequency detected for debugging

# Adjust parameters for debugging
GAIN=39
PPM=43
FREQ=144.390


rtl_fm -f ${FREQ}M -p $PPM -s 22050 -g $GAIN - | play -r 24k -t raw -e s -b 16 -c 1 -V1  -
