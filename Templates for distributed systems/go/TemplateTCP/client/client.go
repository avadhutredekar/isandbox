package client

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
)

func Create() {
	conn, _ := net.Dial("tcp", "127.0.0.1:8081")
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print("Enter the first number >: ")
		strNum1, _ := reader.ReadString('\n')
		fmt.Fprintf(conn, strNum1+"\n")

		fmt.Print("Enter the second number >: ")
		strNum2, _ := reader.ReadString('\n')
		fmt.Fprintf(conn, strNum2+"\n")

		strResult, _ := bufio.NewReader(conn).ReadString('\n')
		log.Print("Response form server:" + strResult)
	}
}
