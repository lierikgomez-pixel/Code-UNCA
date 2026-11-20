# Modelo base del asistente

El modelo base es el mismo asistente **sin** la base de conocimiento local ni los ejemplos few-shot del dominio. Se usa únicamente como línea base de comparación.

## Configuración base

- Prompt general sin FAQs de CODI-UNCA.
- Sin contexto de la última foto analizada.
- Sin reglas de opinión comercial de `lib/services/asesor.dart`.
- Misma interfaz y mismas 10 preguntas reservadas que la versión adaptada.

## Resultado

| Versión | Aciertos |
| --- | --- |
| Base | **1 / 10** |
| Adaptado (RAG local + few-shot) | **10 / 10** |

La comparación completa está en `ajuste/resultados_evaluacion.json`.

## Por qué no se usó LoRA/QLoRA

- El dominio es pequeño y está cerrado (12 FAQs).
- RAG local + few-shot es trazable: cada respuesta puede asociarse a una fuente.
- Funciona sin servicio externo, sin GPU remota y sin pesos adicionales que descargar.
- Evita respuestas inventadas fuera del dominio; cuando no hay fuente, el asistente se abstiene.
