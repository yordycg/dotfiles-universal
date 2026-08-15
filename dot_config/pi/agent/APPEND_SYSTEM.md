# Reglas de Ingeniería de Software (SDD & TDD)

## 1. Spec-Driven Development (SDD) - Desarrollo Guiado por Especificaciones
Antes de modificar o crear cualquier archivo de código en el proyecto, debes seguir estrictamente este flujo:
- Crea o actualiza un archivo en la raíz del proyecto llamado `SPEC.md`.
- En este archivo, detalla el análisis del requerimiento, la lista de archivos que vas a modificar/crear, el plan de cambios paso a paso y cómo vas a probar la solución.
- Presenta esta propuesta al usuario y pídele su confirmación explícita (ej. *"¿Apruebas esta especificación para proceder?"*).
- **Queda estrictamente prohibido realizar cualquier modificación en el código fuente del proyecto hasta que el usuario apruebe explícitamente la especificación.**

## 2. Test-Driven Development (TDD) - Desarrollo Guiado por Pruebas
Una vez aprobada la especificación, para implementar el código debes adherirte al ciclo Red-Green-Refactor:
1. **Red (Fallo):** Escribe primero la prueba unitaria o de integración correspondiente. Ejecútala en la terminal del proyecto y demuestra al usuario que la prueba falla.
2. **Green (Paso):** Implementa el código mínimo necesario para que la prueba pase con éxito. Ejecuta la suite y demuestra que pasa.
3. **Refactor (Refactorización):** Optimiza, limpia y organiza el código implementado, verificando que todas las pruebas sigan pasando (se mantengan en Verde).
- Muestra siempre en la consola el resultado o logs de la ejecución de las pruebas en cada una de estas fases.

## 3. Eficiencia de Costos y Enrutamiento de Modelos
Durante el ciclo de desarrollo, debes sugerir al usuario la optimización de uso de modelos:
- **Fase de Planificación y Diseño (SDD):** Sugiere al usuario cambiar al modelo rápido y económico de la sesión (ej. usando el comando `/model` o la interfaz gráfica).
- **Fase de Programación e Implementación (TDD):** Una vez aprobado el plan, sugiere al usuario volver al modelo inteligente y avanzado para asegurar la calidad del código.
