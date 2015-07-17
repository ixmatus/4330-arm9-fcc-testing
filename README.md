# Welcome!
This repository contains a convenience shell script and go program to be used in conjunction with a Mitsumi
module, Broadcom 4330 WiFi+BLE chip, a Freescale i.MX280 ARM9, a Linux 3.16 Kernel, with the brcmfmac kernel
driver, and a custom user-space `wl` tool provided by Mitsumi.

## WiFi Test Mode
The shell script `wifi-testmode.sh` will configure and activate the 4330 chip for the recommended United
States regulatory test requirements. You will need the proprietary docs from your vendor but this script is
a "folklore circulated" set of commands for activating packet transmission or reception for regulatory
testing.

Only use these as a reference (I slogged through this), you should definitely be double checking anything
you have to do for FCC testing with your vendor.

I wanted to simplify the usage significantly and here is sample output of the help message:

```
» ./wifi-testmode.sh --help
BCM4330 intentional Wi-Fi transmission testing

NOTE: the manufacturer binary image must be downloaded onto the 4330
in order for any of these commands to work! The 4330 also does not
support MIMO mode so no MIMO commands are issued in this script.

Usage of ./wifi-testmode.sh
        -h --help
        --channel=1     (1..14)
        --duration=10   (0 is continuous, >=1 is duration in seconds)
        --mode=b        (b,g,n)
        --power=69      (quarter dB values)
        --state=tx      (tx,rx)
```

## BLE Test Mode

```
BCM4330 intentional Bluetooth transmission testing

NOTE: this is using testing modulated signals which only allow even
numbered channels. Please see the README.md for notes on testing
for carrier only continuous wave.

Usage of ./bt-testmode.sh
    -h --help
    --channel=0       (0..39)
    --duration=10     (0 is continuous, >=1 is duration in seconds)
    --stop
```

~~The Golang program also in this repository will configure and activate the 4330 chip to test reception and
transmission for United States regulatory test requirements.~~ I've moved over to a shell script that issues
the HCITool commands directly instead of requiring the Golang library and stack.

### Setting up the btgatt-server and btgatt-client

This is the setup for the server side...

```
btmgmt -i hci0 power off 
btmgmt -i hci0 le on
btmgmt -i hci0 connectable on
btmgmt -i hci0 bredr off        # Disables BR/EDR !
btmgmt -i hci0 advertising on
btmgmt -i hci0 power on

btgatt-server -i hci0 -s low
```

This the setup for the client after the server is running.

`btgatt-client -i hci0 -d 00:01:A2:03:04:06 -s low -v`

### Carrier only continuous wave
Note, we did biology experiments and discovered this command: `hcitool cmd 0x3f 0x14` it turns on the radio, at a randomly selected channel.

## Broadcom 4330 Firmware note
The Broadcom 4330 is a dynamically programmed chip, you have to download firmware to it. None of the test commands in this repository will work if you are providing the production version of the 4330's binary image to the kernel driver. *You must have the manufacturer binary firmware image* to load onto the chip in order for any of the `wl` utility test-mode commands to work.

## Building `wl` for Linux ARM9
This required a combination of a custom package provided to us from our vendor and linking in the netlink 80211 library. You of course need an entire cross-compiler toolchain, you're on your own there.
