# aprs-igate-rtl-sdr-setup
Scripts to set up, install, and configure an APRS iGate using RTL-SDR receiver on Debian-based systems (including Ubuntu and Raspberry PI)



Start with `download_install_apps.sh` to get your system set up.  It needs to run as root (use sudo) so it can install the applications and configure kernel modules.

If you're a HAM, skip to running the configure script (requires callsign) <filename TBD> and it will guide you thru configuring everything.  Use the `debug_pymultimonaprs.sh` to print full details and all beacons received/sent to the APRS system.  If you think you are having issues, use the `debug_aprs_textdump.sh` and `debug_aprs_listen.sh` scripts to try simple text-dumps of APRS packets and hear the quality of the received audio.

If you're just playing around, you don't need to config script.  You can start by modifying the `debug_aprs_textdump.sh` and `debug_aprs_listen.sh` scripts to enter your PPM, frequencies, gain, etc.  If you don't know what PPM is, run the calibration script `find-ppm-kalibrate-rtl.sh` to determine the proper PPM offset for your particular RTL-SDR.  Note, by default the script is set to lock onto GSM850 base stations, this can be configured in variables in the script.
