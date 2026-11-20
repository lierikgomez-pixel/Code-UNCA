# 02 · Modelos de IA

Paquete de entrenamiento, evaluación y arquitectura de los dos modelos integrados en CODI-UNCA.

| Modelo | Carpeta | Enfoque |
| --- | --- | --- |
| Visión por computadora | `01-modelo_vision/` | EfficientNet-B0 + transfer learning, exportado a ONNX. |
| Asistente conversacional | `02-llm/` | RAG local + prompt engineering con few-shot. |
| Arquitectura | `03-arquitectura/` | Flujo de datos, inferencia local y despliegue. |

## Estructura

```text
02-modelos_IA/
├── README.md                         Este índice
├── 01-modelo_vision/
│   ├── informacion_dataset.md        Fuente, clases y preprocesamiento
│   ├── entrenamiento/
│   │   ├── README.md                 Tarea, modelo, métricas y artefactos
│   │   ├── metricas.json             Métricas reales de prueba
│   │   ├── class_names.json          Orden de clases del ONNX
│   │   └── nvidia_t4.md              Entorno GPU, AMP FP16 y exportación
│   └── evaluacion/
│       ├── README.md                 Resumen de evaluación
│       ├── EVIDENCIAS_EVALUACION.md  Evidencia consolidada
│       ├── verificar_app.dart        12 casos ejecutables de la app
│       └── resultados_app.json       Resultado real 12/12
├── 02-llm/
│   ├── modelo_base.md                Comparación base vs adaptado
│   ├── dataset/
│   │   ├── README.md                 Política de privacidad y temas
│   │   └── knowledge_base.json      Las 12 FAQs
│   ├── entrenamiento/
│   │   ├── README.md                 Configuración del asistente
│   │   └── evaluar.dart             10 casos reservados y consistencia
│   └── ajuste/
│       ├── README.md                 RAG local + few-shot
│       └── resultados_evaluacion.json Resultado real 1/10 vs 10/10
└── 03-arquitectura/
    └── arquitectura.md               Diagrama y decisiones técnicas
```

## Nota de alcance

El asistente **no** se ajustó con LoRA/QLoRA. Se eligió RAG local + few-shot, una de las opciones permitidas por la presentación. La decisión es trazable y reproducible sin servicios externos. Los pesos del modelo de visión y el ONNX generados durante el evento están documentados en `01-modelo_vision/entrenamiento/nvidia_t4.md`; el artefacto desplegado está en `web/modelo_limon.onnx`.
