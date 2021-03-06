#!/bin/sh
 
CHANNEL=1
DURATION=10
MODE="b"
POWER=69
STATE="tx"
STOP=0
BGRATE=1
NRATE=0
WORST=0
 
while [ "$1" != "" ]; do
    PARAM=$(echo "${1}" | awk -F= '{print $1}')
    VALUE=$(echo "${1}" | awk -F= '{print $2}')
    case "${PARAM}" in
        -h | --help)
            echo "BCM4330 intentional Wi-Fi transmission testing"
            echo ""
            echo "NOTE: the manufacturer binary image must be downloaded onto the 4330"
            echo "in order for any of these commands to work! The 4330 also does not"
            echo "support MIMO mode so no MIMO commands are issued in this script."
            echo ""
            echo "MODE & RATE"
            echo "The mode you've selected is also largely dependent on the rate"
            echo "you select. If you select '--mode=b' but set '--bgrate=9' the"
            echo "chip will actually be in \"g mode\". However, if '--mode=n' you"
            echo "must use the '--nrate' switch."
            echo ""
            echo "WORST CASE"
            echo "Setting the worst-case switch to 1 will use the worst-case rates"
            echo "for regulatory which actually use a legacy modulation."
            echo ""
            echo "Usage of ./wifi-testmode.sh"
            echo "    -h --help"
            echo "    --channel=${CHANNEL}       (1..14)"
            echo "    --duration=${DURATION}     (0 is continuous, >=1 is duration in seconds)"
            echo "    --mode=${MODE}          (b,g,n)"
            echo "    --bgrate=${BGRATE}"
            echo "        Valid values for b: 1, 2, 5.5, and 11"
            echo "        Valid values for g: 1, 2, 5.5, 6, 9, 11, 12, 18, 24, 36, 48, and 54"
            echo "        -1 to automatically determine the best rate"
            echo "    --nrate=${NRATE}         (0..7)"
            echo "    --worst-case=${WORST}    (0,1)"
            echo "    --power=${POWER}        (quarter dB values)"
            echo "    --state=${STATE}        (tx,rx)"
            echo "    --stop=           (tx,rx)"
            exit
            ;;
        --channel)
            CHANNEL="${VALUE}"
            ;;
        --duration)
            DURATION="${VALUE}"
            ;;
        --mode)
            MODE="${VALUE}"
            ;;
        --bgrate)
            BGRATE="${VALUE}"
            ;;
        --nrate)
            NRATE="${VALUE}"
            ;;
        --worst-case)
            WORST="${VALUE}"
            ;;
        --power)
            POWER="${VALUE}"
            ;;
        --state)
            STATE="${VALUE}"
            ;;
        --stop)
            STOP="${VALUE}"
            ;;
        *)
            echo "BCM4330 intentional Wi-Fi transmission testing"
            echo ""
            echo "NOTE: the manufacturer binary image must be downloaded onto the 4330"
            echo "in order for any of these commands to work! The 4330 also does not"
            echo "support MIMO mode so no MIMO commands are issued in this script."
            echo ""
            echo "MODE & RATE"
            echo "The mode you've selected is also largely dependent on the rate"
            echo "you select. If you select '--mode=b' but set '--bgrate=9' the"
            echo "chip will actually be in \"g mode\". However, if '--mode=n' you"
            echo "must use the '--nrate' switch."
            echo ""
            echo "WORST CASE"
            echo "Setting the worst-case switch to 1 will use the worst-case rates"
            echo "for regulatory which actually use a legacy modulation."
            echo ""
            echo "Usage of ./wifi-testmode.sh"
            echo "    -h --help"
            echo "    --channel=${CHANNEL}    (1..14)"
            echo "    --duration=${DURATION} (0 is continuous, >=1 is duration in seconds)"
            echo "    --mode=${MODE}        (b,g,n)"
            echo "    --bgrate=${BGRATE}"
            echo "        Valid values for b: 1, 2, 5.5, and 11"
            echo "        Valid values for g: 1, 2, 5.5, 6, 9, 11, 12, 18, 24, 36, 48, and 54"
            echo "        -1 to automatically determine the best rate"
            echo "    --nrate=${NRATE}        (0..7)"
            echo "    --worst-case=${WORST}    (0,1)"
            echo "    --power=${POWER}      (quarter dB values)"
            echo "    --state=${STATE}  (tx,rx)"
            echo "    --stop=           (tx,rx)"
            exit 1
            ;;
    esac
    shift
done

if [ "${STOP}" = "tx" ]
then
    wllinuxarm -a wlan0 --nl80211 pkteng_stop tx
fi

if [ "${STOP}" = "rx" ]
then
    wllinuxarm -a wlan0 --nl80211 pkteng_stop rx
fi

# Initialize, chip must be down when we are configuring it
wllinuxarm -a wlan0 --nl80211 out
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 down
echo "Initializing..."
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
# wllinuxarm -a wlan0 --nl80211 mimo_ss_stf 0

wllinuxarm -a wlan0 --nl80211 bi 65535
echo "Setting the beacon interval to 65535 milliseconds"

wllinuxarm -a wlan0 --nl80211 rateset 1b
echo "Setting rate to 1Mbps"

# This command is recommended but not in the docs provided to me
# wllinuxarm -a wlan0 --nl80211 mimo_txbw 2
wllinuxarm -a wlan0 --nl80211 chanspec -c "${CHANNEL}" -b 2 -w 20 -s 0
echo "Selecting channel ${CHANNEL}"

# Recommended commad but not in the docs provided to me
wllinuxarm -a wlan0 --nl80211 ampdu 1
sleep 1

if [ "${MODE}" = "n" ]
then
    wllinuxarm -a wlan0 --nl80211 nmode 1
    echo "Turning nmode on"
fi

# Bring up it up
wllinuxarm -a wlan0 --nl80211 up
wllinuxarm -a wlan0 --nl80211 frameburst 1
echo "Turning frameburst on"

if [ "${MODE}" = "b" ]
then
    if [ "${WORST}" -eq 1 ]
    then
        wllinuxarm -a wlan0 --nl80211 nrate -r 1 -s 0
        echo "Setting legacy modulation to cck and stf_mode to SISO with a rate of 1mbps ('b' in b/g/n)"
    else
        wllinuxarm -a wlan0 --nl80211 bg_rate "${BGRATE}"
        echo "Setting bgrate to ${BGRATE}"
    fi
elif [ "${MODE}" = "g" ]
then
    if [ "${WORST}" -eq 1 ]
    then
        wllinuxarm -a wlan0 --nl80211 nrate -r 6 -s 0
        echo "Setting legacy modulation to cck and stf_mode to SISO with a rate of 6mbps ('g' in b/g/n)"
    else
        wllinuxarm -a wlan0 --nl80211 bg_rate "${BGRATE}"
        echo "Setting bgrate to ${BGRATE}"
    fi
elif [ "${MODE}" = "n" ]
then
    wllinuxarm -a wlan0 --nl80211 nrate -m "${NRATE}" -s 0
    echo "Setting mimo index to ${NRATE} and stf_mode to SISO in conjunction with nmode ON"
fi

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

wllinuxarm -a wlan0 --nl80211 txpwr1 -o -q "${POWER}"
echo "Pumping power up to ${POWER} quarter dB"

wllinuxarm -a wlan0 --nl80211 interference 0
echo "Turning off interference mitigation"

# The MAC Address in the docs was 00:11:22:33:44:55
if [ "${STATE}" = "tx" ]
then
    echo "Beginning packet transmission"
    wllinuxarm -a wlan0 --nl80211 pkteng_start 00:00:00:c0:ff:ee tx 100 1024 0
else
    echo "Beginning packet reception"
    wllinuxarm -a wlan0 --nl80211 pkteng_start 00:90:4c:c5:34:23 rx
fi

if [ "${DURATION}" -gt 0 ];
then
    echo "Waiting for ${DURATION}s"
    sleep "${DURATION}"
    
    echo "Stopping packet transmission"
    
    if [ "${STATE}" = "tx" ]
    then
        wllinuxarm -a wlan0 --nl80211 pkteng_stop tx
    else
        wllinuxarm -a wlan0 --nl80211 pkteng_stop rx
    fi
else
    echo "Continuous transmission, stop with 'wifi-testmode.sh --stop=(tx,rx)'"
fi
