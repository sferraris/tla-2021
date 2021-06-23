#include "automaton.h"

automaton * init_automaton(string * states, int states_size, char * input_alphabet, int input_alphabet_size, string * stack_alphabet, int stack_alphabet_size, string initial_input_state, string initial_stack, string * final_states, int final_states_size);
void free_automaton(automaton * a);
void print_aut(automaton * a);
int is_input_alphabet(automaton * automaton, char c);
int is_stack_alphabet(automaton * automaton, string word);
int is_state(automaton * automaton, string state);
int is_final_state(automaton * automaton, string state);
int add_transition(automaton * automaton, string state_from, string state_to, string stack_condition, string * stack_replacement, int stack_replacement_size, char c);
int validate_transition(automaton * a, transition * t);
int start(automaton * automaton, string input_string);
int next(automaton * automaton);
int get_input_state_index(automaton * automaton, string state);
int get_stack_index(automaton * automaton, string stack);
int get_transition(automaton * automaton, int current_state, int stack_top, char next_char);
int execute(automaton * automaton, string input_string);

int main(void){

    string states[] = {"q0", "q1","q2", "qf"};
    char input_alph[] = {'a', 'b', 'c'};
    string stack_alph[] = {"z", "A", "B"};
    string i_i_s = "q0";
    string f_i_s[] = {"qf"};
    string i_s = "z";

    automaton * aut = new_automaton(states, 4, input_alph, 3, stack_alph, 3, i_i_s, i_s, f_i_s, 1);

    string replacement[] = {"z", "A"};
    if ( !add_transition(aut, "q0", "q1", "z", replacement, 2, 'a') ){
        printf("Error while adding transition\n");
        return 0;
    }

    string replacementa[] = {"B", "A"};
    if ( !add_transition(aut, "q0", "q1", "B", replacementa, 2, 'a') ){
        printf("Error while adding transition\n");
        return 0;
    }

    string replacementb[] = {"A", "B"};
    if ( !add_transition(aut, "q1", "q0", "A", replacementb, 2, 'b') ){
        printf("Error while adding transition\n");
        return 0;
    }

    string replacement3[] = {"B"};
    if ( !add_transition(aut, "q0", "q2", "B", replacement3, 1, 'c') ){
        printf("Error while adding transition\n");
        return 0;
    }

    string replacement2[] = {LAMBDA};
    add_transition(aut, "q2", "q2", "B", replacement2, 1, 'a');
    add_transition(aut, "q2", "q2", "A", replacement2, 1, 'b');
    add_transition(aut, "q2", "qf", "z", replacement2, 1, LAMBDA);

    if ( aut != NULL){
        print_aut(aut);
    }

    int exec = execute(aut, "abababcababab");
    if ( exec == 0)
        printf("The word does not belong\n");

    free_automaton(aut);
    aut = NULL;
 

    return 0;
}

automaton * new_automaton(string * states, int states_size, char * input_alphabet, int input_alphabet_size, string * stack_alphabet, int stack_alphabet_size, string initial_input_state, string initial_stack, string * final_states, int final_states_size){
    
    automaton * a = init_automaton(states, states_size, input_alphabet, input_alphabet_size, stack_alphabet, stack_alphabet_size, initial_input_state, initial_stack, final_states, final_states_size);    
    if (a == NULL){
        printf("Error initializing automaton\n");
        exit(EXIT_FAILURE);
    }

    //TODO not neccesary
    //Chequea que los elem de la lista de estados finales esten en la lista de estados
    for ( int i = 0; i < final_states_size; i++){
        if ( !is_state(a, final_states[i]) ){
            free_automaton(a);
            printf("Invalid Automaton, final state: %s is not in the states list\n", final_states[i]);
            return NULL;
        }   
    }

    //Chequear que el estado inicial sea un estado
    if ( !is_state(a, initial_input_state) ){
        free_automaton(a);
        printf("Invalid Automaton, initial state: %s is not in the states list\n", initial_input_state);
        return NULL;
    }   
    
    //Chequear que el elem de la pila inicial este en el alfabeto de la pila
    if ( !is_stack_alphabet(a, initial_stack) ){
        free_automaton(a);
        printf("Invalid Automaton, initial stack: %s is not in the stack alphabet list\n", initial_stack);
        return NULL;
    } 

    return a;
}

int add_transition(automaton * automaton, string state_from, string state_to, string stack_condition, string * stack_replacement, int stack_replacement_size, char c){

    for ( int i = 0; i < stack_replacement_size; i++){
        if ( stack_replacement[i] != LAMBDA){
            if ( !is_stack_alphabet(automaton, stack_replacement[i])){
                printf("%s is not in the stack alphabet\n", stack_replacement[i]);
                return 0;
            }
        }  
    }

    transition * t = malloc(sizeof(transition));

    if ( t == NULL){
        printf("Error while adding transition, out of memory\n");
        return 0;
    }

    t->state_from = get_input_state_index(automaton, state_from);
    if ( t->state_from == -1){
        printf("%s is not a state\n", state_from);
        return 0;
    }

    t->state_to = get_input_state_index(automaton, state_to);
    if ( t->state_to == -1 ){
        printf("%s is not a state\n", state_to);
        return 0;
    }

    t->stack_condition = get_stack_index(automaton, stack_condition);
    if ( t->stack_condition == -1){
        printf("%s is not in the stack alphabet\n", stack_condition);
    }

    t->stack_replacement = malloc(sizeof(int) * stack_replacement_size);
    if ( t->stack_replacement == NULL){
        printf("Error while adding transition, out of memory\n");
        return 0;
    }

    for ( int i = 0; i < stack_replacement_size; i++){
        if ( stack_replacement[i] != LAMBDA){
            t->stack_replacement[i] = get_stack_index(automaton, stack_replacement[i]);
            if ( t->stack_replacement[i] == -1){
                printf("Error while adding transition\n");
                return 0;
            }
        }
        else
            t->stack_replacement[i] = LAMBDA_INDEX;
        
    }

    t->stack_replacement_size = stack_replacement_size;
    if ( c != LAMBDA)
        t->c = c;
    else
        t->c = LAMBDA_INDEX;

    if ( validate_transition(automaton, t)){
        automaton->transition_size++;
        automaton->transition = realloc(automaton->transition, sizeof(transition **) * automaton->transition_size);
        if ( automaton->transition == NULL){
            printf("Realloc failed\n");
            return 0;
        }
        automaton->transition[automaton->transition_size - 1] = t;
    }
    else{
        printf("A transition from %s to %s with stack %s when char %c arrives already exists\n", automaton->states[t->state_from], automaton->states[t->state_to], automaton->stack_alphabet[t->stack_condition], t->c);
        return 0;
    }

    return 1;

}

int is_input_alphabet(automaton * automaton, char c){
    for ( int i = 0; i < automaton->input_alphabet_size; i++){
        if ( c == automaton->input_alphabet[i] )
            return 1;
    }
    return 0;
}

int is_stack_alphabet(automaton * automaton, string word){
    for ( int i = 0; i < automaton->stack_alphabet_size; i++){
        if ( strcmp(word, automaton->stack_alphabet[i]) == 0 )
            return 1;
    }
    return 0;
}

int is_state(automaton * automaton, string state){
    for ( int i = 0; i < automaton->states_size; i++){
        if ( strcmp(state, automaton->states[i]) == 0 )
            return 1;
    }
    return 0;
}

int is_final_state(automaton * automaton, string state){
    for ( int i = 0; i < automaton->final_states_size; i++){
        if ( strcmp(state, automaton->states[automaton->final_states[i]]) == 0 )
            return 1;
    }
    return 0;
}

automaton * init_automaton(string * states, int states_size, char * input_alphabet, int input_alphabet_size, string * stack_alphabet, int stack_alphabet_size, string initial_input_state, string initial_stack, string * final_states, int final_states_size){
    automaton * a = malloc(sizeof(automaton));
    if (a == NULL){
        return NULL;
    }

    //Initialize input alphabet
    a->input_alphabet_size = input_alphabet_size;
    a->input_alphabet = malloc(sizeof(char) * input_alphabet_size);
    for ( int i = 0; i < input_alphabet_size; i++){
        a->input_alphabet[i] = input_alphabet[i];
    }

    //Initialize stack alphabet
    a->stack_alphabet_size = stack_alphabet_size;
    a->stack_alphabet = malloc(sizeof(string) * stack_alphabet_size);
    if ( a->stack_alphabet == NULL){
        free_automaton(a);
        return NULL;
    }
    for ( int i = 0; i < stack_alphabet_size; i++){
        int aux = strlen(stack_alphabet[i]) + 1;
        a->stack_alphabet[i] = malloc(aux);
        if ( a->stack_alphabet[i] == NULL){
            free_automaton(a);
            return NULL;
        }
        strcpy(a->stack_alphabet[i], stack_alphabet[i]);
    }

    //Initialize states
    a->states_size = states_size;
    a->states = malloc(sizeof(string) * states_size);
    if ( a->states == NULL){
        free_automaton(a);
        return NULL;
    }
    for ( int i = 0; i < states_size; i++){
        int aux = strlen(states[i]);
        a->states[i] = malloc(aux);
        if ( a->states[i] == NULL){
            free_automaton(a);
            return NULL;
        }
        strcpy(a->states[i], states[i]);
    }


    a->final_states_size = final_states_size;
    a->final_states = malloc(sizeof(int) * final_states_size);
    if ( a->final_states == NULL){
        free_automaton(a);
        return NULL;
    }
    for ( int i = 0; i < final_states_size; i++){
        a->final_states[i] = get_input_state_index(a, final_states[i]);
        if ( a->final_states[i] == -1){
            free_automaton(a);
            return NULL;
        }
    }


    a->initial_input_state = get_input_state_index(a, initial_input_state);
    if ( a->initial_input_state == -1){
        free_automaton(a);
        return NULL;
    }

    a->initial_stack = get_stack_index(a, initial_stack);
    if ( a->initial_stack == -1){
        free_automaton(a);
        return NULL;
    }

    a->transition = NULL;
    a->transition_size = 0;

    a->started = 0;
    a->current_iteration = NULL;
    return a;
}

void free_automaton(automaton * a){
    if ( a != NULL){
        //Free input alphabet
        if ( a->input_alphabet != NULL){
            free(a->input_alphabet);
        }

        //Free stack alphabet
        if ( a->stack_alphabet != NULL){
            for(int i = 0; i < a->stack_alphabet_size; i++){
                if(a->stack_alphabet[i] != NULL)
                    free(a->stack_alphabet[i]);
            }
            free(a->stack_alphabet);
        }

        //Free states
        if ( a->states != NULL){
            for(int i = 0; i < a->states_size; i++){
                if(a->states[i] != NULL)
                    free(a->states[i]);
            }
            free(a->states);
        }

        //Free final states
        if ( a->final_states != NULL){
            free(a->final_states);
        }

        //Free initial stack
        a->initial_stack = -1;

        //Free initial input state
        a->initial_input_state = -1;

        //Free transitions
        if ( a->transition != NULL){
            for ( int i = 0; i < a->transition_size; i++){
                if ( a->transition[i] != NULL)
                    free(a->transition[i]);
            }
            free(a->transition);
        }
        free(a);
    }
}

void print_aut(automaton * a){
    printf("Alfabeto: ");
    for( int i = 0; i < a->input_alphabet_size; i++)
        printf("%c ", a->input_alphabet[i]);
    putchar('\n');

    printf("Alfabeto del stack: ");
    for( int i = 0; i < a->stack_alphabet_size; i++)
        printf("%s ", a->stack_alphabet[i]);
    putchar('\n');

    printf("Estados: ");
    for( int i = 0; i < a->states_size; i++)
        printf("%s ", a->states[i]);
    putchar('\n');

    printf("Estados finales: ");
    for( int i = 0; i < a->final_states_size; i++)
        printf("%s ", a->states[a->final_states[i]]);
    putchar('\n');

    printf("Estado inicial: %s\n", a->states[a->initial_input_state]);

    printf("stack inicial: %s\n", a->stack_alphabet[a->initial_stack]);

    printf("Transiciones:\n");
    for ( int i = 0; i < a->transition_size; i++){
        printf("Transicion %d: from->%s, to->%s, when->%c top->%s, replacement->", i, a->states[a->transition[i]->state_from], a->states[a->transition[i]->state_to],( (a->transition[i]->c == LAMBDA_INDEX)? 'L' : a->transition[i]->c ), a->stack_alphabet[a->transition[i]->stack_condition]);
        for ( int j = 0; j < a->transition[i]->stack_replacement_size; j++)
            printf("%s, ", (a->transition[i]->stack_replacement[j] == LAMBDA_INDEX)? "Lambda" : a->stack_alphabet[a->transition[i]->stack_replacement[j]] );
        putchar('\n');
    }

}

int validate_transition(automaton * a, transition * t){
    int aux = 0;
    for ( int i = 0; i < a->transition_size; i++){
        if ( a->transition[i]->c == t->c 
            && a->transition[i]->state_from == t->state_from 
            && a->transition[i]->stack_condition == t->stack_condition){
                return 0;
        }

        if ( a->transition[i]->c == LAMBDA 
            && a->transition[i]->state_from == t->state_from 
            && a->transition[i]->stack_condition == t->stack_condition){
            aux = 1;
        }
    }

    if ( aux == 1)
        return 0;
    return 1;
}

int start(automaton * automaton, string input_string){

    if ( automaton->started == 0){
        for ( int i = 0; i < strlen(input_string); i++){
            if ( !is_input_alphabet(automaton, input_string[i]) ){
                printf("The word does not belong to the language\n");
                return 0;
            }
        }
        automaton->current_iteration = malloc(sizeof(aut_iteration));
        if ( automaton->current_iteration == NULL){
            printf("Error while initializing iteration\n");
            return 0;
        }

        automaton->current_iteration->current_iteration_pointer = 0;
        automaton->current_iteration->current_state = automaton->initial_input_state;
        automaton->current_iteration->stack = newStack(DEFAULT_STACK_SIZE);

        if ( automaton->current_iteration->stack == NULL){
            printf("Error while initializing stack\n");
            free(automaton->current_iteration);
            return 0;
        }

        //Pushear el estado inicial al stack
        push(automaton->current_iteration->stack, automaton->initial_stack);

        automaton->current_iteration->input_string = malloc(strlen(input_string));
        if ( automaton->current_iteration->input_string == NULL){
            printf("Error while initializing iteration\n");
            return 0;
        }
        strcpy(automaton->current_iteration->input_string, input_string);
        automaton->started = 1;
        return 1;
    }
    else {
        printf("Automaton had already been started, finish current execution to start another\n");
        return 0;
    }
}

int next(automaton * automaton){
    /*
    - Reconocer el estado actual de la iteracion
    - Reconocer la proxima letra del string
    - Reconocer el tope del stack
    --> Hacer un get de la transicion correspondiente
        -> Modificar el estado actual
        -> Adelantar el puntero del string
        -> Modificar el stack
    */
    if ( automaton->started == 0){
        printf("The automaton iteration hasn't been started yet\n");
        return -1;
    }

    int current_state = automaton->current_iteration->current_state;
    char next_char;
    if ( automaton->current_iteration->current_iteration_pointer < strlen(automaton->current_iteration->input_string))
        next_char = automaton->current_iteration->input_string[automaton->current_iteration->current_iteration_pointer];
    else
        next_char =LAMBDA_INDEX;
    int stack_top = peek(automaton->current_iteration->stack);

    //printf("char: %c\n", (next_char == LAMBDA_INDEX)? 'L' : next_char);
    int transition = get_transition(automaton, current_state, stack_top, next_char);
    if ( transition == -1){
        printf("No transition available, word does not belong to the language\n");
        return -1;
    }

    automaton->current_iteration->current_state = automaton->transition[transition]->state_to;
    automaton->current_iteration->current_iteration_pointer++;
    pop(automaton->current_iteration->stack);
    //TODO chequear que esto se haga en el orden correcto
    for ( int i = 0; i < automaton->transition[transition]->stack_replacement_size; i++){
        if ( automaton->transition[transition]->stack_replacement[i] != LAMBDA_INDEX)
            push(automaton->current_iteration->stack, automaton->transition[transition]->stack_replacement[i]);
    }
        
    if ( isEmpty(automaton->current_iteration->stack) && is_final_state(automaton, automaton->states[automaton->current_iteration->current_state]) && strlen(automaton->current_iteration->input_string) <= automaton->current_iteration->current_iteration_pointer){
        automaton->started = 0;
        printf("The word belongs to the language\n");
        return 1;
    }

    return 0;
}

int get_input_state_index(automaton * automaton, string state){
    for ( int i = 0; i < automaton->states_size; i++){
        if ( strcmp(automaton->states[i], state) == 0)
            return i;
    }
    return -1;
}

int get_stack_index(automaton * automaton, string stack){
    for ( int i = 0; i < automaton->stack_alphabet_size; i++){
        if ( strcmp(automaton->stack_alphabet[i], stack) == 0)
            return i;
    }
    return -1;
}

int get_transition(automaton * automaton, int current_state, int stack_top, char next_char){
    for ( int i = 0; i < automaton->transition_size; i++){
        if ( automaton->transition[i]->c == next_char 
            && automaton->transition[i]->state_from == current_state
            && automaton->transition[i]->stack_condition == stack_top){
                return i;
        }
    }
    return -1;
}

int execute(automaton * automaton, string input_string){
    int res = 0;
    int aux = start(automaton, input_string);
    if ( aux == 0)
        return 0;
    while ( res != 1){
        res = next(automaton);
        if ( res == -1)
            return 0;
    }
    return 1;
}

