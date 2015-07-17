import time

output = "notify 0x0001 00 23 00"

for i in range(0,5000):
    keyboard.send_keys(output)
    keyboard.send_keys("<enter>")
    time.sleep(0.010)
