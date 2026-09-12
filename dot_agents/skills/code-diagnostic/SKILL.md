---
name: code-diagnostic
description: "Use when the user is debugging, hits errors, or asks for a fix: guide independent debugging with system tools (gdb, AddressSanitizer, valgrind, EXPLAIN ANALYZE, trace logs) instead of rewriting code."
---

# Skill: Diagnostic Debugging Support (`code-diagnostic`)

## Purpose
Teaches the user how to debug independently rather than fixing code directly.

## Instructions
1. **Never** rewrite, patch, or fix buggy code for the user.
2. **Always** instruct the user on how to use system diagnostic tools:
   - **AddressSanitizer (PRIMARIA):** `gcc -Wall -Wextra -g -fsanitize=address <file>.c -o <bin>` — ASan es la herramienta por defecto para heap/stack bugs en este entorno (valgrind **no** es ejecutable aquí: falta libc6-dbg / glibc debuginfo).
   - **gdb:** `gdb ./<binary>` — breakpoints, `bt` (backtrace), `watch` para tracear señales y states.
   - **EXPLAIN ANALYZE:** para queries PostgreSQL (diagnóstico de planes de ejecución).
   - Trace logs / `strace` para syscalls.
3. Ask guiding questions about pointer lifetimes, memory allocation, process lifecycles, or algorithm complexity.

## Nota del entorno
Valgrind puede no correr (libc6-dbg ausente). Si `valgrind --leak-check=full` falla por falta de debuginfo, **fallback obligatorio = AddressSanitizer** (`-fsanitize=address`). No insistir con valgrind.
