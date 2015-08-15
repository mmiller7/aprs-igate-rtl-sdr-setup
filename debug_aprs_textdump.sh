#!/bin/bash
# Created by Matthew Miller
# 12AUG2015
# Dumps console text output of APRS packets detected for debugging

# Adjust parameters for debugging
GAIN=39
PPM=43
FREQ=144.390


rtl_fm -f ${FREQ}M -p $PPM -s 22050 -g $GAIN - | multimon-ng -a AFSK1200 -A -t raw -
