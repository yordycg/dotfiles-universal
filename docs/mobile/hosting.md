# Hosting del Founder Bot — desktop hoy, VPS cuando esté listo

El bot es **host-agnóstico**: nada hardcodeado por máquina; toda la configuración llega por
`.env`. Migrar es repetir la instalación en el host nuevo.

## Opción actual: este desktop

- Units de systemd **user**: `founder-bot.service`, `founder-daily.timer` (07:15),
  `founder-evening.timer` (20:30).
- El timer con `Persistent=true` corre aunque la máquina haya estado dormida al momento
  programado. Con `loginctl enable-linger` funciona sin sesión abierta.
- **Limitación:** si el desktop está apagado a las 07:15, no hay briefing. El costo de
  dejarlo encendido 24/7 (~USD 8-15/mes de luz) no se justifica si vas a tener un VPS.

## Opción futura: VPS gratis (Oracle Cloud Always Free — Chile/Santiago)

Oracle Free Tier en región **Chile Central (Santiago)** ofrece de forma gratuita y para
siempre: 4 OCPUs ARM Ampere + 24 GB RAM + 10 TB egress/mes. Latencia local ~10 ms.

- **Estado real (2026-09):** la capacidad ARM suele estar en *"out of capacity"*. Ya existe
  un GitHub Action que reintenta y avisa por Telegram cuando se libera capacidad.
- Alternativa pagada (~USD 6/mes): Vultr región Santiago (el desktop encendido sale más caro).

### Migración al VPS (cuando llegue la notificación)

1. En el VPS: instalar chezmoi + `git clone` dotfiles-universal + `chezmoi apply` (restaura
   bot, units y scripts).
2. Clonar el vault y el repo emprendimiento (ya lo hace `sync-core-repos`).
3. Ejecutar `founder-env-setup` → lee los secretos desde el passage store (clonado por el
   setup) y escribe el `.env`.
4. `systemctl --user enable --now founder-bot.service founder-daily.timer founder-evening.timer`
   (+ `loginctl enable-linger` para que corra sin sesión).
5. En el desktop: `systemctl --user disable --now founder-bot.service founder-daily.timer
   founder-evening.timer` (opcional, para no duplicar briefing).

Nota: el VPS con rol "server" ya está contemplado por `.chezmoi.yaml.tmpl` (`CHEZMOI_ROLE=server`);
el bot no depende del rol.

### Notas de red y modelo de IA
- `/yt` (yt-dlp) descarga desde el host del bot. Si el CDN de media de YouTube está
  bloqueado en la red del host (timeouts), el bot lo reporta; en el VPS suele funcionar.
- El modelo de chat por defecto es `qwen/qwen3.8-27b` (Groq rota modelos). El bot, ante un
  404, descubre automáticamente un modelo válido (fallback en `http.py`).
