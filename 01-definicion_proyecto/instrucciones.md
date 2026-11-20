# Instrucciones de uso e instalación — CODI-UNCA

**Entregable:** aplicación funcional e instrucciones; repositorio y dependencias.
**Versión:** 1.0.0+1 · **URL pública:** https://code-unna.vercel.app/

---

## 1. Uso rápido (sin instalación)

1. Abrir https://code-unna.vercel.app/ en Chrome, Edge o Brave.
2. Permitir el micrófono solo si se quiere usar la voz del asistente.
3. Recorrido recomendado (ingreso → procesamiento → revisión → confirmación):

| Paso | Acción | Resultado esperado |
| --- | --- | --- |
| 1 | **Cobrar** → escribir monto y concepto → **Cobrar** → elegir método → confirmar | Nueva venta en «Últimas ventas» y contador actualizado |
| 2 | **Pedidos** → agregar producto → nuevo pedido → **Crear y cobrar** | Pedido pagado + venta generada |
| 3 | **Calidad** → tomar o seleccionar foto | Clase, confianza, probabilidades y panel **Mi opinión** |
| 4 | **Asistente** → escribir o dictar pregunta | Respuesta con contexto de la última foto |
| 5 | **Aprender** → revisar progreso | Pagos digitales, desglose por método y kilos del mes |

---

## 2. Repositorio y dependencias

### 2.1 Repositorios

| Uso | URL |
| --- | --- |
| Código fuente | https://github.com/lierikgomez-pixel/Code-UNCA |
| Despliegue (Vercel) | https://github.com/or-117/code-unna |
| Rama principal | `main` |

### 2.2 Requisitos

- Flutter stable (SDK Dart ^3.13.3; el lock exige Flutter ≥ 3.47.0).
- Para web: navegador con WebAssembly y acceso a `cdn.jsdelivr.net` la primera vez.
- Para entrenamiento: GPU NVIDIA con CUDA 12.1 y PyTorch 2.5.1+cu121.

### 2.3 Instalación local

```bash
git clone https://github.com/lierikgomez-pixel/Code-UNCA.git
cd Code-UNCA
flutter pub get
flutter analyze
flutter run -d chrome
```

### 2.4 Dependencias

| Paquete | Versión | Uso |
| --- | --- | --- |
| `shared_preferences` | ^2.5.6 | Persistencia local |
| `qr_flutter` | ^4.1.0 | QR de demostración |
| `image_picker` | ^1.2.4 | Cámara y galería |
| `image` | ^4.13.1 | Decodificación y resize |
| `flutter_tts` | ^4.2.5 | Voz del asistente |
| `speech_to_text` | ^7.5.0 | Dictado |
| `cupertino_icons` | ^1.0.8 | Iconografía |
| `flutter_lints` | ^6.0.0 | Análisis estático (dev) |

ONNX Runtime no es dependencia Dart: se carga desde CDN en `web/index.html` (`onnxruntime-web@1.23.2`).

### 2.5 Artefactos versionados

- `web/modelo_limon.onnx` y `build/web/modelo_limon.onnx` (idénticos).
- `web/ort_helper.js`: sesión ONNX y predicción.
- `build/web/`: sitio estático servido por Vercel.
- `vercel.json`: `outputDirectory: build/web`, sin comandos de build.

---

## 3. Recorridos detallados

### 3.1 Cobrar

1. En la pantalla **Cobrar**, escribir el monto. Si está vacío o no es válido, la(app no registra la venta.
2. Escribir el concepto (por defecto «Venta de limón»).
3. Tocar **Cobrar** → «¿Cómo te paga?».
4. Elegir:
   - **QR**: mostrar código, pedir al cliente que lo escanee, tocar **Ya me pagaron**.
   - **SPEI**: requiere una CLABE de 18 dígitos configurada; se copia al portapapeles.
   - **Link**: genera un mensaje de ejemplo para WhatsApp/SMS.
   - **Tarjeta**: confirmación manual.
   - **Efectivo**: indica el cambio o el faltante.
5. La venta aparece en «Últimas ventas» y suma a las métricas del día y del mes.

**Datos del negocio** (engrane): nombre, celular o CLABE ligada a CoDi/DiMo y datos bancarios de **simulación local**. No escribir datos reales.

### 3.2 Pedidos

1. Agregar un producto con nombre, precio y unidad (`kg`, `costal`, `caja`, `bolsa`).
2. **Nuevo pedido**: elegir comprador y cantidades (paso 0.5 en kg, 1 en otras unidades, tope 999).
3. **Crear y cobrar {importe}** → method de pago → confirmar.
4. El pedido queda marcado como pagado y genera una venta con nota «Pedido de {comprador}».

### 3.3 Calidad

1. Elegir cámara o galería. La imagen se reduce a 640 px de ancho y calidad 80.
2. La app llama a `predecirModelo`:
   - En web: modelo ONNX en WASM, 224×224, normalización ImageNet, softmax.
   - En móvil/escritorio o si falla la carga: análisis clásico HSV por color.
3. Leer resultado: etiqueta, confianza, probabilidades y consejo.
4. Si aparece **Resultado dudoso**, repetir la foto con el limón centrado y fondo claro.
5. El panel **Mi opinión** indica si se vende, cómo venderlo o si no cumple. La decisión final es humana.

### 3.4 Asistente

1. Escribir una pregunta o tocar el micrófono.
2. Sugerencias útiles:
   - «¿Cómo cobro con QR?», «¿Qué es CoDi?», «¿Es obligatorio aceptar tarjeta?»
   - «¿Qué tipo de limón vendo?», «¿Qué dice la ley de comercio digital?»
   - «¿Qué dice mi última foto?», «¿Vendo este limón?», «¿Cumple para vender?», «Ayúdame a venderlo»
3. Activar/desactivar la voz con **Activar voz** / **Silenciar voz**.
4. Si pregunta por datos bancarios, solo se mencionan los últimos 4 dígitos de la CLABE.

### 3.5 Aprender

Muestra progreso hacia 105 000 MXN digitales mensuales (referencia de Cuenta Nivel 2 Bis), desglose por método y kilos vendidos.

---

## 4. Actualizar el despliegue

```bash
flutter pub get
flutter analyze
flutter build web --release
git add . && git commit -m "Describir el cambio"
git push origin main
git push vercel main
```

Vercel sirve `build/web` sin compilar. Verificar en https://code-unna.vercel.app/.

---

## 5. Funciones simuladas y límites (declaración obligatoria)

| Función | Estado |
| --- | --- |
| QR de cobro | Formato propio `ledpago://cobro`; **no es QR CoDi/DiMo real** |
| Link de pago | Mensaje de ejemplo para WhatsApp/SMS |
| Datos bancarios | Guardados solo en el dispositivo; **no usar datos reales** |
| SPEI | Valida formato de CLABE; no envía transferencia |
| Tarjeta | Confirmación manual; no procesa pagos |
| Asistente legal | Información general; confirmar reglas con Banxico o el banco |
| Modelo en móvil | Respaldo clásico por color; el ONNX corre solo en web |

---

## 6. Solución rápida de problemas

| Síntoma | Acción |
| --- | --- |
| «No se cargó ONNX Runtime Web» | Revisar conexión al CDN y recargar |
| «No se pudo leer la imagen seleccionada» | Repetir la foto con formato compatible |
| Resultado dudoso | Repetir con buena luz y fondo claro |
| Micrófono no responde | Habilitar permiso en el navegador |
| Voz no se escucha | Activar voz y revisar volumen del sistema |
