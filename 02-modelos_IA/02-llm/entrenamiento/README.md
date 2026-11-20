# Asistente conversacional — CODI-UNCA

**Entregable:** paquete de entrenamiento del asistente (diapositiva 11 de la presentación).

## 1. Enfoque elegido

Se implementó **RAG local + prompt engineering con few-shot**, una de las tres opciones permitidas por la presentación (`LoRA / QLoRA`, `RAG`, `prompt engineering con few-shot`).

**No se hizo LoRA/QLoRA.** La decisión fue documentada porque el conocimiento del dominio es pequeño, estable y necesita trazabilidad: doce entradas verificadas sobre ley de economía digital, cobros y contexto de la última foto. El asistente corre sin servicio externo y cada respuesta proviene de una fuente identificable.

## 2. Modelo base, objetivos y fuentes

| Item | Definición |
| --- | --- |
| Modelo base | Recuperador determinista sobre base local + plantillas de respuesta (sin LLM remoto) |
| Objetivo 1 | Responder preguntas frecuentes sobre pagos digitales, CoDi, QR y Cuenta Nivel 2 Bis |
| Objetivo 2 | Explicar tipos de limón y precios/unidades de venta |
| Objetivo 3 | Usar el contexto de la última foto para opinar si la fruta se vende |
| Objetivo 4 | Declarar simulaciones y no exponer datos sensibles |
| Fuentes | Presentación oficial del hackathon, documentación pública de Banxico/CoDi y `lib/services/knowledge.dart` |
| Configuración | Normalización sin tildes ni ñ, 19 stopwords, puntaje por coincidencia de palabras clave, umbral de duda → respuesta por defecto |
| Few-shot | Ejemplos de preguntas y respuestas incrustados en las 12 FAQs y en los chips de la interfaz |

La implementación principal está en `lib/services/knowledge.dart`. La copia auditable está en `knowledge_base.json`.

## 3. Contexto del asistente

`answerFor(question, {contexto})` recibe un contexto construido en `lib/screens/asistente.dart`:

- Clase predicha y confianza de la última foto.
- Indicador de si el resultado fue dudoso.
- Color detectado por el análisis clásico (segunda opinión).
- Estado bancario **simulado**, mostrando únicamente los últimos 4 dígitos de la CLABE.

Si la pregunta contiene `foto`, `calidad`, `resultado`, `banco`, `clabe` o `datos`, el contexto se antepone a la respuesta base.

## 4. Opinión comercial

Además del RAG, `lib/services/asesor.dart` implementa `evaluarVenta`, que transforma la predicción en una recomendación accionable:

- «Sí, véndelo» cuando hay confianza alta y sin señales de daño.
- «Probablemente sí, pero revisa» cuando la confianza es menor a 75 %.
- «Casi maduro» / «Aún verde» según color.
- «Revisa antes de vender» si el color sugiere manchas.
- «No cumple para vender» para podrido.
- «No lo vendas aún» cuando el resultado es dudoso.

El panel lo dice explícitamente: **«Es una segunda opinión. La decisión final es tuya.»**

## 5. Evaluación ejecutada

Script reproducible: `evaluar.dart`.

```bash
dart run 02-modelos_IA/02-llm/evaluar.dart
```

El script:

1. Ejecuta **10 casos reservados**.
2. Compara cada respuesta con una base sin adaptar.
3. Repite cada pregunta **tres veces** para medir consistencia.
4. Escribe `resultados_evaluacion.json`.

**Resultado real:**

| Métrica | Resultado |
| --- | ---: |
| Casos reservados | 10 |
| Aciertos base sin adaptar | **1 / 10** |
| Aciertos asistente adaptado | **10 / 10** |
| Casos consistentes en 3 repeticiones | **10 / 10** |

## 6. Integración en la aplicación

- Diez chips de sugerencias en `lib/screens/asistente.dart`.
- Entrada por texto y por voz (`SpeechToText`, `es_MX`).
- Salida por texto y voz (`FlutterTts`, `es-MX`, velocidad 0.95).
- Detección de preguntas de venta para usar `evaluarVenta(...).paraChat`.
- Contexto bancario sin CLABE completa.

## 7. Límites declarados

- No es un LLM generativo entrenado desde cero.
- La evaluación depende de la calidad de las doce FAQs; preguntas fuera de dominio caen en la respuesta por defecto.
- Las respuestas legales son informativas y piden confirmar con Banxico o el banco.
- No se usaron datos sensibles reales durante las pruebas.
