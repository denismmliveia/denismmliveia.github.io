import pytest
from pathlib import Path
from web_generator import generate_web


def test_creates_index_html(tmp_path, sample_menu):
    web_dir = str(tmp_path / "carta_web")
    qr_path = str(tmp_path / "qr.png")
    generate_web(sample_menu, web_dir, qr_path)
    assert (Path(web_dir) / "index.html").exists()


def test_creates_qr_png(tmp_path, sample_menu):
    web_dir = str(tmp_path / "carta_web")
    qr_path = str(tmp_path / "qr.png")
    generate_web(sample_menu, web_dir, qr_path)
    assert Path(qr_path).exists()
    assert Path(qr_path).stat().st_size > 0


def test_html_contains_restaurant_name(tmp_path, sample_menu):
    web_dir = str(tmp_path / "carta_web")
    qr_path = str(tmp_path / "qr.png")
    generate_web(sample_menu, web_dir, qr_path)
    html = (Path(web_dir) / "index.html").read_text(encoding="utf-8")
    assert "La Piazza" in html


def test_custom_url_used_in_qr(tmp_path, sample_menu):
    web_dir = str(tmp_path / "carta_web")
    qr_path = str(tmp_path / "qr.png")
    generate_web(sample_menu, web_dir, qr_path, url="https://mirestaurante.com/carta")
    # El QR se genera sin error y el archivo existe
    assert Path(qr_path).exists()
