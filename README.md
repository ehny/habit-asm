```
███████████████████████████████████

██   ██  █████  ██████  ██ ████████ 
██   ██ ██   ██ ██   ██ ██    ██    
███████ ███████ ██████  ██    ██    
██   ██ ██   ██ ██   ██ ██    ██    
██   ██ ██   ██ ██████  ██    ██    
                                    
                                    
 █████  ███████ ███    ███          
██   ██ ██      ████  ████          
███████ ███████ ██ ████ ██          
██   ██      ██ ██  ██  ██          
██   ██ ███████ ██      ██          
                                    
███████████████████████████████████   
```
# Habit ASM
A habit tracking program in 32-bit x86 assembly.

## About

Habit ASM was submitted as a final project for Assembly Language, [CSC 314](https://catalog.dsu.edu/preview_course.php?catoid=29&coid=18537), at [Dakota State University](https://dsu.edu) during the Fall 2020 semester. The course instructor was [Andrew Kramer](https://dsu.edu/directory/kramer-andrew.html).

## Installation 

### Program Files

This repository contains the following files:

|File|Description|
|:--|:--|
|`habit.asm`| This is the main program file.|
|`logo.txt`| This file contains the program logo.|
|`habit.txt`| This file stores the user's goal as `goalDuration` `habitName` (for example, `15 running`).|
|`data.txt`| This file stores the user's daily habit entries. Empty values are represented by `-1`.|
|`README.md`| The program documentation.|
|`LICENSE`| The Habit ASM license.| 
|`.editorconfig`| An [EditorConfig](https://editorconfig.org/) file for `habit.asm` to have tabs display correctly on GitHub. 

Habit ASM utilizes assembly I/O routines developed by [Paul Carter](https://pacman128.github.io/pcasm/). 

The following files are included for development on a Linux-based system:

- `asm_io.asm`
- `asm_io.inc`
- `cdecl.h`
- `driver.c`

### Installing Dependencies 

Habit ASM was developed using the [Netwide Assembler (NASM)](https://www.nasm.us) along with the [GCC compiler](https://gcc.gnu.org) on a Linux machine. 

The following instructions describe dependency installation on Ubuntu 20.04.3 LTS.

1. Update package lists with `sudo apt update`.
2. Install NASM using `sudo apt install nasm`.
3. Verify GCC installation with `gcc -v`.
	1. If GCC is not installed, you can install it as part of the `build-essential` package `sudo apt install build-essential`.
4. Install the `gcc-multilib` package for 32-bit C compilation `sudo apt install gcc-multilib`.

### Program Compilation

1. Begin by assembling the I/O routines file with `nasm -f elf -d ELF_TYPE asm_io.asm`. This will create the `asm_io.o` object file. 
2. Assemble the `habit.asm` file with `nasm -f elf habit.asm`. This will create the `habit.o` file. 
3. Finally, compile the C code in 32-bit mode and link the object and library files to create an executable with `gcc -m32 -o habit habit.o driver.c asm_io.o`.
4. Launch Habit ASM with `./habit`.

## Usage

### Using Habit ASM

Please see [the repository Wiki](https://github.com/ehny/habit-asm/wiki) for detailed program documentation. 😉

#### Main Menu:

```
Habit ASM > Main Menu
===================================
Enter 1 ... to set up a new habit
Enter 2 ... to record a daily entry
Enter 3 ... to print a report
Enter 0 ... to exit
===================================
Option: 

```

#### Sample Report:[^1]

``` 
Main Menu > Show Report
-----------------------------------

Goal:    walking
Minutes: 30

+------+------+-------+
| Day: | Min: |  Met: |
+------+------+-------+
|    1 |   30 |   *   |
+------+------+-------+
|    2 |   20 |       |
+------+------+-------+
|    3 |   35 |   *   |
+------+------+-------+
|    4 |   10 |       |
+------+------+-------+
|    5 |   30 |   *   |
+------+------+-------+
|    6 |   15 |       |
+------+------+-------+
|    7 |   30 |   *   |
+------+------+-------+

-----------------------------------
Progress:

▇▇▇▇▇▇▇▇▇▇▇▇▇▇
______________| 100%

-----------------------------------
Total days recorded: 7 / 7
Total goal met:      4 / 7
Total time:          2:50

```

## Credits

The I/O routines for assembly were written by [Paul Carter](https://pacman128.github.io/pcasm/). 

Program compilation instructions are adapted from Chapter 1, Section 4, "Creating a Program" of Carter's textbook, *PC Assembly Language*, available on the author's website.

Habit ASM's logo was generated with Patrick Gillespie's [Text to ASCII Art Generator](http://patorjk.com/software/taag) using the ANSI Regular font.

The author would like to thank [Andrew Kramer](https://dsu.edu/directory/kramer-andrew.html), Instructor of Computer and Cyber Sciences at Dakota State University, for the guidance and support of this project. 

## License

This work, "Habit ASM", incorporates I/O routines for assembly, [`asm_io.asm`, `asm_io.inc`, `cdecl.h`, and `driver.c`](https://github.com/pacman128/pcasm/tree/master/examples) by [Paul Carter](http://pacman128.github.io/pcasm/), used under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). "Habit ASM" is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) by Elchanan Heller.

[^1]: The progress bar does not line up correctly in the documentation examples due to formatting differences.
