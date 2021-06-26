#include "turingmachine.h"

//Creates new turing_machine, returns NULL on error
turing_machine * new_turing_machine(string * states, int states_size, char * input_alphabet, int input_alphabet_size, char * tape_alphabet, int tape_alphabet_size, string initial_input_state, string * final_states, int final_states_size, char blank);
int add_transition_tm(turing_machine * turing_machine, string state_from, string state_to, char tape_condition, char tape_replacement, movement move);
int execute_tm(turing_machine * turing_machine, string input_string);
int start_tm(turing_machine * turing_machine, string input_string);
int next_tm(turing_machine * turing_machine);
void close_tm(turing_machine * turing_machine);
int is_finished_tm(turing_machine * turing_machine);
void print_tm(turing_machine * a);
void print_extended_tm(turing_machine * a);
void print_current_configuration(turing_machine * a);
turing_machine * init_turing_machine(string * states, int states_size, char * input_alphabet, int input_alphabet_size, char * tape_alphabet, int tape_alphabet_size, string initial_input_state, string * final_states, int final_states_size, char blank);
int validate_tm_transition(turing_machine * tm, tm_transition * t);
int is_tm_input_alphabet(turing_machine * tm, char c);
int is_tm_tape_alphabet(turing_machine * tm, char c);
int get_tm_transition(turing_machine * tm, int current_state, char condition);
void end_tm_iteration(turing_machine * tm);
int is_final_tm_state(turing_machine * tm, string state);
void free_tm(turing_machine * tm);
int get_tm_input_state_index(turing_machine * tm, string s);

turing_machine * new_turing_machine(string * states, int states_size, char * input_alphabet, int input_alphabet_size, char * tape_alphabet, int tape_alphabet_size, string initial_input_state, string * final_states, int final_states_size, char blank){
    
    if ( states_size == 0){
        printf("A Turing Machine can't have no states\n");
        return NULL;
    }

    if ( tape_alphabet_size == 0){
        printf("A Turing Machine can't have no tape alphabet\n");
        return NULL;
    }

    if ( final_states_size == 0){
        printf("A Turing Machine can't have no final states\n");
        return NULL;
    }

    if ( input_alphabet_size == 0){
        printf("A Turing Machine can't have no input alphabet\n");
        return NULL;
    }
    
    turing_machine * tm = init_turing_machine(states, states_size, input_alphabet, input_alphabet_size, tape_alphabet, tape_alphabet_size, initial_input_state, final_states, final_states_size, blank);
    if ( tm == NULL){
        printf("Error initializing turing machine\n");
        return NULL;
    }

    for ( int i = 0; i < input_alphabet_size; i++ ){
        if ( !is_tm_tape_alphabet(tm, input_alphabet[i]) ){
            printf("Input alphabet must be included in the tape alphabet\n");
            free_tm(tm);
            return NULL;
        }
    }

    return tm;

}

turing_machine * init_turing_machine(string * states, int states_size, char * input_alphabet, int input_alphabet_size, char * tape_alphabet, int tape_alphabet_size, string initial_input_state, string * final_states, int final_states_size, char blank){
    turing_machine * tm = malloc(sizeof(turing_machine));
    if ( tm == NULL){
        return NULL;
    }

    //Initialize tape alphabet
    tm->tape_alphabet_size = tape_alphabet_size;
    tm->tape_alphabet = malloc(sizeof(char) * tape_alphabet_size);
    for ( int i = 0; i < tape_alphabet_size; i++){
        tm->tape_alphabet[i] = tape_alphabet[i];
    }

    //Initialize input alphabet
    tm->input_alphabet_size = input_alphabet_size;
    tm->input_alphabet = malloc(sizeof(char) * input_alphabet_size);
    for ( int i = 0; i < input_alphabet_size; i++){
        tm->input_alphabet[i] = input_alphabet[i];
    }

    //Initialize states
    tm->states_size = states_size;
    tm->states = malloc(sizeof(string) * states_size);
    if ( tm->states == NULL){
        free_tm(tm);
        printf("states is null\n");
        return NULL;
    }
    for ( int i = 0; i < states_size; i++){
        int aux = strlen(states[i]);
        tm->states[i] = malloc(aux);
        if ( tm->states[i] == NULL){
            printf("states element is null\n");
            free_tm(tm);
            return NULL;
        }
        strcpy(tm->states[i], states[i]);
    }

    //Initialize final states
    tm->final_states_size = final_states_size;
    tm->final_states = malloc(sizeof(int) * final_states_size);
    if ( tm->final_states == NULL){
        printf("final state is null\n");
        free_tm(tm);
        return NULL;
    }
    for ( int i = 0; i < final_states_size; i++){
        tm->final_states[i] = get_tm_input_state_index(tm, final_states[i]);
        if ( tm->final_states[i] == -1){
            printf("final state element is not a state : %s\n", final_states[i]);
            free_tm(tm);
            return NULL;
        }
    }

    //Initialize initial input state
    tm->initial_input_state = get_tm_input_state_index(tm, initial_input_state);
    if ( tm->initial_input_state == -1){
        free_tm(tm);
        printf("initial state is not a state\n");
        return NULL;
    }

    tm->blank = blank;
    if ( !is_tm_tape_alphabet(tm, blank) ){
        free_tm(tm);
        printf("Blank Symbol is not in the Tape Alphabet\n");
        return NULL;
    }

    tm->transition = NULL;
    tm->transition_size = 0;

    tm->started = 0;
    tm->current_iteration = NULL;
    return tm;
}

void free_tm(turing_machine * tm){
    if ( tm != NULL){
        if ( tm->tape_alphabet != NULL){
            free(tm->tape_alphabet);
        }

        if ( tm->states != NULL){
            free(tm->states);
        }

        if ( tm->final_states != NULL){
            free(tm->final_states);
        }

        free(tm);
    }
}

int get_tm_input_state_index(turing_machine * tm, string s){
     for ( int i = 0; i < tm->states_size; i++){
        if ( strcmp(tm->states[i], s) == 0)
            return i;
    }
    return -1;
}

int get_alphabet_index(turing_machine * tm, char c){
    for ( int i = 0; i < tm->tape_alphabet_size; i++){
        if ( tm->tape_alphabet[i] == c)
            return i;
    }
    return -1;
}

int add_transition_tm(turing_machine * turing_machine, string state_from, string state_to, char tape_condition, char tape_replacement, movement move){

    tm_transition * t = malloc(sizeof(tm_transition));
    if ( t == NULL){
        printf("Error while adding transition, out of memory\n");
        return 0;
    }

    t->state_from = get_tm_input_state_index(turing_machine, state_from);
    if ( t->state_from == -1){
        printf("%s is not a state\n", state_from);
        free(t);
        return 0;
    }

    t->state_to = get_tm_input_state_index(turing_machine, state_to);
    if ( t->state_to == -1 ){
        printf("%s is not a state\n", state_to);
        free(t);
        return 0;
    }

    t->tape_condition = get_alphabet_index(turing_machine, tape_condition);
    if ( t->tape_condition == -1){
        printf("%c is not in the tape alphabet\n", tape_condition);
        free(t);
        return 0;
    }


    t->tape_replacement = get_alphabet_index(turing_machine, tape_replacement);
    if ( t->tape_replacement == -1){
        printf("%c is not in the tape alphabet\n", tape_replacement);
        free(t);
        return 0;
    }

    if ( move == RIGHT || move == LEFT)
        t->move = move;
    else{
        printf("The move parameter must be of the type movement\n");
        free(t);
        return 0;
    }

    if ( validate_tm_transition(turing_machine, t)){
        turing_machine->transition_size++;
        turing_machine->transition = realloc(turing_machine->transition, sizeof(tm_transition **) * turing_machine->transition_size);
        if ( turing_machine->transition == NULL){
            printf("Realloc failed\n");
            free(t);
            return 0;
        }
        turing_machine->transition[turing_machine->transition_size - 1] = t;
    }
    else{
        printf("A transition from %s with %c in the tape already exists\n", turing_machine->states[t->state_from], turing_machine->tape_alphabet[t->tape_condition]);
        free(t);
        return 0;
    }

    return 1;
}

int validate_tm_transition(turing_machine * tm, tm_transition * t){
    for ( int i = 0; i < tm->transition_size; i++){
        if ( tm->transition[i]->tape_condition == t->tape_condition 
            && tm->transition[i]->state_from == t->state_from ){
                return 0;
        }
    }
    return 1;
}

int start_tm(turing_machine * turing_machine, string input_string){
     
     if ( turing_machine->started == 0){
        for ( int i = 0; i < strlen(input_string); i++){
            if ( !is_tm_input_alphabet(turing_machine, input_string[i]) ){
                printf("The characters of the input string must belong to the input alphabet\n");
                return 0;
            }
        }

        turing_machine->current_iteration = malloc(sizeof(tm_iteration));
        if ( turing_machine->current_iteration == NULL){
            printf("Error while initializing iteration\n");
            return -1;
        }

        turing_machine->current_iteration->current_state = turing_machine->initial_input_state;
        turing_machine->current_iteration->list = newdoublelist(turing_machine->blank);

        if ( turing_machine->current_iteration->list == NULL){
            printf("Error while initializing tape\n");
            free(turing_machine->current_iteration);
            return -1;
        }

        //Write input string into the turing machine, set current at the start of said string
        int w = write_string(turing_machine->current_iteration->list, input_string);
        if ( w < 0){
            printf("Error while writing input string to the tape\n");
            free(turing_machine->current_iteration->list);
            free(turing_machine->current_iteration);
            return -1;
        }
        turing_machine->current_iteration->input_string = malloc(strlen(input_string));
        if ( turing_machine->current_iteration->input_string == NULL){
            printf("Error while initializing iteration\n");
            free(turing_machine->current_iteration->list);
            free(turing_machine->current_iteration);
            return -1;
        }
        strcpy(turing_machine->current_iteration->input_string, input_string);
        turing_machine->started = 1;
        return 1;
    }
    else {
        printf("Turing Machine had already been started, finish current execution to start another\n");
        return 0;
    }
}

int is_tm_input_alphabet(turing_machine * tm, char c){
    for ( int i = 0; i < tm->input_alphabet_size; i++){
        if ( c == tm->input_alphabet[i] )
            return 1;
    }
    return 0;
}

int is_tm_tape_alphabet(turing_machine * tm, char c){
    for ( int i = 0; i < tm->tape_alphabet_size; i++){
        if ( c == tm->tape_alphabet[i] )
            return 1;
    }
    return 0;
}

int next_tm(turing_machine * turing_machine){
     /*
    - Reconocer el estado actual de la iteracion
    - Reconocer el char actual de la cinta
    --> Hacer un get de la transicion correspondiente
        -> Modificar el estado actual
        -> Realizar el movimiento con escritura de la cinta
    */
    if ( turing_machine->started == 0){
        printf("The turing machine iteration hasn't been started yet\n");
        return -1;
    }


    int current_state = turing_machine->current_iteration->current_state;
    char condition = turing_machine->current_iteration->list->list[turing_machine->current_iteration->list->current];

    int transition = get_tm_transition(turing_machine, current_state, condition);
    if ( transition == -1){
        printf("No transition available, turing machine cannot end\n");
        end_tm_iteration(turing_machine);
        return -1;
    }
    
    //Cambiar el estado actual
    turing_machine->current_iteration->current_state = turing_machine->transition[transition]->state_to;
    
    //Realizar la escritura con movimiento de la cinta
    write(turing_machine->current_iteration->list, turing_machine->tape_alphabet[turing_machine->transition[transition]->tape_replacement]);
    move(turing_machine->current_iteration->list, turing_machine->transition[transition]->move);

    if ( is_final_tm_state(turing_machine, turing_machine->states[turing_machine->current_iteration->current_state]) ){
        printf("Turing Machine reached a final state...\n This is the answer:\n");
        printlistfrom(turing_machine->current_iteration->list, turing_machine->current_iteration->list->current);
        end_tm_iteration(turing_machine);
        return 1;
    }

    return 0;
}

int get_tm_transition(turing_machine * tm, int current_state, char condition){
    for ( int i = 0; i < tm->transition_size; i++){
        if ( tm->tape_alphabet[tm->transition[i]->tape_condition] == condition
            && tm->transition[i]->state_from == current_state){
                return i;
        }
    }
    return -1;
}

void end_tm_iteration(turing_machine * tm){
    if ( tm->started != 0){

        free(tm->current_iteration->list->list);
        free(tm->current_iteration->list);
        free(tm->current_iteration);
        tm->started = 0;
    }
    else {
        printf("There is no current iteration active\n");
    }
}

int is_final_tm_state(turing_machine * tm, string state){
    for ( int i = 0; i < tm->final_states_size; i++){
        if ( strcmp(state, tm->states[tm->final_states[i]]) == 0 )
            return 1;
    }
    return 0;
}

int execute_tm(turing_machine * turing_machine, string input_string){
    int res = 0;
    int aux = start_tm(turing_machine, input_string);
    if ( aux != 1)
        return aux;
    while ( res != 1){
        res = next_tm(turing_machine);
        if ( res == -1)
            return 0;
    }
    return 1;
}

void close_tm(turing_machine * turing_machine){
    free_tm(turing_machine);
}

int is_finished_tm(turing_machine * turing_machine){
    return (turing_machine->started == 0)? 1 : 0;
}

void print_tm(turing_machine * tm){
    printf("TM = < ");
    //Print States
    printf("{");
        for( int i = 0; i < tm->states_size; i++){
            printf("%s", tm->states[i]);
            if ( i < tm->states_size - 1)
                printf(",");
        }        
    printf("}, ");

    //Print Input Alphabet
    printf("{");
    for( int i = 0; i < tm->input_alphabet_size; i++){
        printf("%c", tm->input_alphabet[i]);
        if ( i < tm->input_alphabet_size - 1)
            printf(",");
    }
    printf("}, ");

    //Print Tape Alphabet
    printf("{");
    for( int i = 0; i < tm->tape_alphabet_size; i++){
        printf("%c", tm->tape_alphabet[i]);
        if ( i < tm->tape_alphabet_size - 1)
            printf(",");
    }
    printf("}, ");

    //Print blank symbol
    printf("%c, ", tm->blank);
    
    //Print Initial State
    printf("%s, ", tm->states[tm->initial_input_state]);

    //Print Transition Symbol
    printf("𝛿, ");

    //Print final states
    printf("{");
    for( int i = 0; i < tm->final_states_size; i++){
        printf("%s", tm->states[tm->final_states[i]]);
        if ( i < tm->final_states_size - 1)
            printf(",");
    }
    printf("}");

    printf(" >\n\n");
    

    if ( tm->transition_size == 0){
        printf("𝛿: ∅\n");
    }
    else {
        printf("𝛿:\n");
        for ( int i = 0; i < tm->transition_size; i++){
            printf("%d. %s➔%s\t %c|%c %c\n", i + 1, tm->states[tm->transition[i]->state_from], tm->states[tm->transition[i]->state_to], tm->tape_alphabet[tm->transition[i]->tape_condition], tm->tape_alphabet[tm->transition[i]->tape_replacement], ( tm->transition[i]->move == RIGHT)? 'R' : 'L');
        }
    }
    
    putchar('\n');

}

void print_extended_tm(turing_machine * tm){
    printf("A Turing Machine is defined as:\n\n");
    printf("TM = < Q,Γ,Σ,B,q0,𝛿,F >\n\n");
    printf("Where:\n");
    printf("Q\t--> States Set of the Turing Machine\n");
    printf("Γ\t--> Tape Alphabet of the Turing Machine\n");
    printf("Σ\t--> Input Alphabet of the Turing Machine, Σ ⊆ Γ \n");
    printf("B\t--> Blank Symbol of the Turing Machine\n");
    printf("q0\t--> Initial State of the Turing Machine\n");
    printf("𝛿\t--> Transition Function of the Turing Machine\n");
    printf("F\t--> Final States Set of the Turing Machine\n");
    putchar('\n');
    print_tm(tm);
}

void print_current_configuration(turing_machine * tm){
    if ( tm->started != 0){
        printf("Current state: %s\n", tm->states[tm->current_iteration->current_state]);
        printxlist(tm->current_iteration->list, CONFIGURATION_PRINT_N);
        putchar('\n');
    }
    else{
        printf("No iteration started for this automaton\n");
    }
}
