# Flujo de interacción

## Flujo principal

1. **Cobrar:** ver métricas del día, capturar monto y concepto, generar QR/link de demostración y confirmar pago simulado.
2. **Pedidos:** registrar productos, cantidades y precios; calcular totales.
3. **Calidad:** tomar o elegir foto, ver clase, confianza y opinión comercial.
4. **Asistente:** preguntar en texto o voz; escuchar respuesta en `es-MX`.
5. **Aprender:** consultar conceptos de limón, ley de comercio digital y CoDi.

## Decisiones de diseño

| Decisión | Justificación |
| --- | --- |
| Logo junto al título CODI-UNCA en el inicio | Identidad visual clara sin duplicarlo en barras superiores ni en la pestaña del navegador. |
| Botones grandes y contrastados | Uso con manos ocupadas y luz variable. |
| Voz en `es-MX`, velocidad 0.95 | Comprensión local y manejo manos libres. |
| Resultado dudoso | Evita decisiones comerciales erróneas por baja confianza. |
| Corrección humana | El productor siempre puede ignorar la sugerencia. |

## Accesibilidad y errores

- Mensajes concretos cuando no hay foto o el monto es inválido.
- Sin CLABE completa en pantallas de chat.
- Datos bancarios marcados explícitamente como simulación.

Detalle completo: `documentacion_app.md` e `instrucciones.md`.
