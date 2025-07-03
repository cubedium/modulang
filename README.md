### Modulang
Modulang is a modular esolang made in [C3](https://c3-lang.org). What I mean by modular is that it is very easy to add new instructions.

Modulang uses an array that contains 256 numbers with a range of 0 to 255 as its program memory.

## Current Instructions
```
>            : go to the next memory cell
<            : go to the previous memory cell
+            : increment the current memory cell by 1
-            : decrement the current memory cell by 1
#            : print the current memory cell as a decimal number
p            : print the current memory cell as an ascii character
$            : goes to the memory cell that is specified in the current memory cell
!            : goes to the instruction that is specified in the current memory cell
[            : opens a loop, loops the code in it for whatever the value in current memory cell is
@            : opens a set digit block, the current memory cell is set to whatever number is in the block as long as its in the limit
?            : opens an if statement, the code in it is ran if the current memory cell is equal to one
/            : starts a comment, any code in it will be ignored until the comment is closed 
;            : closes any block, currently closes loops, set digit blocks, and comments
```

## How to use
```
Usage:
  modulang <filename> [OPTIONS]

Options:
  --debug            : turns on debug mode, which prints debug information to the console
  --verbose          : turns on verbose mode, currently the only usage is to print extra debug information. Debug mode has to be on for it to work
  --verbose-debug    : turns on both verbose and debug mode
  --advance-on-enter : a debugging tool which continues to the next instruction once you press enter
  --slow             : a debugging tool which slows down the program to do one instruction per second
  --input <input>    : gives some input to be ran. It is a good idea to have the input in quotes
  --file <filename>  : gives a file to be ran
  --help             : shows this help information
```
