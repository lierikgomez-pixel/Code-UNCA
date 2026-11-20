# -*- coding: utf-8 -*-
"""Genera los iconos web de CODI-UNCA a partir de logo.png."""
from pathlib import Path
import shutil

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "logo.png"
WEB = ROOT / "web"
ICONOS = WEB / "icons"
FONDO = (8, 43, 36, 255)  # AppColors.bosqueProfundo


def crear_icono(size, padding, destino):
    logo = Image.open(SRC).convert("RGBA")
    max_size = int(size * (1 - 2 * padding))
    logo.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
    lieno = Image.new("RGBA", (size, size), FONDO)
    x = (size - logo.width) // 2
    y = (size - logo.height) // 2
    lieno.alpha_composite(logo, (x, y))
    lieno.convert("RGB").save(destino, optimize=True)
    print(f"OK {destino.relative_to(ROOT)}")


def main():
    ICONOS.mkdir(parents=True, exist_ok=True)
    crear_icono(192, 0.12, ICONOS / "Icon-192.png")
    crear_icono(512, 0.12, ICONOS / "Icon-512.png")
    crear_icono(192, 0.22, ICONOS / "Icon-maskable-192.png")
    crear_icono(512, 0.22, ICONOS / "Icon-maskable-512.png")
    crear_icono(64, 0.10, WEB / "favicon.png")
    shutil.copy2(SRC, WEB / "logo.png")
    print("OK web/logo.png")


if __name__ == "__main__":
    main()
