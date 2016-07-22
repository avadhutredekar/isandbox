%%%-------------------------------------------------------------------
%%% @author dydus
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Dec 2015 17:35
%%%-------------------------------------------------------------------
-module(template_client).
-author("dydus").

%% API
-export([st/0]).

st() ->
    {ok, Socket} = gen_tcp:connect({127,0,0,1}, 4000, [binary, {packet, 0}]),
    gen_tcp:send(Socket, list_to_binary([100, 24])),
    Data = gen_tcp:recv(Socket,0),
    gen_tcp:close(Socket),
    Data.
