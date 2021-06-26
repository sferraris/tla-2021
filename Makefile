.PHONY: clean all
all:
	yacc -d lex.y
	flex lex.l 
	clang -o lex lex.yy.c y.tab.c lex.c  
	rm lex.yy.c y.tab.c y.tab.h
clean:
	rm -f output.c out