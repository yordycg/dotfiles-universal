# Herramientas CLI para Agentes de IA (Token-Efficient)

Investigación sobre herramientas de línea de comandos que reducen el consumo de
tokens y mejoran el manejo de contexto de los agentes de IA (OpenCode, Pi, Claude
Code, etc.). Actualizado: septiembre 2026.

## Por qué los agentes queman tokens

Un agente de coding reenvía el historial completo de la conversación en cada
paso (`tool_call`). El coste se concentra en tres frentes:

1. **Búsqueda de archivos** — el agente grep/lee archivos enteros para encontrar
   unas pocas líneas. Cada `grep` que forkca un proceso nuevo re-lee `.gitignore`,
   re-walk y re-stat el árbol.
2. **Output verboso de comandos** — `git status`, `ls`, tests y lint devuelven
   cientos de líneas que entran al contexto aunque solo importan 3.
3. **Output verboso del propio modelo** — cada token que escribe el modelo vuelve
   a entrar en el contexto en el siguiente paso.

La tesis de Dmitry Kovalenko (podcast Hexlet #82): *"los agentes pasan la vida
buscando archivos y generando diffs; quien construya la mejor capa de retrieval
se lleva los tokens ahorrados"*. El ahorro se gana en la **capa de tooling**, no
en el prompt.

---

## `fff` — Fast File Finder (dmtrKovalenko/fff)

> **Es un SDK de búsqueda de archivos, no un CLI clásico.** ~10.4k★, Rust, MIT.

### Qué es exactamente

Nació como plugin de Neovim (`fff.nvim`) y evolucionó a SDK + MCP para agentes.
Mantiene un **índice residente en memoria** en un proceso de larga vida, de modo
que cada búsqueda posterior golpea memoria caliente en lugar de forkcar un
proceso.

| | `ripgrep` / `fd` / `fzf` | `fff` |
|---|---|---|
| Modelo | CLI: fork + exec por llamada | Librería residente (SDK/MCP) |
| Latencia (500k archivos, Chromium) | 3-9 s por spawn | **sub-10 ms** |
| Re-lectura `.gitignore` | cada invocación | una sola vez al indexar |
| Frecency (archivos que usas) | no | sí, rankea por uso |
| Consciente de git | no (spawn `git status`) | sí, etiquetas `modified/staged/untracked` |
| Definiciones inline | no | sí (clasifica `struct/fn/class/def`) |
| RAM extra | 0 | ~26 MB (14k files) / cientos de MB (Chromium) |

### Motores internos

- **Fuzzy matching SIMD** resistente a typos (núcleo derivado de
  [`frizbee`](https://github.com/saghen/frizbee)).
- **Grep en 3 modos**: literal (SIMD memmem), regex (crate `regex`) y fuzzy
  (Smith-Waterman por línea), con auto-fallback fuzzy si hay 0 hits exactos.
- **Multi-patrón OR** con SIMD Aho-Corasick ("encuentra cualquiera de estos 20
  identificadores" en un solo paso).
- **Índice sparse bigrams + mmap**: ~360 bytes/archivo (≈36 MB en 100k archivos);
  no se indexan binarios ni archivos gigantes.
- **File watcher en background** (inotify/FSEvents): no hay rescans en el hot path.
- **Clasificador de definiciones** en Rust, sin overhead regex en el prompt.
- **Paginateo con cursor**: existe "página 2 de estos matches" (ripgrep no lo tiene).

### Por qué ahorra tokens

1. **Frecency**: los archivos que abres seguido rankean primero → el agente lee
   el archivo correcto antes.
2. **Definiciones inline**: grep por un tipo devuelve el cuerpo de la definición
   si es pequeño → se ahorra un `read_file` posterior.
3. **Anotaciones git integradas**: `(modified)`, `(staged)`, `(untracked)` viajan
   con el resultado → se ahorra el tool-call de `git status`.
4. **Resultados tipados**, no texto a re-parsear: `{ relativePath, lineNumber,
   lineContent, gitStatus, isDefinition, ... }`.

### Instalación y bindings

```bash
# MCP server (Claude Code, Codex, OpenCode, Cursor, Cline...)
curl -L https://dmtrkovalenko.dev/install-fff-mcp.sh | bash
#   → instala en ~/.local/bin/fff-mcp (release v0.10.6, checksums verificados)
#   → tools expuestas: ffgrep, fffind, fff-multi-grep

brew install dmtrKovalenko/fff/fff-mcp        # Homebrew (macOS/Linux)
pip install fff-search                         # Python (PyO3)
npm install @ff-labs/fff-node                  # Node/Bun
cargo add fff-search                           # Rust
pi install npm:@ff-labs/pi-fff                 # Pi agent extension
```

### Prompt recomendado para agentes (AGENTS.md)

> For any file search or grep in the current git-indexed directory, use fff tools.

### Tradeoffs

- Requiere RAM (el índice vive en memoria). En repos medianos (14k files) ~26 MB.
- Para un único grep puntual en terminal, `ripgrep` sigue siendo la herramienta
  correcta. `fff` paga desde la **segunda búsqueda** dentro de un proceso vivo.

---

## Ecosistema de herramientas token-efficient

### Capa de búsqueda / contexto (lo que el agente LEE)

| Herramienta | Qué hace | Ahorro | Integración |
|---|---|---|---|
| **fff** | Índice en memoria para file/content search | Menos tool-calls y lecturas | opencode, pi, Claude, Cursor, Codex |
| **rtk** (rtk-ai/rtk, 78k★) | Proxy que comprime el output de `git status`, `ls`, `cat`, tests, lint | hasta **-90%** del output bash | opencode, pi, Claude, Cursor, Codex, Cline... |
| **tokensave / codebase-memory-mcp** | Grafo de conocimiento del código vía MCP | hasta 120x (reportado) | Claude Code |
| **Graphify** (YC S26) | Knowledge graph con tree-sitter (28 lenguajes) | reemplaza lectura exploratoria por queries | Claude Code, Cursor, Gemini CLI, Copilot |
| **Continue.dev / AnythingLLM** | RAG semántico `@codebase` con embeddings locales | -60-80% contexto por query | VS Code / agentes vía API |

### Capa de compresión de salida (lo que el modelo ESCRIBE)

| Herramienta | Qué hace | Ahorro |
|---|---|---|
| **Caveman** (JuliusBrussee) | Skill de Claude Code que reescribe respuestas verbosas | ~**-65%** output |
| **Headroom** (chopratejas, 30k★) | Capa proxy/proxy/MCP con compresión reversible (CCR) de tool-output, logs y RAG | **-60-95%** input |

### CLI esenciales que los seniors asumen instalados

El principio: *que el agente corra un comando en vez de leer un archivo*.

| Job | Herramienta |
|---|---|
| Buscar código / logs | `rg` (ripgrep), `fd` |
| Buscar por patrón de sintaxis | `sg` (ast-grep), `ast-grep` |
| Reemplazo bulk seguro | `sd` |
| JSON / YAML | `jq`, `yq` |
| CSV / Parquet / SQL | `duckdb`, `xsv`, `csvkit`, `sqlite-utils`, `visidata` |
| Markdown | `glow`, `bat`, `pandoc` |
| Diffs legibles | `delta` |
| Task runner | `just`, `watchexec` |
| Cloud / sincronización | `rclone`, `rsync` |

### Optimización de API (a nivel de provider)

- **Prompt caching** (`cache_control`): los bloques estáticos del system prompt
  se cobran al 10% tras la primera petición → ~-90% en input repetido.
- **Context compaction**: Claude API comprime el historial server-side (ej.
  132k → 2k tokens).
- **Model routing** con LiteLLM: subtareas simples → modelos baratos (Haiku 4.5
  ≈ 30x más barato que Opus 4.6).
- **Semantic tool selection**: un índice FAISS sobre las descripciones de tools
  inyecta solo las relevantes (-82% tokens de tools, -89% errores de selección).

---

## Stack recomendado para este repositorio (dotfiles)

Alineado con la filosofía **Clean Host**: todo vive en `$HOME` vía
mise / `~/.local/bin`, sin tocar el sistema.

1. **fff-mcp** → `~/.local/bin/fff-mcp`, registrado como MCP en opencode y como
   extensión nativa en Pi (`@ff-labs/pi-fff`). Es la pieza central.
2. **rtk** → `~/.local/bin/rtk`, con hooks para opencode (`rtk init -g --opencode`)
   y Pi (`rtk init -g --agent pi`).
3. **ast-grep (`sg`) y `sd`** → vía mise (ya tienes `rg`, `fd`, `jq`, `yq`,
   `duckdb`, `bat`, `delta`, `fzf`).
4. Reglas en `AGENTS.md` (opencode global + pi) que instruyen al agente a
   preferir `ffgrep`/`fffind`/`rtk`.

### Integración con OpenCode

```jsonc
// ~/.config/opencode/opencode.jsonc
{
  "mcp": {
    "fff": {
      "type": "local",
      "command": ["fff-mcp"],
      "enabled": true
    }
  }
}
```

### Integración con Pi

```bash
pi install npm:@ff-labs/pi-fff     # inyecta ffgrep/fffind, reemplaza @-autocomplete
rtk init -g --agent pi             # hook de rtk para Pi
```

Los modos de la extensión de Pi son conmutables en runtime con `/fff-mode`:
`tools-and-ui` (default), `tools-only`, `override` (reemplaza el `grep`/`find`
nativos).

---

## Fuentes

- https://github.com/dmtrKovalenko/fff — README oficial (características, benchmarks, MCP)
- https://github.com/saghen/frizbee — motor SIMD que usa fff
- https://github.com/rtk-ai/rtk — proxy de compresión de output
- https://rustman.org/wiki/fff-agent-file-search/ — análisis + resumen del podcast Hexlet #82
- https://pinggy.io/blog/tools_to_reduce_ai_coding_agent_token_usage/ — 8 herramientas open source
- https://www.systweak.com/blogs/agent-token-saver-toolkit/ — toolkit de CLIs para agentes
- https://opencode.ai/docs/tools/ y https://opencode.ai/docs/mcp-servers/ — tools y MCP de opencode
- X/Twitter: @liamdyerr (saghen), @neogoose_btw (benchmarks de RAM de fff)
