# Welcome!
This repository contains a convenience shell script and go program to be used in conjunction with a Mitsumi
module, Broadcom 4330 WiFi+BLE chip, a Freescale i.MX280 ARM9, a Linux 3.16 Kernel, with the brcmfmac kernel
driver, and a custom user-space `wl` tool provided by Mitsumi.

# FCC Certification

When certifying for FCC, be sure to pick a local lab that is friendly because you're going to need a lot of
help deciphering what it is the FCC wants you to demonstrate.

The first set of tests will be WiFi and you must be able to turn the radio on at full power, continuously, and select any channel at will. If you are supporting b/g/n the technician will want to do a series of tests for intentional transmission using the different modes (all modes are in the "b" band). For the 4330 you want to enable legacy modulation, which is "worst case", and for n-mode you just need to demonstrate different data rates.

A sticky portion of the WiFi tests, for us, was our third harmonic being over the allowed limit. Because
these tests are done with the radio at full-power we are allowed to calculate our duty cycle (how big is the
most common packet and how frequently do you transmit it) in order to prove that we qualify for a "discount"
to bring that third harmonic under the average.

Bluetooth is another beast and as of the time of this writing (07/17/2015) we were unable to demonstrate
intentional transmission, at full-power, for selected channels. Broadcom has no tools, nor documentation for
the HCI hex commands, to perform these tests in a Linux ARM9 environment for Bluetooth Classic.

What Plum was capable of passing was Bluetooth Low Energy. The test commands for intentional transmission on
a selected channel within the 40 channels for BLE worked well (they are what compose the ble shell scripts
in this repository). This worked out well for Plum because our product only uses BLE and we turn off
Bluetooth Classic.

One hurdle for Plum: we needed to demonstrate the Adaptive Frequency Hopping mechanism of the chip. I originally solved this by using `SDP` and `rfcomm` to setup a pipe between two devices then `cat` a file or something big over the pipe, which worked but it demonstrated it for Bluetooth Classic. To demonstrate AFH for Low Energy I had to get creative and cross-compile the `btgatt-server` and `btgatt-client` from the `bluez` linux package.

I put the server on one device and the client on the other, started them both up, then used `autokey` for
Ubuntu to write a `notify ...` message to the interactive GATT server prompt on the device running
`btgatt-server`. That autokey script is in this repository. This solution successfully demonstrated the AFH.

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

### Broadcom 4330 Firmware note
The Broadcom 4330 is a dynamically programmed chip, you have to download firmware to it. Disabling of the
automatic power management will not work (but required to work for FCC) if you are providing the production
version of the 4330's binary image to the brcmfmac kernel driver. *You must have the manufacturer binary
firmware image* to load onto the chip in order for the `wl` utility power management commands to work.

### Building `wl` for Linux ARM9
This required a combination of a custom package provided to us from our vendor and linking in the netlink 80211 library. You of course need an entire cross-compiler toolchain, you're on your own there.

## BLE Test Mode

```
BCM4330 intentional Bluetooth transmission testing

NOTE: this is using testing modulated signals which only allow even
numbered channels. Please see the README.md for notes on testing
for carrier only continuous wave.

Usage of ./ble-testmode.sh
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

Issuing a `notify 0x0001 00 23 00` at the prompt of the GATT server should show up on the client.

The setup for the client after the server is running.

`btgatt-client -i hci0 -d 00:01:A2:03:04:06 -s low -v`

### Carrier only continuous wave
Note, we did biology experiments and discovered this command: `hcitool cmd 0x3f 0x14` it turns on the radio,
at a randomly selected channel for *Bluetooth Classic only*, it may be of interest to someone.
