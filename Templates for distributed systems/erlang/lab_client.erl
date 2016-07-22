%%%-------------------------------------------------------------------
%%% @author dydus
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Dec 2015 17:35
%%%-------------------------------------------------------------------
-module(cl).
-author("dydus").

%% API
-export([st/0]).

st() ->
    {ok, Socket} = gen_tcp:connect({127,0,0,1}, 4000, []),
    gen_tcp:send(Socket, term_to_binary("get")),
    gen_tcp:send(Socket, term_to_binary("get")),

    case gen_tcp:recv(Socket, 0) of
        {Socket, Data} ->
            io:format("Handler [~p] received matrix size: ~p~n", [self(), binary_to_term(Data)]);
        _ ->
            io:format("Handler [~p]: network error\n", [self()])
    end.
