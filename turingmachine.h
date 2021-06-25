#ifndef TURINGMACHINE_H
#define TURINGMACHINE_H

#include "lib.h"
#include "doublelist.h"

#define CONFIGURATION_PRINT_N 5


typedef struct {
    string input_string;

    int current_state;

    doublelist * list;

}tm_iteration;

typedef struct{
    int state_from;
    int state_to;

    movement move;

    int tape_condition;
    int tape_replacement;
}tm_transition;

typedef struct{

    char * input_alphabet;
    int input_alphabet_size;

    char * tape_alphabet;
    int tape_alphabet_size;

    string * states;
    int states_size;

    int * final_states;
    int final_states_size;

    int initial_input_state;

    char blank;

    int transition_size;
    tm_transition ** transition;

    int started;
    tm_iteration * current_iteration;
}turing_machine;


//Creates new turing_machine, returns NULL on error
turing_machine * new_turing_machine(string * states, int states_size, char * input_alphabet, int input_alphabet_size, char * tape_alphabet, int tape_alphabet_size, string initial_input_state, string * final_states, int final_states_size, char blank);

//Add a new transition to a given turing_machine, returns 0 on error, 1 on success
int add_transition_tm(turing_machine * turing_machine, string state_from, string state_to, char tape_condition, char tape_replacement, movement move);

//Executes an turing_machine with a given string, returns 0 on error, 1 on success
int execute_tm(turing_machine * turing_machine, string input_string);

//Starts an turing_machine with a given string and implements iteration, returns 0 on error, 1 on success
int start_tm(turing_machine * turing_machine, string input_string);

//Next element of the turing_machine iteration, returns 0 on error, 1 on success
int next_tm(turing_machine * turing_machine);

//Cloase an opened turing_machine and free data structures
void close_tm(turing_machine * turing_machine);

//Returns 1 if iteration finished, 0 if not
int is_finished_tm(turing_machine * turing_machine);

//Prints the entire information of the turing_machine
void print_tm(turing_machine * tm);

//Prints the explanation of the turing_machine and its entire information
void print_extended_tm(turing_machine * tm);

//Prints the current Iteration state
void print_current_configuration(turing_machine * tm);
#endif