all: deps build

deps:
	GOPATH=`pwd` go get github.com/plumlife/gatt

build:
	GOPATH=`pwd` go build ble-testmode.go

clean:
	rm -f ble-testmode
