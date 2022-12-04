#!/bin/bash
make clean
make
echo "=================================="
#valgrind --leak-check=full ./parser_201820682.out  < exp.in
./parser_201820682.out  < exp.in