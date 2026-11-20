# Modelo de visión por computadora — CODI-UNCA

**Entregable:** paquete de entrenamiento del modelo de visión (diapositiva 10 de la presentación).

## 1. Tarea visual y modelo base

| Item | Definición |
| --- | --- |
| Tarea | Clasificación de una foto de limón en cuatro clases |
| Clases | `maduro`, `podrido`, `sin_limon`, `verde` |
| Modelo base | **EfficientNet-B0** de `torchvision`, con pesos ImageNet |
| Técnica | Transfer learning: reemplazo del clasificador final + ajuste fino |
| Entrada | Imagen RGB redimensionada a 224×224 |
| Salida | 4 logits → softmax → confianza por clase |

La clase `sin_limon` no significa «la foto salió mal»: significa que el modelo no detectó fruta. Por eso la app añade la regla de **Resultado dudoso** cuando la evidencia de fruta pesa más que la de ausencia.

## 2. Datos y etiquetas

- Dataset público **`ritikb2211/final-dataset`** (Kaggle, descarga sin token).
- **6032 imágenes válidas**.
- Clases desbalanceadas: `maduro` 2758, `podrido` 1498, `verde` 1462, `sin_limon` 313.
- División antes del entrenamiento:

| Subset | Imágenes |
| --- | ---: |
| Entrenamiento | 4523 |
| Validación | 904 |
| Prueba (nunca vista) | 604 |

Para acelerar la decodificación en CPU se generaron copias a 256 px en `data/processed/`, conservando la carpeta original como fuente.

## 3. Entrenamiento durante el evento

Ejecutado en el servidor NVIDIA asignado:

| Parámetro | Valor |
| --- | --- |
| GPU | NVIDIA Tesla T4 (15.65 GB VRAM) |
| PyTorch / Torchvision | 2.5.1+cu121 / 0.20.1+cu121 |
| Precisión | AMP FP16 |
| Optimizador | AdamW |
| Learning rate | 3e-4 |
| Weight decay | 1e-4 |
| Label smoothing | 0.08 |
| Dropout | 0.35 |
| Batch | 64 |
| Épocas | 12 programadas, early stopping con paciencia 5 |
| Workers | 0 (el servidor no tiene足够的 shm para 2 workers) |
| Augmentación | RandomResizedCrop 0.55–1.0, flips, rotación ±20°, ColorJitter, RandomGrayscale, RandomErasing |

Evolución observada en validación (primeras épocas):

| Época | Loss | Val accuracy | Val F1 |
| --- | ---: | ---: | ---: |
| 1 | 0.5428 | 0.9613 | 0.9690 |
| 2 | 0.3855 | 0.9889 | 0.9913 |
| 3 | 0.3624 | 0.9679 | 0.9741 |
| 4 | 0.3586 | 0.9867 | 0.9895 |
| 5 | 0.3451 | 0.9867 | 0.9896 |

## 4. Evaluación en prueba

Sobre las **604 imágenes nunca vistas durante el entrenamiento**:

| Métrica | Valor |
| --- | ---: |
| Accuracy | **0.9868** |
| F1 macro | **0.9897** |
| Recall `sin_limon` | **1.00** |
| Aciertos estimados | 596 / 604 |
| Errores estimados | 8 / 604 |

> Los aciertos y errores se derivan del accuracy reportado; el log completo quedó en el notebook de la GPU.

### Comparación pertinente

Se comparó contra el analizador clásico de color y forma que ya existía en la app:

| Modelo | Accuracy | F1 macro |
| --- | ---: | ---: |
| Baseline clásico (HSV + forma) | 0.9551 | 0.9566 |
| EfficientNet-B0 → ONNX | **0.9868** | **0.9897** |
| Ganancia | **+0.0317** | **+0.0331** |

La mejora más relevante para el negocio es el recall de `sin_limon`: evita decir «no hay fruta» cuando sí la hay.

## 5. Artefactos guardados

| Archivo | Descripción |
| --- | --- |
| `outputs/mejor_modelo.pt` | Pesos PyTorch del mejor checkpoint |
| `outputs/modelo_limon.onnx` | Modelo exportado para inferencia |
| `outputs/class_names.json` | Orden de clases |
| `outputs/features.csv` | Características del baseline clásico |

El ONNX tiene entrada **`images`** con forma `['batch', 3, 224, 224]` y salida **`logits`**. En la app se copió a `web/modelo_limon.onnx` y `build/web/modelo_limon.onnx`, con SHA-256 `E243791EFA3755440B6FAD171DEEA67AD85915E33C940B3E79B26EA2EA72F810`.

## 6. Integración en la app

1. `ort_helper.js` crea una sesión ONNX Runtime Web con WASM y un hilo.
2. `lib/services/modelo_web.dart` decodifica, redimensiona a 224×224 y normaliza con medias/desviaciones ImageNet en layout NCHW.
3. El modelo devuelve 4 logits; la app aplica softmax.
4. `ModelResult.esDudoso` convierte la baja confianza o el falso negativo de `sin_limon` en **Resultado dudoso**.
5. `lib/services/asesor.dart` convierte la clasificación en una recomendación comercial.

La inferencia es **local en el navegador**: no hay API remota ni servidor GPU en producción.
