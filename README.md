# Assembly Webserver
A little webserver I wrote in x86-64 Assembly. There are a TON of comments because I can't understand what's going on without them.

## An Overview of the Assembly you need to know
In assembly tutorials, you will often see people using `int 0x80` or `int 80h`.
This method of making system calls to the kernel is outdated and is not used in modern systems.
Thus, in this project, I will use the `syscall` instruction to make system calls.

## The `syscall` instruction
The `syscall` instruction is used to make system calls in 64-bit mode.
`syscall` takes arguments by:
- Storing the opcode in `rax`
- Storing the arguments in `rdi`, `rsi`, `rdx`, `r10`, `r8`, and `r9` (in that order)
- Returning the result in `rax`

## Table of Syscalls
I used this [table of linux syscalls](https://filippo.io/linux-syscall-table/) as a reference
