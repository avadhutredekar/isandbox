implement Server;

include "sys.m";
include "draw.m";

Connection: import sys;
sys: Sys;

Server: module
{		
	init: 			fn(nil: ref Draw->Context, argv: list of string);
	runServer: 		fn();
	listen: 		fn(conn : Connection);
	handler:		fn(conn : Connection);
	make:			fn(response: string) : string;
	sum:			fn(num1: int, num2: int) : int;
	split:			fn(str: string, sep: string) : array of string;
	getIndex:		fn(subStr: string, str: string) : int;
};

split(str: string, sep: string) : array of string
{
	params := array[127] of string;
	
	i : int;
	for (i = 0; i < len params; i++)
	{
		if (len str == 0)
			break;
		
		if (index := getIndex(sep, str) != -1)
		{
			params[i] = str[:index];
			str = str[index + 1 : len str];
		}
		else
		{
			params[i] = str;
			break;
		}
	}
	
	return params[:i + 1];
}

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

make(response: string) : string
{
	args := split(response, ",");
	num1 := int args[0];
	num2 := int args[1];
	
	sys->print("Response arg1: %d, arg2: %d\n", num1, num2);
	
	res := sum(num1, num2);
	
	return string res;
	
}

sum(num1: int, num2: int) : int
{
	return num1 + num2;
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
	
	sys->print("A new connection...\n");
	
	spawn handler(c);
}


handler(conn : Connection)
{
	buf := array [sys->ATOMICIO] of byte;
	
	rdfd := sys->open(conn.dir + "/data", Sys->OREAD);
	wdfd := sys->open(conn.dir + "/data", Sys->OWRITE);
	rfd := sys->open(conn.dir + "/remote", Sys->OREAD);
	#wfd := sys->open(conn.dir + "/remote", Sys->OWRITE);
	
	#чтение информации о подключенно клиенте.
	n := sys->read(rfd, buf, len buf);
	
	sys->print("Connection information: %s\n", string buf[:n]);
	
	#получение команды от удаленного узла.
	in := sys->read(rdfd, buf, len buf);
	while (in > 0)
	{
		
		request := string buf[:in];
		res := make(request);
		bRes := array of byte res;
		
		#отправка результата удленному узлу.
		sys->write(wdfd, bRes, len bRes);
			
		#получение новой команды от удаленного узла.
		in = sys->read(rdfd, buf, len buf); 
	}
	
	sys->print("The session is closed.\n");
}


init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	sys->print("Success server init!\n");
	
	sys->print("Run the server.\n");
	runServer();

}