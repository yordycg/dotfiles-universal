# Fase 4 — Diseño Lógico y Pseudocódigo

## Pseudocódigo del flujo principal

```
INICIO
    ...
FIN
```

## Casos de borde y manejo de errores

| Caso | ¿Qué hace el sistema? |
|---|---|
| Ej: red falla | Reintenta 3 veces, luego notifica error |
| | |

## Estructura de carpetas y módulos

```
src/
├── main.py
├── config.py
├── services/
└── utils/
```

## Preguntas clave — respuestas

1. ¿Qué pasa si la red falla, la API está caída o la entrada cambia de estructura?
2. ¿Cómo voy a manejar los errores sin que todo el programa se rompa?
3. ¿Esta lógica es fácil de entender si la leo dentro de 6 meses?
4. ¿Puedo explicarle este pseudocódigo a alguien no técnico en 2 minutos?
