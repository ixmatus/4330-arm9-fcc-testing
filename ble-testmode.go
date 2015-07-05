package main

import (
    "flag"
    "log"
    "time"
    "bytes"
    "github.com/plumlife/gatt"
    "github.com/plumlife/gatt/linux/cmd"
)

var length, payload, channel uint
var duration time.Duration

func main(){
    // Parse CLI arguments
    flag.UintVar(&channel,      "channel",  0, "Transmission channel (1..79)")
    flag.DurationVar(&duration, "duration", (time.Second * time.Duration(10)), "Transmission duration (0 is continuous, >=1 is duration in seconds)")
    flag.UintVar(&length,       "length",   0, "Length of the test data")
    flag.UintVar(&payload,      "payload",  0x00, "Packet payload")
    flag.Parse()
    
    log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
    
    // If the help switch has been given, print out the help message
    log.Println("Initializing BLE intentional transmission... ")

    device := StartBLETransmitterTest(duration, uint8(channel), uint8(length), uint8(payload))

    if duration > 0 {
        time.Sleep(time.Second * time.Duration(duration))
    }
        
    StopBLETransmitterTest(device)
}

func StartBLETransmitterTest(duration time.Duration , channel uint8, length uint8, payload uint8) (gatt.Device) {
    log.Println("duration is ", duration, "channel is ", channel)
    
    device, _ := gatt.NewDevice()
    
    rsp := bytes.NewBuffer(nil)
    
    // Reset the chip
    reset := &cmd.Reset{}
    
    device.Option(gatt.LnxSendHCIRawCommand(reset,rsp))
    
    // Begin transmission
    c := &cmd.LETransmitterTest{TxChannel:channel, LengthOfTestData:length, PacketPayload:payload}
    
    device.Option(gatt.LnxSendHCIRawCommand(c, rsp))
    
    if rsp.Bytes()[0] != 0x00 {
        log.Println("Response bytes not equal to 0x00, this is unexpected")
    }
    
    return device
}

func StopBLETransmitterTest(device gatt.Device){
    rsp     := bytes.NewBuffer(nil) 
    cmd_end := &cmd.LETestEnd{}
    
    device.Option(gatt.LnxSendHCIRawCommand(cmd_end,rsp))
    
    if rsp.Bytes()[0] != 0x00 {
        log.Println("Response bytes not equal to 0x00, this is unexpected")
    }   
}
