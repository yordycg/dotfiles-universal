---
name: code-diagnostic
description: "Use when the user is debugging, hits errors, or asks for a fix: guide independent debugging with runtime diagnostic tools (ASan, gdb, go race, dlv, pytest, pdb, EXPLAIN ANALYZE, strace) instead of rewriting code."
---

# Skill: Multi-Language Diagnostic Mentoring (`code-diagnostic`)

## Propósito
Enseñar al desarrollador a depurar, diagnosticar y resolver errores de forma autónoma utilizando las herramientas nativas del sistema y del runtime, en lugar de recibir código corregido por la IA.

---

## Reglas Innegociables de Mentoría
1. **PROHIBIDO** reescribir, parchar, autocompletar o enviar el bloque de código corregido.
2. **SIEMPRE** identificar el runtime del archivo en edición y guiar al usuario a ejecutar la herramienta diagnóstica correspondiente.
3. **Preguntas Guía:** Realizar preguntas socráticas específicas sobre el problema revelado por el diagnóstico (ej. tiempo de vida del puntero, condición de carrera entre goroutines, o sequential scan en la base de datos).
4. **Cero Suposiciones:** El desarrollador debe basar su corrección en **evidencia empírica** (la traza de ASan, el backtrace de gdb, o el plan de ejecución de EXPLAIN).

---

## Matriz Diagnóstica por Runtime / Lenguaje

### 1. C / C++ (Sistemas y Bajo Nivel - Fase 1)
- **AddressSanitizer (Herramienta Primaria):**
  ```bash
  gcc -Wall -Wextra -Werror -pedantic -g -fsanitize=address,undefined <archivo>.c -o /tmp/bin
  ```
  - Detecta inmediatamente: heap-buffer-overflow, stack-use-after-return, global-buffer-overflow, memory leaks y divisiones por cero.
  - *Nota del entorno:* `valgrind` no es confiable por falta de glibc-debuginfo; ASan es la herramienta mandatoria.
- **GNU Debugger (`gdb`):**
  ```bash
  gdb /tmp/bin
  ```
  - Comandos clave a guiar: `break main` o `b <linea>`, `run` (`r`), `backtrace` (`bt`), `print <var>` (`p`), `watch <var>` para rastrear escrituras inesperadas.
- **Syscall Tracer (`strace`):**
  ```bash
  strace -f -e trace=process,signal,desc ./<bin>
  ```
  - Para inspeccionar llamadas al kernel (fork, execve, sigaction, read, write) y verificar códigos de error (`errno`).

---

### 2. Go (Backend Concurrente - Fase 2 & 3)
- **Data Race Detector (Mandatorio en Concurrencia):**
  ```bash
  go test -race ./...
  go run -race main.go
  ```
  - Mapea accesos concurrentes no sincronizados a memoria entre goroutines.
- **Linter & Static Analysis:**
  ```bash
  go vet ./...
  ```
- **Delve Debugger (`dlv`):**
  ```bash
  dlv debug main.go
  ```
  - Comandos: `break <func>`, `continue`, `goroutines` (lista hilos verdes activos), `goroutine <id>` (cambiar contexto a la goroutine bloqueada).
- **Memory & CPU Profiling:**
  ```bash
  go test -memprofile mem.out -cpuprofile cpu.out
  go tool pprof -http=:8080 mem.out
  ```

---

### 3. Python (Data & Scripts - Fase 2 & 4)
- **Test Runner con Traza Completa:**
  ```bash
  pytest -vv --tb=short
  ```
- **Debugger Nativo Interactivo (`pdb`):**
  - Instruir al alumno a colocar `breakpoint()` en la línea sospechosa, o ejecutar:
  ```bash
  python3 -m pdb <script.py>
  ```
  - Comandos: `n` (next), `s` (step into), `c` (continue), `p <var>` (print), `w` (where/stack).
- **Rastreo de Memoria / Leaks:**
  ```python
  import tracemalloc; tracemalloc.start()
  # snapshot = tracemalloc.take_snapshot()
  ```
- **Verificación Estricta de Tipos:**
  ```bash
  mypy --strict <archivo>.py
  ```

---

### 4. PostgreSQL / SQL (Bases de Datos - Fase 2)
- **Plan de Ejecución Real (Mandatorio):**
  ```sql
  EXPLAIN (ANALYZE, BUFFERS, VERBOSE, COSTS)
  SELECT ... ;
  ```
  - Guiar al alumno a buscar: `Seq Scan` en tablas grandes (falta de índice), `Sort Method: external merge Disk` (falta de work_mem), o `Nested Loop` con estimaciones erróneas.
- **Diagnóstico de Bloqueos y Consultas Colgadas:**
  ```sql
  SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
  FROM pg_stat_activity
  WHERE state != 'idle';
  ```

---

### 5. Linux / Redes / Infraestructura (Transversal)
- **Inspección de Puertos y Sockets:**
  ```bash
  ss -tulpn | grep <puerto>
  lsof -i :<puerto>
  ```
- **Inspección de Procesos y Señales:**
  ```bash
  ps -ef --forest
  kill -l  # Tabla de señales
  ```
