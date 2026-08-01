# Using calc

## Table of Contents
1. [Building from Source](#building-from-source)
2. [Basic Usage](#basic-usage)
3. [Console Mode](#console-mode)
4. [The Keys](#the-keys)
5. [Entry Modes](#entry-modes)
6. [Input Guidelines](#input-guidelines)
7. [How Results Are Displayed](#how-results-are-displayed)
8. [Error Messages](#error-messages)
9. [Examples](#examples)

## Building from Source

### Option 1: Using Make
1. Clone the repository
```bash
git clone https://github.com/Abdalla-Eldoumani/calc.git
cd calc
```
2. On an ARMv8 machine run ```make```, and from an x86 host run ```make cross```
3. Run the executable
```bash
./calculator            # the full-screen device
./calculator console    # the line calculator
```
```make run``` does the same thing and picks qemu for you when you are not on ARM.

### Option 2: By hand
The source uses m4 register aliases, so it goes through m4 before the assembler:
```bash
m4 src/calculator.s > calculator.gen.s
gcc -static calculator.gen.s -o calculator -lm
```
```-lm``` is what supplies sqrt, pow, sin, cos, tan, log, log10 and exp.

## Basic Usage
With no argument calc draws a calculator in your terminal and takes the
keyboard over. Type at it and the matching key lights up. Press ```q``` to give
the terminal back. With the argument ```console``` it stays on plain text and
runs a prompt instead; everything below describes the device unless it says
otherwise.

The display has three parts:

- an indicator strip: DEG or RAD, M when memory holds something, IMM or EXPR
  for the entry mode, and ERR when something went wrong
- a working line, dim, showing the calculation as you build it
- the reading, bright, showing the number the calculator is holding

Under the display is a tape of the last three completed calculations, and under
that the key grid.

## Console Mode
```./calculator console``` skips the device and runs a prompt instead, for
terminals that cannot draw escape sequences and for feeding input in from a
file. Any other argument prints one usage line and exits with status 1.

```txt
calc -- scientific calculator
type an expression, deg or rad for the trig mode, q to quit
calc> 2+3*4
= 14
calc> sqrt(9)
= 3
calc> rad
RAD
calc> sin(pi)
= 0
calc> q
bye
```

- One expression a line, read the way expression mode reads it: precedence,
  parentheses, ```^```, ```%```, and the function words ```sqrt``` ```sin```
  ```cos``` ```tan``` ```log``` ```ln``` ```exp``` and ```pi```, typed out in
  full. Spaces anywhere are fine.
- ```deg``` and ```rad``` switch the trig mode and answer with the mode you
  are now in. They are lowercase, like ```q``` and ```quit```.
- ```q``` or ```quit``` leaves, and so does the end of the input, so
  ```./calculator console < sums.txt``` works.
- A blank line is ignored. A line past 120 characters is refused with
  ```too long``` rather than quietly cut short and answered.
- Errors print the same words the device shows, one to a line, and the prompt
  comes straight back: there is no state to clear.
- Nothing on this path writes an escape byte and nothing changes the terminal
  settings, so a redirected stdout holds exactly what you saw.

## The Keys
Every key on the grid can be reached two ways: type the character it carries,
or walk the highlight to it with the arrow keys and press enter. The highlight
starts on ```=```, so enter works as equals until you move it.

| Key | Type | What it does |
|-----|------|--------------|
| digits, ```.``` | ```0```-```9```, ```.``` | enter a number |
| ```+``` ```-``` ```*``` ```/``` | same | the four operations |
| ```x^y``` | ```^``` | raise to a power |
| ```=``` | ```=``` or enter | finish the calculation |
| ```+/-``` | ```~``` | flip the sign |
| ```<-``` | backspace | delete one character |
| ```C``` | ```C``` | clear the entry |
| ```AC``` | ```A``` | clear the whole calculation |
| ```sqrt``` | ```v``` | square root |
| ```x^2``` | grid only | square |
| ```1/x``` | ```i``` | reciprocal |
| ```%``` | ```%``` | percent, see below |
| ```sin``` ```cos``` ```tan``` | ```s``` ```c``` ```t``` | trigonometry, in DEG or RAD |
| ```log``` | ```g``` | logarithm base 10 |
| ```ln``` | ```n``` | natural logarithm |
| ```e^x``` | ```e``` | exponential |
| ```pi``` | ```p``` | 3.141592654 |
| ```(``` ```)``` | same | grouping, expression mode only |
| ```MC``` ```MR``` ```M+``` ```M-``` | ```w``` ```r``` ```m``` ```M``` | memory |
| ```DRG``` | ```d``` | switch between degrees and radians |
| ```MODE``` | tab | switch between entry modes |
| quit | ```q``` | restore the terminal and exit |

## Entry Modes
### Immediate (IMM)
A pocket calculator. Each operator finishes the one before it, so the
calculation runs left to right and ```2 + 3 * 4 =``` reads 20. Function keys act
on whatever the reading is showing the moment you press them, so ```2```
```sqrt``` gives 1.414213562 straight away.

Pressing an operator twice replaces it rather than stacking: ```5 + * 3 =``` is
15.

### Expression (EXPR)
You type the whole thing, then press ```=```. Multiplication binds tighter than
addition and parentheses override both, so ```2+3*4``` is 14 and ```(2+3)*4```
is 20. Function keys insert their name and an open bracket, so pressing
```sqrt``` gives you ```sqrt(``` to fill in.

```^``` is right-associative and its exponent may be negative, so ```2^-1``` is
0.5. A leading minus binds looser than a power, so ```-2^2``` is -4.

The mode key clears the calculation on the way through, because half a chain
does not mean anything in the other mode. Memory, DEG/RAD and the tape carry
over.

## Input Guidelines
### Numbers
- Integers and decimals: ```123```, ```0.456```, ```.456```, ```5.```
- Leading zeros are fine: ```007``` is 7
- One decimal point per number; the second press is ignored
- Negatives come from the ```+/-``` key, not from typing a minus in front

### Limits
- A number stops accepting at 20 characters
- An expression stops accepting at 40 characters
- Scientific notation cannot be typed in, though results are shown in it

### Clearing
- ```C``` takes back the entry and leaves the rest of the calculation alone. In
  expression mode the expression is the entry, so ```C``` takes the whole line.
- ```AC``` clears the calculation: the entry, the running total and the pending
  operator. Memory and the tape survive; memory belongs to ```MC```.
- After an error, ```C``` behaves like ```AC```, because the calculation it was
  part of can no longer be finished.

### Percent
Percent follows the convention pocket calculators ship, and it reads the same in
both entry modes.

- After ```+``` or ```-``` it is that percent **of the running total**, which is
  how you add a tip or take a discount: ```200 + 10 % =``` is 220 and
  ```200 - 10 % =``` is 180.
- After ```*``` or ```/``` it is a plain hundredth: ```200 * 10 % =``` is 20 and
  ```200 / 10 % =``` is 2000.
- With nothing pending it is a plain hundredth too: ```50 %``` is 0.5.

In expression mode the same rule applies to the operator immediately to the
left, so ```200+10%``` is 220 and ```200*10%``` is 20. A percent that is then
operated on again is a hundredth and stays one: ```200+10%*2``` is 200.2.

### Memory
```M+``` and ```M-``` add and subtract the reading. ```MR``` recalls it as the
current entry, ```MC``` empties it. The M lamp is lit whenever memory holds
something other than zero.

## How Results Are Displayed
Results carry **10 significant digits** and trailing zeros are trimmed, which is
what a scientific calculator shows and why ```0.1 + 0.2``` reads 0.3 rather than
the 0.30000000000000004 a double actually holds. The arithmetic underneath is
full double precision; only the display rounds.

Two rules follow from that and are worth knowing:

- **Near-zero snap.** Anything smaller than 1e-10 displays as 0. Without it
  ```sin(pi)``` in RAD would read 1.224646799e-16, which is rounding dust rather
  than an answer.
- **Mantissa fallback.** Once a number needs more than ten places on either side
  of the point, the display switches to a mantissa and a decade:
  ```1.23456789e+14```, ```3e-09```.

## Error Messages

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "div by zero" | Divided by zero, or took the reciprocal of zero | Use a non-zero divisor |
| "sqrt of neg" | Square root of a negative number | Take the root of a non-negative number |
| "log of <= 0" | ```log``` or ```ln``` of zero or a negative number | Use a positive number |
| "overflow" | The result passed 1e100 | Work with smaller numbers |
| "syntax" | The expression could not be read: an unclosed bracket, a trailing operator, a word that is not a function | Fix the expression and press ```=``` again |
| "undefined" | The operation has no real answer, such as a negative number to a fractional power | Check the operands |

The reading turns red, the ERR lamp lights, and every key except ```C``` and
```AC``` is ignored until you clear it. Nothing is ever printed outside the
frame.

## Examples

### Immediate mode
```txt
keys      5 + 3 =
working   5 + 3 =
reading   8

keys      2 sqrt
working   sqrt(2)
reading   1.414213562

keys      2 + 9 sqrt =
working   2 + sqrt(9) =
reading   5

keys      30 sin              (DEG lamp lit)
working   sin(30)
reading   0.5

keys      200 + 10 % =
working   200 + 10% =
reading   220
```

### Expression mode
```txt
keys      TAB 2+3*4 =
working   2+3*4 =
reading   14

keys      TAB (2+3)*4 =
working   (2+3)*4 =
reading   20

keys      TAB sqrt(2)*sqrt(2) =
working   sqrt(2)*sqrt(2) =
reading   2
```

### Errors
```txt
keys      5 / 0 =
working   5 / 0
reading   div by zero          (ERR lamp lit)

keys      4 +/- sqrt
reading   sqrt of neg

keys      TAB 2+ =
working   2+
reading   syntax
```

`tests/test_cases.txt` holds the full behaviour contract as input and expected
output pairs.
