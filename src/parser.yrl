Nonterminals 
    list elements element function_call
    .

Terminals
    atom liter '(' ')' '\''
    .

Rootsymbol function_call.

function_call -> list : make_list_node('$1').
function_call -> '\'' element : make_list_node([quote | ['$2']]).

list -> '(' ')' : make_empty_list('$1').
list -> '(' elements ')' : '$2'.

elements ->
  element : ['$1'].

elements ->
  element elements : ['$1' | '$2'].

element -> liter : extract_token('$1').
element -> atom : extract_token('$1').
element -> list : '$1'.

Erlang code.

extract_token({_Type, #{value := Value, line := Line, column := Column}}) -> #{value => Value, line => Line, column => Column}.
make_empty_list({_Type, #{line := Line, column := Column}}) -> #{value => [], line => Line, column => Column}.

make_list_node([Element | T]) -> {Element, T};
make_list_node(#{value := [], line := Line, column := Column}) -> return_error([{line, Line}, {column, Column}], "Unexpected (). If you want to define an empty list use `quote` function").
