%{
#include <stdlib.h> 
void yyerror(char *);
 #include "y.tab.h"
%} 


%%
"main()" return MAIN;
"{"     return OPEN_DEL;
"}"     return CLOSE_DEL;
"int "   {yylval=5; return TYPE;}
[a-z] {
    yylval =*yytext - 'a';
    return VARIABLE;
    }
[0-9]+ {
    yylval = atoi(yytext);
    return INTEGER;
    }
[-+()=*/] {
    return *yytext;
    }
[\n]    ;
[\t]   ;
" "  ;
";"  return *yytext;
. {printf("es: %s\n", yytext); yyerror("invalid character"); };
%%


int yywrap(void) {
   return 1;
}