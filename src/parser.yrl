Nonterminals 
    list elements element function_call quote
    .

Terminals
    atom liter '(' ')' '\''
    .

Rootsymbol function_call.

function_call -> list : make_list_node('$1').

quote -> '\'' element : '$2'.

list -> '(' ')' : [].
list -> '(' elements ')' : '$2'.

elements ->
  element : ['$1'].

elements ->
  element elements : ['$1' | '$2'].

element -> liter : extract_token('$1').
element -> atom : extract_token('$1').
element -> quote : '$1'.
element -> list : '$1'.

Erlang code.

extract_token({_Type, Value, _Line, _Column}) -> Value.

make_list_node([Element | T]) -> {Element, T}.
