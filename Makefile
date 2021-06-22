all:
	yacc -d lex.y
	flex lex.l 
	gcc -o lex lex.yy.c y.tab.c -ly 
	rm lex.yy.c y.tab.c y.tab.h
clean:
	rm lex