# -*- coding: utf-8 -*-
"""Genera los PDFs de perfiles de usuario y propuesta de negocio.

Lee los Markdown de 03-interfaz y 04-propuesta_negocio y produce:
- 03-interfaz/perfiles-usuario.pdf
- 04-propuesta_negocio/propuesta.pdf
"""
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen import canvas

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "logo.png"
FUENTE = "Helvetica"
NEGRITA = "Helvetica-Bold"
VERDE = (8 / 255, 43 / 255, 36 / 255)
LIMON = (255 / 255, 214 / 255, 64 / 255)
GRIS = (0.35, 0.40, 0.38)

REPLAZOS = {
    "→": "->", "←": "<-", "≥": ">=", "≤": "<=", "×": "x",
    "•": "-", "–": "-", "—": "-", "“": '"', "”": '"',
    "‘": "'", "’": "'", "·": "-",
}


def limpio(texto):
    for a, b in REPLAZOS.items():
        texto = texto.replace(a, b)
    return texto


def wrap(texto, fuente, tamano, ancho):
    lineas, actual = [], ""
    for palabra in texto.split():
        candidata = f"{actual} {palabra}".strip()
        if stringWidth(candidata, fuente, tamano) <= ancho:
            actual = candidata
        else:
            if actual:
                lineas.append(actual)
            actual = palabra
    if actual:
        lineas.append(actual)
    return lineas


def generar(md, pdf, titulo):
    c = canvas.Canvas(str(pdf), pagesize=A4)
    c.setTitle(titulo)
    c.setAuthor("Equipo CODI-UNCA")
    w, h = A4
    margen = 52
    ancho = w - 2 * margen
    y = h - 60

    c.setFillColorRGB(*VERDE)
    c.rect(0, h - 18, w, 18, stroke=0, fill=1)
    c.setFillColorRGB(*LIMON)
    c.rect(0, h - 22, w, 4, stroke=0, fill=1)

    c.setFillColorRGB(*VERDE)
    c.setFont(NEGRITA, 20)
    c.drawString(margen, y, limpio(titulo))
    y -= 14
    c.setFillColorRGB(*GRIS)
    c.setFont(FUENTE, 10)
    c.drawString(margen, y, "CODI-UNCA · Oaxaca -Sierra de Flores Magón")

    lector = ImageReader(str(LOGO))
    iw, ih = lector.getSize()
    alto = 46
    ancho = alto * iw / ih
    c.drawImage(lector, w - margen - ancho, y - 14, width=ancho, height=alto, mask="auto")
    y -= 30

    for crudo in md.read_text(encoding="utf-8").splitlines():
        linea = limpio(crudo.strip())
        if not linea:
            y -= 8
            continue
        if linea.startswith("# "):
            continue
        if linea.startswith("## "):
            y -= 10
            c.setFillColorRGB(*VERDE)
            c.setFont(NEGRITA, 13)
            c.drawString(margen, y, linea[3:])
            y -= 18
            continue
        if linea.startswith("|"):
            partes = [p.strip() for p in linea.strip("|").split("|")]
            if all(set(p) <= set("-: ") for p in partes):
                continue
            texto = " · ".join(partes)
        elif linea.startswith("> "):
            texto = linea[2:]
        elif linea.startswith(("- ", "* ")):
            texto = "- " + linea[2:]
        else:
            texto = linea.replace("**", "").replace("`", "")

        c.setFillColorRGB(0.12, 0.15, 0.14)
        c.setFont(FUENTE, 10)
        for trozo in wrap(texto, FUENTE, 10, ancho):
            if y < 55:
                c.showPage()
                y = h - 55
            c.drawString(margen, y, trozo)
            y -= 14
        y -= 3

    c.setFont(FUENTE, 8)
    c.setFillColorRGB(*GRIS)
    c.drawString(margen, 28, "Hackathon Oaxaca 2027 · TRL 5 · Documento generado desde Markdown")
    c.save()
    print(f"OK {pdf.relative_to(ROOT)}")


def main():
    pares = [
        (ROOT / "03-interfaz/01-usuarios/perfiles_usuario.md",
         ROOT / "03-interfaz/perfiles-usuario.pdf",
         "Perfiles de usuario"),
        (ROOT / "04-propuesta_negocio/propuesta.md",
         ROOT / "04-propuesta_negocio/propuesta.pdf",
         "Propuesta de negocio"),
    ]
    for md, pdf, titulo in pares:
        generar(md, pdf, titulo)


if __name__ == "__main__":
    main()
