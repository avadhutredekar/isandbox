package client

import (
	"bytes"
	"fmt"
	"github.com/divan/gorilla-xmlrpc/xml"
	"log"
	"net/http"
)


func Create() {
	log.Println("Start client")

	var num1, num2 int
	fmt.Print("Enter the first number >: ")
	fmt.Scan(&num1)
	fmt.Print("Enter the second number >: ")
	fmt.Scan(&num2)
	
	//log.Println("Input number #1:", num1)
	//log.Println("Input number #2:", num2)
	
	execute(num1, num2)
}

func XmlRpcCall(method string, args struct {
	Num1 int
	Num2 int
},) (reply struct{ Result int }, err error) {

	buf, _ := xml.EncodeClientRequest(method, &args)

	resp, err := http.Post("http://localhost:8081/template", "text/xml", bytes.NewBuffer(buf)) //заменить адрес!
	if err != nil {
		return
	}
	defer resp.Body.Close()

	err = xml.DecodeClientResponse(resp.Body, &reply)
	return
}

func execute(num1 int, num2 int) {
	
	reply, err := XmlRpcCall("MessageService.Sum", struct {
			Num1 int
			Num2 int
		}{num1, num2})

	if err != nil {
		log.Fatal(err)
	}

	log.Printf("Response by \"sum\": %d\n", reply.Result)
}
