package comm

import (
	"HashtableRepo/hashtable"
	"bufio"
	"bytes"
	"fmt"
	"github.com/divan/gorilla-xmlrpc/xml"
	"github.com/gorilla/rpc"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

var mutex = &sync.Mutex{}
var snapshot [][]hashtable.Pair

//var sem chan bool

func Create(isType string) {

	if isType == "server" {
		server()
	} else {
		client()
	}
}

func server() {
	//sem = make(chan bool, 0)
	hashtable.Init(4)

	RPC := rpc.NewServer()
	xmlrpcCodec := xml.NewCodec()
	RPC.RegisterCodec(xmlrpcCodec, "text/xml")
	RPC.RegisterService(new(MessageService), "")
	http.Handle("/hashtable", RPC)

	log.Println("Starting XML-RPC Server on localhost:8081/hashtable")
	log.Fatal(http.ListenAndServe(":8081", nil))
}

func client() {

	log.Println("Run client...")
	fmt.Println("Enter \"exit\" command for logout")

	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("Enter the command >: ")
		cmd, _ := reader.ReadString('\n')

		//cmd = cmd[:len(cmd)-1]

		if cmd == "exit\n" {
			break
		}

		executeCommand(cmd)
	}
}

func XmlRpcCall(method string, args struct {
	Key   int
	Value string
},) (reply struct{ Message string }, err error) {

	buf, _ := xml.EncodeClientRequest(method, &args)

	resp, err := http.Post("http://localhost:8081/hashtable", "text/xml", bytes.NewBuffer(buf))
	if err != nil {
		return
	}
	defer resp.Body.Close()

	err = xml.DecodeClientResponse(resp.Body, &reply)
	return
}

func executeCommand(cmd string) {

	//log.Println("Call executeCommand")

	ob := strings.Index(cmd, "(")
	cb := strings.Index(cmd, ")")

	if strings.HasPrefix(cmd, "clear") {
		foo := "Clear"

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, "null"})

		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Response by \"clear\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "containsKey") {
		foo := "ContainsKey"

		key, _ := strconv.Atoi(cmd[ob+1 : cb])

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{key, "null"})

		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Response by \"containsKey\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "containsValue") {
		foo := "ContainsValue"

		value := cmd[ob+1 : cb]

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, value})

		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Response by \"containsValue\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "get") {
		foo := "Get"
		key, _ := strconv.Atoi(cmd[ob+1 : cb])

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{key, "null"})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"get\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "isEmpty") {
		foo := "IsEmpty"

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, "null"})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"isEmpty\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "put") {
		foo := "Put"

		comma := strings.Index(cmd, ",")
		key, _ := strconv.Atoi(cmd[ob+1 : comma])
		value := cmd[comma+2 : cb]

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{key, value})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"put\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "remove") {
		foo := "Remove"
		key, _ := strconv.Atoi(cmd[ob+1 : cb])

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{key, "null"})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"remove\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "size") {
		foo := "Size"

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, "null"})
		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"size\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "toString") {
		foo := "ToString"

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, "null"})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"toString\": %s\n", reply.Message)
	}

	if strings.HasPrefix(cmd, "rollback") {
		foo := "Rollback"

		reply, err := XmlRpcCall("MessageService."+foo, struct {
			Key   int
			Value string
		}{0, "null"})

		if err != nil {
			log.Fatal(err)
		}

		log.Printf("Response by \"rollback\": %s\n", reply.Message)
	}
}

type MessageService struct{}

func (ms *MessageService) Clear(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	lock()
	//log.Println("Call RPC clear")

	snapshot = hashtable.Copy()
	isClear := strconv.FormatBool(hashtable.Clear())
	//log.Println("Is clear hashtable: " + isClear)
	reply.Message = isClear

	unlock()
	return nil
}

func (ms *MessageService) Put(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	lock()
	//log.Println("Call RPC put")

	snapshot = hashtable.Copy()
	var p hashtable.Pair
	val := hashtable.Put(p.New(args.Key, args.Value))

	//log.Println("Is put to hashtable, value: " + val)

	reply.Message = val

	unlock()
	return nil
}

func (ms *MessageService) ToString(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC toString")

	str := hashtable.ToString()

	//log.Println("Is toString hashtable: " + str)

	reply.Message = str

	return nil
}

func (ms *MessageService) ContainsKey(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC containsKey")

	isContains := strconv.FormatBool(hashtable.ContainsKey(args.Key))

	//log.Println("Is containsKey in hashtable: " + isContains)

	reply.Message = isContains

	return nil
}

func (ms *MessageService) ContainsValue(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC containsValue")

	isContains := strconv.FormatBool(hashtable.ContainsValue(args.Value))

	//log.Println("Is containsValue in hashtable: " + isContains)

	reply.Message = isContains

	return nil
}

func (ms *MessageService) Get(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC get")

	val := hashtable.Get(args.Key)

	//log.Println("Is get from hashtable, value: " + val)

	reply.Message = val

	return nil
}

func (ms *MessageService) IsEmpty(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC isEmpty")

	isEmpty := strconv.FormatBool(hashtable.IsEmpty())
	//log.Println("Is empty hashtable: " + isEmpty)
	reply.Message = isEmpty

	return nil
}

func (ms *MessageService) Remove(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	lock()
	//log.Println("Call RPC remove")

	snapshot = hashtable.Copy()
	val := hashtable.Remove(args.Key)

	//log.Println("Is remove from hashtable, value: " + val)

	reply.Message = val

	unlock()
	return nil
}

func (ms *MessageService) Size(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	//log.Println("Call RPC size")

	size := strconv.Itoa(hashtable.Size())
	//log.Println("Size of hashtable: " + size)
	reply.Message = size

	return nil
}

func (ms *MessageService) Rollback(r *http.Request, args *struct {
	Key   int
	Value string
}, reply *struct{ Message string }) error {
	lock()
	//log.Println("Call RPC size")

	isRollback := hashtable.Rollback(snapshot)
	//log.Println("Size of hashtable: " + size)
	reply.Message = strconv.FormatBool(isRollback)

	unlock()
	return nil
}

func lock() {

	log.Println("Lock")
	mutex.Lock()
	//sem <- true
}

func unlock() {
	time.Sleep(time.Second * 1)
	log.Println("Unlock")
	mutex.Unlock()
	//<-sem
}
