package main

import (
	"TemplateTCP/client" //�������� �����.
	"TemplateTCP/server" //�������� �����.
	"os"
)

func main() {
	args := os.Args[1:] //0-� �������� -- ��� ���������.
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
