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
%token <ival> PRINT
%token <strval> STRING
%token <strval> WHILE
%token <ival> GE
%token <ival> EQ
%token <ival> LE
%left '+' '-'
%left '*' '/'
%type <strval> expr
%type <strval> conditional
%type <strval> number
%type <strval> expr_list


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
        | MAIN OPEN_DEL expr_list CLOSE_DEL 
        ;
expr:
    INTEGER {char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | VARIABLE {checkVariable((char *)$1, first); char aux[100]; sprintf(aux, "%s", $<strval>1); $$=aux; }
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
        sprintf(aux, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4), $$=aux;;
        }
    |IF {fprintf(yyout, "if(");}'(' conditional ')' {fprintf(yyout, "){\n");}  OPEN_DEL expr_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    |PRINT '('  STRING ')' ';' {fprintf(yyout, "printf(%s);\n", $<strval>3);$$="";}
    |WHILE  {fprintf(yyout, "while(");}'(' conditional ')'{fprintf(yyout, "){\n");}  OPEN_DEL expr_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    ;
expr_list: expr  {fprintf(yyout, "%s",$<strval>1);}
            |expr_list expr {char aux[100000];fprintf(yyout, "%s",$<strval>2);}
            ;



number:
    INTEGER {fprintf(yyout, "%s", $<strval>1);}
    |VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){
                yyerror("Variable not defined");
                return -1; 
        }
    char aux[100];fprintf(yyout, "%s", $<strval>1); }
    ;

conditional:
        number 
    |   number '<' {fprintf(yyout, " < ");} number 
    |   number LE {fprintf(yyout, " <= ");} number 
    |   number EQ {fprintf(yyout, " == ");} number
    |   number '>' {fprintf(yyout, " > ");}number 
    |   number GE {fprintf(yyout, " >= ");}number
    |   conditional AND {fprintf(yyout, " && ");} conditional 
    |   conditional OR {fprintf(yyout, " || ");} conditional 
    |   NOT {fprintf(yyout, "! ");} conditional 
    |   '('{fprintf(yyout, "(");} conditional ')'{fprintf(yyout, ")");}
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
    fprintf(yyout, "int main(){\n"); 
    if(yyparse()!=0){
        fclose(yyin);
        fclose(yyout);
        return 0;
    }
    fprintf(yyout, "}\n"); 

    fclose(yyin);
    fclose(yyout);
    return 1; 

}

