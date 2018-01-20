#!/bin/bash
#
# This file is designed to monitor for a failure in pymultimonaprs and restart the process automatically
# Save this file to /root/pymultimonaprs_watchdog.sh
#
# Crontab entry
# */5 * * * * /root/pymultimonaprs_watchdog.sh >/dev/null 2>&1

/usr/sbin/service pymultimonaprs status || (
        /bin/echo 'Service pymultimonaprs failed, restarting . . .' | /usr/bin/wall
        /usr/sbin/service pymultimonaprs restart
)
