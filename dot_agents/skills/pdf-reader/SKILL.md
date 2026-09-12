---
name: pdf-reader
description: Read and comprehend PDF files, especially technical books, system manuals, math lecture notes, and academic papers. Use when the user asks to read, parse, analyze, or extract content from a PDF file.
---

# PDF Reader

Read and comprehend PDF files, especially technical books, system manuals, math lecture notes, and papers. Uses a hybrid text extraction + vision approach for maximum comprehension of equations, diagrams, and structured content.

## Setup & Environment

All scripts run in an isolated virtual environment at `~/.agents/skills/pdf-reader/.venv` with `pymupdf` installed via `uv` (Clean Host):

```bash
uv venv ~/.agents/skills/pdf-reader/.venv
~/.agents/skills/pdf-reader/.venv/bin/uv pip install -r ~/.agents/skills/pdf-reader/requirements.txt
```

**Execution Command:** Always invoke scripts using the isolated venv python:
```bash
~/.agents/skills/pdf-reader/.venv/bin/python ~/.agents/skills/pdf-reader/scripts/<script>.py [args]
```

## Scripts

All scripts reside in `~/.agents/skills/pdf-reader/scripts/`:

| Script | Purpose | Key args |
|---|---|---|
| `pdf_info.py <path>` | Metadata + per-page analysis (page count, TOC, text density, math density, image count) | `<path>` |
| `pdf_extract.py <path> [--pages SPEC]` | Extract text by page | `--pages all|1-5|1,3,7|3` |
| `pdf_render.py <path> [--pages SPEC] [--dpi N]` | Render pages to PNG images in `/tmp/pi-pdf-*/` | `--pages`, `--dpi` (default 150) |
| `pdf_search.py <path> <query> [--context N] [--literal]` | Search text content by regex or literal | `--context` lines (default 3), `--literal` flag |

Page specs: `all`, `1-5`, `1,3,7`, `3` (1-indexed, inclusive ranges).

## Strategy: How to Read a PDF

### Step 1: Always Triage First

Run `pdf_info.py` on every new PDF before doing anything else:
```bash
~/.agents/skills/pdf-reader/.venv/bin/python ~/.agents/skills/pdf-reader/scripts/pdf_info.py /path/to/doc.pdf
```
This reveals:
- Total page count (determines reading strategy)
- Table of Contents (structural outline and navigation)
- Per-page math density and image count (identifies pages needing visual inspection)
- Per-page text length (identifies diagram-heavy or sparse pages)

### Step 2: Pick a Strategy Based on Size

#### Short PDFs (≤ 15 pages)
- Extract all text: `pdf_extract.py <path>`
- Render all pages: `pdf_render.py <path>`
- Read rendered images for complete comprehension of figures/diagrams.

#### Medium PDFs (15–60 pages)
- Extract all text first for structural overview.
- Check `pdf_info.py` output for pages with high `math_density` (>0.02), `image_count` > 0, or low `text_length` (<100).
- Render only those math/diagram-heavy pages as images.
- For the rest, text extraction is sufficient.

#### Long PDFs (60+ pages, e.g., CSAPP, K&R)
- Extract text for TOC and section headers only.
- Do NOT render all pages.
- Use `pdf_search.py` to find the exact pages containing the topic or chapter needed.
- Render only the specific target pages (`--pages N`).

### Step 3: Visual Inspection

When reading rendered images:
- **150 DPI** (default) is ideal for text and math formulas.
- **200 DPI** for dense architecture diagrams or small circuit/memory diagrams.
- Quote formulas in LaTeX notation when explaining concepts to the user.
