from __future__ import annotations
import base64
import json
from pathlib import Path

import anthropic

from models import Menu

EXTRACTION_PROMPT = """Analiza esta imagen de una carta de restaurante y extrae toda la información en formato JSON.
Devuelve ÚNICAMENTE el JSON, sin texto adicional, con esta estructura exacta:
{
  "restaurant_name": "",
  "restaurant_type": "",
  "style": "",
  "categories": [
    {
      "name": "Nombre de categoría",
      "items": [
        {
          "name": "Nombre del plato",
          "description": "Descripción del plato",
          "original_description": "Descripción del plato",
          "price": 0.0,
          "ai_improved": false
        }
      ]
    }
  ],
  "price_suggestions": []
}
Para platos ilegibles o sin precio visible usa price: 0.0 y description: "".
Deja restaurant_name, restaurant_type y style vacíos (los rellena el usuario).
"""

_MEDIA_TYPES = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
    ".gif": "image/gif",
}


def extract_menu_from_image(image_path: str) -> Menu:
    client = anthropic.Anthropic()

    image_bytes = Path(image_path).read_bytes()
    b64 = base64.standard_b64encode(image_bytes).decode("utf-8")
    media_type = _MEDIA_TYPES.get(Path(image_path).suffix.lower(), "image/jpeg")

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        messages=[{
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {"type": "base64", "media_type": media_type, "data": b64},
                },
                {"type": "text", "text": EXTRACTION_PROMPT},
            ],
        }],
    )

    data = json.loads(response.content[0].text)
    return Menu(**data)
