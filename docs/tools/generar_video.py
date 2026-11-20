# -*- coding: utf-8 -*-
"""Genera el video de sustentación de CODE UNCA (máximo 3 minutos).

- Narra cada diapositiva con edge-tts (es-MX-JorgeNeural).
- Dibuja las diapositivas con Pillow.
- Muxea video y audio con ffmpeg.
"""
import asyncio
import re
import subprocess
import tempfile
from pathlib import Path

import imageio_ffmpeg
import numpy as np
from PIL import Image, ImageDraw, ImageFont

from contenido_diapositivas import COLORES, SLIDES

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
OUT_VIDEO = DOCS / "VIDEO_CODE_UNCA.mp4"
OUT_GUION = DOCS / "GUION_VIDEO.md"

W, H = 1280, 720
FPS = 10
VOZ = "es-MX-JorgeNeural"
RATE = "+5%"

NARRACION = [
    "CODE UNCA es comercio digital del limón para Oaxaca y la Sierra de Flores Magón. Clasificamos la fruta con inteligencia artificial local y cobramos con historial.",
    "El productor decide cuándo vender mirando el limón y cobra sin dejar un historial útil. Nuestra tarea es ayudarlo a clasificar y cobrar en el mismo momento.",
    "La aplicación tiene cinco pantallas: Cobrar, Pedidos, Calidad, Asistente y Aprender. La foto se analiza, el asistente opina y cada venta suma al historial digital.",
    "El recorrido es sencillo: cobrar ciento ochenta pesos con código QR, crear un pedido de doce kilos y medio, tomar una foto nueva y preguntar si se vende.",
    "Entrenamos EfficientNet B0 con seis mil treinta y dos imágenes públicas, en una Tesla T4 con CUDA y precisión mixta. El modelo se exportó a ONNX y corre en el navegador.",
    "En prueba, el modelo acierta noventa y ocho punto seis ocho por ciento, con F1 macro de cero punto noventa y ocho. La clase sin limón tuvo recall uno.",
    "El asistente usa una base local de doce respuestas verificadas y el contexto de la última foto. En diez casos reservados pasa de uno a diez aciertos frente a la base.",
    "La contribución NVIDIA fue entrenar, guardar pesos y exportar el modelo en el servidor asignado. En diseño elegimos duda explícita, corrección humana y una pantalla por decisión.",
    "Las evidencias son ejecutables: doce casos de aplicación, diez del asistente, métricas de visión y verificación del modelo en producción. Sin errores de consola.",
    "Entregamos la aplicación, instrucciones, entrenamiento, evidencias, ficha, presentación y este video. Lo simulado está declarado. Nivel de madurez tecnológica cinco. La inteligencia artificial orienta; el productor decide. Gracias.",
]


def color(name):
    return COLORES[name]


def font(bold=False, size=18):
    base = Path(r"C:\Windows\Fonts")
    name = "arialbd.ttf" if bold else "arial.ttf"
    path = base / name
    if not path.exists():
        path = base / "segoeui.ttf"
    return ImageFont.truetype(str(path), size)


def wrap_text(draw, text, fnt, max_width):
    words = text.split()
    lines, current = [], ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if draw.textbbox((0, 0), candidate, font=fnt)[2] <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def render_slide(slide, index, progress):
    img = Image.new("RGB", (W, H), color("crema"))
    d = ImageDraw.Draw(img)

    d.rectangle((0, 0, W, 128), fill=color("bosque"))
    d.rectangle((0, 128, W, 136), fill=color("limon"))

    d.text((40, 24), slide.get("kicker", "CODE UNCA · Oaxaca").upper(), font=font(True, 16), fill=color("limon"))
    d.text((40, 55), slide["titulo"], font=font(True, 44 if slide.get("portada") else 38), fill=color("blanco"))
    d.text((42, 106), slide["subtitulo"], font=font(False, 18), fill=color("gris"))

    d.ellipse((W - 112, 30, W - 48, 94), fill=color("limon"))
    d.text((W - 94, 45), "CU", font=font(True, 24), fill=color("bosque"))

    y = 175
    for i, bullet in enumerate(slide["bullets"], 1):
        badge = color("limon") if i % 2 else color("bosque_claro")
        d.ellipse((42, y, 66, y + 24), fill=badge)
        txt_color = color("blanco") if i % 2 else color("crema")
        d.text((49, y + 4), str(i), font=font(True, 13), fill=txt_color)

        f = font(False, 22)
        for line in wrap_text(d, bullet, f, W - 130):
            d.text((82, y), line, font=f, fill=color("bosque"))
            y += 29
        y += 16

    d.rectangle((0, H - 58, W, H), fill=color("bosque"))
    d.text((32, H - 40), slide.get("nota", ""), font=font(False, 14), fill=color("blanco"))
    d.text((W - 90, H - 40), f"{index + 1}/{len(SLIDES)}", font=font(True, 14), fill=color("limon"))

    bar_w = int(W * progress)
    d.rectangle((0, H - 8, W, H), fill=color("bosque_claro"))
    d.rectangle((0, H - 8, bar_w, H), fill=color("limon"))
    return np.asarray(img)


def duration_of(path, ffmpeg):
    result = subprocess.run([ffmpeg, "-i", str(path)], capture_output=True, text=True)
    match = re.search(r"Duration: (\d+):(\d+):(\d+\.\d+)", result.stderr)
    if not match:
        raise RuntimeError(f"No se pudo leer duración de {path}")
    h, m, s = match.groups()
    return int(h) * 3600 + int(m) * 60 + float(s)


async def synthesize(text, path):
    import edge_tts

    communicate = edge_tts.Communicate(text, VOZ, rate=RATE)
    await communicate.save(str(path))


def main():
    DOCS.mkdir(parents=True, exist_ok=True)
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()

    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        audio_files = []

        print("Generando narración...")
        for i, texto in enumerate(NARRACION):
            audio = tmp / f"audio_{i:02d}.mp3"
            asyncio.run(synthesize(texto, audio))
            audio_files.append(audio)

        durations = [duration_of(a, ffmpeg) for a in audio_files]
        gaps = 1.0
        total_audio = sum(durations) + gaps * len(durations)
        print(f"Duración estimada: {total_audio:.1f}s")
        if total_audio > 178:
            raise SystemExit("La narración supera el límite de 3 minutos; acortar el guion.")

        # Concatenar audio con una pausa de 1s después de cada diapositiva.
        inputs = []
        for a in audio_files:
            inputs += ["-i", str(a)]
        filter_parts = [f"[{i}:a]apad=pad_dur={gaps}[a{i}]" for i in range(len(audio_files))]
        filter_parts.append("".join(f"[a{i}]" for i in range(len(audio_files))) + f"concat=n={len(audio_files)}:v=0:a=1[out]")
        full_audio = tmp / "narracion.mp3"
        subprocess.run(
            [ffmpeg, "-y"] + inputs + ["-filter_complex", ";".join(filter_parts), "-map", "[out]", str(full_audio)],
            check=True,
            capture_output=True,
        )

        # Generar video silencioso sincronizado con cada narración.
        silent = tmp / "silencioso.mp4"
        writer = imageio_ffmpeg.write_frames(
            str(silent),
            size=(W, H),
            fps=FPS,
            codec="libx264",
            output_params=["-pix_fmt", "yuv420p", "-crf", "23", "-preset", "veryfast"],
        )
        writer.send(None)
        for i, (slide, dur) in enumerate(zip(SLIDES, durations)):
            frames = max(1, int(round((dur + gaps) * FPS)))
            for f in range(frames):
                writer.send(render_slide(slide, i, (f + 1) / frames).tobytes())
            print(f"Diapositiva {i + 1}/{len(SLIDES)}: {dur:.1f}s")
        writer.close()

        subprocess.run(
            [ffmpeg, "-y", "-i", str(silent), "-i", str(full_audio), "-c:v", "copy", "-c:a", "aac", "-shortest", str(OUT_VIDEO)],
            check=True,
            capture_output=True,
        )

    final_duration = duration_of(OUT_VIDEO, ffmpeg)
    print(f"OK {OUT_VIDEO} ({final_duration:.1f}s)")

    guion = ["# Guion del video — CODE UNCA", "", f"**Duración:** {final_duration:.0f} segundos · **Voz:** {VOZ}", "", "| # | Diapositiva | Narración |", "| --- | --- | --- |"]
    for i, (slide, texto) in enumerate(zip(SLIDES, NARRACION), 1):
        guion.append(f"| {i} | {slide['titulo']} | {texto} |")
    guion += ["", "El video se genera con `python docs/tools/generar_video.py`.", ""]
    OUT_GUION.write_text("\n".join(guion), encoding="utf-8")
    print(f"OK {OUT_GUION}")


if __name__ == "__main__":
    main()
