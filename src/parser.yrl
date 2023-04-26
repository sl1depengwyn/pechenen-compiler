Nonterminals 
   list elements element
    .

Terminals
    atom liter '(' ')' '\''
    .

Rootsymbol elements.

list -> '(' ')' : [].
list -> '(' elements ')' : '$2'.
list -> '\'' element : [extract_token('$1'), '$2'].

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
