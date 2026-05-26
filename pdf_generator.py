from __future__ import annotations
import os
import sys
from pathlib import Path

# On Windows, ensure the GTK3 runtime DLLs are prioritised over other
# directories that may contain older incompatible versions (e.g. Tesseract-OCR).
_GTK_BIN = r"C:\Program Files\GTK3-Runtime Win64\bin"
if sys.platform == "win32" and Path(_GTK_BIN).exists():
    # Prepend GTK3 bin to PATH so Windows finds its DLLs before Tesseract's.
    _current_path = os.environ.get("PATH", "")
    if _GTK_BIN not in _current_path:
        os.environ["PATH"] = _GTK_BIN + os.pathsep + _current_path
    # Also add via the Python 3.8+ DLL directory mechanism.
    if hasattr(os, "add_dll_directory"):
        os.add_dll_directory(_GTK_BIN)

from jinja2 import Environment, FileSystemLoader
from weasyprint import HTML

from models import Menu

_TEMPLATES_DIR = Path(__file__).parent / "templates"


def generate_pdf(menu: Menu, output_path: str) -> None:
    template_file = _TEMPLATES_DIR / f"{menu.style}.html"
    if not template_file.exists():
        raise FileNotFoundError(f"Plantilla no encontrada: {template_file}")

    env = Environment(loader=FileSystemLoader(str(_TEMPLATES_DIR)))
    template = env.get_template(f"{menu.style}.html")
    html_content = template.render(menu=menu)

    HTML(string=html_content, base_url=str(_TEMPLATES_DIR)).write_pdf(output_path)
