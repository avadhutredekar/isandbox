implement Client;

include "sys.m";
include "draw.m";

Connection: import sys;
sys: Sys;


Client: module
{	
	init: 			fn(nil: ref Draw->Context, argv: list of string);
	runClient: 		fn();	
	getIndex:		fn(subStr: string, str: string) : int;
};

getIndex(subStr: string, str: string) : int
{
	for (i := 0; i < len str - len subStr; i++)
	{
		for (j := 0; j < len subStr; j++)
		{
			if (str[i + j] != subStr[j])
				break;
			
			if (j + 1 == len subStr)
				return i;
		}
	}
		
	return -1;
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
			
			if (getIndex("exit", string str) != -1)
				break;
			
			bStr := array of byte str;
			
			#отправка запроса.
			if (sys->write(conn.dfd, bStr, len bStr) != len bStr)
			{
				sys->print("Failed write to conn.dfd.\n");
				exit;
			}
		
			#получение ответа. 
			lenBufReq := sys->read(conn.dfd, bufReq, len bufReq);
			if (lenBufReq > 0)
			{
				strReq := string bufReq[:lenBufReq];
				sys->print("Request: %s.\n", strReq);
			}
		}
		else
			sys->print("Failed input");
	}
}
	
init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	sys->print("Success client init!\n");

	sys->print("Run the client.\n");
	runClient();
}