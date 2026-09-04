"""Configuración del bot desde variables de entorno (host-agnóstico)."""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

HOME = Path.home()
DEFAULT_VAULT = HOME / "workspace/personal/obsidian-notes"
DEFAULT_STATUS = HOME / "workspace/personal/emprendimiento"


def _env_bool(name: str, default: bool = False) -> bool:
    raw = os.environ.get(name, "").strip().lower()
    if not raw:
        return default
    return raw in {"1", "true", "yes", "on"}


@dataclass(frozen=True)
class Config:
    telegram_token: str = ""
    chat_id: int = 0
    groq_api_key: str = ""
    groq_model: str = "qwen/qwen3.8-27b"
    whisper_model: str = "whisper-large-v3"
    vault_dir: Path = field(default_factory=lambda: DEFAULT_VAULT)
    status_dir: Path = field(default_factory=lambda: DEFAULT_STATUS)
    tts_voices: list[str] = field(default_factory=lambda: ["es-CL-CatalinaNeural", "es-ES-ElviraNeural"])
    tts_note: str = ""
    log_level: str = "INFO"
    debug: bool = False

    @classmethod
    def from_env(cls) -> "Config":
        chat_raw = os.environ.get("FOUNDER_CHAT_ID", "").strip()
        chat_id = 0
        if chat_raw:
            try:
                chat_id = int(chat_raw)
            except ValueError:
                chat_id = 0

        voices = [
            v.strip()
            for v in os.environ.get("FOUNDER_TTS_VOICES", "").split(",")
            if v.strip()
        ]
        return cls(
            telegram_token=os.environ.get("FOUNDER_TELEGRAM_TOKEN", "").strip(),
            chat_id=chat_id,
            groq_api_key=os.environ.get("FOUNDER_GROQ_API_KEY", "").strip(),
            groq_model=os.environ.get("FOUNDER_GROQ_MODEL", "qwen/qwen3.8-27b").strip(),
            whisper_model=os.environ.get("FOUNDER_WHISPER_MODEL", "whisper-large-v3").strip(),
            vault_dir=Path(os.environ.get("FOUNDER_VAULT_DIR", str(DEFAULT_VAULT))).expanduser(),
            status_dir=Path(os.environ.get("FOUNDER_STATUS_DIR", str(DEFAULT_STATUS))).expanduser(),
            tts_voices=voices or ["es-CL-CatalinaNeural", "es-ES-ElviraNeural"],
            tts_note=os.environ.get("FOUNDER_TTS_NOTE", "").strip(),
            debug=_env_bool("FOUNDER_DEBUG", False),
        )

    @property
    def ready(self) -> bool:
        return bool(self.telegram_token and self.chat_id and self.groq_api_key)
