# Paquete de entrenamiento — CODE UNCA

**Entregable:** paquete de entrenamiento de ambos modelos (diapositivas 10, 11, 12 y 15 de la presentación del hackathon).

Este directorio contiene todo lo necesario para auditar, reproducir y entender los dos modelos integrados en la aplicación:

| Modelo | Carpeta | Enfoque |
| --- | --- | --- |
| Visión por computadora | `vision/` | EfficientNet-B0 + transfer learning, exportado a ONNX |
| Asistente conversacional | `asistente/` | RAG local + prompt engineering con few-shot |
| Infraestructura NVIDIA | `nvidia/` | Entrenamiento y exportación en GPU Tesla T4 |

## Estructura

```
docs/training/
├── README.md                          Este índice
├── vision/
│   ├── README.md                      Tarea, datos, modelo, métricas y artefactos
│   ├── class_names.json               Orden de clases del ONNX
│   └── metricas.json                  Métricas de prueba y comparación
├── asistente/
│   ├── README.md                      Modelo base, objetivos, fuentes y configuración
│   ├── knowledge_base.json            Las 12 FAQs y la regla de contexto
│   ├── evaluar.dart                   Script reproducible de evaluación
│   └── resultados_evaluacion.json     Resultados reales base vs adaptado
└── nvidia/
    └── README.md                      Contribución técnica y comandos
```

## Nota de alcance

El asistente **no** se ajustó con LoRA/QLoRA. Se eligió RAG local + few-shot, una de las opciones permitidas por la presentación. La decisión está documentada y es reproducible sin servicios externos. Los pesos del modelo de visión y el ONNX generados durante el evento están en `outputs/` del notebook en el servidor NVIDIA; aquí se documentan sus métricas y artefactos.
