import pytest
from pydantic import ValidationError
from models import Menu, Category, MenuItem


def test_menu_item_fields():
    item = MenuItem(
        name="Pizza Margherita",
        description="Pizza clásica",
        original_description="Pizza clásica",
        price=12.0,
        ai_improved=False,
    )
    assert item.name == "Pizza Margherita"
    assert item.ai_improved is False


def test_menu_defaults():
    menu = Menu(
        restaurant_name="El Faro",
        restaurant_type="mediterráneo",
        categories=[],
    )
    assert menu.style == ""
    assert menu.price_suggestions == []


def test_menu_item_requires_name():
    with pytest.raises(ValidationError):
        MenuItem(description="sin nombre", original_description="sin nombre", price=5.0, ai_improved=False)


def test_category_items_list():
    cat = Category(name="Postres", items=[])
    assert cat.items == []


def test_menu_serializes_to_json(sample_menu):
    json_str = sample_menu.model_dump_json()
    assert "La Piazza" in json_str
    assert "Ensalada César" in json_str
