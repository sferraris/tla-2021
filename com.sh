#!/bin/bash

make all
./lex $1
if [ $? -gt 0 ]
then gcc -o out output.c automaton.c stack.c doublelist.c turingmachine.c
fi
if [ $# != 2 ] || [ $2 != "-c" ]
then rm -f output.c
fi
rm -f lex