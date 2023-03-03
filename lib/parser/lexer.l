%option noyywrap

%{
    #include <stdlib.h>
    #include <iostream>
    #include "parser.tab.h"
%}

%%

"(" { return SYM_L_PARENTHESIS; }
")" { return SYM_R_PARENTHESIS; }
"-" { return SYM_MINUS; }
"+" { return SYM_PLUS; }
"." { return SYM_DOT; }
"'" { return SYM_QUOTE; }

"true" { return CONST_TRUE; }
"false" { return CONST_FALSE; }
"null" { return CONST_NULL; }

"quote" { return KEY_QUOTE; }
"setq" { return KEY_SETQ; }
"func" { return KEY_FUNC; }
"lambda" { return KEY_LAMBDA; }
"prog" { return KEY_PROG; }
"cond" { return KEY_COND; }
"while" { return KEY_WHILE; }
"return" { return KEY_RETURN; }
"break" { return KEY_BREAK; }

[0-9]+ { yylval.uival = atoi(yytext); return VAL_UINT; }
[A-Za-z][A-Za-z0-9]* { yylval.sval = strdup(yytext); return VAL_IDENTIFIER; }

[ \t\n] { }
. { std::cout << "ERR: unexpected token \"" << strdup(yytext) << "\"" << std::endl; exit(1); }

%%
