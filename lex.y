%token <strval> INTEGER 
%token <strval> VARIABLE
%token <ival> MAIN
%token <ival> OPEN_DEL
%token <ival> CLOSE_DEL 
%token <ival> TYPE
%token <ival> IF
%token <ival> AND
%token <ival> OR
%token <ival> NOT
%left '+' '-'
%left '*' '/'
%type <strval> expr
%type <strval> conditional
%type <strval> number
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "lex.h"
    void yyerror(char *);
    int yylex(void);
    int sym[26];
    extern FILE * yyin, * yyout;
    struct variables * first = 0;
%}
%union {
    char*   strval;
    int     ival;
}
%%
statement:
        | MAIN OPEN_DEL expr CLOSE_DEL {fprintf(yyout, "int main(){\n%s\n}", $<strval>3);} 
        ;
expr:
    INTEGER {char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | expr expr {char aux[10000];sprintf(aux ,"%s %s", $<strval>1, $<strval>2);$$=aux;}
    | VARIABLE {checkVariable((char *)$1, first); }
    | expr '+' expr {char aux[100];sprintf(aux, "%s + %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '-' expr {char aux[100];sprintf(aux, "%s - %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '*' expr {char aux[100];sprintf(aux, "%s * %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '/' expr {char aux[100];sprintf(aux, "%s / %s", $<strval>1, $<strval>2);$$=aux;}
    | '(' expr ')' {char aux[100];sprintf(aux, "%s", $<strval>1);$$=aux;}
    | VARIABLE '=' expr ';' {
        if(!checkVariable((char *)$<strval>1, first)){
                yyerror("Variable not defined");
                return -1; 
        }
        char aux[100];
        sprintf(aux, "%s = %s;\n", $<strval>1, $<strval>3); $$=aux;}
    | TYPE VARIABLE '=' expr ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror("Variable was already defined in this scope");
                return -1; 
        }
        char aux[1000];
        sprintf(aux, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$=aux;
        }
    | IF '(' conditional ')' OPEN_DEL expr CLOSE_DEL {char aux[100];sprintf(aux, "if(%s){\n%s}\n", $<strval>3, $<strval>6);$$=aux;}
    ;
number:
    INTEGER {char aux[100];sprintf(aux, "%s", $<strval>1);$$=aux;}
    |VARIABLE {checkVariable((char *)$1, first);char aux[100]; sprintf(aux, "%s", $<strval>1);$$=aux; }
    ;

conditional:
       number '<' number {char aux[100];sprintf(aux, "%s < %s", $<strval>1, $<strval>3); $$=aux;}
    |   number "<=" number {char aux[100];sprintf(aux, "%s <= %s", $<strval>1, $<strval>3); $$=aux;}
    |   number "==" number {char aux[100];sprintf(aux, "%s == %s", $<strval>1, $<strval>3); $$=aux;}
    |   number '>' number {char aux[100];sprintf(aux, "%s > %s", $<strval>1, $<strval>3); $$=aux;}
    |   number ">=" number {char aux[100];sprintf(aux, "%s >= %s", $<strval>1, $<strval>3); $$=aux;}
    |   '!' number {char aux[100];sprintf(aux, "!%s", $<strval>2); $$=aux;}
    |   conditional AND conditional {char aux[100];sprintf(aux, "%s && %s", $<strval>1, $<strval>3);$$=aux;}
    |   conditional OR conditional {char aux[100];sprintf(aux, "%s || %s", $<strval>1, $<strval>3);$$=aux;}
    |   NOT conditional {char aux[100];sprintf(aux, "!%s", $<strval>2);$$=aux;}
    ;
%%

void yyerror(char *s) { 
    fprintf(stderr, "%s\n", s); 
}


int main(int argc, char ** argv) {
    if(argc != 2){
        return 0;
    }
  
    yyin = fopen(argv[1], "r");
    yyout = fopen("output.c", "w");
    fprintf(yyout,"#include <stdio.h>\n");
    if(yyparse()<0){
        return 0;
    }

    fclose(yyin);
    fclose(yyout);
    return 1; 

}

