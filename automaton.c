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
void close(automaton * automaton);
void end_iteration(automaton * automaton);
int is_finished(automaton * automaton);
void print_current_state(automaton * a);
void print_extended_aut(automaton * a);


automaton * new_automaton(string * states, int states_size, char * input_alphabet, int input_alphabet_size, string * stack_alphabet, int stack_alphabet_size, string initial_input_state, string initial_stack, string * final_states, int final_states_size){
    
    if ( states_size == 0){
        printf("An automaton can't have no states\n");
        return NULL;
    }

    if ( input_alphabet_size == 0){
        printf("An automaton can't have no input alphabet\n");
        return NULL;
    }

    if ( stack_alphabet_size == 0){
        printf("An automaton can't have no stack alphabet\n");
        return NULL;
    }
        
    automaton * a = init_automaton(states, states_size, input_alphabet, input_alphabet_size, stack_alphabet, stack_alphabet_size, initial_input_state, initial_stack, final_states, final_states_size);    
    if (a == NULL){
        printf("Error initializing automaton\n");
        return NULL;
    }

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

    if ( !is_input_alphabet(automaton, c) && c != LAMBDA){
        printf("%c is not in the input alphabet\n", c);
        return 0;
    }

    transition * t = malloc(sizeof(transition));

    if ( t == NULL){
        printf("Error while adding transition, out of memory\n");
        return 0;
    }

    t->state_from = get_input_state_index(automaton, state_from);
    if ( t->state_from == -1){
        printf("%s is not a state\n", state_from);
        free(t);
        return 0;
    }

    t->state_to = get_input_state_index(automaton, state_to);
    if ( t->state_to == -1 ){
        printf("%s is not a state\n", state_to);
        free(t);
        return 0;
    }


    t->stack_condition = get_stack_index(automaton, stack_condition);
    if ( t->stack_condition == -1){
        printf("%s is not in the stack alphabet\n", stack_condition);
        free(t);
        return 0;
    }
    

    t->stack_replacement = malloc(sizeof(int) * stack_replacement_size);
    if ( t->stack_replacement == NULL){
        printf("Error while adding transition, out of memory\n");
        free(t);
        return 0;
    }

    for ( int i = 0; i < stack_replacement_size; i++){
        if ( stack_replacement[i] != LAMBDA){
            t->stack_replacement[i] = get_stack_index(automaton, stack_replacement[i]);
            if ( t->stack_replacement[i] == -1){
                printf("Error while adding transition\n");
                free(t);
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
            free(t);
            return 0;
        }
        automaton->transition[automaton->transition_size - 1] = t;
    }
    else{
        char aux[2];
        sprintf(aux, "%c", t->c);
        printf("A transition from %s with stack %s when char %s arrives already exists\n", automaton->states[t->state_from], automaton->stack_alphabet[t->stack_condition], (t->c == LAMBDA_INDEX)? "λ" : aux);
        free(t);
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
        printf("error in malloc\n");
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
        printf("stack alphabet is null\n");
        return NULL;
    }
    for ( int i = 0; i < stack_alphabet_size; i++){
        int aux = strlen(stack_alphabet[i]) + 1;
        a->stack_alphabet[i] = malloc(aux);
        if ( a->stack_alphabet[i] == NULL){
            free_automaton(a);
            printf("stack alphabet element is null\n");
            return NULL;
        }
        strcpy(a->stack_alphabet[i], stack_alphabet[i]);
    }

    //Initialize states
    a->states_size = states_size;
    a->states = malloc(sizeof(string) * states_size);
    if ( a->states == NULL){
        free_automaton(a);
        printf("states is null\n");
        return NULL;
    }
    for ( int i = 0; i < states_size; i++){
        int aux = strlen(states[i]);
        a->states[i] = malloc(aux);
        if ( a->states[i] == NULL){
            printf("states element is null\n");
            free_automaton(a);
            return NULL;
        }
        strcpy(a->states[i], states[i]);
    }


    a->final_states_size = final_states_size;
    a->final_states = malloc(sizeof(int) * final_states_size);
    if ( a->final_states == NULL){
        printf("final state is null\n");
        free_automaton(a);
        return NULL;
    }
    for ( int i = 0; i < final_states_size; i++){
        a->final_states[i] = get_input_state_index(a, final_states[i]);
        if ( a->final_states[i] == -1){
            printf("final state element is not a state : %s\n", final_states[i]);
            free_automaton(a);
            return NULL;
        }
    }


    a->initial_input_state = get_input_state_index(a, initial_input_state);
    if ( a->initial_input_state == -1){
        free_automaton(a);
        printf("initial state is not a state\n");
        return NULL;
    }

    a->initial_stack = get_stack_index(a, initial_stack);
    if ( a->initial_stack == -1){
        free_automaton(a);
        printf("initial stack is not in stack alphabet\n");
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

    printf("M = < ");
    //Print States
    printf("{");
        for( int i = 0; i < a->states_size; i++){
            printf("%s", a->states[i]);
            if ( i < a->states_size - 1)
                printf(",");
        }        
    printf("}, ");

    //Print Input Alphabet
    printf("{");
    for( int i = 0; i < a->input_alphabet_size; i++){
        printf("%c", a->input_alphabet[i]);
        if ( i < a->input_alphabet_size - 1)
            printf(",");
    }
    printf("}, ");

    //Print Stack Alphabet
    printf("{");
    for( int i = 0; i < a->stack_alphabet_size; i++){
        printf("%s", a->stack_alphabet[i]);
        if ( i < a->stack_alphabet_size - 1)
            printf(",");
    }
    printf("}, ");
    
    //Print Transition Symbol
    printf("𝛿, ");

    //Print Initial State
    printf("%s, ", a->states[a->initial_input_state]);

    //Print Initial Stack Symbol
    printf("%s, ", a->stack_alphabet[a->initial_stack]);

    //Print final states
    if ( a->final_states_size != 0){
        printf("{");
        for( int i = 0; i < a->final_states_size; i++){
            printf("%s", a->states[a->final_states[i]]);
            if ( i < a->final_states_size - 1)
                printf(",");
        }
        printf("}");
    }
    else
        printf("∅");

    printf(" >\n\n");
    

    if ( a->transition_size == 0){
        printf("𝛿: ∅\n");
    }
    else {
        printf("𝛿:\n");
        for ( int i = 0; i < a->transition_size; i++){
            char aux[2];
            sprintf(aux, "%c", a->transition[i]->c);
            printf("%d. %s➔%s\t%s, %s|", i + 1, a->states[a->transition[i]->state_from], a->states[a->transition[i]->state_to],( (a->transition[i]->c == LAMBDA_INDEX)? "λ" : aux ), (a->transition[i]->stack_condition == LAMBDA_INDEX)? "λ":a->stack_alphabet[a->transition[i]->stack_condition]);
            for ( int j = 0; j < a->transition[i]->stack_replacement_size; j++)
                printf("%s", (a->transition[i]->stack_replacement[j] == LAMBDA_INDEX)? "λ" : a->stack_alphabet[a->transition[i]->stack_replacement[j]] );
            putchar('\n');
        }
    }
    putchar('\n');

}

void print_extended_aut(automaton * a){
    printf("A Pulldown Automaton is defined as:\n\n");
    printf("M = < Κ,Σ,Γ,𝛿,q0,z0,F >\n\n");
    printf("Where:\n");
    printf("Κ\t--> States Set of the Automaton\n");
    printf("Σ\t--> Input Alphabet of the Automaton\n");
    printf("Γ\t--> Stack Alphabet of the Automaton\n");
    printf("𝛿\t--> Transition Function of the Automaton\n");
    printf("q0\t--> Initial State of the Autmaton\n");
    printf("z0\t--> Initial Configuration of the Stack\n");
    printf("F\t--> Final States Set of the Automaton\n");
    putchar('\n');
    print_aut(a);
}

void print_current_state(automaton * a){
    if ( a->started != 0){
        int stack_top;
        if ( !isEmpty(a->current_iteration->stack))
            stack_top = peek(a->current_iteration->stack);
        else
            stack_top = LAMBDA_INDEX;
        printf("Current state: %s\tStack top: %s\tRemaining word: %s\n", a->states[a->current_iteration->current_state], (stack_top == LAMBDA_INDEX)? "λ" : a->stack_alphabet[stack_top], ( (a->current_iteration->input_string[a->current_iteration->current_iteration_pointer] == LAMBDA)? "λ" : a->current_iteration->input_string + a->current_iteration->current_iteration_pointer ) );
    }
    else{
        printf("No iteration started for this automaton\n");
    }
}

int validate_transition(automaton * a, transition * t){
    int aux = 0;
    if ( t->c == LAMBDA_INDEX){
        for ( int i = 0; i < a->transition_size; i++){
        if ( a->transition[i]->state_from == t->state_from
            && a->transition[i]->stack_condition == t->stack_condition){
                return 0;
            }
        }
    }
    else {
        for ( int i = 0; i < a->transition_size; i++){
        if ( a->transition[i]->c == t->c 
            && a->transition[i]->state_from == t->state_from 
            && a->transition[i]->stack_condition == t->stack_condition){
                return 0;
        }

        if ( a->transition[i]->c == LAMBDA_INDEX 
            && a->transition[i]->state_from == t->state_from 
            && a->transition[i]->stack_condition == t->stack_condition){
            aux = 1;
        }
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
            return -1;
        }

        automaton->current_iteration->current_iteration_pointer = 0;
        automaton->current_iteration->current_state = automaton->initial_input_state;
        automaton->current_iteration->stack = newStack(DEFAULT_STACK_SIZE);

        if ( automaton->current_iteration->stack == NULL){
            printf("Error while initializing stack\n");
            free(automaton->current_iteration);
            return -1;
        }

        //Pushear el estado inicial al stack
        push(automaton->current_iteration->stack, automaton->initial_stack);

        automaton->current_iteration->input_string = malloc(strlen(input_string));
        if ( automaton->current_iteration->input_string == NULL){
            printf("Error while initializing iteration\n");
            return -1;
        }
        strcpy(automaton->current_iteration->input_string, input_string);
        automaton->started = 1;
        return 1;
    }
    else {
        printf("Automaton had already been started, finish current execution to start another\n");
        return -1;
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

    if ( isEmpty(automaton->current_iteration->stack)){
        end_iteration(automaton);
        printf("Stack is empty, unable to make any more transitions\n");
        return -1;
    }


    int current_state = automaton->current_iteration->current_state;
    char next_char;
    if ( automaton->current_iteration->current_iteration_pointer < strlen(automaton->current_iteration->input_string))
        next_char = automaton->current_iteration->input_string[automaton->current_iteration->current_iteration_pointer];
    else
        next_char =LAMBDA_INDEX;

    int stack_top;
    if ( !isEmpty(automaton->current_iteration->stack) )
        stack_top = peek(automaton->current_iteration->stack);
    else
        stack_top = LAMBDA_INDEX;

    int transition;
    if ( strlen(automaton->current_iteration->input_string) != 0){
        transition = get_transition(automaton, current_state, stack_top, next_char);
        if ( transition == -1){
            printf("No transition available, word %s does not belong to the language \n", automaton->current_iteration->input_string);
            end_iteration(automaton);
            return -1;
        }
        
        

        automaton->current_iteration->current_state = automaton->transition[transition]->state_to;

        if ( automaton->transition[transition]->c != LAMBDA_INDEX)
            automaton->current_iteration->current_iteration_pointer++;

        pop(automaton->current_iteration->stack);
        
        for ( int i = automaton->transition[transition]->stack_replacement_size - 1; i >= 0 ; i--){
            if ( automaton->transition[transition]->stack_replacement[i] != LAMBDA_INDEX)
                push(automaton->current_iteration->stack, automaton->transition[transition]->stack_replacement[i]);
        }

    }
    if ( strlen(automaton->current_iteration->input_string) <= automaton->current_iteration->current_iteration_pointer && automaton->final_states_size == 0 && isEmpty(automaton->current_iteration->stack)){
        printf("The word %s belongs to the language, automaton finished because of Empty Stack\n", automaton->current_iteration->input_string);
        end_iteration(automaton);
        return 1;
    }
    else if ( strlen(automaton->current_iteration->input_string) <= automaton->current_iteration->current_iteration_pointer && is_final_state(automaton, automaton->states[automaton->current_iteration->current_state]) ){
        printf("The word %s belongs to the language, automaton finished because it reached a Final State\n", automaton->current_iteration->input_string);
        end_iteration(automaton);
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

        if ( ( automaton->transition[i]->c == next_char || automaton->transition[i]->c == LAMBDA_INDEX)
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
    if ( aux != 1)
        return aux;
    while ( res != 1){
        res = next(automaton);
        if ( res == -1)
            return 0;
    }
    return 1;
}

void close(automaton * automaton){
    free_automaton(automaton);
}

void end_iteration(automaton * automaton){
    if ( automaton->started != 0){

        free(automaton->current_iteration->stack->items);
        free(automaton->current_iteration->stack);
        free(automaton->current_iteration->input_string);
        free(automaton->current_iteration);
        automaton->started = 0;
    }
    else {
        printf("There is no current iteration active\n");
    }
}

int is_finished(automaton * automaton){
    return (automaton->started == 0)? 1 : 0;
}
