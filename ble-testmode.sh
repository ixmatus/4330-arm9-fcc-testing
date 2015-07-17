#!/bin/sh
 
CHANNEL=0
DURATION=10
STOP=0
 
while [ "$1" != "" ]; do
    PARAM=$(echo "${1}" | awk -F= '{print $1}')
    VALUE=$(echo "${1}" | awk -F= '{print $2}')
    case "${PARAM}" in
        -h | --help)
            echo "BCM4330 intentional Bluetooth Low Energy transmission testing"
            echo ""
            echo "NOTE: this is using modulated signals which only allow even"
            echo "numbered channels. Please see the README.md for notes on testing"
            echo "for carrier only continuous wave."
            echo ""
            echo "Usage of ./bt-testmode.sh"
            echo "    -h --help"
            echo "    --channel=${CHANNEL}       (0..39)"
            echo "    --duration=${DURATION}     (0 is continuous, >=1 is duration in seconds)"
            echo "    --stop"
            exit
            ;;
        --channel)
            CHANNEL="${VALUE}"
            ;;
        --duration)
            DURATION="${VALUE}"
            ;;
        --stop)
            STOP=1
            ;;
        *)
            echo "BCM4330 intentional Bluetooth Low Energy transmission testing"
            echo ""
            echo "NOTE: this is using modulated signals which only allow even"
            echo "numbered channels. Please see the README.md for notes on testing"
            echo "for carrier only continuous wave."
            echo ""
            echo "Usage of ./bt-testmode.sh"
            echo "    -h --help"
            echo "    --channel=${CHANNEL}       (0..39)"
            echo "    --duration=${DURATION}     (0 is continuous, >=1 is duration in seconds)"
            echo "    --stop"
            exit 1
            ;;
    esac
    shift
done

if [ "${STOP}" -eq 1 ]
then
    echo "Stopping transmission manually"
    hcitool cmd 0x08 0x001f
    exit 1
fi

hciconfig hci0 reset
hciconfig hci0 noauth
hciconfig hci0 noencrypt
hciconfig hci0 noscan

# NOTE: 0x08 is the control code for issuing LE contextual commands,
# 0X3F is the contextual command for vendor specific commands. Low
# Energy is the standard set of commands the chip needs to support in
# its API.

hcitool cmd 0x08 0x001e "${CHANNEL}" 0 0

if [ "${DURATION}" -gt 0 ];
then
    echo "Waiting for ${DURATION}s"
    sleep "${DURATION}"
    
    echo "Stopping transmission"
    hcitool cmd 0x08 0x001f
    exit 1
else
    echo "Continuous transmission, stop with 'bt-testmode.sh --stop'"
    exit 1
fi
