"""Briefing diario: lee status.md y arma el mensaje de cadencia del fundador."""

from __future__ import annotations

import logging
import re
from datetime import datetime

from founder_bot.config import Config
from founder_bot.http import tg_send_message

log = logging.getLogger("founder.briefing")

DIAS = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]


def _status_path(cfg: Config):
    return cfg.status_dir / "status.md"


def _find_section(text: str, header: str) -> str:
    """Devuelve el cuerpo de la sección markdown cuyo encabezado empieza con `header`."""
    pattern = re.compile(rf"^##\s+{re.escape(header)}(?=\s|$)", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return ""
    rest = text[match.end():]
    end = re.search(r"\n##\s", rest)
    return rest if end is None else rest[: end.start()]


def _parse_table_rows(section: str) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in section.splitlines():
        line = line.strip()
        if not line.startswith("|") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if cells and not all(re.fullmatch(r":?-{2,}:?", c) for c in cells):
            rows.append(cells)
    return rows


def build_briefing(cfg: Config) -> str:
    status = _status_path(cfg)
    if not status.is_file():
        return "No encontré status.md. Ejecuta founder-env-setup y verifica FOUNDER_STATUS_DIR."

    text = status.read_text(encoding="utf-8")
    now = datetime.now()
    day = DIAS[now.weekday()]
    date_str = now.strftime("%Y-%m-%d")

    # Hitos del progreso general
    milestones = _find_section(text, "Progreso general")
    hitos_lines = []
    for row in _parse_table_rows(milestones):
        if len(row) >= 2 and row[-1].strip() in {"✅", "☐"}:
            estado = "OK" if "✅" in row[-1] else "pendiente"
            hitos_lines.append(f"- {row[0]}: {estado}")

    # Última sesión (primera fila de datos con fecha)
    sessions = _find_section(text, "Últimas sesiones")
    data_rows = [
        row for row in _parse_table_rows(sessions)
        if row and re.match(r"\d{4}-\d{2}-\d{2}", row[0])
    ]
    last = data_rows[0] if data_rows else []
    tema = last[1] if len(last) > 1 else ""
    compromiso = last[2] if len(last) > 2 else ""
    pregunta = last[3] if len(last) > 3 else ""

    # Ruta de aprendizaje: pasos
    ruta = _find_section(text, "Ruta de aprendizaje")
    pasos = re.findall(r"^\*\*Paso\s+\d.*$", ruta, re.MULTILINE)
    pasos_txt = "\n".join(f"  {p.strip('*').strip()}" for p in pasos[:5]) or "  (sin pasos)"

    lines: list[str] = [
        f"*Briefing fundador — {day} {date_str}*",
        "",
        "**Estado general**",
        *hitos_lines,
        "",
        "**Última sesión**",
        f"- Tema: {tema or '-'}",
        f"- Compromiso: {compromiso or '-'}",
        f"- Pregunta abierta: {pregunta or '-'}",
        "",
        "**Ruta de aprendizaje (1→5)**",
        pasos_txt,
        "",
        "_Regla: una sesión sin compromiso = CAC sin LTV._",
    ]
    return "\n".join(lines)


def main() -> None:
    cfg = Config.from_env()
    logging.basicConfig(level=cfg.log_level, format="%(asctime)s %(name)s %(levelname)s %(message)s")
    if not cfg.telegram_token or not cfg.chat_id:
        log.warning("Falta token/chat_id: skip briefing.")
        return
    message = build_briefing(cfg)
    tg_send_message(cfg.telegram_token, cfg.chat_id, message)
    log.info("Briefing enviado a Telegram.")


if __name__ == "__main__":
    main()
