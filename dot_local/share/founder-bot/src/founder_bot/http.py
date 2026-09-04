"""Helpers HTTP: envío de mensajes/archivos por Bot API y llamadas a Groq."""

from __future__ import annotations

from pathlib import Path

import httpx

GROQ_BASE = "https://api.groq.com/openai/v1"
TG_API = "https://api.telegram.org"

# Modelos de chat preferidos (orden); sirve de fallback si el configurado ya no existe.
PREFERRED_MODELS = [
    "qwen/qwen3.8-27b",
    "openai/gpt-oss-20b",
    "openai/gpt-oss-120b",
]
_blocked_name = ("whisper", "tts", "guard", "safeguard", "compound", "embedding")
_working_model: str | None = None


def _discover_model(cfg) -> str | None:
    """Elige el primer modelo de chat disponible (para sobrevivir a rotaciones de Groq)."""
    headers = {"Authorization": f"Bearer {cfg.groq_api_key}"}
    try:
        with httpx.Client(timeout=20.0) as client:
            resp = client.get(f"{GROQ_BASE}/models", headers=headers)
            resp.raise_for_status()
            ids = [m.get("id", "") for m in resp.json().get("data", [])]
    except Exception:  # noqa: BLE001
        return None
    for pref in PREFERRED_MODELS:
        if pref in ids:
            return pref
    for mid in ids:
        if mid and not any(b in mid for b in _blocked_name):
            return mid
    return None


def groq_chat(cfg, system: str, user: str, timeout: float = 60.0) -> str:
    """Chat completion con Groq (httpx puro, sin SDK). Con fallback de modelo ante 404."""
    global _working_model
    model = _working_model or cfg.groq_model
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": 0.4,
    }
    headers = {"Authorization": f"Bearer {cfg.groq_api_key}"}
    with httpx.Client(timeout=timeout) as client:
        resp = client.post(f"{GROQ_BASE}/chat/completions", json=payload, headers=headers)
        if resp.status_code == 404:
            fallback = _discover_model(cfg)
            if fallback and fallback != model:
                _working_model = fallback
                payload["model"] = fallback
                resp = client.post(f"{GROQ_BASE}/chat/completions", json=payload, headers=headers)
        resp.raise_for_status()
    try:
        return resp.json()["choices"][0]["message"]["content"].strip()
    except (KeyError, IndexError):
        return "(sin respuesta del modelo)"


def groq_transcribe(cfg, audio_path, mime: str = "audio/ogg", timeout: float = 180.0) -> str:
    """Transcripción de audio con Whisper vía Groq."""
    headers = {"Authorization": f"Bearer {cfg.groq_api_key}"}
    with open(audio_path, "rb") as fh:
        files = {"file": (Path(audio_path).name, fh, mime)}
        data = {"model": cfg.whisper_model, "response_format": "json"}
        with httpx.Client(timeout=timeout) as client:
            resp = client.post(
                f"{GROQ_BASE}/audio/transcriptions", data=data, files=files, headers=headers
            )
            resp.raise_for_status()
    try:
        return resp.json()["text"].strip()
    except (KeyError, IndexError):
        return "(no se pudo transcribir)"


def tg_send_message(token: str, chat_id: int, text: str) -> None:
    with httpx.Client(timeout=30.0) as client:
        client.post(
            f"{TG_API}/bot{token}/sendMessage",
            json={"chat_id": chat_id, "text": text},
        ).raise_for_status()


def tg_send_audio(token: str, chat_id: int, path: str, filename: str) -> None:
    with open(path, "rb") as fh:
        with httpx.Client(timeout=300.0) as client:
            client.post(
                f"{TG_API}/bot{token}/sendDocument",
                data={"chat_id": chat_id},
                files={"document": (filename, fh, "application/octet-stream")},
            ).raise_for_status()
