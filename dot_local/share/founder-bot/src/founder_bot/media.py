"""Descarga de audio de YouTube (yt-dlp) para playback offline en Telegram."""

from __future__ import annotations

from pathlib import Path

import yt_dlp


def download_audio(url: str, outdir: Path) -> Path | None:
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    opts: dict = {
        "format": "bestaudio[ext=m4a]/bestaudio/best",
        "outtmpl": str(outdir / "%(title).80s.%(ext)s"),
        "quiet": True,
        "no_warnings": True,
        "noplaylist": True,
        "restrictfilenames": True,
    }
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(url, download=True)
            file = ydl.prepare_filename(info)
        if file and Path(file).is_file():
            return Path(file)
    except Exception as exc:  # noqa: BLE001 — superficie de error al usuario
        raise RuntimeError(f"No pude descargar el audio: {exc}") from exc
    # Fallback: buscar cualquier archivo descargado en outdir (formatos variables)
    files = sorted(outdir.glob("*"), key=lambda p: p.stat().st_mtime, reverse=True)
    return files[0] if files else None
