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
[            : opens a loop, loops the code in it for whatever the value in current memory cell is
@            : opens a set digit block, the current memory cell is set to whatever number is in the block as long as its in the limit
;            : closes any block, currently closes loops and set digit blocks
```
