# Información del dataset — modelo de visión

## Fuente

- Dataset público: **`ritikb2211/final-dataset`** (Kaggle).
- Descarga sin token; se respetó la licencia y el uso público declarado por la fuente.
- No se usaron fotografías personales ni datos sensibles de productores.

## Clases

| Clase | Significado |
| --- | --- |
| `verde` | Limón inmaduro. |
| `maduro` | Punto óptimo de venta. |
| `podrido` | Dañado o con manchas. |
| `sin_limon` | No se detectó fruta. |

## Partición y preprocesamiento

- División reproducible: entrenamiento / validación / prueba con semilla fija.
- Prueba: **604 imágenes**.
- Redimensionado directo a **224 × 224**, RGB, normalización ImageNet
  (`mean=[0.485, 0.456, 0.406]`, `std=[0.229, 0.224, 0.225]`) y layout NCHW.
- Entrada del modelo ONNX: `images` con forma `[1, 3, 224, 224]`.
- Salida: `logits` con 4 clases.

## Consideraciones

El conjunto original puede contener ejemplos ambiguos de fruta parcialmente visible. Para evitar un falso negativo costoso, la app no afirma «Sin limón» cuando gana `sin_limon` pero las clases de fruta suman más probabilidad: muestra **Resultado dudoso** y pide otra foto.

Detalles del entrenamiento y métricas:

- `entrenamiento/README.md`
- `entrenamiento/metricas.json`
- `entrenamiento/nvidia_t4.md`
- `evaluacion/EVIDENCIAS_EVALUACION.md`
