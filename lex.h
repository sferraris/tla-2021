#ifndef LEX_H
#define LEX_H
 

enum types{
    CHAR, 
    INT,  
    LONG,
    LONG_INT,  
    LONG_LONG, 
    FLOAT, 
    DOUBLE, 
    LONG_DOUBLE, 
    STATES, 
    AUTOMATON, 
    INPUT_ALPHABET,
    STACK_ALPHABET,
    STRING_TYPE,
    DEFINE,
    TURING_MACHINE,
    MOVEMENT,
    TAPE_ALPHABET
};

char * getType(enum types type);

struct variables{
    enum types type;
    char * var;
    struct variables * next;
};

int checkVariable(char * var, struct variables * first);

int checkVariableWithType(char * var, struct variables * first, enum types type);

int addVariable(char * var, enum types type, struct variables ** first);

int is_special_type(char * var, struct variables * first);

#endif