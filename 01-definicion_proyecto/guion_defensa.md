# Guion de defensa ante el jurado — CODI-UNCA

**Duración total:** 15 minutos (2 + 4 + 4 + 5)
**Formato según la presentación del hackathon:** problema/usuario/solución, demostración, entrenamiento-evaluación-diseño y preguntas.
**Integrantes sugeridos:** ponente principal (Narrador), demo (Prototipador), técnico (Datos/Modelos), escéptico rotativo.

> Regla de oro: hablar de **evidencia**, no de adjetivos. Cada afirmación va seguida de una métrica, una captura o una demo. Declarar lo que es simulado.

---

## 0. Antes de empezar (checklist del presentador)

- [ ] URL abierta: https://code-unna.vercel.app/
- [ ] Pestaña con el notebook y `outputs/` listos para mostrar pesos y ONNX.
- [ ] Ficha PDF de 4 páginas impresa o en pantalla.
- [ ] Video de 3 minutos listo (por si hay problema con la demo en vivo).
- [ ] TRL declarado: **TRL 5** (validación en entorno relevante con feedback de pares, simulado).
- [ ] Frase de integridad: «Los datos bancarios son simulación local; no hay claves reales ni QR CoDi real».

---

## 1. Problema, usuario y solución — 2 minutos

### 1.1 Gancho (0:00–0:30)

> «Buenos días. En la Sierra de Flores Magón, Oaxaca, un productor de limón decide **cuándo vender** mirando la fruta, y decide **cómo cobrar** con lo que tiene a la mano. Hoy esas dos decisiones viven separadas: una en el ojo del productor, otra en un celular que no deja historial.
>
> Nuestra pregunta no fue *"¿qué app hacemos?"*, sino: **¿cómo ayudar a un pequeño negocio a participar en la economía digital sin dejar de lado su criterio sobre la fruta?**»

### 1.2 Usuario y tarea (0:30–1:10)

> «Usuario: productor o acopiador de limón, con ventas de dos a cien kilos al día, que usa efectivo y a veces transferencias. Su tarea crítica: **clasificar la fruta y cobrarla en el mismo momento**, con una explicación que entienda y que pueda corregir.
>
> Contexto: la Ley de Economía Digital entró en vigor el 5 de noviembre de 2026. No obliga a dejar el efectivo, pero sí empuja a aceptar pagos digitales y a construir historial hacia la Cuenta Nivel 2 Bis.»

### 1.3 Solución (1:10–2:00)

> «CODI-UNCA es una app Flutter con cinco pantallas: **Cobrar, Pedidos, Calidad, Asistente y Aprender**.
> Toma una foto → un modelo de visión entrenado en GPU dice si el limón está verde, maduro, podrido o si no hay fruta → un asistente con contexto opina si se vende, ayuda a venderlo y dice cuándo no cumple → el cobro queda registrado y alimenta el historial digital.
>
> Dos decisiones que queremos defender hoy: **la IA corre en el navegador, sin servidor GPU en producción**, y **la recomendación siempre es corregible por el humano**. El panel *Mi opinión* lo dice literalmente: "Es una segunda opinión. La decisión final es tuya."»

---

## 2. Demostración de la aplicación — 4 minutos

> Regla: **mostrar imagen y consulta nuevas**, no solo la pantalla previa. Usar una foto distinta a las del entrenamiento y una pregunta nueva escrita en el momento.

### 2.1 Cobrar (0:00–0:45) — 45 s

1. Abrir la URL y señalar el hero: **CODI-UNCA · Oaxaca -Sierra de Flores Magón · Comercio digital del limón.**
2. Capturar monto `180`, concepto `Venta de limón`.
3. Tocar **Cobrar** → hoja «¿Cómo te paga?».
4. Elegir **QR** → mostrar el QR → **Ya me pagaron**.
5. Señalar la venta nueva en «Últimas ventas» y el contador del día.

> Guion: «El recorrido completo es **ingreso → procesamiento → revisión → confirmación**. El QR es de demostración: el payload `ledpago://cobro` es nuestro formato de ejemplo, **no un QR CoDi real**. Eso está declarado en la app.»

### 2.2 Pedidos (0:45–1:30) — 45 s

1. Agregar `Limón persa` con precio del día.
2. Nuevo pedido: comprador, `12.5 kg` → **Crear y cobrar**.
3. Pagar y mostrar el check verde más la venta generada automáticamente.

> Guion: «Un pedido pagado genera también una venta. Así el historial digital y los kilos del mes salen de una sola acción, sin doble captura.»

### 2.3 Calidad con imagen nueva (1:30–2:45) — 75 s

1. Tocar **Calidad** → cámara/galería → elegir **una foto nueva**.
2. Leer en voz alta: etiqueta, confianza, probabilidades y badge **IA**.
3. Si sale «Resultado dudoso», decir: «Esto es intencional: el modelo prefiere pedir otra foto antes que afirmar que no hay fruta».
4. Señalar el panel **Mi opinión: …** y la ayuda para vender.

> Guion: «La inferencia ocurre aquí mismo, en el navegador. El modelo pesa 16 MB y usa ONNX Runtime Web con WASM, un hilo. No hay API remota: si se corta internet después de cargar, la lógica sigue siendo local.»

### 2.4 Asistente con consulta nueva (2:45–3:40) — 55 s

1. Escribir en vivo: **«¿Vendo este limón y cómo lo ofrezco?»**
2. Mostrar que la respuesta usa la clase, la confianza y el color de la foto anterior.
3. Tocar un chip nuevo: **«¿Cumple para vender?»**.
4. Opcional: **«¿Qué dice mi última foto?»** para mostrar el contexto sin CLABE completa.

> Guion: «La respuesta no es texto fijo: se arma con el resultado de la visión y con la opinión comercial. Y cuando pregunta por datos bancarios, el asistente solo menciona los últimos cuatro dígitos.»

### 2.5 Aprender y cierre (3:40–4:00) — 20 s

> «Aquí se ve el progreso hacia la Cuenta Nivel 2 Bis: pagos digitales del mes, desglose por método y kilos vendidos. Cada venta que acabamos de hacer ya aparece.»

---

## 3. Entrenamiento, evaluación y diseño — 4 minutos

### 3.1 Visión por computadora (0:00–1:20)

> «Tarea visual: clasificación de cuatro clases — maduro, podrido, verde y sin limón.
> Modelo base: **EfficientNet-B0** con pesos ImageNet.
> Datos: dataset público `ritikb2211/final-dataset`, **6032 imágenes**, sin token. Separamos **4523 entrenamiento / 904 validación / 604 prueba**.
> Entrenamos durante el evento en una **Tesla T4** con PyTorch 2.5.1+cu121, AMP FP16, AdamW, label smoothing y augmentación fuerte; early stopping con paciencia 5.
>
> Resultado en prueba: **accuracy 0.9868**, **F1 macro 0.9897**, **recall 1.00 en sin_limon**. El baseline clásico de color y forma daba 0.9551 de accuracy: ganamos **3.17 puntos** y, sobre todo, reducimos el falso negativo de "no hay fruta".
>
> Artefacto: `modelo_limon.onnx`, 16 040 694 bytes, entrada `images [1,3,224,224]`, salida `logits`. Está en `web/` y en `build/web/`, con el mismo SHA-256.»

### 3.2 Asistente (1:20–2:20)

> «El asistente usa **RAG local más prompt engineering con few-shot**: una base de doce entradas verificadas y una capa de contexto con la última foto. Documentamos modelo base, objetivos, fuentes y configuración en `02-modelos_IA/02-llm/`.
> No afirmamos que hicimos LoRA; elegimos RAG porque corre sin internet y porque la trazabilidad de cada respuesta es explícita.
> Probamos **diez casos reservados** y comparamos contra una base sin adaptar: la versión adaptada responde correctamente **10/10** contra **1/10** de la base. La comparación completa está en `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md`.
> La consistencia se revisó repitiendo cada pregunta tres veces con el mismo resultado.»

### 3.3 NVIDIA y HCI (2:20–3:30)

> «Contribución NVIDIA: entrenamiento y exportación en el servidor asignado; guardamos `mejor_modelo.pt`, `modelo_limon.onnx`, `class_names.json` y los registros de época. AMP FP16 y la TurboMPS del dataset son el uso técnico concreto de la GPU. Producción **no depende** de Jupyter: solo consume el ONNX exportado.
>
> En HCI definimos usuario, tarea y contexto. Justificamos tres decisiones: **una sola pantalla por decisión**, **resultado dudoso en vez de negativa categórica** y **opinión humana corregible**. El flujo permite revisar y corregir: se puede repetir la foto, cambiar el color interpretado y decidir igual contra la recomendación.
> Estado honesto: el protocolo de prueba con dos personas ajenas está preparado; registraremos sus observaciones antes del cierre. No vamos a presentar una prueba que no hicimos como si estuviera hecha.»

### 3.4 Cierre técnico (3:30–4:00)

> «El producto quedó en **TRL 5**: prototipo funcionando en entorno relevante con feedback de pares, todavía lejos de mercado. Lo que hoy está en producción es un prototipo verificable, no un producto terminado. Funciones simuladas: QR CoDi, link de pago y datos bancarios. Sin claves ni datos sensibles reales.»

---

## 4. Preguntas del jurado — 5 minutos

### P1. «¿Por qué no usaron un modelo de lenguaje grande ajustado?»
> «Por tres razones: el contexto es local y finito, la respuesta debe ser reproducible y queríamos trazabilidad de cada afirmación legal. Un RAG con doce fuentes verificadas y una capa de contexto nos da eso sin depender de un servicio externo. Queda documentado como decisión, no como limitación escondida. Si el jurado lo prefiere, la interfaz de `answerFor` permite sustituir la base por un modelo ajustado sin cambiar la app.»

### P2. «¿Cómo saben que el modelo no memorizó el dataset?»
> «Separación estricta train/val/test antes de entrenar; el reporte de prueba usa 604 imágenes nunca vistas. Además reducimos las imágenes a 256 px en `data/processed/` y usamos augmentación agresiva. Aun así, admitimos que el dataset es público y puede tener sesgo de iluminación: por eso el resultado dudoso y la segunda opinión por color.»

### P3. «¿Qué pasa si el modelo dice 'sin limón' pero hay fruta?»
> «Es el caso que más nos preocupaba. `esDudoso` incluye una regla explícita: si gana `sin_limon` pero las tres clases de fruta suman más probabilidad, mostramos **Resultado dudoso** y pedimos otra foto. En prueba, `sin_limon` tuvo recall 1.00, y la regla queda como red de seguridad para el mundo real.»

### P4. «¿Los datos bancarios están seguros?»
> «No hay backend. Banco, CLABE y titular se guardan con `SharedPreferences` en el dispositivo y la app advierte que es simulación. En el chat solo se mencionan los últimos cuatro dígitos. Ninguna clave, token o dato real fue introducido durante el desarrollo.»

### P5. «¿La ley obliga a aceptar tarjeta?»
> «No. La ley promotes pagos digitales y trato gradual, pero no elimina el efectivo ni obliga de forma absoluta a aceptar tarjeta. El asistente lo responde literalmente en la FAQ 1 y pide confirmar reglas vigentes con el banco o Banxico.»

### P6. «¿Por qué Flutter Web si el reto pide app móvil?»
> «El mismo código Dart compila para Android e iOS; el despliegue web es el canal verificable para el jurado y el que permite correr ONNX Runtime en el navegador. La carpeta `android/` e `ios/` está incluida. En móvil, donde la carga del modelo puede fallar, existe el analizador clásico como respaldo.»

### P7. «¿Qué es exactamente lo que entrenaron 'durante las 24 horas'?»
> «El ajuste fino del EfficientNet-B0, no la arquitectura desde cero. Usamos pesos ImageNet como punto de partida, entrenamos el clasificador con los hiperparámetros documentados y exportamos el ONNX. Pesos, métricas y logs quedaron en `outputs/` del notebook.»

### P8. «¿Qué harían con 24 horas más?»
> «Tres cosas, en orden: ejecutar la prueba con dos usuarios reales y cerrar el feedback de HCI; calibrar `MM_POR_PIXEL` con una regla física; y cuantizar el ONNX para reducir la primera carga. No diríamos "agregar más funciones" antes de validar las actuales.»

### P9. «¿Usaron IA generativa para el código? ¿Lo declaran?»
> «Sí, como asistente de implementación y documentación. Todo fue revisado y ejecutado por el equipo; `01-definicion_proyecto/declaracion_ia.md` detalla qué partes se apoyaron en IA y cómo se verificaron. No hay citas fabricadas: cada dato legal se contrastó con la presentación del hackathon y se pide confirmación con fuente oficial.»

### P10. «¿Por qué TRL 5 y no TRL 7?»
> «Porque no hemos validado en campo con usuarios reales ni tenemos despliegue en tienda. TRL 5 es honesto: prototipo probado en entorno relevante con pares. Llegar a TRL 9 sería falso en un hackathon de 24 horas.»

---

## 5. Frases para cerrar (no improvisar)

> «No construimos una app para *tener* una app. Construimos una herramienta para que un productor de limón de la Sierra decida mejor y cobre con historial.
> Si el modelo duda, lo decimos. Si la IA opina, el humano decide. Si algo es simulado, lo declaramos.
> Eso es CODI-UNCA. Gracias.»

---

## 6. Mapa de requerimientos ↔ dónde defenderlos

| Requerimiento de la presentación | Momento del guion | Evidencia |
| --- | --- | --- |
| Recorrido ingreso→procesamiento→revisión→confirmación | 2.1–2.4 | Demo en vivo |
| Integración de ambos modelos | 2.3 + 2.4 | Foto nueva + consulta nueva |
| Pesos/adaptadores verificables | 3.1 | `outputs/mejor_modelo.pt`, ONNX |
| Corrección humana y errores | 2.3 + P3 | Resultado dudoso, panel Mi opinión |
| Visión: tarea, datos, split, entrenamiento | 3.1 | `02-modelos_IA/01-modelo_vision/entrenamiento/` |
| Asistente: base, objetivos, fuentes, consistencia | 3.2 | `02-modelos_IA/02-llm/` |
| NVIDIA: servidor, pesos, herramienta | 3.3 | `02-modelos_IA/01-modelo_vision/entrenamiento/nvidia_t4.md` |
| HCI: usuario, tarea, 3 decisiones, 2 personas | 3.3 | `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md` |
| Pruebas técnicas: 5 app / visión / 10 asistente | 3.1–3.2 | `02-modelos_IA/01-modelo_vision/evaluacion/EVIDENCIAS_EVALUACION.md` |
| Declaración de IA e integridad | 3.4 + P9 | `01-definicion_proyecto/declaracion_ia.md` |
| TRL declarado | 3.4 + P10 | Guion y ficha |
