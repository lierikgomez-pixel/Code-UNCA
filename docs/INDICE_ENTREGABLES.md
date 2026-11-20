# Índice de entregables — Hackathon Oaxaca 2027

Este índice mapea cada requerimiento de la presentación con el archivo que lo cumple.

| Requerimiento (presentación) | Entregable | Ubicación |
| --- | --- | --- |
| Aplicación funcional e instrucciones | App desplegada + guía de uso | https://code-unna.vercel.app/ · `docs/INSTRUCCIONES.md` |
| Repositorio y dependencias | Código, `pubspec.yaml`, `pubspec.lock`, `vercel.json` | `github.com/lierikgomez-pixel/Code-UNCA` |
| Paquete de entrenamiento de ambos modelos | Visión, asistente y NVIDIA | `training/README.md` |
| Ficha PDF máximo 4 páginas | Ficha técnica | `docs/FICHA_TECNICA.pdf` |
| Evidencias de evaluación | Resultados ejecutables | `docs/EVIDENCIAS_EVALUACION.md` |
| Presentación PDF | 10 diapositivas | `docs/PRESENTACION.pdf` |
| Video máximo 3 minutos | Video de sustentación | `docs/VIDEO_CODE_UNCA.mp4` |
| Guion para defender el tema | Guion de 15 min + preguntas | `docs/GUION_DEFENSA.md` |
| Declaración de uso de IA | Transparencia y responsable | `docs/DECLARACION_IA.md` |
| TRL declarado | Honestidad técnica | `docs/GUION_DEFENSA.md`, `docs/FICHA_TECNICA.pdf` |

## Requerimientos por sección

### Aplicación funcional (diapositiva 9)

- Recorrido completo ingreso → procesamiento → revisión → confirmación: `docs/INSTRUCCIONES.md`.
- Integración de ambos modelos: `docs/DOCUMENTACION_APP.md`, sección 7.
- Pesos/adaptadores verificables: `training/vision/`, `training/nvidia/`.
- Corrección humana y errores: `docs/HCI_PRUEBA_USUARIOS.md`, `docs/EVIDENCIAS_EVALUACION.md`.

### Visión por computadora (diapositiva 10)

- Tarea, modelo base, datos, split, entrenamiento y artefactos: `training/vision/README.md`.
- Métricas: `training/vision/metricas.json`.

### Asistente conversacional (diapositiva 11)

- Base, objetivos, fuentes y configuración: `training/asistente/README.md`.
- Consistencia y comparación base vs adaptado: `training/asistente/resultados_evaluacion.json`.
- Integración: `lib/screens/asistente.dart`.

### NVIDIA (diapositiva 12)

- Entorno, comandos, AMP FP16 y artefactos: `training/nvidia/README.md`.

### HCI (diapositiva 13)

- Usuario, tarea, contexto y tres decisiones: `docs/HCI_PRUEBA_USUARIOS.md`.
- Protocolo con dos personas ajenas: mismo archivo, sección 5 (**pendiente de ejecutar**).

### Pruebas técnicas (diapositiva 14)

- 12 casos de aplicación: `evidencias/resultados_app.json`.
- Métricas y comparación de visión: `training/vision/metricas.json`.
- 10 casos de asistente: `training/asistente/resultados_evaluacion.json`.

### Presentación al jurado (diapositiva 17)

- 2 + 4 + 4 + 5 minutos: `docs/GUION_DEFENSA.md`.
- Demostrar imagen y consulta nuevas: guion, sección 2.

### Cierre e integridad (diapositiva 18)

- Funciones simuladas: `docs/INSTRUCCIONES.md`, sección 5.
- Sin datos sensibles: `docs/DECLARACION_IA.md`.
- Sin evidencias falsas: `docs/EVIDENCIAS_EVALUACION.md`.

---

## Nota de honestidad

La prueba con dos personas ajenas al equipo está **preparada pero pendiente**. El resto de los entregables fueron generados y verificados con scripts o artefactos reales. No se modificarán códigos, modelos ni datos después del cierre del evento.
