-module(ecounter).

%% API exports
-export([
         new/0,
         get/1,
         reset/1,
         inc/1,
         inc/2
        ]).

%%====================================================================
%% API functions
%%====================================================================
new() ->
  ecounter_nif:new().

get(Counter) ->
  ecounter_nif:get(Counter).

reset(Counter) ->
  ecounter_nif:reset(Counter).

inc(Counter) ->
  inc(Counter, 1).

inc(Counter, Value) ->
  ecounter_nif:add(Counter, Value).
