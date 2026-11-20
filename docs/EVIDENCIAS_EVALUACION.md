# Evidencias de evaluación — CODI-UNCA

**Entregable:** evidencias de evaluación (diapositiva 15 de la presentación).
**Fecha:** 20 de noviembre de 2026.
**Principio:** toda cifra reportada aquí proviene de un script ejecutable, un log del entrenamiento o una verificación en producción. Lo que no se ejecutó aparece marcado como pendiente.

---

## 1. Aplicación funcional

Script reproducible:

```bash
dart run docs/evidencias/verificar_app.dart
```

Resultado guardado en `docs/evidencias/resultados_app.json`:

| Indicador | Resultado |
| --- | ---: |
| Casos ejecutados | **12** |
| Casos pasados | **12** |
| Casos fallidos | **0** |
| Incluye errores | Sí |
| Incluye datos inválidos | Sí |

### Casos ejecutados

| ID | Caso | Tipo | Resultado |
| --- | --- | --- | --- |
| APP-01 | Formatear importe de venta | normal | paso |
| APP-02 | Calcular total de pedido | normal | paso |
| APP-03 | Resumen de pedido | normal | paso |
| APP-04 | Opinión sin foto | error | paso |
| APP-05 | Confianza baja se abstiene | error | paso |
| APP-06 | Posible falso negativo de `sin_limon` | dato inválido | paso |
| APP-07 | Etiqueta de falso negativo | dato inválido | paso |
| APP-08 | Limón dañado | normal | paso |
| APP-09 | Verde amarillando | normal | paso |
| APP-10 | Maduro con manchas | dato inválido | paso |
| APP-11 | Maduro con confianza intermedia | normal | paso |
| APP-12 | Pregunta fuera de dominio | error | paso |

### Verificación en navegador

Además de los casos automatizados se verificó en producción (https://code-unna.vercel.app/):

- Título: **CODI-UNCA · Comercio digital del limón**.
- `/modelo_limon.onnx` responde 16 040 694 bytes con el mismo SHA-256 local.
- La sesión `onnxruntime-web@1.23.2` se crea con `executionProviders: ['wasm']` y `numThreads: 1`.
- Entrada `images`, salida `logits`, 4 logits devueltos.
- Sin errores en consola.
- La forma `['batch',3,224,224]` no es válida en ORT; la app usa dimensiones numéricas `[1,3,224,224]`.

---

## 2. Modelo de visión por computadora

Fuente: `docs/training/vision/metricas.json` y logs del notebook de la GPU.

| Métrica | Resultado |
| --- | ---: |
| Imágenes de prueba | 604 |
| Accuracy | **0.9868** |
| F1 macro | **0.9897** |
| Recall `sin_limon` | **1.00** |
| Aciertos estimados | 596 |
| Errores estimados | 8 |
| Accuracy baseline clásico | 0.9551 |
| Ganancia de accuracy | **+0.0317** |
| Ganancia de F1 macro | **+0.0331** |

### Aciertos y errores

- El modelo acierta **596 de 604** imágenes de prueba.
- Erra **8 de 604**.
- El caso crítico de negocio —decir que no hay fruta cuando sí la hay— tuvo **recall 1.00** en prueba.
- Como red de seguridad adicional, `ModelResult.esDudoso` marca el caso en que gana `sin_limon` pero las clases con fruta suman más probabilidad.

### Artefacto verificable

| Dato | Valor |
| --- | --- |
| Archivo | `modelo_limon.onnx` |
| Tamaño | 16 040 694 bytes |
| Entrada | `images`, `[1,3,224,224]` |
| Salida | `logits` |
| Clases | `maduro`, `podrido`, `sin_limon`, `verde` |
| SHA-256 | `E243791EFA3755440B6FAD171DEEA67AD85915E33C940B3E79B26EA2EA72F810` |

---

## 3. Asistente conversacional

Script reproducible:

```bash
dart run docs/training/asistente/evaluar.dart
```

Resultado guardado en `docs/training/asistente/resultados_evaluacion.json`:

| Indicador | Resultado |
| --- | ---: |
| Casos reservados | **10** |
| Aciertos base sin adaptar | **1 / 10** |
| Aciertos asistente adaptado | **10 / 10** |
| Casos consistentes en 3 repeticiones | **10 / 10** |

### Temas evaluados

1. Ley y efectivo.
2. CoDi y comisiones.
3. Cuenta Nivel 2 Bis.
4. Cobro con QR.
5. Métodos de pago.
6. Precios y unidades.
7. Pedidos.
8. Frescura y color.
9. Tipos de limón.
10. Datos bancarios simulados.

### Comparación

La base sin adaptar solo acierta el caso de precios porque su respuesta por defecto menciona los pedidos. El asistente adaptado responde correctamente los diez casos y mantiene la misma respuesta al repetir cada pregunta tres veces.

---

## 4. HCI y experiencia de usuario

### Lo que sí quedó evidenciado

| Requerimiento | Evidencia |
| --- | --- |
| Definir usuario, tarea y contexto | `docs/HCI_PRUEBA_USUARIOS.md`, sección 1 |
| Diseñar un flujo claro | Flujo de cinco pasos en `docs/INSTRUCCIONES.md` |
| Justificar tres decisiones | `docs/HCI_PRUEBA_USUARIOS.md`, sección 3 |
| Permitir revisar y corregir | Resultado dudoso, repetir foto y panel «Mi opinión» |
| Registrar observaciones y mejoras | Formato listo en `docs/HCI_PRUEBA_USUARIOS.md`, sección 5 |

### Estado honesto

La prueba con **dos personas ajenas al equipo** quedó **preparada pero pendiente de ejecutar**. No reportamos nombres ni observaciones que no ocurrieron. El protocolo y el formato de registro están en `docs/HCI_PRUEBA_USUARIOS.md` para completarse antes del cierre del evento.

---

## 5. Trazabilidad de la evaluación

| Archivo | Contenido |
| --- | --- |
| `docs/evidencias/verificar_app.dart` | 12 casos de app, errores y datos inválidos |
| `docs/evidencias/resultados_app.json` | Resultados reales de la app |
| `docs/training/vision/metricas.json` | Métricas, split, comparación y artefactos |
| `docs/training/vision/README.md` | Memoria técnica del modelo de visión |
| `docs/training/asistente/evaluar.dart` | 10 casos reservados y consistencia |
| `docs/training/asistente/resultados_evaluacion.json` | Resultados reales base vs adaptado |
| `docs/training/nvidia/README.md` | Entorno, comandos y artefactos NVIDIA |
| `docs/REPORTE_DETALLADO.md` | Contexto completo del entrenamiento y deploy |
