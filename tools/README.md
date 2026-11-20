# Herramientas de generación de entregables

Estos scripts solo generan documentos; **no son dependencias de la app Flutter**.

| Script | Genera | Dependencias de Python |
| --- | --- | --- |
| `generar_iconos.py` | Iconos web, favicon y `web/logo.png` desde `logo.png` | `Pillow` |
| `generar_pdfs.py` | `presentacion.pdf` y `01-definicion_proyecto/ficha_tecnica.pdf` | `reportlab` |
| `generar_video.py` | `Video-de-demostracion.mp4` y `01-definicion_proyecto/guion_video.md` | `edge-tts`, `imageio-ffmpeg`, `Pillow`, `numpy` |
| `generar_documentos.py` | `03-interfaz/perfiles-usuario.pdf` y `04-propuesta_negocio/propuesta.pdf` | `reportlab` |
| `contenido_diapositivas.py` | Contenido compartido | — |

## Uso

```bash
python tools/generar_iconos.py
python tools/generar_pdfs.py
python tools/generar_video.py
python tools/generar_documentos.py
```

El logo original está en `logo.png` y también se incluye como `assets/logo.png` para la app Flutter.

El video dura aproximadamente 125 segundos, usa voz `es-MX-JorgeNeural` y respeta el límite de tres minutos de la presentación.

Si no hay acceso a internet para `edge-tts`, el guion queda disponible en `01-definicion_proyecto/guion_video.md` para grabarlo manualmente.
