# Arquitectura y Flujo de Trabajo (Homelab)

Este documento detalla la topología de la infraestructura personal y el flujo de trabajo remoto para el desarrollo diario.

## 1. Topología de Nodos

La infraestructura se categoriza en tres roles estrictos:

- **Nodo 1 (Servidor Central):** El cuartel general. Generalmente un equipo headless (sin interfaz gráfica) conectado 24/7 (ej. Debian). Aloja el código fuente, servicios persistentes y entornos de desarrollo mediante contenedores.
- **Nodo 2 (Estación de Fuerza / Desktop):** El músculo. Un equipo potente utilizado para compilaciones pesadas, simulaciones 3D, máquinas virtuales o videojuegos. Su sistema operativo es agnóstico (Linux, DualBoot o Windows+WSL) ya que las herramientas base (Chezmoi, Docker) funcionan igual.
- **Nodo N (Clientes Ligeros):** Las interfaces. Laptops (ej. Fedora Sway), tablets o equipos secundarios. Su trabajo es proyectar la interfaz de usuario. Tienen paquetes mínimos, no compilan localmente, y actúan como "controles remotos" hacia el Nodo 1 o Nodo 2.

## 2. El Flujo de Trabajo Diario (Online)
El objetivo es mantener a los Nodos N fríos, con batería y sin archivos residuales.

1. Se abre el Nodo N (ej. Laptop en un café).
2. Se ejecuta la conexión hacia el Nodo 1: `ssh homelab`
3. Automáticamente se adjunta (o crea) una sesión persistente:
   `ssh -t yordycg@192.168.18.99 "tmux attach -t dev || tmux new -s dev"`
4. **Resultado:** El usuario está dentro del Nodo 1. La sesión de Neovim y los procesos en ejecución consumen la RAM y CPU del Servidor. 

## 3. La Regla de Tmux (Persistencia)
Trabajar mediante SSH tiene un peligro: la inestabilidad de red. Tmux soluciona esto garantizando **Persistencia Total**. Si el Nodo N pierde conexión, la sesión sigue viva en el Servidor. Al reconectarse, el estado del editor, los logs y los paneles se recuperan intactos.

## 4. El "Plan B" (Modo Offline o Desconectado)
Si el Nodo N pierde la conexión a internet de manera prolongada y el Nodo 1 es inaccesible, el desarrollo no se detiene gracias al estándar de contenedores. Ya no se requieren entornos complejos ni máquinas virtuales locales:

1. Se clona (o se utiliza la copia local) el repositorio del proyecto en el Nodo N.
2. Como todos los proyectos cumplen con la arquitectura de *Capa 2 y Capa 3*, solo se necesita ejecutar el Task Runner (ej. `just up` o `podman compose up`).
3. El proyecto descargará sus propias imágenes y se levantará idéntico a como lo hace en el servidor.
4. Se utiliza Neovim localmente en el Nodo N para editar. Al volver la conexión, se realiza un `git push` y se reanuda el trabajo en el Nodo 1.

## 5. Estrategia Dual de Editores (Neovim)
Para optimizar el rendimiento y la comodidad, se han configurado dos instancias aisladas de Neovim mediante `NVIM_APPNAME`:

- **LazyVim (`lv`)**: Orientado a la productividad máxima en proyectos grandes. Incluye LSPs pesados, debugging y herramientas de refactorización complejas.
- **Nvim Personal (`nv` / `v`)**: Una configuración ligera y altamente personalizada ubicada en `~/.config/nvim-personal`. Ideal para edición rápida de archivos de sistema, scripts o proyectos pequeños donde la velocidad de arranque es prioridad.

Esta separación permite experimentar con nuevas configuraciones en la versión Personal sin romper el entorno de producción (LazyVim).

---
### Resumen del Flujo por Defecto
| Acción | Ubicación | Herramienta |
| :--- | :--- | :--- |
| **Interfaz (Ventana)** | Nodo N (Cliente Ligero) | Terminal (Kitty) + SSH |
| **Edición de Código** | Nodo 1 (Servidor) | Neovim |
| **Persistencia** | Nodo 1 (Servidor) | Tmux |
| **Ejecución y BD** | Nodo 1 (Servidor) | Podman / Dockerfiles |
