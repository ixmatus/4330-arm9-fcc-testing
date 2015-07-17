# NOTE: btgatt-client is part of the bluez package and needs to be
# cross-compiled for the ARM9

killall -9 beam.smp
killall -9 wpa_supplicant
killall -9 udhcpc
killall -9 plumGATT

hciconfig hci0 reset

btgatt-client -i hci0 -d 00:01:A2:03:04:06 -s low -v
