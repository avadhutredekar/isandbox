%%%-------------------------------------------------------------------
%%% @author dydus
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Dec 2015 17:35
%%%-------------------------------------------------------------------
-module(s).
-author("dydus, oxaoo, FatherOctober").
-compile([{nowarn_unused_function}]).
-import(model, [get/2, set/3, remove/2]).

%% API
-export([st/0]).

st() ->
	start_server(4000).

start_server(Port) ->
	MapPid = spawn_link(fun() -> map_handler([]) end),
	Pid = spawn_link(fun() ->
		{ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0}, {reuseaddr, true}, {active, true}, {ip, {192,168,137,250}}]),
		spawn(fun() -> acceptor(MapPid, Listen) end),
		timer:sleep(infinity)
		end),
	{ok, Pid}.

% Create new connection and call handler
acceptor(MapPid, ListenSocket) ->
	io:format("Start accepting [~p]\n", [self()]),
	{ok, Socket} = gen_tcp:accept(ListenSocket),
	spawn(fun() -> acceptor(MapPid, ListenSocket) end),
	handler(MapPid, Socket).

% Define types of operation which can be use for Dictionary
handler(MapPid, Socket) ->
	%inet:setopts(Socket, [{active, once}]),
	io:format("Start handling ~p, Map ~p\n", [self(), MapPid]),
	receive
		{tcp, Socket, <<"get">>} ->
					io:format(">Operation: GET [~p]\n", [self()]),
            		ok = gen_tcp:send(Socket, list_to_binary("ok")),
            		io:format(">Answer ok ~p\n", [self()]),
					Key = get_message(Socket),
					io:format(">Key ~p\n", [Key]),
					MapPid ! {self(),get,list_to_binary(Key)},
					Value = get_answer(MapPid),
					io:format(">Value ~p\n", [Value]),
					ok = gen_tcp:send(Socket, list_to_binary(Value)),
					handler(MapPid, Socket);
		{tcp, Socket, <<"set">>} ->
					io:format(">Operation: SET [~p]\n", [self()]),
            		ok = gen_tcp:send(Socket, list_to_binary("ok")),
            		io:format(">Answer ok ~p\n", [self()]),
					Key = get_message(Socket),
					io:format(">Key ~p\n", [Key]),
					ok = gen_tcp:send(Socket, list_to_binary("ok")),
					Value = get_message(Socket),
					io:format(">Value ~p\n", [Value]),
					MapPid ! {self(),set,list_to_binary(Key), list_to_binary(Value)},
					Answer = get_answer(MapPid),
					io:format(">Value has been saved ~p\n", [Answer]),
					gen_tcp:send(Socket, list_to_binary(Answer)),
					handler(MapPid, Socket);
		{tcp, Socket, <<"remove">>} ->
					io:format(">Operation: REMOVE [~p]\n", [self()]),
            		ok = gen_tcp:send(Socket, list_to_binary("ok")),
            		io:format(">Answer ok ~p\n", [self()]),
					Key = get_message(Socket),
					io:format(">Key  ~p\n", [Key]),
					MapPid ! {self(),remove,list_to_binary(Key)},
					Answer = get_answer(MapPid),
					io:format(">Value with key ~p has been removed\n", [Key]),
					gen_tcp:send(Socket, list_to_binary(Answer)),
					handler(MapPid, Socket);
		_ ->
					% io:fwrite("> Wrong message\n"),
           	 		handler(MapPid, Socket)
	end.

% Listen to any messages
get_message(Socket) ->
	receive
		{tcp, Socket, Message} ->
			binary_to_list(Message)
	end.

% Get a message from another actor
get_answer(Pid) ->
	receive
		{Pid, ok, Msg} ->
			binary_to_list(Msg)
	end.

% Manage operations with map
map_handler(Map) ->
	io:format("Map handler has started ~p\n", [Map]),
    receive
        {Pid,get,Key} ->
        	io:format("map_handler GET ~p\n", [Key]),
        	Value = model:get(Key, Map),
        	Pid ! {self(), ok, Value},
        	map_handler(Map);
        {Pid,set,Key,Value} ->
        	io:format("map_handler SET ~p\n", [Key]),
        	NewMap = model:set(Key, Value, Map),
        	Pid ! {self(), ok, Value},
        	map_handler(NewMap);
        {Pid,remove,Key} ->
        	io:format("map_handler REMOVE ~p\n", [Key]),
        	NewMap = model:remove(Key, Map),
        	Pid ! {self(), ok, Key},
        	map_handler(NewMap);
        _ ->
        	io:format("map_handler gets wrong mesage ~p\n", [self()]),
        	map_handler(Map)	            	
    end.