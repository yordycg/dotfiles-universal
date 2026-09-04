"""Ruta 1→5 y Q&A ligero sobre el vault (RAG-lite por grep + contexto al LLM)."""

from __future__ import annotations

import re
from pathlib import Path

from founder_bot.config import Config
from founder_bot.http import groq_chat

ZETTEL = "000 Zettelkasten"
MAX_HITS = 12
MAX_CONTEXT_CHARS = 9000


def note_path(cfg: Config, name: str) -> Path:
    return cfg.vault_dir / ZETTEL / name


def build_ruta(cfg: Config) -> str:
    lib = note_path(cfg, "Biblioteca de Recursos - Emprendimiento.md")
    if not lib.is_file():
        return "No encontré la nota Biblioteca de Recursos en el vault."
    text = lib.read_text(encoding="utf-8")
    pasos = re.findall(r"^\*\*Paso\s+(\d)\s+—\s+(.*?)\*\*$", text, re.MULTILINE)
    metas = dict(re.findall(r"^\*\*Paso\s+(\d)\s+—.*?\*\*\s*\n>\s*Meta:\s*(.*)$", text, re.MULTILINE))
    if not pasos:
        return "No pude parsear los pasos de la ruta en la biblioteca."
    lines = ["*Ruta de aprendizaje (1→5)*", ""]
    for num, title in pasos:
        meta = metas.get(num, "")
        lines.append(f"**Paso {num} — {title}**")
        if meta:
            lines.append(f"> {meta}")
        lines.append("")
    return "\n".join(lines).rstrip()


def search_vault(cfg: Config, query: str) -> str:
    """Recolecta fragmentos relevantes del vault y de status.md."""
    tokens = [t for t in re.split(r"\s+", query.lower()) if len(t) > 3]
    if not tokens:
        tokens = [query.lower()]

    files: list[tuple[Path, str]] = []
    zettel_dir = cfg.vault_dir / ZETTEL
    if zettel_dir.is_dir():
        for path in sorted(zettel_dir.glob("*.md")):
            try:
                body = path.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            low = body.lower()
            if any(t in low for t in tokens):
                files.append((path, body))

    # status.md del repo emprendimiento siempre aporta contexto de cadencia
    status = cfg.status_dir / "status.md"
    if status.is_file():
        files.insert(0, (status, status.read_text(encoding="utf-8")))

    if not files:
        return ""

    # Ordenar por frescura (mtime desc) y cortar contexto
    files.sort(key=lambda pair: pair[0].stat().st_mtime, reverse=True)
    chunks: list[str] = []
    used = 0
    for path, body in files[:MAX_HITS]:
        if used >= MAX_CONTEXT_CHARS:
            break
        snippet = re.sub(r"\n{3,}", "\n\n", body)
        snippet = snippet[: min(len(snippet), MAX_CONTEXT_CHARS - used)]
        chunks.append(f"--- {path.name} ---\n{snippet}")
        used += len(snippet)
    return "\n\n".join(chunks)


SYSTEM_PROMPT = (
    "Eres el asistente del cockpit de un fundador novato (estilo mentor Y Combinator). "
    "Respondes en español, directo y concreto, sin teoría abstracta. "
    "Usa SOLO el contexto de las notas del fundador que se te entrega; si no está en el "
    "contexto, dilo y sugiere revisarlo juntos. Conecta siempre Capa Negocio y Capa Fundador."
)


def answer_query(cfg: Config, query: str) -> str:
    context = search_vault(cfg, query)
    if not context:
        return "No encontré nada relevante en tus notas todavía."
    user = f"Contexto de mis notas:\n\n{context}\n\nPregunta: {query}"
    return groq_chat(cfg, SYSTEM_PROMPT, user)
