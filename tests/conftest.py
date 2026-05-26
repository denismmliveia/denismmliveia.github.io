import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))

from models import Menu, Category, MenuItem


@pytest.fixture
def sample_menu() -> "Menu":
    return Menu(
        restaurant_name="La Piazza",
        restaurant_type="italiano",
        style="fresco",
        categories=[
            Category(name="Entrantes", items=[
                MenuItem(
                    name="Ensalada César",
                    description="Ensalada fresca con lechuga romana",
                    original_description="Ensalada fresca con lechuga romana",
                    price=8.50,
                    ai_improved=False,
                )
            ]),
            Category(name="Principales", items=[
                MenuItem(
                    name="Risotto funghi",
                    description="Risotto cremoso con setas",
                    original_description="Risotto cremoso con setas",
                    price=14.00,
                    ai_improved=False,
                )
            ]),
        ],
    )
