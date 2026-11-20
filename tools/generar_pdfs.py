# -*- coding: utf-8 -*-
"""Genera la presentación PDF y la ficha técnica PDF de CODI-UNCA."""
from pathlib import Path

from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen import canvas

from contenido_diapositivas import COLORES, FICHA_PAGINAS, SLIDES

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "01-definicion_proyecto"
LOGO = ROOT / "logo.png"


def rgb(t):
    return tuple(v / 255.0 for v in t)


def hexc(name):
    return rgb(COLORES[name])


def draw_logo(c, right, bottom, alto):
    reader = ImageReader(str(LOGO))
    iw, ih = reader.getSize()
    ancho = alto * iw / ih
    c.drawImage(reader, right - ancho, bottom, width=ancho, height=alto, mask="auto")


def wrap(text, font, size, max_width):
    words = text.split()
    lines, current = [], ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if stringWidth(candidate, font, size) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def draw_footer(c, w, h, text, page, total):
    c.setFillColor(hexc("bosque"))
    c.rect(0, 0, w, 34, stroke=0, fill=1)
    c.setFillColor(hexc("blanco"))
    c.setFont("Helvetica", 8)
    c.drawString(28, 12, text)
    c.drawRightString(w - 28, 12, f"{page} / {total}")


def draw_slide(c, slide, page, total):
    w, h = landscape(A4)
    c.setFillColor(hexc("crema"))
    c.rect(0, 0, w, h, stroke=0, fill=1)

    c.setFillColor(hexc("bosque"))
    c.rect(0, h - 118, w, 118, stroke=0, fill=1)
    c.setFillColor(hexc("limon"))
    c.rect(0, h - 124, w, 6, stroke=0, fill=1)

    c.setFillColor(hexc("limon"))
    c.setFont("Helvetica-Bold", 10)
    c.drawString(34, h - 28, slide.get("kicker", "CODI-UNCA · Oaxaca").upper())

    c.setFillColor(hexc("blanco"))
    c.setFont("Helvetica-Bold", 26 if not slide.get("portada") else 40)
    c.drawString(34, h - 66, slide["titulo"])

    c.setFillColor(hexc("gris"))
    c.setFont("Helvetica", 13)
    c.drawString(34, h - 94, slide["subtitulo"])

    # Logo institucional.
    draw_logo(c, w - 34, h - 84, 62)

    y = h - 165
    for i, bullet in enumerate(slide["bullets"], 1):
        c.setFillColor(hexc("limon") if i % 2 else hexc("bosque_claro"))
        c.circle(44, y + 5, 8, stroke=0, fill=1)
        c.setFillColor(hexc("blanco") if i % 2 else hexc("crema"))
        c.setFont("Helvetica-Bold", 10)
        c.drawCentredString(44, y + 1, str(i) if not slide.get("portada") else "-")

        c.setFillColor(hexc("bosque"))
        c.setFont("Helvetica", 15)
        for line in wrap(bullet, "Helvetica", 15, w - 120):
            c.drawString(66, y, line)
            y -= 21
        y -= 12

    draw_footer(c, w, h, slide.get("nota", ""), page, total)
    c.showPage()


def draw_ficha_page(c, data, page, total):
    w, h = A4
    c.setFillColor(hexc("crema"))
    c.rect(0, 0, w, h, stroke=0, fill=1)

    c.setFillColor(hexc("bosque"))
    c.rect(0, h - 130, w, 130, stroke=0, fill=1)
    c.setFillColor(hexc("limon"))
    c.rect(0, h - 136, w, 6, stroke=0, fill=1)

    c.setFillColor(hexc("limon"))
    c.setFont("Helvetica-Bold", 10)
    c.drawString(40, h - 32, "HACKATHON OAXACA 2027 · TRL 5")

    c.setFillColor(hexc("blanco"))
    c.setFont("Helvetica-Bold", 20)
    c.drawString(40, h - 68, data["titulo"])

    c.setFillColor(hexc("gris"))
    c.setFont("Helvetica", 11)
    c.drawString(40, h - 96, data["subtitulo"])

    draw_logo(c, w - 40, h - 104, 70)

    y = h - 170
    for titulo, texto in data["bloques"]:
        c.setFillColor(hexc("bosque_claro"))
        c.rect(40, y - 4, 5, 24, stroke=0, fill=1)
        c.setFillColor(hexc("bosque"))
        c.setFont("Helvetica-Bold", 12)
        c.drawString(56, y + 4, titulo)

        y -= 24
        c.setFillColor(hexc("bosque"))
        c.setFont("Helvetica", 10.5)
        for line in wrap(texto, "Helvetica", 10.5, w - 100):
            c.drawString(56, y, line)
            y -= 16
        y -= 20

    draw_footer(c, w, h, data["pie"], page, total)
    c.showPage()


def main():
    OUT.mkdir(parents=True, exist_ok=True)

    pres = ROOT / "presentacion.pdf"
    c = canvas.Canvas(str(pres), pagesize=landscape(A4))
    c.setTitle("CODI-UNCA · Presentación")
    c.setAuthor("Equipo CODI-UNCA")
    for i, slide in enumerate(SLIDES, 1):
        draw_slide(c, slide, i, len(SLIDES))
    c.save()
    print(f"OK {pres}")

    ficha = OUT / "ficha_tecnica.pdf"
    c = canvas.Canvas(str(ficha), pagesize=A4)
    c.setTitle("CODI-UNCA · Ficha técnica")
    c.setAuthor("Equipo CODI-UNCA")
    for i, data in enumerate(FICHA_PAGINAS, 1):
        draw_ficha_page(c, data, i, len(FICHA_PAGINAS))
    c.save()
    print(f"OK {ficha}")


if __name__ == "__main__":
    main()
