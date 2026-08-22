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

Antes de iniciar la sincronización de dotfiles, debes copiar tus llaves maestras desde tu USB seguro:

1. **Llave de cifrado Age:**
   Copia tu llave privada a:
   `~/.config/age/key.txt`
2. **Llaves SSH (Separadas por propósito):**
   Copia tus llaves a `~/.ssh/`:
   - `id_ed25519_github` y `id_ed25519_github.pub` (Autenticación con GitHub)
   - `id_ed25519_oracle` y `id_ed25519_oracle.pub` (Conexión al VPS `nodo1` y servidores)
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

---

## ☁️ Apéndice: Despliegue en Cloud VPS (Ej. Oracle Cloud - Ubuntu Headless)

A diferencia de las estaciones físicas (Desktop/Laptop) donde se utiliza un USB físico para sembrar las credenciales, en un servidor en la nube el proceso se realiza mediante transferencia remota segura (`scp`).

### 🛠️ Paso 1: Creación de la Instancia en Oracle Cloud
1. Al crear tu instancia (ej. Ubuntu 24.04 LTS en arquitectura ARM Ampere):
   - En la sección de **SSH keys**, selecciona *"Paste public keys"* y pega el contenido de tu llave pública **`id_ed25519_oracle.pub`** (generada previamente en tu repositorio y respaldada en tu USB).
2. Anota la **Dirección IP Pública** asignada a tu instancia (ej. `129.150.xx.xx`).

### 🔑 Paso 2: Siembra Remota de Credenciales (Desde tu Desktop Principal)
Dado que el VPS no tiene un puerto USB físico, transferirás tus llaves maestras de forma segura desde tu máquina de desarrollo actual (`nodo2`) usando `scp`:

1. Conéctate inicialmente usando la llave de Oracle:
   ```bash
   ssh -i ~/.ssh/id_ed25519_oracle ubuntu@<IP_PUBLICA_ORACLE>
   ```
2. Desde tu máquina local (`nodo2`), crea las carpetas necesarias en el VPS y transfiere tu llave Age y tus llaves SSH privadas:
   ```bash
   # Crear directorios en el VPS
   ssh -i ~/.ssh/id_ed25519_oracle ubuntu@<IP_PUBLICA_ORACLE> "mkdir -p ~/.config/age ~/.ssh"

   # Transferir llave Age (Maestra de descifrado)
   scp -i ~/.ssh/id_ed25519_oracle ~/.config/age/key.txt ubuntu@<IP_PUBLICA_ORACLE>:/home/yordycg/.config/age/key.txt

   # Transferir llaves SSH de GitHub y Oracle
   scp -i ~/.ssh/id_ed25519_oracle ~/.ssh/id_ed25519_github ubuntu@<IP_PUBLICA_ORACLE>:/home/yordycg/.ssh/id_ed25519_github
   scp -i ~/.ssh/id_ed25519_oracle ~/.ssh/id_ed25519_oracle ubuntu@<IP_PUBLICA_ORACLE>:/home/yordycg/.ssh/id_ed25519_oracle
   ```
3. Conéctate al VPS y asegura los permisos estrictos de seguridad (`0600`):
   ```bash
   ssh -i ~/.ssh/id_ed25519_oracle ubuntu@<IP_PUBLICA_ORACLE>
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
   chmod 600 ~/.config/age/key.txt
   ```

### 🚀 Paso 3: Bootstrap Desatendido con Chezmoi (Rol Server)
Una vez listas las credenciales en el VPS, ejecuta el comando de inicialización indicando el rol de servidor (`CHEZMOI_ROLE=server`):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --env CHEZMOI_ROLE=server yordycg
```

* **Qué hará este comando automáticamente:**
  - Detectará que es un sistema Debian/Ubuntu y actualizará los paquetes base.
  - Omitirá todo el entorno gráfico (Hyprland, Waybar, etc.).
  - Instalará el entorno CLI completo: Zsh, Neovim, Tmux, Lazygit y los SDKs de desarrollo mediante `mise`.
  - Configurará Tailscale VPN y asignará tu hostname `nodo1`.

### 🖥️ Paso 4: Verificación Final
1. Cierra sesión en el VPS y vuelve a entrar usando tu alias limpio configurado por Chezmoi:
   ```bash
   ssh nodo1
   ```
2. ¡Listo! Ya estás dentro de tu servidor `nodo1` con tu entorno de desarrollo idéntico al de tu computadora personal.
