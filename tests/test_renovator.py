import json
import pytest
from unittest.mock import MagicMock, patch
from models import Menu, Category, MenuItem


def _make_improved_menu(original_menu: Menu) -> dict:
    data = json.loads(original_menu.model_dump_json())
    for cat in data["categories"]:
        for item in cat["items"]:
            item["description"] = item["description"] + " — mejorado por IA"
            item["ai_improved"] = True
    data["price_suggestions"] = ["Los precios son coherentes entre sí"]
    return data


def _mock_client(response_data: dict):
    mock_response = MagicMock()
    mock_response.content = [MagicMock(text=json.dumps(response_data))]
    mock_client = MagicMock()
    mock_client.messages.create.return_value = mock_response
    return mock_client


def test_renovate_returns_menu(sample_menu):
    improved = _make_improved_menu(sample_menu)

    with patch("renovator.anthropic.Anthropic", return_value=_mock_client(improved)):
        from renovator import renovate_menu
        result = renovate_menu(sample_menu)

    assert isinstance(result, Menu)


def test_renovate_sets_ai_improved(sample_menu):
    improved = _make_improved_menu(sample_menu)

    with patch("renovator.anthropic.Anthropic", return_value=_mock_client(improved)):
        from renovator import renovate_menu
        result = renovate_menu(sample_menu)

    assert all(
        item.ai_improved
        for cat in result.categories
        for item in cat.items
    )


def test_renovate_preserves_original_description(sample_menu):
    original_desc = sample_menu.categories[0].items[0].description
    improved = _make_improved_menu(sample_menu)

    with patch("renovator.anthropic.Anthropic", return_value=_mock_client(improved)):
        from renovator import renovate_menu
        result = renovate_menu(sample_menu)

    assert result.categories[0].items[0].original_description == original_desc


def test_renovate_fills_price_suggestions(sample_menu):
    improved = _make_improved_menu(sample_menu)

    with patch("renovator.anthropic.Anthropic", return_value=_mock_client(improved)):
        from renovator import renovate_menu
        result = renovate_menu(sample_menu)

    assert len(result.price_suggestions) > 0


def test_renovate_uses_correct_model(sample_menu):
    improved = _make_improved_menu(sample_menu)
    mock_client = _mock_client(improved)

    with patch("renovator.anthropic.Anthropic", return_value=mock_client):
        from renovator import renovate_menu
        renovate_menu(sample_menu)

    call_kwargs = mock_client.messages.create.call_args.kwargs
    assert call_kwargs["model"] == "claude-sonnet-4-6"
