package server

import (
	"github.com/divan/gorilla-xmlrpc/xml"
	"github.com/gorilla/rpc"
	"log"
	"net/http"
)


func Create() {
	RPC := rpc.NewServer()
	xmlrpcCodec := xml.NewCodec()
	RPC.RegisterCodec(xmlrpcCodec, "text/xml")
	RPC.RegisterService(new(MessageService), "")
	http.Handle("/template", RPC) //заменить имя.

	log.Println("Starting XML-RPC Server on localhost:8081/template") //заменить строку.
	log.Fatal(http.ListenAndServe(":8081", nil))
}

type MessageService struct{}

func (ms *MessageService) Sum(r *http.Request, args *struct {
	Num1 int
	Num2 int
}, reply *struct{ Result int }) error {
	log.Printf("Request sum number %d, %d", args.Num1, args.Num2)

	val := args.Num1 + args.Num2
	reply.Result = val

	return nil
}

