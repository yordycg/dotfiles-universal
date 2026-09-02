# Reglas Globales de Búsqueda (Token-Efficient)

Estas reglas aplican a todos los proyectos en este equipo para reducir el
consumo de tokens en la capa de retrieval.

## Búsqueda de archivos y contenido

- Para cualquier **file search o grep** en el directorio git-indexado actual,
  usa las herramientas **fff** (`ffgrep`, `fffind`, `fff-multi-grep`) en lugar
  de las herramientas de búsqueda por defecto.
- Prefiere `ffgrep` sobre `grep`/`rg` cuando el repo ya esté indexado por fff:
  los resultados llegan ordenados por frecency, etiquetados con estado git y con
  las definiciones inline.
- Cuando necesites inspeccionar la estructura de un directorio o el output de
  un comando, usa los comandos compactos de **rtk** (p.ej. `rtk ls`, `rtk git
  status`, `rtk read`) para no volcar salida verbosa al contexto.

## Prompts

- Los tools MCP (fff) añaden contexto; úsalos con criterio y no los invoques
  para búsquedas triviales de un solo archivo conocido.
