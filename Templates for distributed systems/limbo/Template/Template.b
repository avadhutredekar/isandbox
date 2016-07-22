implement Template;

include "sys.m";
include "draw.m";
include "XMLRPC.m";

Connection: import sys;
XMLStruct : import xmlrpc;

xmlrpc: XMLRPC;
sys: Sys;


Template: module
{
	boolean:		type int;
	
	mAlreadyInit : boolean;
		
	init: 			fn(nil: ref Draw->Context, argv: list of string);
	runClient: 		fn();
	runServer: 		fn();
	listen: 		fn(conn : Connection);
	handlerThread:	fn(conn : Connection);
	make:			fn(xmlResponse: XMLStruct) : XMLStruct;
	sum:			fn(num1: int, num2: int) : int;
	
};


make(xmlResponse: XMLStruct) : XMLStruct
{
	case xmlResponse.methodName
	{
		"sum" =>
		{
			num1 := int xmlResponse.params[0];
			num2 := int xmlResponse.params[1];
			
			res := sum(num1, num2);
			strRes := string res;
			
			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {strRes});
			
		}
		
		* =>
		{
			str := "Incorrect input: " + xmlResponse.methodName;
			sys->print("%s.\n", str);

			return xmlrpc->XMLStruct.new(xmlrpc->request, nil, array[] of {str});
		}
	}
}

sum(num1: int, num2: int) : int
{
	return num1 + num2;
}


runClient()
{
	(ok, conn) := sys->dial("tcp!127.0.0.1!80", nil);
	if (ok < 0)
	{
		sys->print("Failed dial the client.\n");
		exit;
	}

	buf := array[255] of byte;
	bufReq := array[sys->ATOMICIO] of byte;
    stdin := sys->fildes(0);
	
	sys->print("To exit, enter the key: exit.\n");
	for(;;)
	{
		sys->print("Input two numbers: ");
		lenBuf := sys->read(stdin, buf, len buf);
		
		if (lenBuf > 0)
		{			
			str := buf[:lenBuf];
			
			if (xmlrpc->getIndex("exit", string str) != -1)
				break;
			
			# парсинг и генерация xmlrpc.
			x := xmlrpc->parseInput(string str);
			strX := array of byte xmlrpc->encode(x); #кодирование в строку.
						
			if (x.typeXml == xmlrpc->unknown)
			{
				sys->print("Invalid input: %s.\n", string str[:len str - 1]);
				continue;
			}
			
			#отправка запроса.
			if (sys->write(conn.dfd, strX, len strX) != len strX)
			{
				sys->print("Failed write to conn.dfd.\n");
				exit;
			}
		
			#получение ответа. 
			lenBufReq := sys->read(conn.dfd, bufReq, len bufReq);
			if (lenBufReq > 0)
			{
				strReqX := string bufReq[:lenBufReq];
				reqX := xmlrpc->decode(strReqX);
				if (reqX.typeXml != xmlrpc->unknown)
				{
					for (i := 0; i < len reqX.params; i++)
						sys->print("Request: %s.\n", reqX.params[i]);
				}
				else
					sys->print("Nil response.\n");
				
				#sys->print("Request: %s\n", string bufReq[:lenBufReq]);
			}

		}
		else
			sys->print("Failed input");
	}
}

runServer()
{
	(ok, conn) := sys->announce("tcp!*!80");
	if (ok < 0)
	{
		sys->print("Failed announce the server.\n");
		exit;
	}
	
	for(;;)
	{
		listen(conn);
	}
}

listen(conn : Connection)
{
	buf := array[sys->ATOMICIO] of byte;
	(ok, c) := sys->listen(conn);
	if (ok < 0)
	{
		sys->print("Failed to start listening on the server.\n");
		exit;
	}
	
	rfd := sys->open(conn.dir + "/remote", Sys->OREAD);
	n := sys->read(rfd, buf, len buf);
	
	#sys->print("Got new connection from: %s\n", string buf[:n]);
	sys->print("A new connection...\n");
	
	#spawn handlerThread(c); #новый поток.
	handlerThread(c);
}

handlerThread(conn : Connection)
{
	buf := array [sys->ATOMICIO] of byte;
	
	rdfd := sys->open(conn.dir + "/data", Sys->OREAD);
	wdfd := sys->open(conn.dir + "/data", Sys->OWRITE);
	rfd := sys->open(conn.dir + "/remote", Sys->OREAD);
	wfd := sys->open(conn.dir + "/remote", Sys->OWRITE);
	
	n := sys->read(rfd, buf, len buf);
	
	sys->print("Connection information: %s\n", string buf[:n]);
	
	in := sys->read(rdfd, buf, len buf); #получение команды от удаленного узла.
	while (in > 0)
	{
		strX := string buf[:in];
		x := xmlrpc->decode(strX);
		
		if (x.typeXml != xmlrpc->unknown)
		{
			res := make(x);
			#ДЕЙСТВИЯ НАД X.
			strRes := array of byte xmlrpc->encode(res);
			
			sys->write(wdfd, strRes, len strRes); #отправка результата удленному узлу.				
		}
		else
			sys->print("Nil response.\n");
		
		in = sys->read(rdfd, buf, len buf); #получение новой команды от удаленного узла.
	}
	
	sys->print("The session is closed.\n");
}

	
init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	xmlrpc = load XMLRPC "XMLRPC.dis";
	sys->print("Success init!\n");

	if (len argv < 2)
	{
		sys->print("Unknown module type.\n");
		exit;
	}
	
	moduleType := hd tl argv;
	
	if (moduleType == "server")
	{
		sys->print("Run the server.\n");
		runServer();
	}
	else
	{
		sys->print("Run the client.\n");
		runClient();
	}
}