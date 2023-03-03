bison -d parser.y ; flex lexer.l; mv lex.yy.c lex.yy.cpp; mv parser.tab.c parser.tab.cpp; g++ lex.yy.cpp parser.tab.cpp ast_builder.cpp; cat prog | ./a.out
