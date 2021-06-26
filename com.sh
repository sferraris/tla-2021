#!/bin/bash

make all
./lex $1
if [ $? -gt 0 ]
then gcc -o out output.c automaton.c stack.c doublelist.c turingmachine.c
fi
rm lex output.c