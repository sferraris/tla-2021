#ifndef LEX_H
#define LEX_H
 

enum types{
    CHAR, 
    SIGNED_CHAR,
    UNSIGNED_CHAR, 
    SHORT, 
    SHORT_INT, 
    SIGNED_SHORT, 
    SIGNED_SHORT_INT, 
    UNSIGNED_SHORT, 
    UNSIGNED_SHORT_INT, 
    INT, 
    SIGNED, 
    SIGNED_INT, 
    UNSIGNED, 
    UNSIGNED_INT, 
    LONG,
    LONG_INT, 
    SIGNED_LONG, 
    SIGNED_LONG_INT,
    UNSIGNED_LONG, 
    UNSIGNED_LONG_INT, 
    LONG_LONG, 
    LONG_LONG_INT, 
    SIGNED_LONG_LONG, 
    SIGNED_LONG_LONG_INT, 
    UNSIGNED_LONG_LONG, 
    UNSIGNED_LONG_LONG_INT,
    FLOAT, 
    DOUBLE, 
    LONG_DOUBLE, 
    STATES, 
    AUTOMATON, 
    INPUT_ALPHABET,
    STACK_ALPHABET,
    STRING_TYPE
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

#endif