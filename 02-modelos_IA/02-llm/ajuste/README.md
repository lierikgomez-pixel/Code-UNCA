# Ajuste del asistente (RAG local + few-shot)

El adaptador no es un modelo entrenado con LoRA/QLoRA. Es una capa de recuperación local y ejemplos few-shot que condicionan al modelo base.

## Componentes

1. **Recuperación local**: se selecciona la FAQ con mayor coincidencia de palabras clave.
2. **Few-shot**: se incluyen ejemplos de preguntas del dominio con su respuesta esperada.
3. **Contexto de visión**: si hay una foto reciente, se inyectan clase, confianza y color detectado.
4. **Opinión comercial**: se usa `evaluarVenta({clase, confianza, dudoso, color})` de `lib/services/asesor.dart`.
5. **Corrección humana**: el productor puede ignorar la sugerencia y decidir igual.

## Evaluación

- 10 preguntas reservadas, distintas de las usadas en los ejemplos.
- 3 repeticiones por pregunta para medir consistencia.
- Resultado: **10/10 aciertos** y **10/10 consistencia**.
- Línea base: **1/10**.

## Resultados

`resultados_evaluacion.json` contiene el detalle por caso y la comparación base vs adaptado.

Reproducir:

```bash
dart run 02-modelos_IA/02-llm/entrenamiento/evaluar.dart
```
