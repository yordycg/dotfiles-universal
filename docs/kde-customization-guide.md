# Guía de Personalización Estética de KDE Plasma 6 (Respaldo)

Este documento detalla el procedimiento manual para alinear la estética, los atajos de teclado y la disposición visual de tu escritorio de respaldo **KDE Plasma 6** con tu configuración principal de **Hyprland** (actualmente basada en Gruvbox, pero adaptable a cualquier tema futuro).

---

## 🎨 1. Sincronización del Tema Visual

Para que KDE coincida con el tema del sistema definido en tus dotfiles (ej: Gruvbox, Catppuccin, Tokyo Night):

### A. Estilo de Aplicación (Transparencias y Blur)
KDE Plasma utiliza **Kvantum** para lograr efectos de desenfoque y transparencia similares a Hyprland:
1. Abre **Ajustes del Sistema** -> **Aspecto** -> **Estilo de las aplicaciones**.
2. Selecciona **Kvantum** como estilo de aplicación y haz clic en Aplicar.
3. Abre la aplicación **Gestor de Kvantum** (Kvantum Manager).
4. En la pestaña *Change/Delete Theme*, selecciona el tema que coincida con tu paleta activa (ej. `KvGruvbox` o `KvCatppuccin`) y actívalo.

### B. Esquema de Colores y Decoración de Ventanas
1. En **Ajustes del Sistema** -> **Aspecto** -> **Colores**, haz clic en *Obtener nuevos esquemas de color...* en la esquina inferior y descarga el esquema correspondiente a tu tema (ej. `Gruvbox Material Dark`).
2. En **Decoraciones de Ventanas**, selecciona un tema minimalista (como `Breeze` o descarga uno sin bordes superiores).

### C. Tema de Iconos
1. En **Aspecto** -> **Iconos**, selecciona **Papirus-Dark** (o la variante correspondiente a tu tema activo, como `Papirus-Dark-Gruvbox`).
2. Si no están instalados, puedes descargarlos directamente desde el gestor de iconos de KDE.

---

## 📐 2. Disposición del Escritorio (Símil Waybar)

Para mantener la misma memoria espacial y visual que tienes en Hyprland:

1. **Panel Superior (Barra de Estado):**
   * Haz clic derecho en el escritorio -> **Añadir Panel** -> **Panel Vacío** y muévelo a la parte superior de la pantalla.
   * Añade los siguientes widgets (de izquierda a derecha):
     * *Menú de aplicaciones* (equivalente a Rofi).
     * *Buscador de tareas* o *Paginador* (equivalente a los Workspaces de Waybar).
     * *Espaciador* (para centrar elementos).
     * *Reloj digital* (centrado).
     * *Espaciador*.
     * *Bandeja del sistema* (System Tray).
2. **Modo Ocultar Panel:**
   * Configura el panel superior como "Esquivar ventanas" o dejarlo fijo, según tu preferencia en Waybar.

---

## ⌨️ 3. Consistencia de Atajos de Teclado

Para que no pierdas memoria muscular al pasar de Hyprland a KDE:

1. Ve a **Ajustes del Sistema** -> **Atajos** -> **Atajos Globales**.
2. Remapea los atajos críticos del sistema para que coincidan con tu `binds.lua`:
   * **Abrir Terminal:** Configura `ALT + Return` (o Enter) para abrir `kitty`.
   * **Explorador de Archivos:** Configura `ALT + E` para abrir `thunar` (o Dolphin).
   * **Cerrar Ventana Activa:** Configura `ALT + W` (reemplazando el clásico `Alt + F4` de KDE).
   * **Lanzador de Aplicaciones:** Configura `ALT + D` para abrir el menú de aplicaciones (o Rofi).
3. Haz clic en **Aplicar**.
