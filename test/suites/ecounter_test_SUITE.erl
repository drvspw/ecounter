-module(ecounter_test_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl"). % Eunit macros for convenience

-export([all/0
        ,groups/0
        ,init_per_suite/1, end_per_suite/1
        ,init_per_group/2, end_per_group/2
        %%,init_per_testcase/2, end_per_testcase/2
        ]).

-export([
         new_counter_test/1,
         get_counter_value_test/1,
         reset_counter_value_test/1,
         inc_counter_value_test/1
        ]).

-export([
         concurrent_test/1
]).

%%=================================================
%% Test Setup
%%=================================================
all() ->
    [
     {group, ecounter_tests},
     {group, concurrent_tests}
    ].

groups() ->
    [
     {ecounter_tests, [],
      [new_counter_test, get_counter_value_test, inc_counter_value_test, reset_counter_value_test]
     },

     {concurrent_tests, [],
      [concurrent_test]
     }
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(ecounter_tests, Config) ->
    %% test setup for group ecounter_tests
    Config;

init_per_group(_, Config) ->
    Config.

end_per_group(ecounter_tests, _Config) ->
    %% teardown test setup for group ecounter_tests
    ok;

end_per_group(_Name, _Config) ->
    ok.


%%=================================================
%% Test Cases
%%=================================================
new_counter_test(_Config) ->
  Counter = ecounter:new(),
  ?assertEqual(true, is_reference(Counter)).

get_counter_value_test(_Config) ->
  Counter = ecounter:new(),
  Value = ecounter:get(Counter),
  ?assertEqual(0, Value).

inc_counter_value_test(_Config) ->
  Counter = ecounter:new(),
  Value1 = ecounter:inc(Counter),
  ?assertEqual(1, Value1),

  Value10 = ecounter:inc(Counter, 9),
  ?assertEqual(10, Value10).

reset_counter_value_test(_Config) ->
  Counter = ecounter:new(),
  Value1 = ecounter:inc(Counter),
  ?assertEqual(1, Value1),

  ok = ecounter:reset(Counter),
  ?assertEqual(0, ecounter:get(Counter)).


concurrent_test(_Config) ->
  Parent = self(),
  N = 1000,
  Counter = ecounter:new(),
  DoneMessage = incremented,

  %% spawn 100 processes
  lists:foreach( fun(_Id) ->
                     spawn( fun() ->
                                WaitTime = round(timer:seconds(rand:uniform())),
                                timer:sleep(WaitTime),
                                ecounter:inc(Counter),
                                Parent ! DoneMessage
                            end)
                 end, lists:seq(1, N)),

  %% wait for processes to finish
  ok = wait_loop(N, DoneMessage),
  ?assertEqual(N, ecounter:get(Counter)).


%%=================================================
%% private functions
%%=================================================
wait_loop(0, _) ->
  ok;

wait_loop(N, Message) ->
  receive
    Message ->
      wait_loop(N-1, Message)
  end.
