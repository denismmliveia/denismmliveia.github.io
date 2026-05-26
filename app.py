from __future__ import annotations
import os
import io
import zipfile
import tempfile

import streamlit as st
from dotenv import load_dotenv

from models import Menu
from extractor import extract_menu_from_image
from renovator import renovate_menu
from pdf_generator import generate_pdf
from web_generator import generate_web

load_dotenv()

st.set_page_config(page_title="Renovador de Cartas", page_icon="🍽️", layout="wide")
st.title("🍽️ Renovador de Cartas de Restaurante")

# --- Estado de sesión ---
for key in ("menu_crudo", "menu_renovado", "step"):
    if key not in st.session_state:
        st.session_state[key] = None
if st.session_state["step"] is None:
    st.session_state["step"] = 1

# --- Barra lateral de progreso ---
with st.sidebar:
    st.header("Progreso")
    steps = ["1 · Subir foto", "2 · Revisar", "3 · Mejorar", "4 · Generar"]
    for i, label in enumerate(steps, start=1):
        if i < st.session_state["step"]:
            st.success(label)
        elif i == st.session_state["step"]:
            st.info(f"**{label}**")
        else:
            st.caption(label)

# ============================================================
# PASO 1 — Subir foto
# ============================================================
if st.session_state["step"] == 1:
    st.header("Paso 1 — Datos del restaurante y foto de la carta")

    col1, col2 = st.columns(2)
    with col1:
        nombre = st.text_input("Nombre del restaurante", placeholder="Ej: La Piazza")
    with col2:
        tipo = st.selectbox(
            "Tipo de cocina",
            ["mediterráneo", "italiano", "español", "fusión", "asiático", "otro"],
        )

    foto = st.file_uploader(
        "Sube la foto de la carta actual",
        type=["jpg", "jpeg", "png"],
        help="Foto clara y bien iluminada — mejor resultado con la carta extendida",
    )

    if foto:
        st.image(foto, caption="Foto subida", use_column_width=True)

    if st.button("Extraer carta con IA →", disabled=not foto, type="primary"):
        with tempfile.NamedTemporaryFile(
            suffix=foto.name[foto.name.rfind("."):], delete=False
        ) as tmp:
            tmp.write(foto.read())
            tmp_path = tmp.name

        with st.spinner("Claude está analizando la foto…"):
            menu = extract_menu_from_image(tmp_path)
        os.unlink(tmp_path)

        menu.restaurant_name = nombre
        menu.restaurant_type = tipo
        st.session_state["menu_crudo"] = menu
        st.session_state["step"] = 2
        st.rerun()

# ============================================================
# PASO 2 — Revisar extracción
# ============================================================
if st.session_state["step"] == 2:
    menu: Menu = st.session_state["menu_crudo"]
    st.header("Paso 2 — Revisa los platos detectados")
    st.caption(
        "🟢 Verde = extraído correctamente · 🟠 Naranja = precio 0 o descripción vacía"
    )

    for cat_idx, category in enumerate(menu.categories):
        st.subheader(category.name)
        for item_idx, item in enumerate(category.items):
            is_suspicious = item.price == 0.0 or item.description == ""
            color = "🟠" if is_suspicious else "🟢"

            with st.expander(f"{color} {item.name} — {item.price:.2f} €"):
                new_name = st.text_input(
                    "Nombre", value=item.name,
                    key=f"name_{cat_idx}_{item_idx}"
                )
                new_desc = st.text_input(
                    "Descripción", value=item.description,
                    key=f"desc_{cat_idx}_{item_idx}"
                )
                new_price = st.number_input(
                    "Precio (€)", value=float(item.price), min_value=0.0, step=0.5,
                    key=f"price_{cat_idx}_{item_idx}"
                )
                menu.categories[cat_idx].items[item_idx].name = new_name
                menu.categories[cat_idx].items[item_idx].description = new_desc
                menu.categories[cat_idx].items[item_idx].original_description = new_desc
                menu.categories[cat_idx].items[item_idx].price = new_price

    if st.button("Continuar — mejorar con IA →", type="primary"):
        st.session_state["menu_crudo"] = menu
        st.session_state["step"] = 3
        st.rerun()

# ============================================================
# PASO 3 — Mejoras IA + estilo visual
# ============================================================
if st.session_state["step"] == 3:
    menu: Menu = st.session_state["menu_crudo"]
    st.header("Paso 3 — Mejoras de IA y estilo visual")

    if st.session_state["menu_renovado"] is None:
        with st.spinner("Claude está mejorando la carta…"):
            st.session_state["menu_renovado"] = renovate_menu(menu)
        st.rerun()

    menu_renovado: Menu = st.session_state["menu_renovado"]

    # Sugerencias de precios
    if menu_renovado.price_suggestions:
        with st.expander("💡 Sugerencias de precios"):
            for sug in menu_renovado.price_suggestions:
                st.info(sug)

    # Aceptar / rechazar por ítem
    st.subheader("Mejoras de descripciones")
    for cat_idx, category in enumerate(menu_renovado.categories):
        st.markdown(f"**{category.name}**")
        for item_idx, item in enumerate(category.items):
            if item.ai_improved:
                col1, col2, col3 = st.columns([3, 1, 1])
                with col1:
                    st.markdown(
                        f"**{item.name}**  \n"
                        f"~~{item.original_description}~~  \n"
                        f"✨ {item.description}"
                    )
                with col2:
                    if st.button("✓ Aceptar", key=f"ok_{cat_idx}_{item_idx}"):
                        pass  # descripción ya está actualizada
                with col3:
                    if st.button("✗ Rechazar", key=f"ko_{cat_idx}_{item_idx}"):
                        menu_renovado.categories[cat_idx].items[item_idx].description = item.original_description
                        menu_renovado.categories[cat_idx].items[item_idx].ai_improved = False
                        st.session_state["menu_renovado"] = menu_renovado
                        st.rerun()

    # Selector de estilo
    st.subheader("Estilo visual")
    style_labels = {"rustico": "🪵 Rústico", "elegante": "✨ Elegante", "fresco": "🌿 Fresco"}
    selected_style = st.radio(
        "Elige el estilo de la carta",
        options=list(style_labels.keys()),
        format_func=lambda x: style_labels[x],
        horizontal=True,
    )
    menu_renovado.style = selected_style
    st.session_state["menu_renovado"] = menu_renovado

    if st.button("Generar carta →", type="primary"):
        st.session_state["step"] = 4
        st.rerun()
