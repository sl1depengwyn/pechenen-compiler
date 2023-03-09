Nonterminals 
    list elements element
    .
Terminals
    atom liter '(' ')' operator
    .

Rootsymbol list.

list -> '(' ')' : [].
list -> '(' elements ')' : '$2'.

elements ->
  element : ['$1'].

elements ->
  element elements : ['$1' | '$2'].

element -> liter : extract_liter('$1').
element -> atom : extract_atom('$1').
element -> list : '$1'.

Erlang code.

extract_liter(#{value := Value, type := liter}) -> Value.
extract_atom(#{value := Value, type := atom}) -> Value.