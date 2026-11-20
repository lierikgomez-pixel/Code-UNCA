# Herramientas de generación de entregables

Estos scripts solo generan documentos; **no son dependencias de la app Flutter**.

| Script | Genera | Dependencias de Python |
| --- | --- | --- |
| `generar_pdfs.py` | `docs/PRESENTACION.pdf` y `docs/FICHA_TECNICA.pdf` | `reportlab` |
| `generar_video.py` | `docs/VIDEO_CODE_UNCA.mp4` y `docs/GUION_VIDEO.md` | `edge-tts`, `imageio-ffmpeg`, `Pillow`, `numpy` |
| `contenido_diapositivas.py` | Contenido compartido | — |

## Uso

```bash
python docs/tools/generar_pdfs.py
python docs/tools/generar_video.py
```

El video dura aproximadamente 125 segundos, usa voz `es-MX-JorgeNeural` y respeta el límite de tres minutos de la presentación.

Si no hay acceso a internet para `edge-tts`, el guion queda disponible en `docs/GUION_VIDEO.md` para grabarlo manualmente.
