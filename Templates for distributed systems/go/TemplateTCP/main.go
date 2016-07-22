package main

import (
	"TemplateTCP/client" //заменить пакет.
	"TemplateTCP/server" //заменить пакет.
	"os"
)

func main() {
	args := os.Args[1:] //0-й аргумент -- имя программы.
	if len(args) > 0 {
		if args[0] == "server" {
			server.Create()
		} else {
			client.Create()
		}
	} else {
		client.Create()
	}
}
