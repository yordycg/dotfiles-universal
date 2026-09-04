"""Captura rápida: guarda una idea/texto como nota inbox en el vault (quick/)."""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path

from founder_bot.config import Config


def _slug(text: str) -> str:
    base = re.sub(r"[^a-z0-9áéíóúñü\s-]", "", text.lower())
    words = [w for w in re.split(r"\s+", base) if w]
    return "-".join(words[:6]) if words else "idea"


def save_capture(cfg: Config, text: str, source: str = "telegram") -> Path:
    now = datetime.now()
    stamp = now.strftime("%Y-%m-%d_%H%M")
    quick = cfg.vault_dir / "quick"
    quick.mkdir(parents=True, exist_ok=True)

    body = text.strip()
    if not body:
        raise ValueError("captura vacía")

    title = body.splitlines()[0][:60]
    filename = f"{stamp}-{_slug(title)}.md"
    path = quick / filename

    content = (
        f"---\nDate: {now.strftime('%Y-%m-%d')}\nTime: {now.strftime('%H:%M')}\n"
        f"Tags:\n  - inbox\n  - emprendimiento\nFuente: {source}\n---\n\n"
        f"# {title}\n\n{body}\n"
    )
    path.write_text(content, encoding="utf-8")
    return path
