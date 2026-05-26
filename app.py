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
