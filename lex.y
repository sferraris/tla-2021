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
%token <ival> PEA
%token <ival> PCS
%token <ival> TM
%token <ival> NTM
%token <ival> MOVEMENT_TYPE 
%token <ival> ATM
%token <ival> EXM
%token <ival> CLM
%token <ival> STM
%token <ival> NXM
%token <ival> ISFM
%token <ival> PM
%token <ival> PEM
%token <ival> PCC
%token <ival> GE
%token <ival> EQ
%token <ival> LE
%token <ival> NE
%token <strval> LAMBDA2
%token <strval> MTS
%token <strval> DEFINE_TYPE
%token <strval> DEF_VARIABLE
%left '+' '-'
%left '*' '/'
%type <strval> expr
%type <strval> stmt
%type <strval> conditional
%type <strval> number
%type <strval> number2
%type <strval> string
%type <strval> stmt_list
%type <strval> simple_string_list
%type <strval> string_list
%type <strval> define_list
%type <strval> char
%type <strval> asignable_functions
%type <strval> define
%type <strval> value
%type <strval> simple_expr
%type <strval> movement
%error-verbose
%locations


%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "lex.h"
    #include "automaton.h"
    void yyerror2(char * msg, char * word);
    void yyerror(char * s);
    int yylex(void);
    int sym[26];
    extern FILE * yyin, * yyout;
    struct variables * first = 0;
    extern int yylineno;
%}
%union {
    char*   strval;
    int     ival;
}
%%
statement:
        | MAIN  {fprintf(yyout, "int main(){\n");}  OPEN_DEL stmt_list CLOSE_DEL 
        | define_list MAIN { fprintf(yyout, "int main(){\n"); }OPEN_DEL stmt_list CLOSE_DEL 
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
    | VARIABLE {
        if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
        
        char aux[100]; sprintf(aux, "%s", $<strval>1); $$=aux; }
    | DEF_VARIABLE {
        if(!checkVariable((char *)$<strval>1, first)){
                yyerror2("Macro is not defined", $<strval>1);
                return -1; 
        }
        
        char aux[100]; sprintf(aux, "%s", $<strval>1); $$=aux; }
    | expr '+' expr {char aux[100];sprintf(aux, "%s + %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '-' expr {char aux[100];sprintf(aux, "%s - %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '*' expr {char aux[100];sprintf(aux, "%s * %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '/' expr {char aux[100];sprintf(aux, "%s / %s", $<strval>1, $<strval>2);$$=aux;}
    | '(' expr ')' {char aux[100];sprintf(aux, "%s", $<strval>1);$$=aux;}  
    | asignable_functions
    ;

asignable_functions:  AT '(' VARIABLE ',' string ',' string ',' string ',' VARIABLE ',' number2 ',' char ')'  {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON) && !checkVariableWithType($<strval>11, first, STACK_ALPHABET) ){
            yyerror2("Variable not defined or of the wrong type", $$);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "add_transition(%s, %s, %s, %s, %s, %s, %s)", $<strval>3, $<strval>5, $<strval>7, $<strval>9,$<strval>11, $<strval>13, $<strval>15);
        $$=aux;
    }
    | EX '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "execute(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | ST '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
             yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "start(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | NX '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "next(%s)", $<strval>3);
        $$=aux;
    }
    | ISF '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "is_finished(%s)", $<strval>3);
        $$=aux;
    }
    | ATM '(' VARIABLE ',' string ',' string ',' char ',' char ',' movement ')'  {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $$);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "add_transition_tm(%s, %s, %s, %s, %s, %s)", $<strval>3, $<strval>5, $<strval>7, $<strval>9,$<strval>11, $<strval>13);
        $$=aux;
    }
    | EXM '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "execute_tm(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | STM '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
             yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "start_tm(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | NXM '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "next_tm(%s)", $<strval>3);
        $$=aux;
    }
    | ISFM '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char aux[1024];
        sprintf(aux, "is_finished_tm(%s)", $<strval>3);
        $$=aux;
    }
    ;



stmt: VARIABLE '=' expr ';' {
        if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
        char aux[100];
        sprintf(aux, "%s = %s;\n", $<strval>1, $<strval>3); $$=aux;}
    | TYPE VARIABLE '=' expr ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        char aux[1000];
        sprintf(aux, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$=aux;
        }
    | TYPE VARIABLE ';' {
         if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        char aux[1000];
        sprintf(aux, "%s %s;\n",getType($<ival>1), $<strval>2); $$=aux;
        
    }
    | SPECIAL_TYPE VARIABLE '=' OPEN_DEL
    {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        fprintf(yyout, "char %s[] = { ",$<strval>2);
    } simple_string_list CLOSE_DEL ';' { fprintf(yyout, " };\n");  $$ = "";}
    | SPECIAL_TYPE2 VARIABLE '=' OPEN_DEL
    {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        fprintf(yyout, "string %s[] = { ",$<strval>2);
    } string_list CLOSE_DEL ';' { fprintf(yyout, " };\n");  $$ = "";}
    | STRING_T VARIABLE '=' STRING ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        
        fprintf(yyout, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$="";
        }
    | MOVEMENT_TYPE VARIABLE '=' MTS {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        
        fprintf(yyout, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$="";
    } 
    | IF {fprintf(yyout, "if(");}'(' conditional ')' {fprintf(yyout, "){\n");}  OPEN_DEL stmt_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | PRINT '('  STRING ')' ';' {fprintf(yyout, "printf(%s);\n", $<strval>3);$$="";}
    | WHILE  {fprintf(yyout, "while(");}'(' conditional ')'{fprintf(yyout, "){\n");}  OPEN_DEL stmt_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | AUTOMATON_T VARIABLE '=' NA '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2  ',' string ',' string ',' VARIABLE ',' number2 ')' ';'{
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2); 
                return -1; 
        }
         if(!checkVariableWithType((char *)$<strval>6, first, STATES) && !checkVariableWithType((char *)$<strval>10, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>14, first, STACK_ALPHABET) && !checkVariableWithType((char *)$<strval>22, first, STACK_ALPHABET) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "automaton * %s = new_automaton(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>2,$<strval>6, $<strval>8, $<strval>10,$<strval>12,$<strval>14,$<strval>16,$<strval>18,$<strval>20,$<strval>22,$<strval>24); $$ = "";
    }
    | CL '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "close(%s);\n", $<strval>3); $$="";
    }
    | PA '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_aut(%s);", $<strval>3);
        $$="";
    }
    | PEA '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_extended_aut(%s);", $<strval>3);
        $$="";
    }
    | PCS '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_current_state(%s);", $<strval>3);
        $$="";
    }
    | TM VARIABLE '=' NTM '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2 ',' string ',' VARIABLE ',' number2 ',' char ')' ';'{
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2); 
                return -1; 
        }
         if(!checkVariableWithType((char *)$<strval>6, first, STATES) && !checkVariableWithType((char *)$<strval>10, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>14, first, TAPE_ALPHABET) && !checkVariableWithType((char *)$<strval>20, first, STATES) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "turing_machine * %s = new_turing_machine(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>2,$<strval>6, $<strval>8, $<strval>10,$<strval>12,$<strval>14,$<strval>16,$<strval>18,$<strval>20,$<strval>22,$<strval>24); $$ = "";
    }
    | CLM '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "close_tm(%s);\n", $<strval>3); $$="";
    }
    | PM '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_tm(%s);", $<strval>3);
        $$="";
    }
    | PEM '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_extended_tm(%s);", $<strval>3);
        $$="";
    }
    | PCC '(' VARIABLE ')' ';' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        fprintf(yyout, "print_current_configuration(%s);", $<strval>3);
        $$="";
    }
    | asignable_functions ';' {fprintf(yyout, "%s;\n", $<strval>1); $$="";}
    ;


simple_string_list: SIMPLE_STRING  {fprintf(yyout, "%s",$<strval>1);}
            | simple_string_list ',' SIMPLE_STRING {fprintf(yyout, " , %s",$<strval>3);}
            ;

string_list: STRING  {fprintf(yyout, "%s",$<strval>1);}
            | LAMBDA2 {fprintf(yyout, "LAMBDA");}
            | string_list ',' STRING {fprintf(yyout, " , %s",$<strval>3);}
            ;

stmt_list: stmt  {fprintf(yyout, "%s",$<strval>1);}
            |stmt_list stmt { fprintf(yyout, "%s",$<strval>2);}
            ;

define: DEFINE_TYPE DEF_VARIABLE value {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        char aux[100];
        sprintf(aux, "#define %s %s", $<strval>2, $<strval>3);$$=aux;}
       | DEFINE_TYPE DEF_VARIABLE '(' simple_expr ')' {
            if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
            }
            char aux[100];
        sprintf(aux, "#define %s (%s)", $<strval>2, $<strval>4);
        $$=aux;}
;

define_list: define {fprintf(yyout, "%s\n", $<strval>1);}
            | define_list define {fprintf(yyout, "%s\n", $<strval>2);}
;

simple_expr:
    INTEGER {char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | SIMPLE_STRING{char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | STRING {char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | expr '+' expr {char aux[100];sprintf(aux, "%s + %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '-' expr {char aux[100];sprintf(aux, "%s - %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '*' expr {char aux[100];sprintf(aux, "%s * %s", $<strval>1, $<strval>2);$$=aux;}
    | expr '/' expr {char aux[100];sprintf(aux, "%s / %s", $<strval>1, $<strval>2);$$=aux;}
    | '(' expr ')' {char aux[100];sprintf(aux, "%s", $<strval>1);$$=aux;}  
    ;
value:  INTEGER {char aux[100];
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    ;


number:
    INTEGER {fprintf(yyout, "%s", $<strval>1);}
    |VARIABLE {
     if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
    fprintf(yyout, "%s", $<strval>1); }
    |DEF_VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){
                yyerror2("Macro is not defined", $<strval>1);
                return -1; 
        }
    fprintf(yyout, "%s", $<strval>1); }
    | asignable_functions {fprintf(yyout, "%s", $<strval>1);}
    ;
number2:
    INTEGER 
    |VARIABLE  {
      if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
    }
    |DEF_VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){
                yyerror2("Macro is not defined", $<strval>1);
                return -1; 
        }
    }
    ;

string:
    STRING 
    |VARIABLE  {
     if(!checkVariableWithType((char *)$<strval>1, first, STRING_TYPE)){
                yyerror2("Variable not defined or of the wrong type", $<strval>1);
                return -1; 
        }
    }
    ;
char:
    SIMPLE_STRING 
    |VARIABLE {
     if(!checkVariableWithType((char *)$<strval>1, first, CHAR)){ //Tendria que aceptar integer tambien? 
                yyerror2("Variable not defined or of the wrong type", $<strval>1);
                return -1; 
        }
    }
    ;
movement:
    MTS 
    |VARIABLE {
     if(!checkVariableWithType((char *)$<strval>1, first, MOVEMENT)){
                yyerror2("Variable not defined or of the wrong type", $<strval>1);
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

void yyerror2(char * msg, char * word ) { 
    fprintf(stderr, "\033[1m\033[31m%s in line: %d \n%s\n\n\033[0m", msg, yylineno, word); 
}
void yyerror(char * s) { 
    fprintf(stderr, "%s in line: %d \n\n", s, yylineno); 
}



int main(int argc, char ** argv) {
    if(argc != 2){
        return 0;
    }
  
    yyin = fopen(argv[1], "r");
    yyout = fopen("output.c", "w");
    fprintf(yyout,"#include <stdio.h>\n");
    fprintf(yyout,"#include \"automaton.h\"\n");
    fprintf(yyout,"#include \"turingmachine.h\"\n");
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

