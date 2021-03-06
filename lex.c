#include "lex.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char * getType(enum types type){
    char * types[] = {
    "char", 
    "int", 
    "long", 
    "long int",  
    "long long", 
    "float", 
    "double", 
    "long double", 
    "states", 
    "automaton", 
    "input_alphabet",
    "stack_alphabet",
    "string",
    "#define",
    "turing_machine",
    "movement",
    "tape_alphabet"
    };

    return types[type];

}

int checkVariable(char * var, struct variables * first){
    while(first != 0){
        if(strcmp(var, first->var) == 0){
            return 1;
        }
        first = first->next;
    }
    return 0;
}

int checkVariableWithType(char * var, struct variables * first, enum types type){
    while(first != 0){
        if(strcmp(var, first->var) == 0){
            return first->type == type;
        }
        first = first->next;
    }
    return 0;
}

int addVariable(char * var, enum types type,  struct variables ** first){
    if(*first == 0){
         *first = malloc(sizeof(struct variables));
        (*first)->var = malloc(strlen(var)+1);
        memcpy((*first)->var, var, strlen(var));
        (*first)->type = type;
        (*first)->next = 0;
        return 1;
    }
    struct variables * aux = *first;
    while(aux->next !=0){
        if(strcmp(var, aux->var) == 0){
            return 0;
        }
        aux=aux->next;
  
    }
    if(strcmp(var, aux->var) == 0){
        return 0;
    }
    aux->next = malloc(sizeof(struct variables));
    aux = aux->next;
    aux->var = malloc(strlen(var)+1);
    memcpy(aux->var, var, strlen(var));
    aux->type = type;
    aux->next = 0;


    return 1;
}

int is_special_type(char * var, struct variables * first){
    while(first != 0){
        if(strcmp(var, first->var) == 0){
            if(first->type >= STATES){
                return 0;
            }
            return 1;
        }
        first = first->next;
    }
    return 0;

}

int save_memory(char * new_memory, struct memory ** mems){

     if(*mems == 0){
         *mems = malloc(sizeof(struct memory));
        (*mems)->mem = new_memory;
        (*mems)->next = 0;
        return 1;
    }
    struct memory * aux = *mems;
    while(aux->next !=0){
        aux=aux->next;
  
    }
    aux->next = malloc(sizeof(struct memory));
    aux = aux->next;
    aux->mem = new_memory;
    aux->next = 0;


    return 1;
}

void free_memory(struct memory * mems){
    if(mems == 0){
        return;
    }
    free_memory(mems->next);
    free(mems->mem);
    free(mems);
}
void free_variables(struct variables * var){
    if(var == 0){
        return;
    }
    free_variables(var->next);
    free(var->var);
    free(var);
}