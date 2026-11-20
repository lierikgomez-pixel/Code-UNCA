# Guion del video — CODI-UNCA

**Duración:** 125 segundos · **Voz:** es-MX-JorgeNeural

| # | Diapositiva | Narración |
| --- | --- | --- |
| 1 | CODI-UNCA | CODI-UNCA es comercio digital del limón para Oaxaca -Sierra de Flores Magón. Clasificamos la fruta con inteligencia artificial local y cobramos con historial. |
| 2 | Problema y usuario | El productor decide cuándo vender mirando el limón y cobra sin dejar un historial útil. Nuestra tarea es ayudarlo a clasificar y cobrar en el mismo momento. |
| 3 | Nuestra solución | La aplicación tiene cinco pantallas: Cobrar, Pedidos, Calidad, Asistente y Aprender. La foto se analiza, el asistente opina y cada venta suma al historial digital. |
| 4 | Demostración en vivo | El recorrido es sencillo: cobrar ciento ochenta pesos con código QR, crear un pedido de doce kilos y medio, tomar una foto nueva y preguntar si se vende. |
| 5 | Visión por computadora | Entrenamos EfficientNet B0 con seis mil treinta y dos imágenes públicas, en una Tesla T4 con CUDA y precisión mixta. El modelo se exportó a ONNX y corre en el navegador. |
| 6 | Resultados de visión | En prueba, el modelo acierta noventa y ocho punto seis ocho por ciento, con F1 macro de cero punto noventa y ocho. La clase sin limón tuvo recall uno. |
| 7 | Asistente con criterio | El asistente usa una base local de doce respuestas verificadas y el contexto de la última foto. En diez casos reservados pasa de uno a diez aciertos frente a la base. |
| 8 | NVIDIA y diseño HCI | La contribución NVIDIA fue entrenar, guardar pesos y exportar el modelo en el servidor asignado. En diseño elegimos duda explícita, corrección humana y una pantalla por decisión. |
| 9 | Evidencias verificables | Las evidencias son ejecutables: doce casos de aplicación, diez del asistente, métricas de visión y verificación del modelo en producción. Sin errores de consola. |
| 10 | Cierre | Entregamos la aplicación, instrucciones, entrenamiento, evidencias, ficha, presentación y este video. Lo simulado está declarado. Nivel de madurez tecnológica cinco. La inteligencia artificial orienta; el productor decide. Gracias. |

El video se genera con `python tools/generar_video.py`.
