from __future__ import annotations
import json

import anthropic

from models import Menu

RENOVATION_PROMPT = """Eres un experto en gastronomía y copywriting para restaurantes de habla hispana.

Dado el siguiente menú en JSON, realiza estas tres mejoras:
1. Reescribe la "description" de cada plato para que sea más apetecible y descriptiva (añade ingredientes clave, técnica de cocción, textura). Mantén menos de 20 palabras por descripción.
2. Reorganiza las categorías en orden lógico si hace falta (Entrantes → Principales → Postres → Bebidas).
3. Añade entre 1 y 3 entradas en "price_suggestions" señalando inconsistencias de precio o desequilibrios internos.

REGLAS ESTRICTAS:
- No modifiques "original_description" bajo ningún concepto.
- Pon "ai_improved": true en cada item cuya "description" hayas modificado.
- Devuelve ÚNICAMENTE el JSON completo con exactamente la misma estructura. Sin texto adicional.

Menú:
{menu_json}
"""


def renovate_menu(menu: Menu) -> Menu:
    client = anthropic.Anthropic()

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=8192,
        messages=[{
            "role": "user",
            "content": RENOVATION_PROMPT.format(menu_json=menu.model_dump_json(indent=2)),
        }],
    )

    data = json.loads(response.content[0].text)
    return Menu(**data)
