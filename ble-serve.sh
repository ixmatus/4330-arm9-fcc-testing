killall -9 beam.smp
killall -9 wpa_supplicant
killall -9 udhcpc
killall -9 plumGATT

hciconfig hci0 reset

btmgmt -i hci0 power off 
btmgmt -i hci0 le on
btmgmt -i hci0 connectable on
btmgmt -i hci0 bredr off        # Disables BR/EDR !
btmgmt -i hci0 advertising on
btmgmt -i hci0 power on

btgatt-server -i hci0 -s low
