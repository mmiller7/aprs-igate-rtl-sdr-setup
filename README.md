# aprs-igate-rtl-sdr-setup
Scripts to set up, install, and configure an APRS iGate using RTL-SDR receiver on Debian-based systems (including Ubuntu and Raspberry PI)



Start with `download_install_apps.sh` to get your system set up.  It needs to run as root (use sudo) so it can install the applications and configure kernel modules.

If you're a HAM, skip to running the configure script (requires callsign) `configure_pymultimonaprs.sh` and it will guide you thru configuring everything.  Use the `debug_pymultimonaprs.sh` to print full details and all beacons received/sent to the APRS system.  Configure a start-up script to run `pymultimonaprs` on boot if-desired.  If you think you are having issues, use the `debug_aprs_textdump.sh` and `debug_aprs_listen.sh` scripts to try simple text-dumps of APRS packets and hear the quality of the received audio.

If you're just playing around, you don't need to config script.  You can start by modifying the `debug_aprs_textdump.sh` and `debug_aprs_listen.sh` scripts to enter your PPM, frequencies, gain, etc.  If you don't know what PPM is, run the calibration script `find-ppm-kalibrate-rtl.sh` to determine the proper PPM offset for your particular RTL-SDR.  Note, by default the script is set to lock onto GSM850 base stations, this can be configured in variables in the script.



NOTE: These scripts assume you are in North America, if you are somewhere else you will need to modify variables at the top of the scripts (bands, frequencies, gateway):
find-ppm-kalibrate-rtl.sh
   BAND=850
      Valid selections are GSM850, GSM-R, GSM900, EGSM, DCS, PCS


configure_pymultimonaprs.sh
   freq=144.390
      Input the APRS frequency to monitor
   aprs_gateway=noam.aprs.net
      Valid selections are listed on http://www.aprs2.net/
