# Initialize, chip must be down when we are configuring it
wllinuxarm -a wlan0 --nl80211 out
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 down
sleep 1

# This may not be necessary but it WAS in the documentation
wllinuxarm -a wlan0 --nl80211 frameburst 1
wllinuxarm -a wlan0 --nl80211 ampdu 1
wllinuxarm -a wlan0 --nl80211 ssid ""

# Disable power management so we can crank up the power
wllinuxarm -a wlan0 --nl80211 mpc 0

# Make sure the clock is turned on
wllinuxarm -a wlan0 --nl80211 clk 1

# The txcore command was copied from docs might want to uncomment it
# wllinuxarm -a wlan0 --nl80211 txcore -s 1 -c 0x07

wllinuxarm -a wlan0 --nl80211 band a
wllinuxarm -a wlan0 --nl80211 country ALL

sleep 1

# Bring it up
wllinuxarm -a wlan0 --nl80211 up

wllinuxarm -a wlan0 --nl80211 chanspec -c 1 -b 2 -w 20 -s 0

wllinuxarm -a wlan0 --nl80211 nrate -m 0
wllinuxarm -a wlan0 --nl80211 phy_watchdog 0

# Disassoc was added by me from docs - I believe it's related to the
# zeroing out of the SSID up above
wllinuxarm -a wlan0 --nl80211 disassoc
wllinuxarm -a wlan0 --nl80211 scansuppress 1
wllinuxarm -a wlan0 --nl80211 phy_forcecal 1

# The MAC Address in the docs was 00:11:22:33:44:55
wllinuxarm -a wlan0 --nl80211 pkteng_start 00:90:4c:c5:34:23 rx
