# Advent of code 2023 

This repo started as an excercise to remind myself whether I love or hate good old BASIC. 

Now, it also aims to include other programming language solutions for the tasks, 
all with the goal of making them compile, and run, on 8-bit machines.


# BASIC?

It's related to [a post for RetroFun.PL](https://retrofun.pl/2023/12/18/was-basic-that-horrible-or-better/) - 
digging into what was good and bad about the language, and what *did* Dijkstra actually rant about.

For this excercise, the tasks 01-03 are implemented in BBC BASIC, with some restrictions:
* trying not to use more than 48KB of RAM
* trying not to use keywords that weren't accessible on the 80s 8-bits - no procedures, no structs, no magic


# Pascal?

Task 04 is the first one done in Turbo Pascal.
It contains a version that compiles with Free Pascal, as well as one that was battle-tested on Amstrad CPC6128 running CP/M Plus and compiled with Turbo Pascal 3.00 - though had to workaround something that looks like a compiler bug regarding `New` and `Dispose` calls. 

![43cf5625f3dfbc95](https://github.com/ikari-pl/advent-of-code-2023/assets/811702/97fa3b8e-0d3e-4889-94b8-9c96836ed6b7)
