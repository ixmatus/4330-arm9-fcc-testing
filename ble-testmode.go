package main

import (
    "flag"
    "log"
    "time"
    "bytes"
    "os"
    "github.com/plumlife/gatt"
    "github.com/plumlife/gatt/linux/cmd"
)

var length, payload, channel uint
var duration time.Duration
var state string
var stop bool

func main(){
    // Parse CLI arguments
    flag.UintVar(&channel,      "channel",  0, "Transmission channel (1..79)")
    flag.DurationVar(&duration, "duration", (time.Second * time.Duration(10)), "Transmission duration (0 is continuous, >=1 is duration in seconds)")
    flag.StringVar(&state,      "state",    "tx", "Are we transmitting or receiving? (tx | rx)")
    flag.UintVar(&length,       "length",   0, "Length of the test data")
    flag.UintVar(&payload,      "payload",  0x00, "Packet payload")
    flag.BoolVar(&stop,         "stop",     false, "If a test was started without a duration of zero, issue this command to halt it")
    flag.Parse()
    
    log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)

    if stop {
        device, _ := gatt.NewDevice()
        StopBLETest(device, uint8(payload))
        os.Exit(0)
    }
    
    if state == "tx" {
        log.Println("Initializing BLE intentional transmission... ")
        device := StartBLETransmitterTest(duration, uint8(channel), uint8(length), uint8(payload))
        WaitAndStop(duration, device, uint8(payload))
    } else if state == "rx" {
        log.Println("Initializing BLE intentional reception...")
        device := StartBLEReceiverTest(duration, uint8(channel), uint8(payload))
        WaitAndStop(duration, device, uint8(payload))
    } else {
        log.Println("Unrecognized state")
        os.Exit(1)
    }
}

// Given a duration in seconds, sleep, then halt the test. If duration
// is zero, the test will never be halted and must be done so manually.
func WaitAndStop(duration time.Duration, device gatt.Device, payload uint8) {
    if duration > 0 {
        time.Sleep(time.Second * time.Duration(duration))
        StopBLETest(device, payload)
    } else {
        log.Println("WARNING no duration given, you must manually halt the test with: ble-testmode --stop --payload=0x00 (or whatever the original payload was)")
    }
}

// Given a duration, channel, payload length, and packet payload
// initialize a transmission test.
func StartBLETransmitterTest(duration time.Duration, channel uint8, length uint8, payload uint8) (gatt.Device) {
    log.Println("duration is ", duration, "channel is ", channel)
    
    device, _ := gatt.NewDevice()
    
    rsp := bytes.NewBuffer(nil)
    
    // Reset the chip
    reset := &cmd.Reset{}
    
    device.Option(gatt.LnxSendHCIRawCommand(reset,rsp))
    
    // Begin transmission
    c := &cmd.LETransmitterTest{TxChannel:channel, LengthOfTestData:length, PacketPayload:payload}
    
    device.Option(gatt.LnxSendHCIRawCommand(c, rsp))
    
    if rsp.Bytes()[0] != payload {
        log.Println("Response bytes (%d) not equal to %d, this is unexpected", rsp.Bytes()[0], payload)
    }
    
    return device
}

// Given a duration, a channel, and a payload (to compare against what
// was received) initialize a receiver test.
func StartBLEReceiverTest(duration time.Duration, channel uint8, payload uint8) (gatt.Device) {
    log.Println("duration is ", duration, "channel is ", channel)

    device, _ := gatt.NewDevice()
    
    // Reset the chip
    reset := &cmd.Reset{}

    rsp := bytes.NewBuffer(nil)
    
    device.Option(gatt.LnxSendHCIRawCommand(reset,rsp))
    
    // Begin receiving
    c := &cmd.LEReceiverTest{RxChannel:channel}

    device.Option(gatt.LnxSendHCIRawCommand(c, rsp))
    
    if rsp.Bytes()[0] != payload {
        log.Println("Response bytes (%d) not equal to %d, this is unexpected", rsp.Bytes()[0], payload)
    }
    
    return device
}

// Halt either a receiver or transmission test.
func StopBLETest(device gatt.Device, payload uint8){
    rsp     := bytes.NewBuffer(nil) 
    cmd_end := &cmd.LETestEnd{}
    
    device.Option(gatt.LnxSendHCIRawCommand(cmd_end,rsp))
    
    if rsp.Bytes()[0] != payload {
        log.Println("Response bytes not equal to 0x00, this is unexpected")
    }   
}
