%%%-------------------------------------------------------------------
%%% @author dydus
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Dec 2015 17:35
%%%-------------------------------------------------------------------
-module(template_server).
-author("dydus, oxaoo, FatherOctober").
-compile([{nowarn_unused_function}]).

%% API
-export([st/0]).


% Запуск
% В консоли набрать erl
% Затем используя название модуля - c(template_server).
% Затем используя название функции - st().
% Profit

st() ->
	start_server(4000).

start_server(Port) ->
	% Запуск нового потока 
	MapPid = spawn_link(fun() -> map_handler([]) end),
	Pid = spawn_link(fun() ->
		{ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0}, {reuseaddr, true}, {active, true}, {ip, {127,0,0,1}}]),
		spawn(fun() -> acceptor(MapPid, Listen) end),
		timer:sleep(infinity)
		end),
	{ok, Pid}.

% Create new connection and call handler
acceptor(MapPid, ListenSocket) ->
	io:format("Start accepting [~p]\n", [self()]),
	{ok, Socket} = gen_tcp:accept(ListenSocket),
	handler(MapPid, Socket),
	acceptor(MapPid, ListenSocket).

% Define types of operation which can be use for Dictionary
handler(MapPid, Socket) ->
	%inet:setopts(Socket, [{active, once}]),
	% Вывести строку с параметрами на экран
	io:format("Start handling ~p, Map ~p\n", [self(), MapPid]),
	% Перечислены возможные операции, которые способен обрабатывать сервер
	receive
		{tcp, Socket, Data} ->
					io:format(">Operation: SUM [~p] request = ~p\n", [self(), binary_to_list(Data)]),
					[First | [Second | _]] = binary_to_list(Data),

					% Отправить сообщение процессу-обработчику
					MapPid ! {self(),sum, term_to_binary(First), term_to_binary(Second)},

					% Получить ответ от процесса-обработчика
					Value = get_answer(MapPid),
					io:format(">Value ~p\n", [Value]),

					% Отправить ответ клиенту. Клиент должен слушать сокет в этот момент
					Answer = gen_tcp:send(Socket, term_to_binary(Value)),
					
					io:format(">Answer ~p\n", [Answer]),
					ok;
		_ ->
					io:fwrite("> Wrong message\n"),
           	 		ok
	end.

% Listen to any messages
get_message(Socket) ->
	receive
		{tcp, Socket, Message} ->
			binary_to_term(Message)
	end.

% Get a message from another actor
get_answer(Pid) ->
	receive
		{Pid, ok, Msg} ->
			binary_to_term(Msg)
	end.

% Manage operations with map
map_handler(Map) ->
	io:format("Map handler has started ~p\n", [Map]),
    receive
        {Pid,sum,First,Second} ->
        	io:format("map_handler SUM\n", []),
        	Value = binary_to_term(First) + binary_to_term(Second),
        	Pid ! {self(), ok, term_to_binary(Value)},
        	map_handler(Map);
        _ ->
        	io:format("map_handler gets wrong message ~p\n", [self()]),
        	map_handler(Map)	            	
    end.