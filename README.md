# Welcome!
This repository contains a set of convenience shell scripts to be used in conjunction with a Mitsumi module,
Broadcom 4330 WiFi+BLE chip, a Freescale i.MX280 ARM9, a Linux 3.16 Kernel, with the brcmfmac kernel driver,
and a custom user-space `wl` tool provided by Mitsumi.

The scripts will activate and turn on the test mode commands. You will need the proprietary docs from your
vendor but here is "folklore circulated" set of commands for activating packet transmission or reception for
regulatory testing.

Only use these as a reference (I slogged through this), you should definitely be double checking anything you have to do for FCC testing with your vendor.

## Broadcom 4330 Firmware note
The Broadcom 4330 is a dynamically programmed chip, you have to download firmware to it. None of the test commands in this repository will work if you are providing the production version of the 4330's binary image to the kernel driver. *You must have the manufacturer binary firmware image* to load onto the chip in order for any of the `wl` utility test-mode commands to work.

## Building `wl` for Linux ARM9
This required a combination of a custom package provided to us from our vendor and linking in the netlink 80211 library. You of course need an entire cross-compiler toolchain, you're on your own there.
