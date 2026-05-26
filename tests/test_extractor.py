import json
import pytest
from unittest.mock import MagicMock, patch
from models import Menu


MOCK_RESPONSE_JSON = {
    "restaurant_name": "",
    "restaurant_type": "",
    "style": "",
    "categories": [
        {
            "name": "Entrantes",
            "items": [
                {
                    "name": "Ensalada",
                    "description": "Ensalada mixta",
                    "original_description": "Ensalada mixta",
                    "price": 8.5,
                    "ai_improved": False,
                }
            ],
        }
    ],
    "price_suggestions": [],
}


def _mock_client(json_data: dict):
    mock_response = MagicMock()
    mock_response.content = [MagicMock(text=json.dumps(json_data))]
    mock_client = MagicMock()
    mock_client.messages.create.return_value = mock_response
    return mock_client


def test_extract_returns_menu(tmp_path):
    img = tmp_path / "carta.jpg"
    img.write_bytes(b"\xff\xd8\xff")  # JPEG header mínimo

    with patch("extractor.anthropic.Anthropic", return_value=_mock_client(MOCK_RESPONSE_JSON)):
        from extractor import extract_menu_from_image
        menu = extract_menu_from_image(str(img))

    assert isinstance(menu, Menu)
    assert len(menu.categories) == 1
    assert menu.categories[0].items[0].name == "Ensalada"


def test_extract_marks_zero_price_items(tmp_path):
    img = tmp_path / "carta.jpg"
    img.write_bytes(b"\xff\xd8\xff")

    data = json.loads(json.dumps(MOCK_RESPONSE_JSON))
    data["categories"][0]["items"][0]["price"] = 0.0
    data["categories"][0]["items"][0]["description"] = ""

    with patch("extractor.anthropic.Anthropic", return_value=_mock_client(data)):
        from extractor import extract_menu_from_image
        menu = extract_menu_from_image(str(img))

    item = menu.categories[0].items[0]
    assert item.price == 0.0
    assert item.description == ""


def test_extract_uses_correct_model(tmp_path):
    img = tmp_path / "carta.jpg"
    img.write_bytes(b"\xff\xd8\xff")

    mock_client = _mock_client(MOCK_RESPONSE_JSON)
    with patch("extractor.anthropic.Anthropic", return_value=mock_client):
        from extractor import extract_menu_from_image
        extract_menu_from_image(str(img))

    call_kwargs = mock_client.messages.create.call_args.kwargs
    assert call_kwargs["model"] == "claude-sonnet-4-6"
