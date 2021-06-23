%{
#include <stdlib.h> 
void yyerror(char *);
 #include "y.tab.h"
 #include "lex.h"
 #include <string.h>
%} 


%%
"main()" return MAIN;
"{"     return OPEN_DEL;
"}"     return CLOSE_DEL;


"char "  {yylval.ival=CHAR; return TYPE;}
"signed"[' ']+"char "  {yylval.ival=SIGNED_CHAR; return TYPE;} 
"unsigned"[' ']+"char "  {yylval.ival=UNSIGNED_CHAR; return TYPE;} 
"short "  {yylval.ival=SHORT; return TYPE;} 
"short"[' ']+"int "  {yylval.ival=SHORT_INT; return TYPE;}
"signed"[' ']+"short "  {yylval.ival=SIGNED_SHORT; return TYPE;}
"signed"[' ']+"short"[' ']+"int "  {yylval.ival=SIGNED_SHORT_INT; return TYPE;}
"unsigned"[' ']+"short "  {yylval.ival=UNSIGNED_SHORT; return TYPE;}
"unsigned"[' ']+"short"[' ']+"int " {yylval.ival=UNSIGNED_SHORT_INT; return TYPE;}
"int "  {yylval.ival=INT; return TYPE;}
"signed "  {yylval.ival=SIGNED; return TYPE;}
"signed"[' ']+"int "  {yylval.ival=SIGNED_INT; return TYPE;}
"unsigned "  {yylval.ival=UNSIGNED; return TYPE;}
"unsigned"[' ']+"int "  {yylval.ival=UNSIGNED_INT; return TYPE;}
"long "  {yylval.ival=LONG; return TYPE;}
"long"[' ']+"int " {yylval.ival=LONG_INT; return TYPE;}
"signed"[' ']+"long "  {yylval.ival=SIGNED_LONG; return TYPE;}
"signed"[' ']+"long"[' ']+"int "  {yylval.ival=SIGNED_LONG_INT; return TYPE;}
"unsigned"[' ']+"long "  {yylval.ival=UNSIGNED_LONG; return TYPE;}
"unsigned"[' ']+"long"[' ']+"int "  {yylval.ival=UNSIGNED_LONG_INT; return TYPE;}
"long"[' ']+"long "  {yylval.ival=LONG_LONG; return TYPE;}
"long"[' ']+"long"[' ']+"int "  {yylval.ival=LONG_LONG_INT; return TYPE;}
"signed"[' ']+"long"[' ']+"long "  {yylval.ival=SIGNED_LONG_LONG; return TYPE;}
"signed"[' ']+"long"[' ']+"long"[' ']+"int "  {yylval.ival=SIGNED_LONG_LONG_INT; return TYPE;}
"unsigned"[' ']+"long"[' ']+"long " {yylval.ival=UNSIGNED_LONG_LONG; return TYPE;}
"unsigned"[' ']+"long"[' ']+"long"[' ']+"int " {yylval.ival=UNSIGNED_LONG_LONG_INT; return TYPE;}
"float "  {yylval.ival=FLOAT; return TYPE;}
"double "  {yylval.ival=DOUBLE; return TYPE;}
"long"[' ']+"double "  {yylval.ival=LONG_DOUBLE; return TYPE;}
"states "  {yylval.ival=STATES; return TYPE;}
"automaton "  {yylval.ival=AUTOMATON; return TYPE;}
"alphabet " {yylval.ival=ALPHABET; return TYPE;}

"print" {yylval.ival=0;return PRINT;}
"while" {yylval.ival=0;return WHILE;}



"if" {yylval.ival=0;return IF;}
"AND" {yylval.ival=0;return AND;}
"OR" {yylval.ival=0;return OR;}
"NOT" {yylval.ival=0;return NOT;}
"&&" {yylval.ival=0;return AND;}
"||" {yylval.ival=0;return OR;}
"!" {yylval.ival=0;return NOT;}
">=" { yylval.ival=0;return GE;}
"==" { yylval.ival=0;return EQ;}
"<=" { yylval.ival=0;return LE;}

[a-z]+ {
    yylval.strval =strdup(yytext);
    return VARIABLE;
    }
[0-9]+ {
    yylval.strval = strdup(yytext);
    return INTEGER;
    }

"\""[a-zA-Z0-9\\]+"\"" {
    yylval.strval =strdup(yytext);
    return STRING;
}

[-+()=*/><!] {
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