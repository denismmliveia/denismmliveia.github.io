from __future__ import annotations
import os
from pathlib import Path

import qrcode
from jinja2 import Environment, FileSystemLoader

from models import Menu

_TEMPLATES_DIR = Path(__file__).parent / "templates"


def generate_web(
    menu: Menu,
    web_dir: str,
    qr_path: str,
    url: str = "",
) -> None:
    os.makedirs(web_dir, exist_ok=True)

    style = menu.style or "fresco"
    env = Environment(loader=FileSystemLoader(str(_TEMPLATES_DIR)))
    template = env.get_template(f"{style}.html")
    html_content = template.render(menu=menu)

    index_path = Path(web_dir) / "index.html"
    index_path.write_text(html_content, encoding="utf-8")

    qr_target = url.strip() if url.strip() else "./index.html"
    img = qrcode.make(qr_target)
    img.save(qr_path)
