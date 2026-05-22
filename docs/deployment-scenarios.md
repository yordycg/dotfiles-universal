# Escenarios de Despliegue y Recuperación (Zero-Touch)

Este documento sirve como manual de operaciones. Describe exactamente qué comandos ejecutar en los tres escenarios más comunes al gestionar la infraestructura del HomeLab (Nodo 1) y los dotfiles (Nodos N).

La premisa de estos flujos es el **Zero-Touch**: evitar escribir contraseñas o secretos manualmente usando automatización y gestores de contraseñas.

---

## Escenario 1: Servidor Nuevo (Expansión)
**Situación:** Tienes un servidor nuevo (limpio) y tu laptop (Nodo N) ya está completamente configurada y funcional.
**Objetivo:** Pasar el servidor de cero a operativo sin intervención manual, usando tu laptop como "puente".

### Pasos (Ejecutar desde tu laptop - Nodo N):

1. **Autorizar tu laptop en el servidor nuevo:**
   Permite que tu laptop se conecte sin pedir contraseña.
   ```bash
   ssh-copy-id usuario@IP_DEL_SERVIDOR
   ```

2. **Blindar el Servidor (Capa 1 - homelab-infra):**
   Envía la orden para clonar la infraestructura y ejecutar el hardening de red y SSH remoto.
   ```bash
   ssh usuario@IP_DEL_SERVIDOR "git clone https://github.com/yordycg/homelab-infra.git && sudo bash homelab-infra/deploy.sh"
   ```

3. **Aprovisionar el Entorno (Capa 2 - Dotfiles):**
   Usa `just` desde tu laptop para inyectar dinámicamente tus secretos al servidor y lanzar Chezmoi. *(Asegúrate de tener la receta configurada en tu Justfile local, ver anexo)*.
   ```bash
   just deploy-remote usuario@IP_DEL_SERVIDOR
   ```
   *El servidor ahora tiene tus dotfiles, herramientas y su propia copia de la llave `age`.*

4. **Levantar Servicios (Capa 3 - Contenedores):**
   ```bash
   ssh usuario@IP_DEL_SERVIDOR "cd ~/homelab-infra && ./manage.sh up"
   ```

---

## Escenario 2: Servidor Andando (Actualización del día a día)
**Situación:** Has actualizado tu configuración de Neovim, modificado un alias en `dotfiles-universal` o cambiado un script. Quieres que el servidor reciba esos cambios.
**Objetivo:** Sincronizar el servidor rápidamente.

### Pasos:
Como el servidor ya pasó por el Escenario 1, **ya tiene los secretos guardados en su bóveda local** (`~/.config/chezmoi/key.txt`). No necesitas pasarlos de nuevo.

1. **Opción A (Desde dentro del servidor):**
   ```bash
   ssh usuario@IP_DEL_SERVIDOR
   just update
   ```

2. **Opción B (Remoto desde tu laptop):**
   ```bash
   ssh usuario@IP_DEL_SERVIDOR "just -f ~/.local/share/chezmoi/Justfile update"
   ```
   *(`just update` ejecuta un `git pull` de los dotfiles seguido de un `chezmoi apply` automático).*

---

## Escenario 3: Desastre Total (Bare Metal)
**Situación:** Pérdida total de equipos. Estás frente a una computadora vacía (o prestada) y necesitas volver a tener tu entorno (tu "Nodo N") operativo para luego recuperar el servidor.
**Objetivo:** Reconstruir la "llave maestra" de tu infraestructura.

### Pasos (Intervención manual obligatoria):
Dado que no hay máquinas con acceso a tus secretos, debes realizar el puente inicial a mano.

1. **Accede a tus secretos:**
   Abre la web o instala la app de tu Gestor de Contraseñas (Bitwarden, 1Password) en la máquina limpia.

2. **Extrae las llaves:**
   Busca y copia temporalmente al portapapeles:
   * Tu **GitHub Personal Access Token (PAT)**.
   * Tu **Llave secreta Age**.

3. **El Bootstrap Maestro:**
   Pega este comando en la terminal limpia, reemplazando los valores. Este comando auto-configurará Chezmoi, guardará la llave age, instalará paquetes e inyectará tu identidad.
   ```bash
   CHEZMOI_AGE_KEY="AGE-SECRET-KEY-1..." GITHUB_TOKEN="ghp_X..." \
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yordycg
   ```

4. **Resurrección:**
   Cuando el script termine, esta computadora será oficialmente tu nuevo **Nodo N**. Ahora puedes seguir los pasos del **Escenario 1** para recuperar los servidores caídos.

---

## Anexo: Configuración del `Justfile` para el Escenario 1
Para que el Escenario 1 funcione fluidamente desde tu Nodo N, debes añadir esta receta a tu `Justfile` principal (el que vive en `~/.local/share/chezmoi/Justfile`).

Reemplaza la lógica de lectura según el gestor que utilices (ejemplo con `1password` o `bitwarden`).

```just
# Despliega los dotfiles en un servidor remoto inyectando secretos
[private]
deploy-remote host:
    @echo "Desplegando en {{host}}..."
    
    # --- EJEMPLO CON BITWARDEN (bw) ---
    # Asegúrate de estar logueado ('bw unlock') antes de ejecutar esto
    # ssh {{host}} "CHEZMOI_AGE_KEY='$(bw get item 'Age Key' --fields password)' GITHUB_TOKEN='$(bw get item 'GitHub Token' --fields password)' sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply yordycg"
    
    # --- EJEMPLO CON 1PASSWORD (op) ---
    # ssh {{host}} "CHEZMOI_AGE_KEY='$(op read 'op://Private/AgeKey/password')' GITHUB_TOKEN='$(op read 'op://Private/GitHubToken/credential')' sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply yordycg"
```
