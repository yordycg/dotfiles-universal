# Guía de Aprovisionamiento en Limpio (Bootstrap Guide)

Este documento detalla el procedimiento estándar para instalar y configurar desde cero (bare-metal) cualquier nodo de la infraestructura personal (Desktop, Laptop o Servidor), garantizando un entorno reproducible y seguro.

---

## 🛠️ Fase 1: Instalación del Sistema Base (KDE Primero)

Para garantizar que todo el hardware (Wi-Fi, Bluetooth, audio, tarjetas gráficas) se reconozca correctamente y tener un entorno gráfico de recuperación estable, siempre instalamos primero **KDE Plasma 6**.

### Opción A: Fedora (Laptop / Desktop de Respaldo)

1. Descarga la imagen oficial de **Fedora KDE Spin**.
2. Realiza la instalación gráfica estándar (crea tu usuario `yordycg`).

### Opción B: Arch Linux (Desktop Principal / Laptop Avanzada)

1. Arranca con la ISO oficial de Arch Linux.
2. Ejecuta el instalador oficial interactivo:
   ```bash
   archinstall
   ```
3. En el menú de configuración, asegúrate de seleccionar:
   - **Profile:** `Desktop` -> `KDE`
   - **Display Manager:** `SDDM`
   - **User:** Crea el usuario `yordycg` y dale privilegios de administrador (sudo).

---

## 🔑 Fase 2: Siembra de Identidad (Manual y Segura)

Antes de iniciar la sincronización de dotfiles, debes copiar tus llaves maestras desde un medio seguro (ej. pendrive encriptado):

1. **Llave de cifrado Age:**
   Copia tu llave privada a:
   `~/.config/age/key.txt`
2. **Llaves SSH:**
   Copia tus llaves de conexión a:
   `~/.ssh/id_ed25519` y `~/.ssh/id_ed25519.pub`
3. **Permisos de SSH:**
   Asegura los permisos correctos en tu terminal:
   ```bash
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
   ```

---

## 🚀 Fase 3: Bootstrap con Chezmoi (Zero-Touch)

Abre una terminal en tu nuevo escritorio de KDE. Dependiendo del tipo de máquina, ejecuta el comando correspondiente. Chezmoi auto-detectará el hardware y aprovisionará el sistema sin hacerte preguntas:

### A. Para Laptops y Desktops (Entorno Gráfico + Hyprland):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
```

- _Chezmoi detectará si hay batería para aplicar el perfil ECO (Laptop) o FULL (Desktop), instalará la suite de Hyprland (`hyprland`, `waybar`, `rofi`, `swaync`) y configurará los estilos y atajos._

### B. Para Servidores Headless (Solo Consola):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --env CHEZMOI_ROLE=server yordycg
```

- _Al pasar `CHEZMOI_ROLE=server`, Chezmoi sabrá que es un servidor sin interfaz gráfica. Omitirá instalar paquetes de Hyprland y solo aprovisionará tu entorno de consola (Zsh, Neovim, Tmux, Mise)._

---

## 🖥️ Fase 4: Primer Inicio en Hyprland

Una vez que Chezmoi finalice la instalación de paquetes y dotfiles:

1. Cierra tu sesión actual de KDE (Log out).
2. En la pantalla de inicio de sesión de **SDDM**:
   - Busca el selector de sesión (usualmente en una esquina de la pantalla).
   - Cambia de "Plasma (Wayland)" a **"Hyprland"**.
3. Introduce tu contraseña e inicia sesión.
4. ¡Listo! Ya estás en tu gestor de ventanas productivo (Hyprland).
