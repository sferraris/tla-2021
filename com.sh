#!/bin/bash
make all
./lex $1
if [ $? -gt 0 ]
then gcc -o out output.c
fi