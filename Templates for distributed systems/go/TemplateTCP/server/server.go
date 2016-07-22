package server

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"strconv"
)

func Create() {
	log.Println("Starting Server on TCP 127.0.0.1:8081")
	ln, _ := net.Listen("tcp", ":8081")
	conn, _ := ln.Accept()
	for {
		strNum1, _ := bufio.NewReader(conn).ReadString('\n')
		strNum2, _ := bufio.NewReader(conn).ReadString('\n')

		num1, err1 := strconv.Atoi(strNum1[:len(strNum1)-1])
		num2, err2 := strconv.Atoi(strNum2[:len(strNum2)-1])

		if err1 != nil {
			fmt.Println(err1)
		}

		if err2 != nil {
			fmt.Println(err2)
		}

		result := num1 + num2
		strResult := strconv.Itoa(result)

		log.Println("Result Sum:", strResult)
		conn.Write([]byte(strResult + "\n"))
	}
}
