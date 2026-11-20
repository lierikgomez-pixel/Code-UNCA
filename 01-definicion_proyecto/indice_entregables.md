# Índice de entregables — Hackathon Oaxaca 2027

Este índice mapea cada requerimiento de la presentación con el archivo que lo cumple.

| Requerimiento (presentación) | Entregable | Ubicación |
| --- | --- | --- |
| Aplicación funcional e instrucciones | App desplegada + guía de uso | https://code-unna.vercel.app/ · `01-definicion_proyecto/instrucciones.md` |
| Repositorio y dependencias | Código, `pubspec.yaml`, `pubspec.lock`, `vercel.json` | `github.com/lierikgomez-pixel/Code-UNCA` |
| Paquete de entrenamiento de ambos modelos | Visión, asistente y NVIDIA | `02-modelos_IA/README.md` |
| Ficha PDF máximo 4 páginas | Ficha técnica | `01-definicion_proyecto/ficha_tecnica.pdf` |
| Evidencias de evaluación | Resultados ejecutables | `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md` |
| Presentación PDF | 10 diapositivas | `presentacion.pdf` |
| Video máximo 3 minutos | Video de sustentación | `Video-de-demostracion.mp4` |
| Guion para defender el tema | Guion de 15 min + preguntas | `01-definicion_proyecto/guion_defensa.md` |
| Declaración de uso de IA | Transparencia y responsable | `01-definicion_proyecto/declaracion_ia.md` |
| Perfiles de usuario | Perfil principal y secundario | `03-interfaz/01-usuarios/perfiles_usuario.md` · `03-interfaz/perfiles-usuario.pdf` |
| Propuesta de negocio | Valor, modelo y riesgos | `04-propuesta_negocio/propuesta.md` · `04-propuesta_negocio/propuesta.pdf` |
| TRL declarado | Honestidad técnica | `01-definicion_proyecto/guion_defensa.md`, `01-definicion_proyecto/ficha_tecnica.pdf` |

## Requerimientos por sección

### Aplicación funcional (diapositiva 9)

- Recorrido completo ingreso → procesamiento → revisión → confirmación: `01-definicion_proyecto/instrucciones.md`.
- Integración de ambos modelos: `03-interfaz/02-interaccion/documentacion_app.md`, sección 7.
- Pesos/adaptadores verificables: `02-modelos_IA/01-modelo_vision/entrenamiento/`, `02-modelos_IA/01-modelo_vision/entrenamiento/nvidia_t4.md`.
- Corrección humana y errores: `03-interfaz/01-usuarios/hci_prueba_usuarios.md`, `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md`.

### Visión por computadora (diapositiva 10)

- Tarea, modelo base, datos, split, entrenamiento y artefactos: `02-modelos_IA/01-modelo_vision/entrenamiento/README.md`.
- Métricas: `02-modelos_IA/01-modelo_vision/entrenamiento/metricas.json`.

### Asistente conversacional (diapositiva 11)

- Base, objetivos, fuentes y configuración: `02-modelos_IA/02-llm/modelo_base.md`, `02-modelos_IA/02-llm/entrenamiento/README.md`.
- Consistencia y comparación base vs adaptado: `02-modelos_IA/02-llm/ajuste/resultados_evaluacion.json`.
- Integración: `lib/screens/asistente.dart`.

### NVIDIA (diapositiva 12)

- Entorno, comandos, AMP FP16 y artefactos: `02-modelos_IA/01-modelo_vision/entrenamiento/nvidia_t4.md`.

### HCI (diapositiva 13)

- Usuario, tarea, contexto y tres decisiones: `03-interfaz/01-usuarios/hci_prueba_usuarios.md`.
- Protocolo con dos personas ajenas: mismo archivo, sección 5 (**pendiente de ejecutar**).

### Pruebas técnicas (diapositiva 14)

- 12 casos de aplicación: `02-modelos_IA/01-modelo_vision/evaluacion/resultados_app.json`.
- Métricas y comparación de visión: `02-modelos_IA/01-modelo_vision/entrenamiento/metricas.json`.
- 10 casos de asistente: `02-modelos_IA/02-llm/ajuste/resultados_evaluacion.json`.

### Presentación al jurado (diapositiva 17)

- 2 + 4 + 4 + 5 minutos: `01-definicion_proyecto/guion_defensa.md`.
- Demostrar imagen y consulta nuevas: guion, sección 2.

### Cierre e integridad (diapositiva 18)

- Funciones simuladas: `01-definicion_proyecto/instrucciones.md`, sección 5.
- Sin datos sensibles: `01-definicion_proyecto/declaracion_ia.md`.
- Sin evidencias falsas: `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md`.

---

## Nota de honestidad

La prueba con dos personas ajenas al equipo está **preparada pero pendiente**. El resto de los entregables fueron generados y verificados con scripts o artefactos reales. No se modificarán códigos, modelos ni datos después del cierre del evento.
