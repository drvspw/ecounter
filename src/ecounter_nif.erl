-module(ecounter_nif).

%% API Exports
-export([
         new/0,
         get/1,
         reset/1,
         add/2
        ]).

-on_load(init/0).

-define(APPNAME, ?MODULE).
-define(LIBNAME, "libecounter").

%%====================================================================
%% API functions - NIFS
%%====================================================================

%% @doc new/0 creates a new atomic counter
%%
%% @end
-spec new() -> Counter
                 when
    Counter :: reference().
new() ->
  not_loaded(?LINE).

%% @doc get/1 Returns the value of the counter
%%
%% @end
-spec get(Counter) -> Value
                 when
    Counter :: reference(),
    Value :: integer().
get(_Counter) ->
  not_loaded(?LINE).

%% @doc reset/1 reset counter to 0
%%
%% @end
-spec reset(Counter) -> ok
                 when
    Counter :: reference().
reset(_Counter) ->
  not_loaded(?LINE).

%% @doc add/2 increments counter given value
%%
%% @end
-spec add(Counter, Value) -> IncValue
                     when
    Counter :: reference(),
    Value :: integer(),
    IncValue :: integer().
add(_Counter, _Value) ->
  not_loaded(?LINE).

%%====================================================================
%%%% Internal functions
%%%%%====================================================================
init() ->
  PrivDir = code:priv_dir(?APPNAME),
  LibFile = lib_file(PrivDir, ?LIBNAME),
  erlang:load_nif(LibFile, 0).

lib_file({error, bad_name}, LibName) ->
  case filelib:is_dir(filename:join(["..", priv])) of
    true ->
      filename:join(["..", priv, LibName]);
    _ ->
      filename:join([priv, LibName])
  end;

lib_file(PrivDir, LibName) ->
  filename:join(PrivDir, LibName).

not_loaded(Line) ->
  exit({not_loaded, [{module, ?MODULE}, {line, Line}]}).
