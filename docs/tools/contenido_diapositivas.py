# -*- coding: utf-8 -*-
"""Contenido único para la presentación PDF, la ficha y el video."""

TITULO = "CODI-UNCA"
SUBTITULO = "Comercio digital del limón"
KICKER = "OAXACA -SIERRA DE FLORES MAGÓN"
COLORES = {
    "bosque": (8, 43, 36),
    "bosque_claro": (18, 78, 64),
    "limon": (255, 214, 64),
    "crema": (247, 245, 235),
    "blanco": (255, 255, 255),
    "gris": (190, 205, 198),
    "rojo": (226, 92, 74),
}

SLIDES = [
    {
        "titulo": TITULO,
        "subtitulo": SUBTITULO,
        "kicker": KICKER,
        "bullets": [
            "Clasificación de limón con IA local",
            "Cobro digital con historial",
            "Asistente con opinión comercial",
        ],
        "nota": "Hackathon Oaxaca 2027 · TRL 5 · https://code-unna.vercel.app/",
        "portada": True,
    },
    {
        "titulo": "Problema y usuario",
        "subtitulo": "Dos decisiones separadas en la misma jornada",
        "bullets": [
            "El productor decide cuándo vender mirando la fruta.",
            "Cobra en efectivo o con transferencias sin historial útil.",
            "La Ley de Economía Digital entró en vigor el 5 de noviembre de 2026.",
            "Tarea crítica: clasificar la fruta y cobrarla en el mismo momento.",
            "Necesita una respuesta clara, corregible y en español.",
        ],
        "nota": "Usuario: productor/acopiador de limón · 2 a 100 kg al día · Sierra de Flores Magón",
    },
    {
        "titulo": "Nuestra solución",
        "subtitulo": "Una app, cinco decisiones, un solo flujo",
        "bullets": [
            "Cobrar: monto, QR, SPEI, link, tarjeta o efectivo.",
            "Pedidos: producto, unidad, cantidad y comprador.",
            "Calidad: foto → clase, confianza y opinión.",
            "Asistente: responde y opina con contexto de la última foto.",
            "Aprender: historial digital, kilos y progreso Nivel 2 Bis.",
        ],
        "nota": "Flujo: Ingreso → Procesamiento → Revisión → Confirmación → Seguimiento",
    },
    {
        "titulo": "Demostración en vivo",
        "subtitulo": "Recorrido completo con imagen y consulta nuevas",
        "bullets": [
            "1. Cobrar $180 con QR y confirmar el pago.",
            "2. Crear un pedido de 12.5 kg de limón persa.",
            "3. Tomar una foto nueva en Calidad.",
            "4. Preguntar: «¿Vendo este limón y cómo lo ofrezco?».",
            "5. Revisar el progreso digital en Aprender.",
        ],
        "nota": "La IA corre en el navegador; no hay API GPU remota.",
    },
    {
        "titulo": "Visión por computadora",
        "subtitulo": "Datos, modelo y entrenamiento durante el evento",
        "bullets": [
            "Dataset público ritikb2211/final-dataset: 6,032 imágenes.",
            "Split: 4,523 entrenamiento · 904 validación · 604 prueba.",
            "EfficientNet-B0 con pesos ImageNet + transfer learning.",
            "GPU NVIDIA Tesla T4 · PyTorch 2.5.1+cu121 · AMP FP16.",
            "ONNX: entrada images [1,3,224,224], salida logits.",
        ],
        "nota": "Artefacto: modelo_limon.onnx · 16,040,694 bytes · SHA-256 E243791E…",
    },
    {
        "titulo": "Resultados de visión",
        "subtitulo": "Evaluación sobre 604 imágenes nunca vistas",
        "bullets": [
            "Accuracy: 0.9868 → 596 aciertos y 8 errores.",
            "F1 macro: 0.9897.",
            "Recall de sin_limon: 1.00.",
            "Baseline clásico: 0.9551 accuracy · 0.9566 F1.",
            "Ganancia: +3.17 puntos de accuracy y +3.31 de F1.",
        ],
        "nota": "Regla adicional: si gana sin_limon pero hay más probabilidad de fruta → Resultado dudoso.",
    },
    {
        "titulo": "Asistente con criterio",
        "subtitulo": "RAG local + few-shot, sin servicio externo",
        "bullets": [
            "12 FAQs verificadas sobre ley, cobros y tipos de limón.",
            "Contexto: última foto, confianza, color y datos simulados.",
            "Opinión comercial: vender, revisar, esperar o no cumplir.",
            "10 casos reservados: base 1/10 · adaptado 10/10.",
            "Consistencia: 10/10 casos estables en 3 repeticiones.",
        ],
        "nota": "«Es una segunda opinión. La decisión final es tuya.»",
    },
    {
        "titulo": "NVIDIA y diseño HCI",
        "subtitulo": "Contribución técnica y decisiones de experiencia",
        "bullets": [
            "Entrenamiento y exportación en Tesla T4 con CUDA 12.1.",
            "AMP FP16, checkpoints, ONNX y registros guardados.",
            "Producción no depende de Jupyter ni de la GPU.",
            "HCI: una pantalla por decisión, duda explícita, corrección humana.",
            "Prueba con dos personas ajenas: protocolo listo, pendiente de ejecutar.",
        ],
        "nota": "Honestidad técnica: TRL 5, prototipo validado con pares en entorno relevante.",
    },
    {
        "titulo": "Evidencias verificables",
        "subtitulo": "Todo reportado puede ejecutarse o inspeccionarse",
        "bullets": [
            "Aplicación: 12/12 casos, con errores y datos inválidos.",
            "Visión: 596/604 aciertos, F1 0.9897 y recall 1.00.",
            "Asistente: 10/10 casos y consistencia 10/10.",
            "Producción: ONNX descargado e inferido en el navegador.",
            "Sin errores de consola y mismo hash ONNX local/producción.",
        ],
        "nota": "Scripts: dart run docs/evidencias/verificar_app.dart · dart run docs/training/asistente/evaluar.dart",
    },
    {
        "titulo": "Cierre",
        "subtitulo": "Entregables y límites declarados",
        "bullets": [
            "App funcional, instrucciones, repositorio y dependencias.",
            "Paquete de entrenamiento de ambos modelos y evidencias.",
            "Ficha PDF, presentación PDF y video de 3 minutos.",
            "Simulado: QR CoDi, link de pago y datos bancarios.",
            "Sin claves, datos sensibles ni evidencias falsas.",
        ],
        "nota": "No construimos una app para tener una app: ayudamos a decidir mejor y cobrar con historial.",
        "cierre": True,
    },
]

FICHA_PAGINAS = [
    {
        "titulo": "FICHA TÉCNICA · CODI-UNCA",
        "subtitulo": "Comercio digital del limón · OAXACA -SIERRA DE FLORES MAGÓN",
        "bloques": [
            ("Problema", "El productor decide la venta de la fruta con su criterio visual y cobra sin dejar historial digital útil. La Ley de Economía Digital de 2026 empuja a aceptar pagos digitales sin eliminar el efectivo."),
            ("Usuario y tarea", "Productor o acopiador de limón de 2 a 100 kg diarios. Su tarea crítica es clasificar la fruta y cobrarla en el mismo momento, con una explicación que pueda corregir."),
            ("Solución", "App Flutter con cinco pantallas: Cobrar, Pedidos, Calidad, Asistente y Aprender. La foto se clasifica con un modelo ONNX local; el asistente opina si la fruta se vende; el cobro alimenta el historial."),
            ("Decisiones de IA", "La inferencia ocurre en el navegador con ONNX Runtime Web. El asistente usa RAG local de 12 FAQs y contexto de la última foto. La recomendación siempre es corregible por el humano."),
        ],
        "pie": "Hackathon Oaxaca 2027 · TRL 5 · Versión 1.0.0+1",
    },
    {
        "titulo": "MODELOS Y EVALUACIÓN",
        "subtitulo": "Visión por computadora y asistente conversacional",
        "bloques": [
            ("Visión", "EfficientNet-B0 + transfer learning, entrenado en Tesla T4 con CUDA 12.1 y AMP FP16. Dataset público de 6,032 imágenes; split 4,523/904/604. Exportado a ONNX con entrada images [1,3,224,224]."),
            ("Métricas de prueba", "Accuracy 0.9868 (596/604), F1 macro 0.9897, recall sin_limon 1.00. Frente al baseline clásico (0.9551 accuracy), gana 3.17 puntos. SHA-256 del ONNX: E243791EFA375544…"),
            ("Asistente", "RAG local + few-shot. Base de 12 FAQs verificadas, contexto de foto, color y datos simulados. Diez casos reservados: base 1/10, adaptado 10/10; consistencia 10/10 en tres repeticiones."),
            ("Opinión comercial", "Reglas para «Sí, véndelo», «Probablemente sí, pero revisa», «Casi maduro», «Aún verde», «Revisa antes de vender», «No cumple para vender» y «No lo vendas aún» cuando el resultado es dudoso."),
        ],
        "pie": "Evidencias: docs/training/ · docs/evidencias/ · docs/EVIDENCIAS_EVALUACION.md",
    },
    {
        "titulo": "ENTREGABLES E INTEGRIDAD",
        "subtitulo": "Lo que se entrega y lo que queda declarado",
        "bloques": [
            ("Entregables", "Aplicación funcional e instrucciones; repositorio con dependencias; paquete de entrenamiento de ambos modelos; ficha PDF de 3 páginas; evidencias de evaluación; presentación PDF y video de 3 minutos."),
            ("HCI", "Usuario, tarea y contexto definidos; flujo de cinco pasos; tres decisiones justificadas; corrección humana en foto, color y recomendación. Protocolo con dos personas ajenas preparado y pendiente de ejecutar."),
            ("NVIDIA", "Entrenamiento, AMP FP16, checkpoints y exportación ONNX en el servidor asignado. Pesos, métricas, clases y hash documentados en docs/training/nvidia/."),
            ("Límites y TRL", "TRL 5: prototipo probado en entorno relevante con pares, sin validación en campo. Simulados: QR CoDi, link de pago y datos bancarios. No se usaron datos sensibles reales ni evidencias falsas."),
        ],
        "pie": "URL: https://code-unna.vercel.app/ · Repositorio: github.com/lierikgomez-pixel/Code-UNCA",
    },
]
