# Contribución técnica NVIDIA — CODI-UNCA

**Entregable:** entrenamiento y ajuste en servidor asignado, pesos y registros guardados, uso de herramienta NVIDIA y documentación técnica (diapositiva 12).

## 1. Entorno verificado

| Item | Valor |
| --- | --- |
| GPU | **NVIDIA Tesla T4** |
| VRAM | 15.65 GB |
| Driver | 545.23.08 |
| CUDA runtime | 12.1 |
| cuDNN | 90100 |
| PyTorch | `2.5.1+cu121` |
| Torchvision | `0.20.1+cu121` |
| `torch.cuda.is_available()` | `True` |

La verificación se ejecutó en el notebook antes de entrenar:

```python
import torch, torchvision
print(torch.__version__, torchvision.__version__)
print('CUDA disponible:', torch.cuda.is_available())
print(torch.cuda.get_device_name(0))
```

## 2. Herramienta NVIDIA utilizada

Se usó **CUDA/cuDNN a través de PyTorch** para el entrenamiento y la exportación. La contribución concreta no fue solo «tener una GPU»:

- **AMP FP16** (`torch.cuda.amp`) para reducir memoria y acelerar el ajuste fino.
- Habitualmente se usa **TensorCore** de la T4 al entrenar EfficientNet-B0 en FP16.
- Guardado de checkpoints en GPU y posterior exportación a ONNX.
- El dataset se mantuvo en TurboMPS del servidor; las copias reducidas a 256 px se crearon para evitar cuellos de botella de decodificación en CPU.

## 3. Qué se ejecutó en el servidor

1. Descarga del dataset público desde Kaggle (sin token).
2. Preparación de `data/processed/` a 256 px.
3. Entrenamiento/ajuste fino de EfficientNet-B0 con pesos ImageNet.
4. Early stopping con paciencia 5.
5. Evaluación en 604 imágenes de prueba.
6. Exportación del ONNX con entrada `images` y salida `logits`.
7. Guardado de artefactos en `outputs/`.

## 4. Comandos y fragmentos relevantes

```python
EPOCHS = 12
PATIENCE = 5
LR = 3e-4
WEIGHT_DECAY = 1e-4
LABEL_SMOOTHING = 0.08
NUM_WORKERS = 0   # el servidor no tiene shm suficiente para 2 workers

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
scaler = torch.cuda.amp.GradScaler()

with torch.autocast(device_type='cuda', dtype=torch.float16):
    salida = modelo(images)
    loss = criterio(salida, etiquetas)

scaler.scale(loss).backward()
scaler.step(optimizer)
scaler.update()

torch.onnx.export(
    modelo,
    dummy,
    'outputs/modelo_limon.onnx',
    input_names=['images'],
    output_names=['logits'],
    dynamic_axes={'images': {0: 'batch'}},
)
```

## 5. Artefactos guardados

| Archivo | Tamaño | Uso |
| --- | ---: | --- |
| `outputs/mejor_modelo.pt` | 16 350 718 bytes | Checkpoint PyTorch del mejor modelo |
| `outputs/modelo_limon.onnx` | 16 040 694 bytes | Inferencia en navegador |
| `outputs/class_names.json` | 53 bytes | Orden de clases |
| `outputs/features.csv` | 368 065 bytes | Baseline clásico y análisis |

SHA-256 del ONNX: `E243791EFA3755440B6FAD171DEEA67AD85915E33C940B3E79B26EA2EA72F810`.

## 6. Importante para la defensa

- El entrenamiento se hizo **durante el evento** en el servidor asignado.
- La app en producción **no depende** de Jupyter ni de la GPU: solo sirve el ONNX exportado.
- El modelo es verificable: pesos, métricas, clases y hash están documentados.
- Las incidencias resueltas (shm, celdas restauradas, transferencia del ONNX) están en `01-definicion_proyecto/reporte_detallado.md`.
