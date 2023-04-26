Nonterminals 
   list elements element
    .

Terminals
    atom liter '(' ')' '\''
    .

Rootsymbol elements.

list -> '(' ')' : make_empty_list('$1').
list -> '(' elements ')' : make_list_node('$2').
list -> '\'' element : make_list_node([extract_token('$1') | ['$2']]).

elements ->
  element : ['$1'].

elements ->
  element elements : ['$1' | '$2'].

element -> liter : extract_token('$1').
element -> atom : extract_token('$1').
element -> list : '$1'.

Erlang code.

extract_token({'\'', #{value := _Value, line := Line, column := Column}}) -> #{value => quote, line => Line, column => Column};
extract_token({_Type, #{value := Value, line := Line, column := Column}}) -> #{value => Value, line => Line, column => Column}.
make_empty_list({_Type, #{line := Line, column := Column}}) -> #{value => [], line => Line, column => Column}.

make_list_node([Element | T]) -> {Element, T}.
