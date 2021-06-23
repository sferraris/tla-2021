#ifndef STACK_H
#define STACK_H

#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_STACK_SIZE 255

// Data structure to represent a stack
typedef struct
{
    int maxsize;    // define max capacity of the stack
    int top;
    int *items;

} stack;
 
// Utility function to initialize the stack
stack* newStack(int capacity);

// Utility function to return the size of the stack
int size(stack *pt);

// Utility function to check if the stack is empty or not
int isEmpty(stack *pt);

// Utility function to check if the stack is full or not
int isFull(stack *pt);

// Utility function to add an element `x` to the stack
void push(stack *pt, int x);

// Utility function to return the top element of the stack
int peek(stack *pt);

// Utility function to pop a top element from the stack
int pop(stack *pt);

#endif