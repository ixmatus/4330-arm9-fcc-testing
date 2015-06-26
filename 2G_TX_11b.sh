channel=$1
duration=$2

# Initialize, chip must be down when we are configuring it
wllinuxarm -a wlan0 --nl80211 out
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 down
echo "Initialized..."
sleep 1


# Disable power management so we can crank up the power
wllinuxarm -a wlan0 --nl80211 mpc 0
echo "Power management is off"

# Make sure the clock is turned on
wllinuxarm -a wlan0 --nl80211 clk 1
echo "Clock is turned on"

# The txcore command was copied from docs might want to uncomment it
# wllinuxarm -a wlan0 --nl80211 txcore -s 1 -c 0x07
wllinuxarm -a wlan0 --nl80211 band b
wllinuxarm -a wlan0 --nl80211 country ALL
echo "Band is set to 'b' and country set to 'ALL'"

# This command is recommended but not in the docs provided to me
wllinuxarm -a wlan0 --nl80211 mimo_ss_stf 0

wllinuxarm -a wlan0 --nl80211 bi 65535
echo "Setting the beacon interval to 65535 milliseconds"

wllinuxarm -a wlan0 --nl80211 rateset 1b
echo "Setting rate to 1Mbps"

# This command is recommended but not in the docs provided to me and
# when I use it it returns the following:
# # wllinuxarm -a wlan0 --nl80211 mimo_bw_cap 1
# [ 1036.838444] brcmfmac: brcmf_fil_cmd_data: failed at line 52
# [ 1036.844300] brcmfmac: brcmf_fil_cmd_data: Failed err=-23
# wllinuxarm: Unsupported


# This command is recommended but not in the docs provided to me
wllinuxarm -a wlan0 --nl80211 mimo_txbw 2
wllinuxarm -a wlan0 --nl80211 chanspec -c $channel -b 2 -w 20 -s 0
echo "Selecting channel ${channel}"

# Recommended commad but not in the docs provided to me
wllinuxarm -a wlan0 --nl80211 ampdu 1
sleep 1

# Bring up it up
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 frameburst 1
echo "Turning frameburst on"

wllinuxarm -a wlan0 --nl80211 nrate -r 1 -s 0
echo "Setting legacy modulation to cck and stf_mode to SISO"

wllinuxarm -a wlan0 --nl80211 down

wllinuxarm -a wlan0 --nl80211 txant 0
echo "Forcing the use of antenna 1 for transmission"

wllinuxarm -a wlan0 --nl80211 antdiv 0
echo "Forcing the use of antenna 1 for diversity protocol during signal reception"

wllinuxarm -a wlan0 --nl80211 up
###########################################
## wl txpwr1 -o -q 60
##  -q [power setting quater dB] (60=15dBm)
###########################################
wllinuxarm -a wlan0 --nl80211 phy_watchdog 0
echo "Turning off the physical watchdog"

wllinuxarm -a wlan0 --nl80211 scansuppress 1
echo "Suppressing scans"

# Recommended but not in the docs provided to me
wllinuxarm -a wlan0 --nl80211 phy_forcecal 1

# This may not be necessary but it WAS in the documentation
wllinuxarm -a wlan0 --nl80211 ssid ""
echo "Setting SSID to an empty string"

wllinuxarm -a wlan0 --nl80211 txpwr1 -o -q 69
echo "Pumping power up to 69 quarter dB"

wllinuxarm -a wlan0 --nl80211 interference 0
echo "Turning off interference mitigation"

# The MAC Address in the docs was 00:11:22:33:44:55
echo "Beginning packet transmission for a duration of $duration seconds"
wllinuxarm -a wlan0 --nl80211 pkteng_start 00:00:00:c0:ff:ee tx 100 1024 0

sleep $duration

echo "Stopping packet transmission"
wllinuxarm -a wlan0 --nl80211 pkteng_stop tx
