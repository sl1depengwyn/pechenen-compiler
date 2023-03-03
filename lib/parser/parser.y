%{
    #include <stdlib.h>
    #include <iostream>
    #include "ast_builder.h"

    int yylex();
    void yyerror(const char* msg) {
        std::cout << "ERR: " << msg << std::endl;
        exit(1);
    }
%}

%define parse.error detailed

%union {
    unsigned int uival;
    char *sval;
    void *node;
}

%token 
SYM_L_PARENTHESIS
SYM_R_PARENTHESIS
SYM_MINUS
SYM_PLUS
SYM_DOT
SYM_QUOTE
CONST_TRUE
CONST_FALSE
CONST_NULL
KEY_QUOTE
KEY_SETQ
KEY_FUNC
KEY_LAMBDA
KEY_PROG
KEY_COND
KEY_WHILE
KEY_RETURN
KEY_BREAK

%token<uival>
VAL_UINT

%token<sval>
VAL_IDENTIFIER

%type<node>
input
elements
element
list
atom
literal
integer
real
null
boolean

%%

input: 
    elements { create_program_ast($1); }

elements: { $$ = make_empty_elements_node(); }
|   element elements { $$ = make_recursive_elements_node($1, $2); }

element: 
    atom { $$ = make_element_node($1); }
|   literal { $$ = make_element_node($1); }
|   list { $$ = make_element_node($1); }

list:
    SYM_L_PARENTHESIS element elements SYM_R_PARENTHESIS { $$ = make_list_node(make_recursive_elements_node($2, $3)); }

atom:
    VAL_IDENTIFIER { $$ = make_atom_node($1); }

literal:
    integer { $$ = make_literal_node($1); }
|   real { $$ = make_literal_node($1); }
|   boolean { $$ = make_literal_node($1); }
|   null { $$ = make_literal_node($1); }

integer:
    SYM_PLUS VAL_UINT { $$ = make_integer_node($2); }
|   SYM_MINUS VAL_UINT { $$ = make_integer_node(-1 * $2); }
|   VAL_UINT { $$ = make_integer_node($1); }

real:
    SYM_PLUS VAL_UINT SYM_DOT VAL_UINT { $$ = make_real_node($2, $4); }
|   SYM_MINUS VAL_UINT SYM_DOT VAL_UINT { $$ = make_real_node(-1 * $2, -1 * $4); }
|   VAL_UINT SYM_DOT VAL_UINT { $$ = make_real_node($1, $3); }

boolean:
    CONST_TRUE { $$ = make_boolean_node(1); }
|   CONST_FALSE { $$ = make_boolean_node(0); }

null:
    CONST_NULL { $$ = make_null_node();}

%%


int main() {
    yyparse();

    print_ast();

    return 0;
}
