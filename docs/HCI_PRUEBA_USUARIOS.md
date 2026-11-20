# HCI y experiencia de usuario — CODE UNCA

**Entregable:** definición de usuario/tarea/contexto, flujo, tres decisiones justificadas, corrección humana y protocolo de prueba con dos personas ajenas al equipo (diapositiva 13).

---

## 1. Usuario, tarea y contexto

| Dimensión | Definición |
| --- | --- |
| Usuario principal | Productor o acopiador de limón de la Sierra de Flores Magón, Oaxaca, con ventas diarias de 2 a 100 kg |
| Contexto | Vende en el mercado local o a acopiadores; usa efectivo y transfers; decide la venta observando la fruta |
| Tarea crítica | Decidir si una pieza se vende y cobrarla en el mismo momento, dejando historial digital |
| Limitaciones | Luz variable, fondo irregular, conexión intermitente, poco tiempo y desconfianza hacia QA complejos |
| Resultado deseado | Una respuesta clara, corregible y en español: «sí, véndelo», «no cumple» o «repite la foto» |

---

## 2. Flujo claro de cinco pasos

```
1. Ingreso      → Cobrar: monto y concepto
2. Procesamiento→ Pedidos: producto y cantidad
3. Revisión     → Calidad: foto → clase + confianza + opinión
4. Confirmación → Asistente: opinión comercial y cobro
5. Seguimiento  → Aprender: historial digital y progreso
```

Este flujo evita cambiar de pantalla para cada decisión y permite volver a cualquier paso sin perder el contexto de la última foto.

---

## 3. Tres decisiones de diseño justificadas

| Decisión | Justificación | Cómo se ve en la app |
| --- | --- | --- |
| **Una pantalla por decisión** | Reduce carga cognitiva: cobrar, pedir, revisar calidad y aprender son tareas distintas; agruparlas en un `IndexedStack` evita formularios largos | `NavigationBar` de cinco pestañas en `main.dart` |
| **«Resultado dudoso» en vez de «Sin limón» categórico** | Un falso negativo puede costar una venta; el sistema se abstiene cuando la evidencia es débil o contradictoria | `ModelResult.esDudoso` y sugerencia de repetir foto |
| **Opinión humana corregible** | La IA orienta, pero el productor conoce su lote; la recomendación debe poder contradecirse sin fricción | Panel «Mi opinión» + aviso «Es una segunda opinión. La decisión final es tuya.» |

### Otras decisiones derivadas

- **Voz opcional**: se activa solo si el usuario quiere; el texto siempre está disponible.
- **Datos simulados visibles**: la app advierte que no se escriban datos bancarios reales.
- **Respaldo sin modelo**: si el ONNX no carga, se usa análisis clásico por color.

---

## 4. Revisión y corrección de información

El usuario puede corregir o contradecir al sistema en cuatro puntos:

1. **Repetir la foto** si el resultado es dudoso o la luz fue mala.
2. **Usar el color como segunda opinión**: `amarillando` matiza `verde`; `manchas` puede revertir `maduro`.
3. **Ignorar la recomendación**: el panel lo dice explícitamente; la decisión final es humana.
4. **Corregir datos del negocio** desde «Mi negocio» en Cobrar.

---

## 5. Protocolo de prueba con dos personas ajenas al equipo

> **Estado:** preparado, pendiente de ejecutar. No se han inventado participantes ni observaciones. Completar antes del cierre del hackathon.

### 5.1 Participantes

| Participante | Rol ajeno al equipo | Nombre | Fecha | Firma |
| --- | --- | --- | --- | --- |
| P1 | Compañero/a de otra disciplina, sin acceso al código | ___________________ | __________ | __________ |
| P2 | Productor/a, acopiador/a o persona ajena al equipo | ___________________ | __________ | __________ |

### 5.2 Guion de la sesión (10 minutos por persona)

1. Dar la URL https://code-unna.vercel.app/ sin explicación previa.
2. Pedir que complete: cobrar `180`, crear un pedido de `12.5 kg` y analizar una foto nueva.
3. Preguntar: «¿Vendo este limón y cómo lo ofrezco?».
4. Observar en silencio; solo ayudar si la persona se bloquea más de 60 segundos.
5. Aplicar la escala SUS de 10 preguntas o estas cinco preguntas rápidas:
   - ¿Qué significa «Resultado dudoso»?
   - ¿Qué harías si el asistente dice «No lo vendas aún»?
   - ¿Encontraste fácil cambiar los datos de tu negocio?
   - ¿Qué parte te generó desconfianza?
   - ¿Qué cambiarías antes de usarla mañana?

### 5.3 Formato de registro

| Participante | Tiempo total | Errores observados | Dificultad principal | Mejora propuesta | Prioridad |
| --- | --- | --- | --- | --- | --- |
| P1 | ___ | ___ | ___ | ___ | alta / media / baja |
| P2 | ___ | ___ | ___ | ___ | alta / media / baja |

### 5.4 Mejoras ya identificadas en revisión interna

| Observación | Mejora aplicada |
| --- | --- |
| El modelo podía decir «Sin limón» con probabilidades de fruta altas | Regla de «Resultado dudoso» |
| La opinión comercial no estaba cerca del resultado | Panel «Mi opinión» en Calidad |
| El asistente no sabía de la última foto | Contexto `setLastPhoto` en `AppStore` |
| La CLABE podía aparecer completa en el chat | Solo últimos 4 dígitos |

---

## 6. Cierre

El diseño quedó en **TRL 5**: prototipo probado en entorno relevante con pares y listo para ejecutar la prueba con dos personas ajenas. No se presenta como producto validado en campo.
