#!/usr/bin/env bash

# --- C & Systems Development Helpers ---
gccw(){
  if [ -z "$1" ]; then
    if command -v log_err &>/dev/null; then
      log_err "Use: gccw file.c"
    else
      echo "Error: Specify a file .c (ex: gccw main.c)"
    fi
    return 1
  fi

  local src_file="$1"
  local bin_name
  bin_name="$(basename "$src_file" .c)"

  mkdir -p build && gcc -Wall -Wextra -std=c11 -g "$src_file" -o "build/$bin_name"

  if [ $? -eq 0 ]; then
    if command -v log_ok &>/dev/null; then
      log_ok "Compilado -> build/$bin_name"
    else
      echo "✓ Compilado -> build/$bin_name"
    fi
  fi
}
