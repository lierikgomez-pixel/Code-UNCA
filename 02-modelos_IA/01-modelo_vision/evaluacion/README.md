# Evaluación — modelo de visión y aplicación

## Métricas del modelo

Fuente: `../entrenamiento/metricas.json`.

| Métrica | Valor |
| --- | --- |
| Accuracy | **0.9868** |
| F1 macro | **0.9897** |
| Aciertos | **596 / 604** |
| Errores | **8 / 604** |
| Recall `sin_limon` | **1.00** |

## Comparación y casos límite

- El modelo anterior se conserva como referencia en el reporte detallado.
- El reentrenamiento corrigió el falso negativo de `sin_limon`.
- Regla de seguridad: si `sin_limon` gana pero la suma de `verde + maduro + podrido` es mayor, se muestra **Resultado dudoso**.
- Confianza menor a 60 % también produce **Resultado dudoso**.

## Evidencias ejecutables

- `verificar_app.dart` — 12 casos de la aplicación, incluyendo errores y datos inválidos.
- `resultados_app.json` — resultado real: **12/12 casos pasados**.
- `EVIDENCIAS_EVALUACION.md` — evidencia consolidada de app, visión y asistente.

## Reproducir

```bash
dart run 02-modelos_IA/01-modelo_vision/evaluacion/verificar_app.dart
```

Salida esperada: `casos_pasados: 12`, `casos_fallidos: 0`.
