# Runbook iOS — Cockpit del fundador en ruta

Pasos **manuales-una-sola-vez** en el iPhone para activar la capa móvil. Todo lo que se
puede automatizar desde Linux ya vive en chezmoi (bot, timers, secretos). Esto es lo que
requiere el teléfono.

## 1. Apps a instalar

| App | Rol |
|---|---|
| Obsidian | Abrir/editar el vault (offline) |
| Working Copy | Cliente Git del vault (fuente de verdad: GitHub) |
| Telegram | El bot (briefing, captura por voz, audio del día, /yt) |
| Shortcuts | Automatizar pull/push de Working Copy |
| Apple Podcasts | Huberman Lab, YC, etc. (descarga offline) |
| Lector con TTS (opcional) | Voice Dream / @Voice para libros EPUB hablados |

## 2. Preparar el acceso Git (una vez, en GitHub web o desktop)

1. Crea un **fine-grained PAT** (Settings → Developer settings → Personal access tokens →
   Fine-grained) con permiso `Contents: Read and write` SOLO sobre `yordycg/obsidian-notes`.
2. Guárdalo en passage (desktop): `passage insert founder/github-pat` (o en 1Password).

## 3. Working Copy

1. Abre Working Copy → `+` → "Clone repository" → pega `git@github.com:yordycg/obsidian-notes.git`
   (SSH) o la URL HTTPS + PAT como password.
2. Espera el clone completo (primera vez puede tardar por el `.obsidian` y adjuntos).
3. Working Copy → Settings (gear) → **URL key**: pínchala una vez para generar la `key`
   que usarán los Shortcuts.

## 4. Obsidian abre el vault desde Working Copy

1. En Working Copy toca el repo → icono compartir → **"Open in Obsidian"** (o: repo →
   "Show in Files" → añade la carpeta a Favoritos).
2. En Obsidian iOS: Open folder as vault → selecciona la carpeta del repo.
3. Activa en Obsidian: Ajustes → Editor → **"Readable line length"** a gusto. Nada más:
   **no** instales obsidian-git en iOS (no corre git nativo); Working Copy manda.

## 5. Shortcuts (pull/push automático)

Crea **2 atajos**, luego 2 automatizaciones por hora:

- Atajo `Vault Pull` → "Abrir URLs" →
  `working-copy://x-callback-url/pull?repo=obsidian-notes&key=TU_KEY`
- Atajo `Vault Push` → "Abrir URLs" →
  `working-copy://x-callback-url/commit?repo=obsidian-notes&key=TU_KEY&message=vault:+ios&push=1`
  (Working Copy acepta `commit`+`push` combinado; si tu versión separa pasos, encadena
  `pull` al inicio y `push` al final del mismo atajo).

Automatizaciones (app Shortcuts → Automatización):
- **Hora: 07:00** → ejecutar `Vault Pull` (antes del viaje).
- **Hora: 20:00** → ejecutar `Vault Push` (sube cambios del día).

> Los nombres exactos de acciones x-callback se verifican en la ayuda in-app de Working
> Copy (icono `?` dentro del repo). La mecánica es: pull al despertar, push al volver.

## 6. Bot de Telegram

1. Asegúrate de que el desktop tenga el bot corriendo (`systemctl --user status founder-bot`).
2. En Telegram abre tu bot → `/start` → responde el HELP.
3. Para fijar `FOUNDER_CHAT_ID`: mándale cualquier mensaje al bot; el log del desktop te
   muestra tu chat_id, o usa `@userinfobot` para obtenerlo. Pásalo a `founder-env-setup`.

## 7. Flujo de uso diario

- 07:15 → llega el briefing push.
- Viaje ida → audio del día (TTS nocturno) o podcast o lectura del vault ya sincronizado.
- En la calle → audio al bot = nota a `quick/` (el sync del desktop la sube a GitHub; el
  pull de las 07:00 la trae al iPhone al día siguiente).
- Viaje vuelta → `/yt <url>` para dejar audio descargado de mañana.
  **Ojo:** `/yt` descarga desde el host del bot (hoy el desktop). En algunas redes el CDN
  de media de YouTube está bloqueado (error de timeout); funciona desde el VPS o una red
  sin ese bloqueo.
- En casa → las sesiones del ritual destilan esas notas al Zettelkasten.
