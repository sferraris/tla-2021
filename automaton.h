#ifndef AUTOMATON_H
#define AUTOMATON_H

#include "lib.h"
#include "stack.h"

#define LAMBDA 0
#define LAMBDA_INDEX -1

typedef struct {
    string input_string;
    int current_iteration_pointer;

    int current_state;
    stack * stack;

}aut_iteration;

typedef struct{
    int state_from;
    int state_to;
    int stack_condition;
    int * stack_replacement;
    int stack_replacement_size;

    char c;
}transition;

typedef struct {
    char * input_alphabet;
    int input_alphabet_size;
    string * stack_alphabet;
    int stack_alphabet_size;

    string * states;
    int states_size;

    int * final_states;
    int final_states_size;

    int initial_input_state;
    int initial_stack;

    int transition_size;
    transition ** transition;

    int started;
    aut_iteration * current_iteration;

} automaton;

//Creates new pushdown Automaton, returns NULL on error
automaton * new_automaton(string * states, int states_size, char * input_alphabet, int input_alphabet_size, string * stack_alphabet, int stack_alphabet_size, string initial_input_state, string initial_stack, string * final_states, int final_states_size);

//Add a new transition to a given automaton, returns 0 on error, 1 on success
int add_transition(automaton * automaton, string state_from, string state_to, string stack_condition, string * stack_replacement, int stack_replacement_size, char c);

//Executes an automaton with a given string, returns 0 on error, 1 on success
int execute(automaton * automaton, string input_string);

//Starts an automaton with a given string and implements iteration, returns 0 on error, 1 on success
int start(automaton * automaton, string input_string);

//Next element of the automaton iteration, returns 0 on error, 1 on success
int next(automaton * automaton);

//Cloase an opened automaton and free data structures
void close(automaton * automaton);

//Returns 1 if iteration finished, 0 if not
int is_finished(automaton * automaton);

//Prints the entire information of the automaton
void print_aut(automaton * a);

//Prints the explanation of the automaton and its entire information
void print_extended_aut(automaton * a);

//Prints the current Iteration state
void print_current_state(automaton * a);


#endif