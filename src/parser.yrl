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

element -> liter : extract_token('$1').
element -> atom : extract_token('$1').
element -> list : '$1'.

Erlang code.

extract_token({Value, _liter, Line}) -> Value.
% extract_atom({Value, atom, Line}) -> Value.