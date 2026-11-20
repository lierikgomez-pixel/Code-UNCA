# Declaración de uso de IA — CODI-UNCA

**Entregable:** transparencia sobre el uso de IA durante el hackathon (reglas de autonomía, diapositivas 7, 45 y 46 de la presentación).

---

## 1. Principio

La IA se usó como **herramienta de apoyo**, no como autora. Todo código, modelo, dato y texto incluido fue **revisado, ejecutado y entendido por el equipo**. Ninguna decisión final del prototipo queda únicamente en manos de un modelo: la recomendación comercial siempre puede ser corregida por el productor.

---

## 2. Qué se apoyó en IA y cómo se verificó

| Parte del proyecto | Uso de IA | Verificación realizada |
| --- | --- | --- |
| Implementación Dart (pantallas y servicios) | Sugerencias de código y refactorización | `flutter analyze` sin problemas; `flutter build web --release` correcto; demo ejecutada en navegador |
| Modelo de visión | Apoyo en el diseño de la receta de augmentación y del notebook | Entrenamiento real en GPU; métricas en 604 imágenes de prueba; ONNX cargado e inferido en el navegador |
| Base de conocimiento del asistente | Redacción de borradores de FAQs | Contrastadas con la presentación oficial del hackathon (ley de economía digital, Cuenta Nivel 2 Bis, CoDi) y con documentación pública; se pide confirmar con Banxico/banco |
| Documentación (`README`, `docs/`, este archivo) | Apoyo en redacción y estructura | Revisión humana línea por línea; las cifras se tomaron de los logs reales del entrenamiento |
| Guion de defensa | Apoyo en estructura y ensayo de preguntas | Revisado por el equipo; las respuestas se basan en evidencias verificables del repositorio |

---

## 3. Qué NO se hizo con IA

- No se ingresaron datos sensibles, claves, tokens ni información bancaria real en ninguna herramienta de IA.
- No se usaron citas generadas sin verificación: cada dato legal proviene de la presentación del hackathon o de fuente pública, y se recomienda confirmarlo con la autoridad correspondiente.
- No se presentó código generado sin revisar ni ejecutar.
- No se falsificaron métricas, capturas ni pruebas de usuario.
- No se contrató asesoría externa durante el desarrollo, conforme a las reglas de autonomía.

---

## 4. Modelos y fuentes declaradas

| Modelo / herramienta | Origen | Uso |
| --- | --- | --- |
| EfficientNet-B0 (pesos ImageNet) | `torchvision.models` | Transfer learning para clasificación de limón |
| `onnxruntime-web@1.23.2` | jsDelivr | Inferencia local en el navegador |
| Asistente RAG + few-shot | Base local de 12 FAQs en `lib/services/knowledge.dart` | Respuestas sobre ley, cobros y contexto de foto |
| Dataset `ritikb2211/final-dataset` | Kaggle público, sin token | Entrenamiento y evaluación |

---

## 5. Humanos en el circuito

1. **Calidad:** el modelo propone una clase; el productor puede repetir la foto y decidir vender o no.
2. **Resultado dudoso:** el sistema se abstiene en vez de afirmar.
3. **Opinión comercial:** el panel lo dice explícitamente — «Es una segunda opinión. La decisión final es tuya.»
4. **Datos bancarios:** configuración local y simulada; ningún pago real se ejecuta desde la app.
5. **Legal:** las FAQs informing general, siempre con la recomendación de confirmar reglas vigentes.

---

## 6. Estado de honestidad técnica (TRL)

Declaramos **TRL 5**: prototipo validado en entorno relevante con feedback de pares, aún sinvalidación en campo ni despliegue comercial. No presentamos la demo como problema resuelto en mercado.

---

## 7. Responsable de Ia

El equipo designa un responsable único de IA para el evento, encargado de aplicar estas reglas y resolver dudas de uso durante el desarrollo. Cualquier cambio en este archivo debe ser aprobado por él y registrado en el repositorio.
