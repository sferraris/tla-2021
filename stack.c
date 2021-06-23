#include "stack.h"


stack* newStack(int capacity)
{
    stack *pt = (stack*)malloc(sizeof(stack));
 
    pt->maxsize = capacity;
    pt->top = -1;
    pt->items = (int*)malloc(sizeof(int) * capacity);
 
    return pt;
}

stack* grow_stack(stack *pt){
    pt->items = (int*) realloc(pt, sizeof(int) * ( (ssize_t) pt->maxsize + DEFAULT_STACK_SIZE) );

    if ( pt->items == NULL){
        printf("Out of memory\n");
        exit(EXIT_FAILURE);
    }

    pt->maxsize += DEFAULT_STACK_SIZE;
}


int size(stack *pt) {
    return pt->top + 1;
}
 

int isEmpty(stack *pt) {
    return pt->top == -1;                   // or return size(pt) == 0;
}
 

int isFull(stack *pt) {
    return pt->top == pt->maxsize - 1;      // or return size(pt) == pt->maxsize;
}
 

void push(stack *pt, int x)
{
    // check if the stack is already full. Then inserting an element would
    // lead to stack overflow
    if (isFull(pt))
    {
        grow_stack(pt);
    }

 
    // add an element and increment the top's index
    pt->items[++pt->top] = x;
}
 

int peek(stack *pt)
{
    // check for an empty stack
    if (!isEmpty(pt)) {
        return pt->items[pt->top];
    }
    else {
        exit(EXIT_FAILURE);
    }
}
 

int pop(stack *pt)
{
    // check for stack underflow
    if (isEmpty(pt))
    {
        printf("Underflow\nProgram Terminated\n");
        exit(EXIT_FAILURE);
    }
 
    // decrement stack size by 1 and (optionally) return the popped element
    return pt->items[pt->top--];
}
 
/*
int main(void){
    stack *pt = newStack(3);
    push(pt, 1);
    push(pt, 2);
    push(pt, 3);
    
    printf("The maxsize is: %d\n", pt->maxsize);

    for ( int i = 0; i < 3; i++){
        printf("stack: %d\n", peek(pt));
    }

    push(pt, 4);
    printf("Now the maxsize is: %d\n", pt->maxsize);

    for ( int i = 0; i < 4; i++){
        printf("stack: %d\n", peek(pt));
    }
    return 0;
}
*/