"""TTS nocturno: convierte la nota del día en audio (edge-tts) y lo envía a Telegram."""

from __future__ import annotations

import asyncio
import logging
import re
import tempfile
from pathlib import Path

from founder_bot.config import Config
from founder_bot.http import tg_send_audio

log = logging.getLogger("founder.tts")


def strip_markdown(text: str) -> str:
    text = re.sub(r"```.*?```", " ", text, flags=re.DOTALL)
    text = re.sub(r"\[\[([^\]|]+)(\|[^\]]+)?\]\]", r"\1", text)
    text = re.sub(r"!\[.*?\]\(.*?\)", " ", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"^#{1,6}\s*", "", text, flags=re.MULTILINE)
    text = re.sub(r"[*_>`~]", "", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


async def synthesize(text: str, voice: str, out: Path) -> Path:
    from edge_tts import Communicate

    communicate = Communicate(text, voice)
    await communicate.save(str(out))
    return out


def _notes_text(cfg: Config) -> str:
    """Arma el texto a leer: la nota TTS configurada o las notas semilla por defecto."""
    parts: list[str] = []
    if cfg.tts_note:
        names = [n.strip() for n in cfg.tts_note.split("|") if n.strip()]
        for name in names:
            p = Path(name).expanduser()
            if not p.is_file():
                p = cfg.vault_dir / "000 Zettelkasten" / name
                if not p.name.endswith(".md"):
                    p = p.with_suffix(".md")
            if p.is_file():
                parts.append(strip_markdown(p.read_text(encoding="utf-8")))
        if parts:
            return "\n\n".join(parts)

    defaults = [
        cfg.vault_dir / "000 Zettelkasten/Descubrimiento de Problemas - Negocio.md",
        cfg.vault_dir / "000 Zettelkasten/Introversion Como Ventaja - Fundador.md",
    ]
    for p in defaults:
        if p.is_file():
            parts.append(strip_markdown(p.read_text(encoding="utf-8")))
    return "\n\n".join(parts)


def generate_evening_audio(cfg: Config) -> str | None:
    text = _notes_text(cfg)
    if not text:
        log.warning("No hay notas para leer (falta vault o FOUNDER_TTS_NOTE).")
        return None
    tmp = Path(tempfile.gettempdir()) / "founder-bot"
    tmp.mkdir(parents=True, exist_ok=True)
    out = tmp / "nota-del-dia.mp3"

    for voice in cfg.tts_voices:
        try:
            asyncio.run(synthesize(text[:6000], voice, out))
            return str(out)
        except Exception as exc:  # noqa: BLE001
            log.warning("Voz %s falló: %s", voice, exc)
    log.error("Ninguna voz de edge-tts funcionó.")
    return None


def main() -> None:
    cfg = Config.from_env()
    logging.basicConfig(level=cfg.log_level, format="%(asctime)s %(name)s %(levelname)s %(message)s")
    if not cfg.telegram_token or not cfg.chat_id:
        log.warning("Falta token/chat_id: skip envío nocturno.")
        return
    audio = generate_evening_audio(cfg)
    if not audio:
        return
    tg_send_audio(cfg.telegram_token, cfg.chat_id, audio, "nota-del-dia.mp3")
    log.info("Audio nocturno enviado a Telegram.")


if __name__ == "__main__":
    main()
