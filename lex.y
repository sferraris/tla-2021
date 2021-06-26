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
%token <ival> END
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
%type <strval> action
%type <strval> action_list
%locations


%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "lex.h"
    #include "automaton.h"
    #include "turingmachine.h"
    #define MAX_LENGTH 1024
    void yyerror2(char * msg, char * word);
    void yyerror(char * s);
    int yylex(void);
    extern FILE * yyin, * yyout;
    struct variables * first = 0;
    struct memory * mem = 0;
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
    INTEGER {
        char * aux = malloc(strlen($<strval>1)+1);
        save_memory(aux, &mem);
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | SIMPLE_STRING{char * aux = malloc(strlen($<strval>1)+1);
         save_memory(aux, &mem);
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    | VARIABLE {
        if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
        char * aux = malloc(strlen($<strval>1)+1);
        save_memory(aux, &mem);
        sprintf(aux, "%s", $<strval>1); $$=aux; }
    | DEF_VARIABLE {
        if(!checkVariable((char *)$<strval>1, first)){
                yyerror2("Macro is not defined", $<strval>1);
                return -1; 
        }
        
        char * aux = malloc(strlen($<strval>1)+1);
        save_memory(aux, &mem); sprintf(aux, "%s", $<strval>1); $$=aux; }
    | expr '+' expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+2); save_memory(aux, &mem);sprintf(aux, "%s+%s", $<strval>1, $<strval>3);$$=aux;}
    | expr '-' expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+2); save_memory(aux, &mem);sprintf(aux, "%s-%s", $<strval>1, $<strval>3);$$=aux;}
    | expr '*' expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+2); save_memory(aux, &mem);sprintf(aux, "%s*%s", $<strval>1, $<strval>3);$$=aux;}
    | expr '/' expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+2); save_memory(aux, &mem);sprintf(aux, "%s/%s", $<strval>1, $<strval>3);$$=aux;}
    | '(' expr ')' {char * aux = malloc(strlen($<strval>2)+1); save_memory(aux, &mem);sprintf(aux, "(%s)", $<strval>1);$$=aux;}  
    | asignable_functions
    ;

asignable_functions:  AT '(' VARIABLE ',' string ',' string ',' string ',' VARIABLE ',' number2 ',' char ')'  {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON) && !checkVariableWithType($<strval>11, first, STACK_ALPHABET) ){
            yyerror2("Variable not defined or of the wrong type", $$);
            return -1; 
        }
        char * aux = malloc(strlen("add_transition()") + strlen($<strval>3) + strlen($<strval>5) + strlen($<strval>7) +strlen($<strval>9) +strlen($<strval>11) +strlen($<strval>13) +strlen($<strval>15)+7);
        save_memory(aux, &mem);
        sprintf(aux, "add_transition(%s,%s,%s,%s,%s,%s,%s)", $<strval>3, $<strval>5, $<strval>7, $<strval>9,$<strval>11, $<strval>13, $<strval>15);
        $$=aux;
    }
    | EX '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("execute()") + strlen($<strval>3) + strlen($<strval>5)+3);
        save_memory(aux, &mem);
        sprintf(aux, "execute(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | ST '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
             yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("start( )") + strlen( $<strval>3) + strlen($<strval>5) + 3);
        save_memory(aux, &mem);
        sprintf(aux, "start(%s, %s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | NX '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("next()") + strlen( $<strval>3) + 1);
        save_memory(aux, &mem);
        sprintf(aux, "next(%s)", $<strval>3);
        $$=aux;
    }
    | ISF '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,AUTOMATON)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("is_finished()") + strlen( $<strval>3) + 1);
        save_memory(aux, &mem);
        sprintf(aux, "is_finished(%s)", $<strval>3);
        $$=aux;
    }
    | ATM '(' VARIABLE ',' string ',' string ',' char ',' char ',' movement ')'  {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $$);
            return -1; 
        }
        char * aux = malloc(strlen("add_transition_tm()") + strlen($<strval>3) + strlen($<strval>5) + strlen($<strval>7) +strlen($<strval>9) +strlen($<strval>11) +strlen($<strval>13)+6);
        save_memory(aux, &mem);
        sprintf(aux, "add_transition_tm(%s,%s,%s,%s,%s,%s)", $<strval>3, $<strval>5, $<strval>7, $<strval>9,$<strval>11, $<strval>13);
        $$=aux;
    }
    | EXM '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("execute_tm()") + strlen( $<strval>3) + strlen($<strval>5) + 2);
        save_memory(aux, &mem);
        sprintf(aux, "execute_tm(%s,%s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | STM '(' VARIABLE ',' string ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
             yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("start_tm()") + strlen( $<strval>3) + strlen($<strval>5) + 2);
        save_memory(aux, &mem);
        sprintf(aux, "start_tm(%s,%s)", $<strval>3, $<strval>5);
        $$=aux;
    }
    | NXM '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("next_tm()") + strlen( $<strval>3) + 1);
        save_memory(aux, &mem);
        sprintf(aux, "next_tm(%s)", $<strval>3);
        $$=aux;
    }
    | ISFM '(' VARIABLE ')' {
        if(!checkVariableWithType($<strval>3, first,TURING_MACHINE)){
            yyerror2("Variable not defined or of the wrong type", $<strval>3);
            return -1; 
        }
        char * aux = malloc(strlen("is_finished_tm()") + strlen( $<strval>3) + 1);
        save_memory(aux, &mem);
        sprintf(aux, "is_finished_tm(%s)", $<strval>3);
        $$=aux;
    }
    ;



stmt: VARIABLE '=' expr ';' {
        if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
        char * aux = malloc(strlen($<strval>1)  + strlen( $<strval>3) + 4);
        save_memory(aux, &mem);
        sprintf(aux, "%s=%s;\n", $<strval>1, $<strval>3); $$=aux;}
    | TYPE VARIABLE '=' expr ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        char * aux = malloc(strlen(getType($<ival>1)) + strlen($<strval>2)  + strlen( $<strval>4) + 5);
        save_memory(aux, &mem);
        sprintf(aux, "%s %s=%s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$=aux;
        }
    | TYPE VARIABLE ';' {
         if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        char * aux = malloc(strlen(getType($<ival>1)) + strlen($<strval>2) + 4);
        save_memory(aux, &mem);
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
    | MOVEMENT_TYPE VARIABLE '=' MTS ';' {
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
        }
        
        fprintf(yyout, "%s %s = %s;\n",getType($<ival>1), $<strval>2, $<strval>4); $$="";
    } 
    | IF {fprintf(yyout, "if(");}'(' conditional ')' {fprintf(yyout, "){\n");}  OPEN_DEL action_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | PRINT '('  STRING ')' ';' {fprintf(yyout, "printf(%s);\n", $<strval>3);$$="";}
    | WHILE  {fprintf(yyout, "while(");}'(' conditional ')'{fprintf(yyout, "){\n");}  OPEN_DEL action_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
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
    | AUTOMATON_T VARIABLE ';'{
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2); 
                return -1; 
        }
        fprintf(yyout, "automaton * %s;\n", $<strval>2); $$ = "";
    }
    | VARIABLE '=' NA '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2  ',' string ',' string ',' VARIABLE ',' number2 ')' ';'{
         if(!checkVariableWithType((char *) $<strval>1, first, AUTOMATON) && !checkVariableWithType((char *)$<strval>5, first, STATES) && !checkVariableWithType((char *)$<strval>9, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>13, first, STACK_ALPHABET) && !checkVariableWithType((char *)$<strval>21, first, STACK_ALPHABET) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "%s = new_automaton(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>1,$<strval>5, $<strval>7, $<strval>9,$<strval>11,$<strval>13,$<strval>15,$<strval>17,$<strval>19,$<strval>21,$<strval>23); $$ = "";
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
    | TM VARIABLE ';'{
        if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2); 
                return -1; 
        }
        fprintf(yyout, "turing_machine * %s ;\n", $<strval>2); $$ = "";
    }
    | VARIABLE '=' NTM '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2 ',' string ',' VARIABLE ',' number2 ',' char ')' ';'{
         if(!checkVariableWithType($<strval>1, first, TURING_MACHINE) && !checkVariableWithType((char *)$<strval>5, first, STATES) && !checkVariableWithType((char *)$<strval>9, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>13, first, TAPE_ALPHABET) && !checkVariableWithType((char *)$<strval>19, first, STATES) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "%s = new_turing_machine(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>1,$<strval>5, $<strval>7, $<strval>9,$<strval>11,$<strval>13,$<strval>15,$<strval>17,$<strval>19,$<strval>21,$<strval>23); $$ = "";
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
    | END {fprintf(yyout,"return 0;\n");$$="";}
    ;

action: VARIABLE '=' expr ';' {
        if(!is_special_type((char *)$<strval>1, first)){
                yyerror2("Variable is not defined or is not numeric", $<strval>1);
                return -1; 
        }
        char * aux = malloc(strlen($<strval>1)  + strlen( $<strval>3) + 4);
        save_memory(aux, &mem);
        sprintf(aux, "%s=%s;\n", $<strval>1, $<strval>3); $$=aux;}
    | IF {fprintf(yyout, "if(");}'(' conditional ')' {fprintf(yyout, "){\n");}  OPEN_DEL action_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | PRINT '('  STRING ')' ';' {fprintf(yyout, "printf(%s);\n", $<strval>3);$$="";}
    | WHILE  {fprintf(yyout, "while(");}'(' conditional ')'{fprintf(yyout, "){\n");}  OPEN_DEL action_list CLOSE_DEL {fprintf(yyout, "}\n");$$="";}
    | VARIABLE '=' NA '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2  ',' string ',' string ',' VARIABLE ',' number2 ')' ';'{
         if(!checkVariableWithType((char *) $<strval>1, first, AUTOMATON) && !checkVariableWithType((char *)$<strval>5, first, STATES) && !checkVariableWithType((char *)$<strval>9, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>13, first, STACK_ALPHABET) && !checkVariableWithType((char *)$<strval>21, first, STACK_ALPHABET) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "%s = new_automaton(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>1,$<strval>5, $<strval>7, $<strval>9,$<strval>11,$<strval>13,$<strval>15,$<strval>17,$<strval>19,$<strval>21,$<strval>23); $$ = "";
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
    | VARIABLE '=' NTM '('  VARIABLE ',' number2 ',' VARIABLE ',' number2  ',' VARIABLE ','  number2 ',' string ',' VARIABLE ',' number2 ',' char ')' ';'{
         if(!checkVariableWithType($<strval>1, first, TURING_MACHINE) && !checkVariableWithType((char *)$<strval>5, first, STATES) && !checkVariableWithType((char *)$<strval>9, first, STRING_TYPE) && !checkVariableWithType((char *)$<strval>13, first, TAPE_ALPHABET) && !checkVariableWithType((char *)$<strval>19, first, STATES) ){
                yyerror2("Variable not defined or of the wrong type", $$);
                return -1; 
        }
        fprintf(yyout, "%s = new_turing_machine(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);\n", $<strval>1,$<strval>5, $<strval>7, $<strval>9,$<strval>11,$<strval>13,$<strval>15,$<strval>17,$<strval>19,$<strval>21,$<strval>23); $$ = "";
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
    | END {fprintf(yyout,"return 0;\n");$$="";}
;

action_list: action  {fprintf(yyout, "%s",$<strval>1);}
            |action_list action { fprintf(yyout, "%s",$<strval>2);}
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
        char * aux = malloc(strlen("#define ") + strlen($<strval>2) + strlen($<strval>3) + 2);
        save_memory(aux, &mem);
        sprintf(aux, "#define %s %s", $<strval>2, $<strval>3);$$=aux;}
       | DEFINE_TYPE DEF_VARIABLE '(' simple_expr ')' {
            if(!addVariable($<strval>2, $<ival>1, &first)){
                yyerror2("Variable was already defined in this scope", $<strval>2);
                return -1; 
            }
        char * aux = malloc(strlen("#define ()") + strlen($<strval>2) + strlen($<strval>4) + 2);
        save_memory(aux, &mem);
        sprintf(aux, "#define %s (%s)", $<strval>2, $<strval>4);
        $$=aux;}
;

define_list: define {fprintf(yyout, "%s\n", $<strval>1);}
            | define_list define {fprintf(yyout, "%s\n", $<strval>2);}
;

simple_expr:
    INTEGER
    | simple_expr '+' simple_expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+4); save_memory(aux, &mem); sprintf(aux, "%s + %s", $<strval>1, $<strval>3);$$=aux;}
    | simple_expr '-' simple_expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+4); save_memory(aux, &mem);sprintf(aux, "%s - %s", $<strval>1, $<strval>3);$$=aux;}
    | simple_expr '*' simple_expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+4); save_memory(aux, &mem);sprintf(aux, "%s * %s", $<strval>1, $<strval>3);$$=aux;}
    | simple_expr '/' simple_expr {char * aux = malloc(strlen($<strval>1)+strlen($<strval>3)+4); save_memory(aux, &mem);sprintf(aux, "%s / %s", $<strval>1, $<strval>3);$$=aux;}
    | '(' simple_expr ')' {char * aux = malloc(strlen($<strval>2)+3); save_memory(aux, &mem);sprintf(aux, "(%s)", $<strval>1);$$=aux;}  
    ;
value:  INTEGER {char * aux =malloc(strlen($<strval>1) +1);
        save_memory(aux, &mem);
        sprintf(aux, "%s", $<strval>1);
        $$=aux;
        }
    ;


number:
    INTEGER {fprintf(yyout, "%s", $<strval>1);}
    |VARIABLE {
     if(!checkVariable((char *)$<strval>1, first)){
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
    | LAMBDA2
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
    fprintf(stderr, "\033[1m\033[31m%s in line: %d \n\n\033[0m", s, yylineno); 
}



int main(int argc, char ** argv) {

    if(argc != 2){
        printf("Needs a file\n");
        return 0;
    }
    char aux[strlen(argv[1])]; 
    strcpy(aux, argv[1]);
    char* token = strtok(aux, ".");
    while (token != NULL) {
        memcpy(aux, token, strlen(token)+1);
        token = strtok(NULL, ".");
    }
    if (strcmp(aux, "rdk") != 0) {
        fprintf(stderr, "Wrong file extension\n");
        return 0;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "File does not exist\n");
        return 0;
    }
    yyout = fopen("output.c", "w");
    fprintf(yyout,"#include <stdio.h>\n");
    fprintf(yyout,"#include \"automaton.h\"\n");
    fprintf(yyout,"#include \"turingmachine.h\"\n");
    if(yyparse()!=0){
        fclose(yyin);
        fclose(yyout);
        return 0;
    }
    free_memory(mem);
    free_variables(first);
    fprintf(yyout, "return 0;\n");
    fprintf(yyout, "}\n"); 

    fclose(yyin);
    fclose(yyout);
    return 1; 

}

