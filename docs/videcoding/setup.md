# Videcoding — Setup (checklist de inicio)

Pasos manuales al **crear un proyecto nuevo** y al **arrancar una sesión**. No todo es automático: esto es lo que tienes que hacer tú.

## 1. Crear el proyecto

```bash
new-videcoding-project <nombre>
cd <nombre>
```

El comando copia la plantilla, inicializa git y hace el commit inicial.

## 2. Instalar el hook pre-commit (¡no se autoinstala!)

```bash
just install-hooks
```

Instala `.git/hooks/pre-commit`, que corre `just gate` (lint + test + verificación dual-write) en **cada commit**. Sin esto el gate no se ejecuta solo.

## 3. Verificar el tablero

```bash
just setup     # comprueba canvas-tool.py + Project.canvas y muestra el estado
```

## 4. (Opcional) Abrir en Obsidian

Abre la carpeta del proyecto como vault para ver el tablero `Project.canvas` visualmente. El flujo funciona igual sin Obsidian (vía `TASKS.md` + CLI), pero el canvas es lo más cómodo para revisar dependencias y marcar verdes.

## 5. opencode: verificar el modelo del architect

```bash
opencode       # dentro del proyecto
/models        # en la TUI
```

- Confirma que aparece `anthropic/claude-sonnet-4.6` (OpenRouter). La whitelist de OpenRouter solo muestra ese modelo.
- Si el slug cambió (nuevas versiones de Claude), ajusta `.opencode/agent/architect.md` (`model:`).

## 6. pi: registrar el proyecto y asignar modelos

```bash
pi             # dentro del proyecto
/sdd-init      # una vez: detecta stack y testing
/gentle:models # design=Claude (OpenRouter), implement=DeepSeek, explore=Gemini
```

## 7. Fase 0 — ¡crítico! El architect debe llenar el Justfile

Los targets `lint`, `test` y `dev` del `Justfile` son **placeholders** (`⚠ FASE 0: define ...`). Hasta que el architect no los llene con los comandos reales del stack, **el gate no verifica nada** (pasa vacío). Tarea obligatoria del architect en la Fase 0/1, junto con el scaffolding y el ejemplo de estilo en `CODESTYLE.md`.

## 8. Auth de proveedores (una vez por máquina)

- **OpenRouter** (architect): `opencode auth login` → OpenRouter → pegar key (`sk-or-...`). La misma key en pi (`/connect` o auth de pi). Keys en `~/.local/share/opencode/auth.json` y `~/.pi/agent/auth.json` — **fuera de chezmoi**, no se commitean.
- **DeepSeek** (worker) y **Google** (scout): ya configurados en opencode y pi.
- Crédito: cargar en OpenRouter (solo se usa para Claude). Empezar con $5-10 y poner alerta de gasto en el dashboard.

## Resumen rápido

| Paso | Comando | ¿Cuándo? |
|------|---------|----------|
| Crear proyecto | `new-videcoding-project <nombre>` | 1 vez |
| Hook pre-commit | `just install-hooks` | 1 vez por proyecto |
| Verificar tablero | `just setup` | 1 vez por proyecto |
| Verificar slug | `/models` en opencode | 1 vez por proyecto (o al cambiar modelos) |
| Registrar en pi | `/sdd-init` + `/gentle:models` | 1 vez por proyecto |
| Llenar Justfile | (Fase 0 del architect) | 1 vez por proyecto |
