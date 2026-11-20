# Herramientas de generación de entregables

Estos scripts solo generan documentos; **no son dependencias de la app Flutter**.

| Script | Genera | Dependencias de Python |
| --- | --- | --- |
| `generar_iconos.py` | Iconos web, favicon y `web/logo.png` desde `docs/logo.png` | `Pillow` |
| `generar_pdfs.py` | `docs/PRESENTACION.pdf` y `docs/FICHA_TECNICA.pdf` | `reportlab` |
| `generar_video.py` | `docs/VIDEO_CODI_UNCA.mp4` y `docs/GUION_VIDEO.md` | `edge-tts`, `imageio-ffmpeg`, `Pillow`, `numpy` |
| `contenido_diapositivas.py` | Contenido compartido | — |

## Uso

```bash
python docs/tools/generar_iconos.py
python docs/tools/generar_pdfs.py
python docs/tools/generar_video.py
```

El logo original está en `docs/logo.png` y también se incluye como `assets/logo.png` para la app Flutter.

El video dura aproximadamente 125 segundos, usa voz `es-MX-JorgeNeural` y respeta el límite de tres minutos de la presentación.

Si no hay acceso a internet para `edge-tts`, el guion queda disponible en `docs/GUION_VIDEO.md` para grabarlo manualmente.
