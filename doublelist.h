#ifndef DOUBLELIST_H
#define DOUBLELIST_H

#define DEFAULT_LIST_SIZE 11
#define DEFAULT_LIST_ADDITION 10


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lib.h"


// Data structure to represent a doublelist
typedef struct
{
    int size;    // define max capacity of the list
    int current;
    char *list;

    char blank;

}doublelist;

typedef enum
{
    LEFT,
    RIGHT

}movement;
 
// Utility function to initialize the doublelist
doublelist* newdoublelist(char blank);

// Utility function to write an element `x` to the current position of the doublelist
void write(doublelist *pt, char x);

// Utility function to return the current element of the doublelist
char get_current(doublelist *pt);

// Utility function to move the doublelist
int move(doublelist *pt, movement move);

//Prints current list state
void printlist(doublelist * pt);

//Prints list from indicated position
void printlistfrom(doublelist * pt, int pos);

//Prints current list state limited to x characters each side from current
void printxlist(doublelist * pt, int x);

//Writes a string from the current position to the write and returns pointer to current
int write_string(doublelist * pt, string s);

#endif