from __future__ import annotations
from typing import List
from pydantic import BaseModel


class MenuItem(BaseModel):
    name: str
    description: str
    original_description: str
    price: float
    ai_improved: bool = False


class Category(BaseModel):
    name: str
    items: List[MenuItem]


class Menu(BaseModel):
    restaurant_name: str
    restaurant_type: str
    style: str = ""
    categories: List[Category]
    price_suggestions: List[str] = []
