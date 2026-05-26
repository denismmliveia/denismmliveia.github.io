import pytest
from pathlib import Path
from pdf_generator import generate_pdf


def test_generate_pdf_creates_file(tmp_path, sample_menu):
    sample_menu.style = "fresco"
    output = tmp_path / "carta.pdf"
    generate_pdf(sample_menu, str(output))
    assert output.exists()
    assert output.stat().st_size > 500


def test_generate_pdf_all_styles(tmp_path, sample_menu):
    for style in ("rustico", "elegante", "fresco"):
        sample_menu.style = style
        output = tmp_path / f"carta_{style}.pdf"
        generate_pdf(sample_menu, str(output))
        assert output.exists()


def test_generate_pdf_unknown_style_raises(tmp_path, sample_menu):
    sample_menu.style = "inexistente"
    with pytest.raises(FileNotFoundError):
        generate_pdf(sample_menu, str(tmp_path / "carta.pdf"))
