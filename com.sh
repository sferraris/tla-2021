#!/bin/bash

make all
./lex $1
if [ $? -gt 0 ]
then clang -o out output.c automaton.c stack.c turingmachine.c doublelist.c
fi
rm lex output.c