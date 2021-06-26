%{
#include <stdlib.h> 
void yyerror(char *);
 #include "y.tab.h"
 #include "lex.h"
 #include <string.h>

%}

%option yylineno



%%
"main()" return MAIN;
"{"     return OPEN_DEL;
"}"     return CLOSE_DEL;


"char "  {yylval.ival=CHAR; return TYPE;} 
"int "  {yylval.ival=INT; return TYPE;}
"long "  {yylval.ival=LONG; return TYPE;}
"long"[' ']+"int " {yylval.ival=LONG_INT; return TYPE;}
"long"[' ']+"long "  {yylval.ival=LONG_LONG; return TYPE;}
"float "  {yylval.ival=FLOAT; return TYPE;}
"double "  {yylval.ival=DOUBLE; return TYPE;}
"long"[' ']+"double "  {yylval.ival=LONG_DOUBLE; return TYPE;}
"states "  {yylval.ival=STATES; return SPECIAL_TYPE2;}
"automaton "  {yylval.ival=AUTOMATON; return AUTOMATON_T;}
"input_alphabet " {yylval.ival= INPUT_ALPHABET; return SPECIAL_TYPE;}
"stack_alphabet " {yylval.ival= STACK_ALPHABET; return SPECIAL_TYPE2;}
"string" {yylval.ival= STRING_TYPE; return STRING_T;}
"#define " {yylval.ival= DEFINE; return DEFINE_TYPE;}
"turing_machine" {yylval.ival= TURING_MACHINE; return TM;}
"movement" {yylval.ival= MOVEMENT; return MOVEMENT_TYPE;}
"tape_alphabet " {yylval.ival= TAPE_ALPHABET; return SPECIAL_TYPE;}

"print" {yylval.ival=0;return PRINT;}
"while" {yylval.strval=0;return WHILE;}
"new_automaton" {yylval.ival=0;return NA;}
"add_transition" {yylval.ival=0;return AT;}
"execute" {yylval.ival=0;return EX;}
"close" {yylval.ival=0;return CL;}
"start" {yylval.ival=0;return ST;}
"next" {yylval.ival=0;return NX;}
"is_finished" {yylval.ival=0;return ISF;}
"print_aut" {yylval.ival = 0; return PA;}
"print_extended_aut" {yylval.ival = 0; return PEA;}
"print_current_state" {yylval.ival = 0; return PCS;}
"new_turing_machine" {yylval.ival = 0; return NTM;} 
"add_transition_tm" {yylval.ival = 0; return ATM;}
"execute_tm" {yylval.ival=0;return EXM;}
"close_tm" {yylval.ival=0;return CLM;}
"start_tm" {yylval.ival=0;return STM;}
"next_tm" {yylval.ival=0;return NXM;}
"is_finished_tm" {yylval.ival=0;return ISFM;}
"print_tm" {yylval.ival = 0; return PM;}
"print_extended_tm" {yylval.ival = 0; return PEM;}
"print_current_configuration" {yylval.ival = 0; return PCC;} 


"if" {yylval.ival=0;return IF;}
"AND" {yylval.ival=0;return AND;}
"OR" {yylval.ival=0;return OR;}
"NOT" {yylval.strval=0;return NOT;}
"&&" {yylval.ival=0;return AND;}
"||" {yylval.ival=0;return OR;}
"!" {yylval.strval=0;return NOT;}
">=" { yylval.ival=0;return GE;}
"==" { yylval.ival=0;return EQ;}
"<=" { yylval.ival=0;return LE;}
"!=" { yylval.ival=0;return NE;}

"//"[ -~]*([\n]|[\r\n]) ;

"LAMBDA" {yylval.strval=strdup(yytext);return LAMBDA2;}
"LEFT" {yylval.strval=strdup(yytext);return MTS;}
"RIGHT" {yylval.strval=strdup(yytext);return MTS;}
"end;"  {yylval.ival = 0; return END;}

[a-z_]+ {
    yylval.strval =strdup(yytext);
    return VARIABLE;
    }
[A-Z_]+ {
yylval.strval =strdup(yytext);
return DEF_VARIABLE;
}
[-]?[0-9]+([.][0-9]+)? {
    yylval.strval = strdup(yytext);
    return INTEGER; 
    }

"\""[ a-zA-Z0-9\*\\]*"\"" {
    yylval.strval =strdup(yytext);
    return STRING;
}

"\'"[a-zA-Z0-9\*\\]"\'" {
    yylval.strval =strdup(yytext);
    return SIMPLE_STRING;
}

[-+()=*/><!,] {
    return *yytext;
    }
[\n\r]    ;
[\t]   ;
" "  ;
";"  return *yytext;
. { yyerror("invalid character"); };
%%


int yywrap(void) {
   return 1;
}