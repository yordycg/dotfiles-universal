# Lista de Tareas de Reestructuración (tasks.md)

Este archivo sirve para trackear el progreso de la reestructuración del repositorio `dotfiles-universal`. Cada tarea debe completarse de forma atómica y ser confirmada en Git tras su validación.

---

## 📋 Fase 1: Documentación y Reglas de Base
*El objetivo es alinear las directrices del repositorio con la nueva visión.*

- [ ] **Tarea 1.1:** Actualizar `context.md` con la nueva definición de Nodo 2 (Arch + Hyprland) y Nodo N (Arch/Fedora + Hyprland ECO).
- [ ] **Tarea 1.2:** Actualizar `docs/roadmap.md` marcando las fases previas como completadas e incorporando la nueva Fase 7 de infraestructura declarativa.
- [ ] **Tarea 1.3:** Registrar este archivo `tasks.md` en el repositorio para seguimiento interactivo.

---

## 📋 Fase 2: Configuración del Core de Chezmoi
*El objetivo es establecer la lógica interactiva y las variables de entorno de Chezmoi.*

- [ ] **Tarea 2.1:** Modificar `.chezmoi.yaml.tmpl` para introducir la selección interactiva de perfil (`node.profile`), distribución (`node.distro`) y gráfica (`node.gpu`).
- [ ] **Tarea 2.2:** Crear `.chezmoidata/packages.yaml` unificando la lista de paquetes del sistema para Arch y Fedora de forma estructurada.
- [ ] **Tarea 2.3:** Adaptar `.chezmoiscripts/run_once_before_00-provision-system.sh.tmpl` para leer del nuevo YAML y resolver la instalación silenciosa de paquetes en Arch y Fedora.

---

## 📋 Fase 3: Modularización de Hyprland (Lua Templates)
*El objetivo es inyectar la lógica dinámica en los archivos Lua de Hyprland.*

- [ ] **Tarea 3.1:** Crear `dot_config/hypr/modules/decorations.lua.tmpl` para alternar entre el perfil FULL (Desktop) y el perfil ECO (Laptop: sin blur, sin sombras).
- [ ] **Tarea 3.2:** Crear `dot_config/hypr/modules/animations.lua.tmpl` para desactivar las animaciones en el perfil ECO.
- [ ] **Tarea 3.3:** Crear `dot_config/hypr/modules/autostarts.lua.tmpl` para inyectar daemons adicionales (como `hyprpm reload`) condicionados al perfil del nodo.
- [ ] **Tarea 3.4:** Crear `dot_config/hypr/modules/monitors.lua.tmpl` para cargar configuraciones de monitores basadas en el hostname.
- [ ] **Tarea 3.5:** Integrar en `dot_config/hypr/modules/binds.lua` los atajos rescatados de capturas de pantalla (`hyprshot`), calculadora (`rofi-calc`) y Alt+Tab (`snappy`).

---

## 📋 Fase 4: Entornos de Desarrollo Declarativos (Distrobox)
*El objetivo es declarar la flota de contenedores como código.*

- [ ] **Tarea 4.1:** Crear la plantilla de ensamblaje `dot_config/distrobox/distrobox.ini.tmpl` declarando los contenedores de desarrollo base (Node, Python, base de datos).
- [ ] **Tarea 4.2:** Implementar el script disparador `.chezmoiscripts/run_onchange_after_30-distrobox-assemble.sh` para levantar los contenedores de forma desatendida cuando el archivo de configuración cambie.
