all: deps build

deps:
	go get github.com/plumlife/gatt

build:
	go build ble-testmode.go

clean:
	rm -f ble-testmode
