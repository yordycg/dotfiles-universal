# Guía de Instalación y Post-Configuración de Windows 11 (Entorno Dual-Boot y Desarrollo)

Esta guía detalla los pasos para realizar una instalación limpia, segura y optimizada de **Windows 11** en el SSD secundario (**Crucial BX500 de 240 GB / ~223 GiB**), configurado en Dual-Boot nativo con Fedora (SSD ADATA 953 GB). Está optimizada para cargas de trabajo de desarrollo (SQL Server) y diseño gráfico (AutoCAD).

---

## Fase 1: Instalación y Evasión de Cuenta de Microsoft

Windows 11 obliga a iniciar sesión con una cuenta de Microsoft durante la configuración inicial (OOBE). Si deseas crear una **cuenta local tradicional** (sin vincular correos), utiliza uno de estos métodos:

### Método A: El truco del correo bloqueado (Recomendado - Con Internet)
1. Cuando el asistente te pida tu correo de Microsoft, escribe:  
   `no@thankyou.com` (o bien `a@a.com`).
2. Haz clic en **Siguiente**.
3. En la contraseña, escribe cualquier texto corto (ej: `123456`) y dale a **Iniciar sesión**.
4. El sistema mostrará un error indicando que la cuenta está bloqueada. Haz clic en **Siguiente**.
5. El instalador saltará el bloqueo y te permitirá crear tu **usuario local** con su respectiva contraseña.

### Método B: Comando `BypassNRO` (Sin Internet)
1. Desconecta el cable Ethernet de la computadora.
2. En la pantalla de conexión de red o inicio de sesión, presiona **`Shift + F10`** (o `Fn + Shift + F10`) para abrir la consola de comandos.
3. Escribe el siguiente comando y presiona **Enter**:
   ```cmd
   oobe\bypassnro
   ```
4. El PC se reiniciará. Al volver a la pantalla de red, selecciona la opción **"No tengo internet"** abajo a la derecha y luego **"Continuar con la configuración limitada"**. Esto te permitirá crear el usuario local.

---

## Fase 2: Actualizaciones del Sistema y Drivers Críticos

Antes de instalar herramientas de software pesado, es fundamental asegurar la estabilidad del sistema.

### 1. Bucle de Windows Update
* Dirígete a *Configuración > Windows Update*.
* Haz clic en **Buscar actualizaciones**. Instala todo (incluyendo actualizaciones acumulativas y de Framework) y reinicia.
* Repite el proceso hasta que Windows Update indique que el sistema está completamente al día.

### 2. Drivers Oficiales de GPU (GTX 1660 SUPER)
Evita los drivers genéricos de Windows Update para tu tarjeta gráfica dedicada.
* Descarga el driver oficial desde el sitio web de NVIDIA.
* **Tip Senior:** Durante la descarga, selecciona el **NVIDIA Studio Driver** en lugar de *Game Ready Driver*. Los Studio Drivers están certificados y optimizados para la máxima estabilidad en aplicaciones de diseño y CAD como **AutoCAD**.

---

## Fase 3: Optimización del Sistema (Windows Debloat)

Para limpiar el sistema de telemetría y software innecesario (bloatware) de forma segura sin romper características del sistema.

### 1. Ejecución de la utilidad de Chris Titus
1. Abre **PowerShell** como Administrador.
2. Ejecuta el siguiente comando para iniciar la herramienta web interactiva:
   ```powershell
   iwr -useb https://christitus.com/win | iex
   ```
3. En la pestaña **Tweaks**, selecciona la opción **`Standard`** (perfil recomendado para computadoras de escritorio).
4. *Nota de seguridad:* Evita el debloat agresivo o deshabilitar servicios al azar. Programas como SQL Server o el validador de licencias de AutoCAD dependen de servicios de fondo de Windows que el debloat agresivo podría desactivar.
5. Haz clic en **`Run Tweaks`** en el panel lateral derecho y espera a que la consola de PowerShell termine el proceso.

---

## Fase 4: Punto de Restauración del Sistema (Línea Base)

Antes de realizar cambios mayores o instalar software invasivo, crea un punto de retorno seguro.

1. Abre el menú de inicio, busca **"Crear punto de restauración"** y ábrelo.
2. Selecciona la unidad `C:`, haz clic en **Configurar** y activa la protección del sistema asignando un **5%** de espacio en disco.
3. Haz clic en **Crear** y asígnale un nombre descriptivo:  
   *Ejemplo: `Post-Drivers-y-Config-Base`*
4. Si la instalación de AutoCAD o SQL Server falla en el futuro o altera registros críticos, podrás restaurar Windows a este estado limpio en minutos.

---

## Fase 5: Instalación Limpia de Aplicaciones

### 1. Uso de la pestaña `Installs` (Chris Titus Utility)
La pestaña de instalaciones de esta utilidad ejecuta comandos nativos de `winget` en segundo plano. Es totalmente segura y recomendada para instalar aplicaciones básicas de uso diario (navegadores, utilidades, herramientas de compresión, etc.) de una sola vez.

### 2. Uso nativo de `winget` en Terminal
Para instalar otros programas de forma limpia mediante la consola de comandos de Windows (evitando descargar archivos `.exe` sospechosos):
```powershell
# Buscar el ID exacto del programa
winget search "nombre_programa"

# Instalar el programa usando su ID
winget install "ID.Del.Programa"
```

---

## Fase 6: Configuración de Herramientas de Trabajo

### 1. AutoCAD
* Instala AutoCAD mediante el instalador oficial de Autodesk.
* Abre el programa, entra a la configuración de rendimiento gráfico y asegúrate de que la aceleración por hardware esté **activada** y apuntando a tu GPU NVIDIA GTX 1660 SUPER.

### 2. SQL Server (Optimización de Recursos)
SQL Server es un motor de base de datos pesado que activa servicios automáticos en segundo plano, consumiendo RAM y CPU incluso cuando no los estás utilizando.
* Abre el menú de inicio y escribe **`services.msc`** (Servicios).
* Busca los servicios relacionados con SQL Server, principalmente:
  * `SQL Server (MSSQLSERVER)`
  * `SQL Server Launchpad (MSSQLSERVER)`
* Haz clic derecho en cada uno de ellos, selecciona **Propiedades** y cambia el *Tipo de inicio* de **Automático** a **Manual**.
* **Resultado:** Los servicios solo se ejecutarán cuando inicios manualmente el motor de base de datos para trabajar, dejando el sistema libre para el navegador y AutoCAD el resto del tiempo.

---

## Fase 7: Ajustes en el Dual-Boot (BIOS MSI)

Para garantizar que la instalación de Windows no altere el acceso a tu Fedora principal:

1. Reinicia el equipo y entra a la BIOS presionando la tecla **`Delete / Supr`** repetidamente.
2. Navega a la configuración de arranque (**Boot**).
3. Asegúrate de que el **Fedora GRUB** (o la opción que representa tu SSD ADATA de 953 GB) esté establecida como la **Prioridad número 1** de arranque (Boot Option #1).
4. **Uso diario:** 
   * Al encender el PC, se presentará el menú GRUB de Fedora permitiéndote elegir el sistema operativo.
   * Si en el GRUB no aparece Windows de inmediato, puedes presionar **`F11`** al encender la PC para abrir el menú de arranque físico de la placa MSI y elegir el disco Crucial BX500 (~223 GB) directamente.
