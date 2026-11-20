# Reporte detallado — CODI-UNCA

**Fecha:** 20 de noviembre de 2026
**Commit final:** `2b02e32` — *Mejorar modelo ONNX y opinión comercial del asistente*
**Producción:** https://code-unna.vercel.app/

---

## 1. Resumen ejecutivo

Se mejoró el modelo de control de calidad de limón de **CODI-UNCA** reentrenándolo en una GPU NVIDIA Tesla T4 y se conectó una **opinión comercial** al asistente y a la pantalla de calidad. El resultado quedó desplegado en Vercel y verificado de extremo a extremo en el navegador.

| Entregable | Resultado |
| --- | --- |
| Modelo reentrenado | EfficientNet-B0 + CUDA, 12 épocas programadas, early stopping |
| Accuracy en prueba | **0.9868** (604 imágenes) |
| F1 macro en prueba | **0.9897** |
| Recall `sin_limon` | **1.00** |
| Artefacto ONNX | 16 040 694 bytes (~15.3 MB) |
| Inferencia en producción | Verificada con `onnxruntime-web@1.23.2` (WASM) |
| Análisis estático | `flutter analyze`: sin problemas |
| Despliegue | `origin main` y `vercel main` actualizados |

---

## 2. Objetivo

El usuario solicitó, tras cargar la GPU:

> «ya cargue la gpu podrias mejorar el modelo para que reaccione mejor y tambien para que el asistente tenga opni del limon y ayuda a venderlo o opien si no cumple»

Se descompuso en dos objetivos:

1. **Reentrenar el clasificador** para mejorar su reacción ante fotos reales de limón, reduciendo falsos negativos (fotos con fruta clasificadas como `sin_limon`).
2. **Dar criterio comercial al asistente**: opinar si la pieza se vende, ayudar a venderla y decir claramente cuando no cumple.

Restricciones respetadas: respuesta y documentación en español; inferencia local en el navegador sin API GPU remota; cambios «fáciles y que no provoquen errores»; la CLABE completa nunca aparece en el chat.

---

## 3. Entorno de cómputo

Se validó el entorno CUDA antes de entrenar:

| Item | Valor |
| --- | --- |
| PyTorch | `2.5.1+cu121` |
| Torchvision | `0.20.1+cu121` |
| CUDA disponible | `True` |
| GPU | Tesla T4 |
| VRAM | 15.65 GB |
| CUDA runtime | 12.1 |
| cuDNN | 90100 |
| Driver | 545.23.08 |

El notebook activo quedó en `http://32.201.72.11/lab/lab/workspaces/auto-f/control_calidad_limon.ipynb`; la copia local de origen es `C:\Users\carre\control_calidad_limon\control_calidad_limon.ipynb`.

---

## 4. Dataset y preparación

- Fuente pública: **`ritikb2211/final-dataset`** (Kaggle, sin token), descargado con `kagglehub` (7.34 GB).
- Imágenes válidas: **6032**.

| Clase | Imágenes |
| --- | ---: |
| `maduro` | 2758 |
| `podrido` | 1498 |
| `verde` | 1462 |
| `sin_limon` | 313 |

- Se generaron características clásicas en `outputs/features.csv` (1513 filas) para el baseline interpretables.
- Se crearon copias reducidas a 256 px en `data/processed/` para acelerar la decodificación en CPU durante el entrenamiento:
  - train **4523**, validación **904**, prueba **604**.
  - Batch: **64**.
- Baseline clásico (color/forma): accuracy **0.9551**, F1 macro **0.9566**.

---

## 5. Cambios en el entrenamiento

Se conservó la arquitectura EfficientNet-B0 con pesos ImageNet y se ajustó la receta:

| Parámetro | Valor |
| --- | --- |
| Augmentación | `RandomResizedCrop(0.55–1.0)`, flip horizontal/vertical, rotación ±20°, `ColorJitter`, `RandomGrayscale`, `RandomErasing` |
| Dropout del clasificador | 0.35 |
| Épocas | 12 |
| Paciencia (early stopping) | 5 |
| Learning rate | 3e-4 |
| Weight decay | 1e-4 |
| Label smoothing | 0.08 |
| Precisión | AMP FP16 |
| Optimizador | AdamW |
| Workers de dataloader | 0 (ver incidencias) |

Evolución observada en las primeras épocas:

| Época | Loss | Val accuracy | Val F1 |
| --- | ---: | ---: | ---: |
| 1 | 0.5428 | 0.9613 | 0.9690 |
| 2 | 0.3855 | 0.9889 | 0.9913 |
| 3 | 0.3624 | 0.9679 | 0.9741 |
| 4 | 0.3586 | 0.9867 | 0.9895 |
| 5 | 0.3451 | 0.9867 | 0.9896 |

Resultado final en prueba: **accuracy 0.9868**, **F1 macro 0.9897**, recall `sin_limon` **1.00**.

Artefactos generados en `outputs/`:

| Archivo | Tamaño |
| --- | ---: |
| `mejor_modelo.pt` | 16 350 718 bytes |
| `modelo_limon.onnx` | 16 040 694 bytes |
| `class_names.json` | 53 bytes |
| `features.csv` | 368 065 bytes |

Contrato del ONNX verificado: entrada **`images`**, forma `['batch', 3, 224, 224]`, salida **`logits`**, clases `['maduro', 'podrido', 'sin_limon', 'verde']`.

---

## 6. Cambios en la aplicación

### 6.1 Modelo y reglas de duda

- `lib/services/modelo.dart`
  - `ModelResult.esDudoso`: dudoso si `confianza < 0.60` o si gana `sin_limon` pero la fruta suma más probabilidad.
  - Etiqueta dudosa: **«Resultado dudoso»**, con consejo de repetir la foto centrada y sobre fondo claro.
  - `clasesModelo` conserva el orden del ONNX.

### 6.2 Opinión comercial (nuevo)

- `lib/services/asesor.dart` (archivo nuevo):
  - `VeredictoVenta` con `titulo`, `opinion`, `ayuda`, `vendible`, `dudoso` y getter `paraChat`.
  - `evaluarVenta({clase, confianza, dudoso, color})` aplica reglas en orden:

    | Condición | Veredicto |
    | --- | --- |
    | Sin foto | «Aún no tengo una foto» |
    | Resultado dudoso | «No lo vendas aún» |
    | `podrido` | «No cumple para vender» |
    | `sin_limon` | «Sin limón detectado» |
    | `verde` + `amarillando` | «Casi maduro» |
    | `verde` | «Aún verde» |
    | `maduro` + `manchas` | «Revisa antes de vender» |
    | `maduro` con confianza < 0.75 | «Probablemente sí, pero revisa» |
    | Por defecto | «Sí, véndelo» |

  - `ayudaVender()` sugiere registrar el producto en Pedidos, generar el QR en Cobrar y destacar la fruta revisada; personaliza el mensaje para limón persa (jugoso, sin semilla) o mexicano (acidez de la Sierra).

### 6.3 Integración en UI y chat

- `lib/screens/calidad.dart`: guarda el color detectado en el estado y muestra el panel **«Mi opinión: …»** bajo el resultado, con el aviso «Es una segunda opinión. La decisión final es tuya.»
- `lib/store.dart`: nuevo campo `lastPhotoColor` y método `setLastPhoto(clase, confianza, dudoso, color)`.
- `lib/screens/asistente.dart`: detecta preguntas de venta («¿Vendo este limón?», «¿Cumple para vender?», «Ayúdame a venderlo», variantes sin tilde) y responde con `evaluarVenta(...).paraChat`; agregó esos tres chips al chat.
- El color clásico actúa como **segunda opinión**: `amarillando` matiza `verde`, `manchas` puede revertir `maduro`.
- El contexto del chat sigue exponiendo solo los **últimos 4 dígitos** de la CLABE.

### 6.4 Modelo servido

- Se copió el ONNX nuevo a `web/modelo_limon.onnx` y `build/web/modelo_limon.onnx`.
- Ambos archivos tienen el mismo SHA-256: `E243791EFA3755440B6FAD171DEEA67AD85915E33C940B3E79B26EA2EA72F810`.

---

## 7. Incidencias y soluciones

| Incidencia | Solución |
| --- | --- |
| Al parchear el notebook se borró la configuración del dataset (`IMG_SIZE` no definido) | Restaurar las celdas 15 y 17 desde el notebook original y conservar solo el entrenamiento mejorado |
| El primer entrenamiento tardaba ~13 min por época | Crear copias reducidas a 256 px en `data/processed/`; bajó a ~40 s por época |
| `NUM_WORKERS = 2` provocó `ERROR: Unexpected bus error ... insufficient shared memory (shm)` | Volver a `NUM_WORKERS = 0` |
| El puerto alterno 8899 de Jupyter no era alcanzable | Descartar ese canal |
| El navegador bloqueó `localhost` desde la IP pública y Jupyter bloqueó peticiones cross-origin | Descargar con el token de Jupyter directamente desde Windows (`/lab/files/outputs/...?token=...`) |
| `transfer.sh` agotó el tiempo de conexión | Descartar; usar el token de Jupyter |

---

## 8. Compilación, despliegue y verificación

```bash
flutter analyze          # No issues found!
flutter build web --release   # √ Built build\web
git add ... && git commit -m "Mejorar modelo ONNX y opinión comercial del asistente"
git push origin main
git push vercel main
```

- `vercel.json` sirve `build/web` sin compilar (`buildCommand` e `installCommand` vacíos, `framework: null`, rewrite a `index.html`).
- Tras el push se verificó en `https://code-unna.vercel.app/`:
  - Título: **CODI-UNCA · Comercio digital del limón**.
  - Descarga de `/modelo_limon.onnx`: 16 040 694 bytes, mismo hash local.
  - Sesión ORT creada en el navegador con `executionProviders: ['wasm']`, `numThreads: 1`.
  - Entrada `images`, salida `logits`, 4 logits devueltos correctamente.
  - Sin errores en consola.

---

## 9. Estado final

**Completado.** GPU, dataset, entrenamiento, exportación, integración de la opinión comercial, build, commit, push y verificación en producción.

**No bloqueante.** El notebook de la GPU quedó guardado con el entrenamiento completo y dos celdas auxiliares de transferencia; no afectan a la aplicación ni al despliegue.

### Recomendaciones de seguimiento

1. Actualizar `web/manifest.json`: hoy usa nombre corto `flutter_application_1`, descripción genérica y colores azules de Flutter; alinearlo con CODI-UNCA.
2. Renombrar el paquete técnico (`flutter_application_1`) y los bundle ids (`com.example.flutterApplication1`) cuando se publique en tiendas.
3. Sustituir `test/widget_test.dart` por pruebas reales: actualmente contiene una copia rezagada de funciones ya centralizadas.
4. Documentar la calibración `MM_POR_PIXEL` del análisis clásico con una regla física para estimar tamaño en milímetros.
5. Considerar cuantización del ONNX si se necesita reducir el tiempo de primera carga en móvil.

---

## 10. Trazabilidad

| Item | Valor |
| --- | --- |
| Repositorio de código | `github.com/lierikgomez-pixel/Code-UNCA` |
| Repositorio de despliegue | `github.com/or-117/code-unna` |
| Commit | `2b02e32` |
| Rama | `main` |
| URL pública | https://code-unna.vercel.app/ |
| Documentación relacionada | `docs/DOCUMENTACION_APP.md`, `README.md` |
