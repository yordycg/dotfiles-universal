"""Bot de Telegram: /hoy /ruta /q /nota /yt + captura por voz.

Host-agnóstico: toda la configuración llega por env vars (ver founder_bot.config).
"""

from __future__ import annotations

import asyncio
import logging
import tempfile
from pathlib import Path

from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes, MessageHandler, filters

from founder_bot import capture
from founder_bot.briefing import build_briefing
from founder_bot.config import Config
from founder_bot.media import download_audio
from founder_bot.qa import answer_query, build_ruta

log = logging.getLogger("founder.bot")

HELP = (
    "*Cockpit del fundador en ruta*\n\n"
    "/hoy — briefing de cadencia (status.md)\n"
    "/ruta — pasos 1→5 de la ruta de aprendizaje\n"
    "/q <texto> — pregúntale a tus notas\n"
    "/nota <texto> — captura rápida al inbox (quick/)\n"
    "/yt <url> — descarga el audio y te lo deja aquí (offline)\n"
    "Mándame un audio de voz y lo convierto en nota"
)


def _build_app(cfg: Config) -> Application:
    app = Application.builder().token(cfg.telegram_token).build()

    def register(fn):
        async def guard(update: Update, context: ContextTypes.DEFAULT_TYPE):
            chat_id = update.effective_chat.id if update.effective_chat else 0
            log.info("Mensaje recibido de chat_id=%s", chat_id)
            if cfg.chat_id and chat_id != cfg.chat_id:
                log.warning("Mensaje ignorado de chat no autorizado: %s", chat_id)
                return
            await fn(update, context)

        return guard

    async def start(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        await update.message.reply_text(HELP, parse_mode="Markdown")

    async def hoy(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        await update.message.reply_text(build_briefing(cfg))

    async def ruta(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        await update.message.reply_text(build_ruta(cfg))

    async def q(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        args = " ".join(ctx.args or [])
        if not args:
            await update.message.reply_text("Uso: /q <tu pregunta>")
            return
        await update.message.reply_text("Buscando en tus notas...")
        try:
            answer = await asyncio.to_thread(answer_query, cfg, args)
        except Exception as exc:  # noqa: BLE001
            log.exception("Fallo /q")
            answer = f"Error consultando Groq: {exc}"
        await update.message.reply_text(answer)

    async def nota(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        text = " ".join(ctx.args or [])
        if not text:
            await update.message.reply_text("Uso: /nota <texto de la idea>")
            return
        try:
            path = capture.save_capture(cfg, text, source="telegram")
            await update.message.reply_text(f"Guardada: `{path.relative_to(cfg.vault_dir)}`", parse_mode="Markdown")
        except ValueError as exc:
            await update.message.reply_text(str(exc))

    async def yt(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        args = " ".join(ctx.args or []).strip()
        if not args:
            await update.message.reply_text("Uso: /yt <url de youtube>")
            return
        await update.message.reply_text("Descargando audio (puede tardar)...")
        tmp = Path(tempfile.gettempdir()) / "founder-bot"
        try:
            path = await asyncio.to_thread(download_audio, args, tmp)
            if path is None:
                await update.message.reply_text("No encontré audio descargable.")
                return
            with open(path, "rb") as fh:
                await update.message.reply_document(fh, filename=path.name)
            path.unlink(missing_ok=True)
        except Exception as exc:  # noqa: BLE001
            log.exception("Fallo /yt")
            await update.message.reply_text(f"Error: {exc}")

    async def voice(update: Update, ctx: ContextTypes.DEFAULT_TYPE) -> None:
        v = update.message.voice
        if v is None:
            return
        await update.message.reply_text("Transcribiendo...")
        tmp = Path(tempfile.gettempdir()) / "founder-bot"
        tmp.mkdir(parents=True, exist_ok=True)
        oga = tmp / "voice.oga"
        file = await v.get_file()
        await file.download_to_drive(oga)
        ogg = oga.with_suffix(".ogg")
        if oga.exists() and not ogg.exists():
            ogg = oga
        try:
            from founder_bot.http import groq_transcribe

            transcript = await asyncio.to_thread(groq_transcribe, cfg, ogg, "audio/ogg")
        except Exception as exc:  # noqa: BLE001
            log.exception("Fallo transcripción")
            await update.message.reply_text(f"No pude transcribir: {exc}")
            return
        finally:
            oga.unlink(missing_ok=True)
            if ogg != oga:
                ogg.unlink(missing_ok=True)

        if not transcript or transcript.startswith("("):
            await update.message.reply_text(transcript or "Silencio capturado.")
            return
        try:
            path = capture.save_capture(cfg, transcript, source="voice")
            await update.message.reply_text(
                f"Nota guardada:\n\n{transcript}\n\n`{path.relative_to(cfg.vault_dir)}`",
                parse_mode="Markdown",
            )
        except ValueError as exc:
            await update.message.reply_text(str(exc))

    app.add_handler(CommandHandler("start", register(start)))
    app.add_handler(CommandHandler("help", register(start)))
    app.add_handler(CommandHandler("hoy", register(hoy)))
    app.add_handler(CommandHandler("ruta", register(ruta)))
    app.add_handler(CommandHandler("q", register(q)))
    app.add_handler(CommandHandler("nota", register(nota)))
    app.add_handler(CommandHandler("yt", register(yt)))
    app.add_handler(MessageHandler(filters.VOICE, register(voice)))
    return app


def main() -> None:
    cfg = Config.from_env()
    logging.basicConfig(
        level=cfg.log_level,
        format="%(asctime)s %(name)s %(levelname)s %(message)s",
    )
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("telegram.vendor").setLevel(logging.WARNING)
    if not cfg.telegram_token:
        log.error("Falta FOUNDER_TELEGRAM_TOKEN. Ejecuta founder-env-setup.")
        raise SystemExit(1)

    app = _build_app(cfg)
    log.info("Founder bot arrancando (polling)...")
    app.run_polling(drop_pending_updates=True)


if __name__ == "__main__":
    main()
