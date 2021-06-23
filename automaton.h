#ifndef AUTOMATON_H
#define AUTOMATON_H

#include "strings.h"
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

//Returns 1 if a word is in the automaton's input alphabet and 0 if it isn't
int is_input_alphabet(automaton * automaton, char c);

//Returns 1 if a word is in the automaton's stack alphabet and 0 if it isn't
int is_stack_alphabet(automaton * automaton, string word);

//Returns 1 if a word is in the automaton's states list and 0 if it isn't
int is_state(automaton * automaton, string state);

//Returns 1 if a word is in the automaton's final states list and 0 if it isn't
int is_final_state(automaton * automaton, string state);


#endif