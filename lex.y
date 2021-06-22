%token INTEGER 
%token VARIABLE
%token MAIN
%token OPEN_DEL
%token CLOSE_DEL 
%token TYPE
%left '+' '-'
%left '*' '/'
%{
    #include <stdio.h>
    void yyerror(char *);
    int yylex(void);
    int sym[26];
    extern FILE * yyin;
%}
%%
statement:
        | MAIN OPEN_DEL expr CLOSE_DEL {printf("got main\n");}
        ;
expr:
    INTEGER {$$=$1;}
    | expr expr 
    | expr '+' expr {$$=$1+$3;printf("suma: %d %d\n", $1, $3);}
    | expr '-' expr {$$=$1-$3;}
    | expr '*' expr {$$=$1*$3;}
    | expr '/' expr {$$=$1/$3;}
    | '(' expr ')' {$$=$2;}
    | VARIABLE {$$=sym[$1]; printf("num: %d\n", sym[$1]);}
    | VARIABLE '=' expr ';' { sym[$1] = $3;  printf("asignacion sin int: %d %d\n", $1, $3);} 
    | TYPE VARIABLE '=' expr ';' {sym[$2] = $4; printf("con int: %d %d %d\n", $1, sym[$2], $4);}
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
    yyparse();
    return 0; 

}

