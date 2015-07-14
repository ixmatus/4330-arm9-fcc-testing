#!/bin/sh
 
CHANNEL=4
POWER=69
PACKET=200

wllinuxarm -a wlan0 --nl80211 out
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 down
wllinuxarm -a wlan0 --nl80211 mpc 0
wllinuxarm -a wlan0 --nl80211 clk 1
wllinuxarm -a wlan0 --nl80211 band b
wllinuxarm -a wlan0 --nl80211 country ALL
wllinuxarm -a wlan0 --nl80211 bi 65535
wllinuxarm -a wlan0 --nl80211 rateset 1b
wllinuxarm -a wlan0 --nl80211 chanspec -c "${CHANNEL}" -b 2 -w 20 -s 0
wllinuxarm -a wlan0 --nl80211 ampdu 1
sleep 1
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 frameburst 1
wllinuxarm -a wlan0 --nl80211 nrate -r 6 -s 0
wllinuxarm -a wlan0 --nl80211 down
wllinuxarm -a wlan0 --nl80211 txant 0
wllinuxarm -a wlan0 --nl80211 antdiv 0
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 phy_watchdog 0
wllinuxarm -a wlan0 --nl80211 scansuppress 1
wllinuxarm -a wlan0 --nl80211 phy_forcecal 1
wllinuxarm -a wlan0 --nl80211 ssid ""
wllinuxarm -a wlan0 --nl80211 txpwr1 -o -q "${POWER}"
wllinuxarm -a wlan0 --nl80211 interference 0

# This is where we have to get specific and send two packets
# consecutively with a three millisecond pause between.
#
# This sends a ${PACKET}byte packet in one frame with an inter-packet gap
# of 100 nanoseconds.
wllinuxarm -a wlan0 --nl80211 pkteng_start 00:00:00:c0:ff:ee tx 100 "${PACKET}" 1
usleep 3000
wllinuxarm -a wlan0 --nl80211 pkteng_stop tx
wllinuxarm -a wlan0 --nl80211 pkteng_start 00:00:00:c0:ff:ee tx 100 "${PACKET}" 1
wllinuxarm -a wlan0 --nl80211 pkteng_stop tx
