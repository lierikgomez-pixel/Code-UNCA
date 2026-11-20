# CODI-UNCA — Comercio digital del limón

Oaxaca -Sierra de Flores Magón.

App Flutter (cobro, pedidos, control de calidad, asistente y aprendizaje) para
productores de limón/lima (*Citrus aurantiifolia*).

## Estructura del repositorio

```text
README.md
presentacion.pdf
Video-de-demostracion.mp4
01-definicion_proyecto/   → alcance, guion, instrucciones, IA, ficha
02-modelos_IA/            → visión, asistente y arquitectura
03-interfaz/              → usuarios e interacción
04-propuesta_negocio/     → propuesta.md y propuesta.pdf
lib/ assets/ web/ build/  → aplicación Flutter y despliegue
tools/                    → scripts para regenerar entregables
```

## Modelo de control de calidad integrado

La sección **Calidad** clasifica cada foto en cuatro clases con un modelo
EfficientNet-B0 entrenado con PyTorch y exportado a ONNX:

| Clase | Significado |
| --- | --- |
| `verde` | Limón inmaduro |
| `maduro` | Punto óptimo de venta |
| `podrido` | Dañado / manchado |
| `sin_limon` | No se detectó fruta |

- Resultados del reentrenamiento (GPU NVIDIA, 20 nov 2026):
  **accuracy 0.9868**, **F1 macro 0.9897** sobre 604 imágenes de prueba, con
  **recall 1.00** en `sin_limon`.
- Dataset público: `ritikb2211/final-dataset` en Kaggle (descarga sin token).
- Entrenamiento: `control_calidad_limon/control_calidad_limon.ipynb`, con
  transfer learning, AMP FP16 y exportación ONNX.
- Artefacto: `web/modelo_limon.onnx` (16 040 694 bytes ≈ 15.3 MB), entrada
  `images` de forma `[1, 3, 224, 224]`, salida `logits`.
- Preprocesamiento: resize directo a 224×224, RGB, normalización ImageNet
  (`mean=[0.485, 0.456, 0.406]`, `std=[0.229, 0.224, 0.225]`) y layout NCHW.

### Inferencia

En **Flutter Web** el modelo corre dentro del navegador con
[ONNX Runtime Web](https://onnxruntime.ai/docs/tutorials/web/) (WASM, un hilo),
por lo que no se necesita un servidor GPU ni API remota. La primera carga
descarga el modelo; las siguientes suelen servirse desde la caché HTTP del
navegador. En móvil/escritorio se usa el analizador de color clásico como
respaldo.

Cuando la predicción no es concluyente (confianza menor al 60 %, o cuando gana
`sin_limon` pero las clases de fruta suman más probabilidad), la interfaz muestra
**Resultado dudoso** y pide una nueva foto en vez de afirmar que no hay fruta.
Así se evita el falso negativo en el que el modelo da, por ejemplo, 45 % a
`sin_limon` y 55 % repartido entre `maduro`, `podrido` y `verde`.

Archivos relacionados:

- `lib/services/modelo.dart` — API Dart y clases.
- `lib/services/modelo_web.dart` — preprocesamiento e interop con ORT Web.
- `lib/services/modelo_stub.dart` — respaldo no web.
- `web/ort_helper.js` — carga de la sesión ONNX.
- `web/index.html` — scripts de ORT desde CDN.

### Asistente y simulación bancaria

El asistente responde sobre tipos de limón (persa y mexicano), la ley de
comercio digital, CoDi, la Cuenta Nivel 2 Bis y el contexto de la última foto
analizada. Además emite una **opinión comercial**: dice si la pieza se vende,
ayuda a venderla y señala cuando no cumple (`lib/services/asesor.dart`). La
pantalla **Calidad** muestra el mismo criterio en el panel **Mi opinión**. El
color detectado actúa como segunda opinión (`amarillando` matiza `verde`;
`manchas` puede revertir `maduro`).

Desde **Cobrar → Datos del negocio** el vendedor puede capturar banco, CLABE y titular
**solo como simulación local**; el asistente menciona el estado de esos datos sin
mostrar la CLABE completa (solo los últimos 4 dígitos).

## Documentación y entregables del hackathon

- `01-definicion_proyecto/indice_entregables.md` — mapa de requerimientos ↔ archivos.
- `03-interfaz/02-interaccion/documentacion_app.md` — guía funcional y técnica de la aplicación.
- `01-definicion_proyecto/reporte_detallado.md` — entrenamiento en GPU, métricas, cambios,
  incidencias y verificación del despliegue.
- `01-definicion_proyecto/guion_defensa.md` — guion de 15 minutos para sustentar ante el jurado.
- `01-definicion_proyecto/instrucciones.md` — uso e instalación de la app.
- `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md` — resultados ejecutables de app, visión y asistente.
- `03-interfaz/01-usuarios/hci_prueba_usuarios.md` — usuario, flujo, decisiones y protocolo con usuarios.
- `01-definicion_proyecto/declaracion_ia.md` — transparencia sobre el uso de IA.
- `01-definicion_proyecto/ficha_tecnica.pdf` — ficha de 3 páginas.
- `presentacion.pdf` — presentación de 10 diapositivas.
- `Video-de-demostracion.mp4` — video de sustentación de 125 segundos.
- `02-modelos_IA/` — paquete de entrenamiento de visión, asistente y NVIDIA.
- `02-modelos_IA/01-modelo_vision/evaluacion/` — script y resultados de 12 casos de la aplicación.

## Despliegue en Vercel

`build/web` está incluido en el repositorio y `vercel.json` indica:

- `outputDirectory: build/web`
- `buildCommand` e `installCommand` vacíos (Vercel no compila Flutter).

Para actualizar el despliegue tras cambiar código Dart:

```bash
flutter pub get
flutter analyze
flutter build web --release
git add . && git commit -m "Actualizar app y modelo"
git push origin main
git push vercel main
```

Luego Vercel vuelve a desplegar automáticamente desde `build/web`. La versión
publicada está en https://code-unna.vercel.app/.
