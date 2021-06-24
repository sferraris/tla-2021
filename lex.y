%token <strval> INTEGER 
%token <strval> VARIABLE
%token <ival> MAIN
%token <ival> OPEN_DEL
%token <ival> CLOSE_DEL 
%token <ival> TYPE
%token <ival> SPECIAL_TYPE
%token <ival> SPECIAL_TYPE2
%token <ival> STRING_T
%token <ival> AUTOMATON_T
%token <ival> IF
%token <ival> AND
%token <ival> OR
%token <strval> NOT
%token <ival> PRINT
%token <strval> STRING
%token <strval> SIMPLE_STRING
%token <strval> WHILE
%token <ival> NA
%token <ival> AT
%token <ival> EX
%token <ival> CL
%token <ival> ST
%token <ival> NX
%token <ival> ISF
%token <ival> PA
%token <ival> GE
%token <ival> EQ
%token <ival> LE
%token <ival> NE
%token <strval> LAMBDA2
%left '+' '-'
%left '*' '/'
%type <strval> expr
%type <strval> conditional
%type <strval> number
%type <strval> number2
%type <strval> string
%type <strval> expr_list
%type <strval> simple_string_list
%type <strval> string_list
%type <strval> char
%error-verbose

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "lex.h"
    #include "automaton.h"
    void yyerror(char *);
    int yylex(void);
    int sym[26];
    char aux1[100];
    char aux2[100];
    char aux3[100];
    char aux4[100];
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
    | SIMPLE_STRING{char aux[100];
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
        sprintf(aux, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$=aux;
        }
    | SPECIAL_TYPE VARIABLE '=' OPEN_DEL
    {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror("Variable was already defined in this scope");
                return -1; 
        }
        fprintf(yyout, "char %s[] = { ",$<strval>2);
    } simple_string_list CLOSE_DEL ';' { fprintf(yyout, " };\n");  $$ = "";}
    | SPECIAL_TYPE2 VARIABLE '=' OPEN_DEL
    {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror("Variable was already defined in this scope");
                return -1; 
        }
        fprintf(yyout, "string %s[] = { ",$<strval>2);
    } string_list CLOSE_DEL ';' { fprintf(yyout, " };\n");  $$ = "";}
    | STRING_T VARIABLE '=' STRING ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror("Variable was already defined in this scope");
                return -1; 
        }
        
        fprintf(yyout, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$="";
        }
    |IF {fprintf(yyout, "if(");}'(' conditional ')' {fprintf(yyout, "){\n");}  OPEN_DEL expr_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    |PRINT '('  STRING ')' ';' {fprintf(yyout, "printf(%s);\n", $<strval>3);$$="";}
    |WHILE  {fprintf(yyout, "while(");}'(' conditional ')'{fprintf(yyout, "){\n");}  OPEN_DEL expr_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | AUTOMATON_T VARIABLE '=' NA '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2  ',' string ',' string ',' VARIABLE ',' number2 ')' ';'{
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror("Variable was already defined in this scope"); 
                return -1; 
        }
         if(!checkVariableWithType((char *)$<strval>6, first, STATES) && !checkVariableWithType((char *)$<strval>10, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>14, first, STACK_ALPHABET) && !checkVariableWithType((char *)$<strval>22, first, STACK_ALPHABET) ){
                yyerror("Variable not defined");
                return -1; 
        }
        fprintf(yyout, "automaton * %s = new_automaton(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>2,$<strval>6, $<strval>8, $<strval>10,$<strval>12,$<strval>14,$<strval>16,$<strval>18,$<strval>20,$<strval>22,$<strval>24); $$ = "";
    }
    |AT '(' VARIABLE ',' string ',' string ',' string ',' VARIABLE ',' number2 ',' char ')'  {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON) && !checkVariableWithType($<strval>11, first, STACK_ALPHABET) ){
            yyerror("Variable not defined");
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "add_transition(%s, %s, %s, %s, %s, %s, %s)", $<strval>3, $<strval>5, $<strval>7, $<strval>9,$<strval>11, $<strval>13, $<strval>15);
        $$=aux;
    }
    |EX '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "execute(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    |CL '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        fprintf(yyout, "close(%s);\n", $<strval>3); $$="";
    }
    |ST '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "start(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    |NX '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "next(%s)", $<strval>3);
        $$=aux;
    }
    |ISF '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "is_finished(%s)", $<strval>3);
        $$=aux;
    }
    | PA '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror("Variable not defined");
            return -1; 
        }
        fprintf(yyout, "print_aut(%s);", $<strval>3);
        $$="";
    }
    ;

simple_string_list: SIMPLE_STRING  {fprintf(yyout, "%s",$<strval>1);}
            | simple_string_list ',' SIMPLE_STRING {fprintf(yyout, " , %s",$<strval>3);}
            ;

string_list: STRING  {fprintf(yyout, "%s",$<strval>1);}
            | LAMBDA2 {fprintf(yyout, "LAMBDA");}
            | string_list ',' STRING {fprintf(yyout, " , %s",$<strval>3);}
            ;

expr_list: expr  {fprintf(yyout, "%s",$<strval>1);}
            |expr_list expr { fprintf(yyout, "%s",$<strval>2);}
            ;

number:
    INTEGER {fprintf(yyout, "%s", $<strval>1);}
    |VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){
                yyerror("Variable not defined");
                return -1; 
        }
    fprintf(yyout, "%s", $<strval>1); }
    ;
number2:
    INTEGER 
    |VARIABLE  {
     if(!checkVariable((char *)$<strval>1, first)){ //TODO ver que la variable sea un integer
                yyerror("Variable not defined");
                return -1; 
        }
    }
    ;

string:
    STRING 
    |VARIABLE  {
     if(!checkVariable((char *)$<strval>1, first)){ //TODO ver que la variable sea string
                yyerror("Variable not defined");
                return -1; 
        }
    }
    ;
char:
    SIMPLE_STRING 
    |VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){ //TODO ver que la variable se char. Tendria que aceptar integer tambien? 
                yyerror("Variable not defined");
                return -1; 
        }
    }
    ;

conditional:
        number 
    |   number '<' {fprintf(yyout, " < ");} number 
    |   number LE {fprintf(yyout, " <= ");} number 
    |   number EQ {fprintf(yyout, " == ");} number
    |   number NE {fprintf(yyout, " != ");} number
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
    fprintf(yyout,"#include \"automaton.h\"\n");
    fprintf(yyout, "int main(){\n"); 
    if(yyparse()!=0){
        fclose(yyin);
        fclose(yyout);
        return 0;
    }
    fprintf(yyout, "return 0;\n");
    fprintf(yyout, "}\n"); 

    fclose(yyin);
    fclose(yyout);
    return 1; 

}

