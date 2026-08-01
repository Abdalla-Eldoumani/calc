# calc

Short for calculator.

Yes, I wrote a calculator in assembly. No, there was not a good reason. It
started as four arithmetic operators and three prompts, and it is now a pocket
scientific calculator drawn in your terminal, in ARMv8 assembly, with nothing
underneath it but libc and libm.

## What it is

A full-screen device. It takes the terminal over in raw mode, draws a chassis
with a display window and a key grid, and responds to every keystroke as you
make it. There is an entry line showing the calculation as you build it, a
reading below it, indicator lamps for DEG/RAD, memory, entry mode and errors,
and a tape of the last three things you worked out.

- four operations, powers, roots, reciprocals, percent
- sin, cos, tan, log, ln, e^x, pi, in degrees or radians
- two entry styles: a pocket calculator that chains left to right, and an
  expression mode with real precedence and parentheses, so `2+3*4` is 14
- memory keys, a backspace that deletes one character, `C` for the entry and
  `AC` for the whole calculation
- 10 significant digits with the trailing zeros trimmed, so `0.1 + 0.2` reads
  `0.3` and not the thing a double really holds
- errors named on the display, in red, and never printed outside the frame

The display formatter is written out by hand, digit by digit, because `%g` was
not an option and a device readout is right-aligned in a fixed cell anyway.

## Controls

Type at it. Digits and operators go straight to the key that carries them and
that key lights up. The arrow keys walk a highlight around the grid and enter
presses whatever it is sitting on, which starts on `=`.

| | |
|---|---|
| `0`-`9` `.` `+` `-` `*` `/` `^` `=` | as typed |
| `~` | +/- |
| backspace | delete a character |
| `C` / `A` | clear entry / clear all |
| `v` `i` `%` | sqrt, 1/x, percent |
| `s` `c` `t` `g` `n` `e` `p` | sin, cos, tan, log, ln, e^x, pi |
| `m` `M` `r` `w` | M+, M-, MR, MC |
| `d` | degrees / radians |
| tab | switch entry mode |
| `q` | quit, terminal restored |

`docs/USAGE.md` has the rest, including what percent means and how results are
rounded.

## Build and run

```bash
make          # on an ARMv8 machine
make cross    # from an x86 host, needs aarch64-linux-gnu-gcc
make run      # runs it, under qemu when you are not on ARM
./calculator
```

The source needs `m4` (it uses m4 register aliases) and links `-lm`. The
Makefile handles both.

## Try it in a browser

https://aarch64-playground.vercel.app/playground?example=calc
