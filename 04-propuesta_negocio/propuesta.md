# Propuesta de negocio — CODI-UNCA

## Problema

El productor de limón de la Sierra de Flores Magón decide cuándo vender basándose solo en la experiencia visual y cobra sin dejar un historial útil. Una mala clasificación reduce el precio o provoca devoluciones.

## Usuario

Productor/acopiador de 2 a 100 kg diarios, con teléfono Android y conectividad intermitente. Necesita una herramienta sencilla, local y en español.

## Solución

CODI-UNCA reúne en una sola app:

1. Clasificación de limón con IA local (EfficientNet-B0 → ONNX).
2. Opinión comercial basada en clase, confianza, duda y color.
3. Cobro digital con QR/link de demostración e historial.
4. Asistente en español con conocimiento del dominio.

## Propuesta de valor

- Decide mejor cuándo vender con una segunda opinión, no con una orden.
- Evita el falso negativo: ante duda, pide otra foto.
- Cobrar deja un registro de monto, método y concepto.
- Funciona sin servidor GPU ni servicio externo.

## Modelo de negocio (propuesto, no implementado)

- Suscripción mensual baja para acopiadores.
- Comisión por transacción real una vez se integre un proveedor de pagos autorizado.
- Servicios de capacitación y diagnóstico de calidad para cooperativas.

> En la versión actual los pagos, QR, SPEI/tarjeta y datos bancarios son **simulación local**. No se procesa dinero real.

## Validación y TRL

- TRL declarado: **5** (prototipo validado en entorno relevante, no producto en campo).
- Evidencias: 12/12 casos de app, 596/604 aciertos de visión, asistente 10/10 frente a 1/10 de la línea base.
- Prueba HCI con dos personas ajenas: protocolo listo, pendiente de ejecutar.

## Riesgos y mitigación

| Riesgo | Mitigación |
| --- | --- |
| Fotos con poca luz | Regla de resultado dudoso y nueva captura. |
| Datos bancarios sensibles | Simulación local; nunca CLABE completa en chat. |
| Dependencia de red | Inferencia y asistente locales; historial en el dispositivo. |
| Expectativa de pagos reales | Etiquetado explícito de simulación en la interfaz y documentación. |
