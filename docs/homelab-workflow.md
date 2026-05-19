# Flujo de Trabajo: Homelab (Nodo 1)

Este documento detalla la arquitectura de trabajo remoto para el desarrollo diario.

## 1. El Flujo de Trabajo Diario: De la Laptop al Servidor
Tu notebook del instituto tiene Fedora Sway. Es ligero, rápido y consume mínima batería. No vas a compilar proyectos pesados de .NET o Node.js ahí; todo se ejecutará en el servidor.

### El paso a paso de tu rutina:
1.  Abres la laptop en el instituto o en tu casa.
2.  Presionas `Super + Enter` y abres tu terminal (**Kitty**).
3.  Escribes el comando `homelab`. Este alias hace esto internamente:
    ```bash
    ssh -t yordycg@192.168.18.99 "tmux attach -t dev || tmux new -s dev"
    ```
4.  **Resultado:** Estás dentro del servidor, y automáticamente se abrió (o se recuperó) una sesión de Tmux llamada `dev`.

## 2. ¿Por qué TMUX es obligatorio? 🪟
Trabajar en el servidor mediante SSH tiene un peligro: la red se puede caer. Con Tmux esto no pasa:
*   **Persistencia Total:** Si cierras la laptop, la sesión sigue viva en el servidor. Al reconectarte desde cualquier nodo (Laptop o Desktop), recuperas exactamente el mismo estado.
*   **Multiplexación:** Dentro de la conexión SSH, divides la pantalla:
    *   **Panel superior:** Neovim abierto.
    *   **Panel inferior izquierdo:** Terminal para tests/logs.
    *   **Panel inferior derecho:** Git (Lazygit).

## 3. ¿Cómo se conecta tu editor (Neovim)? 💻
No vas a usar Neovim en tu laptop para editar archivos locales. Tu Neovim va a correr directamente dentro del servidor. Al usar **dotfiles universales**, la configuración es idéntica en ambos sitios. El editor consume la RAM y CPU del servidor, manteniendo tu notebook fría y con batería.

## 4. ¿Y qué pasa si no tienes internet? (El Plan B) 📶
Si el Wi-Fi falla, el flujo no se detiene gracias a **Distrobox**:
1.  Abres una terminal local en Fedora.
2.  Escribes `distrobox enter dev-dotnet` (o el contenedor correspondiente).
3.  Trabajas de forma aislada. Al volver el internet, subes cambios a GitHub y sincronizas con el servidor.

---
### Resumen del Flujo
| Acción | ¿Dónde ocurre? | Herramienta |
| :--- | :--- | :--- |
| **Escribir Código** | Servidor (Nodo 1) | Neovim (vía SSH) |
| **Persistencia** | Servidor (Nodo 1) | Tmux |
| **Compilar / Ejecutar** | Servidor (Nodo 1) | Terminal en Tmux |
| **Interfaz / Teclado** | Laptop (Nodo 2) | Fedora Sway + Kitty |
