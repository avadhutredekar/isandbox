package main

import (
	"HashtableRepo/comm"
	"os"
)

func main() {

	args := os.Args[1:]
	if len(args) > 0 {
		comm.Create(args[0])
	} else {
		comm.Create("client")
	}
}
