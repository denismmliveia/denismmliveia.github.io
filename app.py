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

if not os.getenv("ANTHROPIC_API_KEY"):
    st.error("Falta ANTHROPIC_API_KEY en el archivo .env")
    st.stop()


def build_zip(menu: Menu, qr_url: str = "") -> bytes:
    with tempfile.TemporaryDirectory() as tmp_dir:
        pdf_path = os.path.join(tmp_dir, "carta.pdf")
        web_dir = os.path.join(tmp_dir, "carta_web")
        qr_path = os.path.join(tmp_dir, "qr.png")

        generate_pdf(menu, pdf_path)
        generate_web(menu, web_dir, qr_path, url=qr_url)

        buffer = io.BytesIO()
        with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.write(pdf_path, "carta.pdf")
            zf.write(qr_path, "qr.png")
            for root, _, files in os.walk(web_dir):
                for fname in files:
                    full = os.path.join(root, fname)
                    arcname = os.path.relpath(full, tmp_dir)
                    zf.write(full, arcname)

        buffer.seek(0)
        return buffer.getvalue()


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
        st.image(foto, caption="Foto subida", use_container_width=True)

    if st.button("Extraer carta con IA →", disabled=not foto, type="primary"):
        with tempfile.NamedTemporaryFile(
            suffix=foto.name[foto.name.rfind("."):], delete=False
        ) as tmp:
            tmp.write(foto.read())
            tmp_path = tmp.name

        try:
            with st.spinner("Claude está analizando la foto…"):
                menu = extract_menu_from_image(tmp_path)
        except Exception as e:
            st.error(f"Error al analizar la foto: {e}")
            os.unlink(tmp_path)
            st.stop()
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
        try:
            with st.spinner("Claude está mejorando la carta…"):
                st.session_state["menu_renovado"] = renovate_menu(menu)
        except Exception as e:
            st.error(f"Error al mejorar la carta: {e}")
            st.stop()
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

# ============================================================
# PASO 4 — Generar y descargar
# ============================================================
if st.session_state["step"] == 4:
    menu: Menu = st.session_state["menu_renovado"]
    st.header("Paso 4 — Generar y descargar")

    qr_url = st.text_input(
        "URL pública para el QR (opcional)",
        placeholder="https://mirestaurante.com/carta",
        help="Si lo dejas vacío, el QR apuntará a carta_web/index.html (uso local)",
    )

    cached_url = st.session_state.get("zip_url")
    if "zip_bytes" not in st.session_state or cached_url != qr_url:
        with st.spinner("Generando PDF y web…"):
            st.session_state["zip_bytes"] = build_zip(menu, qr_url)
            st.session_state["zip_url"] = qr_url
    zip_bytes = st.session_state["zip_bytes"]

    st.success("✅ Carta generada correctamente")
    st.download_button(
        label="⬇️ Descargar todo (.zip)",
        data=zip_bytes,
        file_name=f"carta_{menu.restaurant_name.replace(' ', '_') or 'restaurante'}.zip",
        mime="application/zip",
        type="primary",
    )

    st.caption("El ZIP incluye: `carta.pdf`, `carta_web/index.html` y `qr.png`")

    if st.button("🔄 Nueva carta"):
        for key in ("menu_crudo", "menu_renovado", "step", "zip_bytes", "zip_url"):
            st.session_state[key] = None
        st.rerun()
