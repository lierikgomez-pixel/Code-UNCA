# Documentación de la app — CODI-UNCA

**Versión:** 1.0.0+1
**Plataforma principal:** Flutter Web (también compila para móvil y escritorio)
**URL pública:** https://code-unna.vercel.app/
**Última actualización:** 20 de noviembre de 2026

---

## 1. Qué es CODI-UNCA

**CODI-UNCA — Comercio digital del limón** es una aplicación para productores de limón/lima (*Citrus aurantiifolia*) de **Oaxaca** y la **Sierra de Flores Magón**. Reúne en una sola herramienta:

- Cobro con QR, SPEI, link de pago, tarjeta y efectivo.
- Alta de productos y pedidos por kilo, costal, caja o bolsa.
- Control de calidad por foto con un modelo de IA que corre en el navegador.
- Asistente conversacional con voz que conoce el contexto de la última foto y opina si la fruta se vende.
- Seguimiento del progreso hacia la **Cuenta Nivel 2 Bis**.

La identidad visible es:

| Elemento | Texto |
| --- | --- |
| Título de la app | **CODI-UNCA** |
| Kicker | **OAXACA -SIERRA DE FLORES MAGÓN** |
| Subtítulo | **Comercio digital del limón.** |
| Título del navegador | **CODI-UNCA · Comercio digital del limón** |

> Nota técnica: el nombre del paquete Dart sigue siendo `flutter_application_1` y los bundle ids `com.example.flutterApplication1`. La marca de producto es CODI-UNCA.

---

## 2. Arquitectura general

```
┌──────────────────────────────────────────────────────────┐
│                    main.dart (shell)                      │
│              IndexedStack + NavigationBar                │
└───┬────────┬────────┬────────┬────────┬────────┬──────────┘
    │        │        │        │        │
 Cobrar   Pedidos  Calidad  Asistente  Aprender
    │        │        │        │        │
    └────────┴───┬────┴────────┴────────┘
                │
        AppStore (ChangeNotifier + SharedPreferences)
                │
   ┌────────────┼─────────────┬─────────────┬──────────────┐
   │            │             │             │              │
 modelo.dart  asesor.dart  knowledge.dart  payments.dart  freshness.dart
   │
 modelo_web.dart ──▶ ort_helper.js ──▶ onnxruntime-web (CDN)
                                   ──▶ modelo_limon.onnx (local)
```

- **No hay rutas nombradas**: la navegación es un `IndexedStack` con cinco pestañas.
- **Estado global**: una única instancia `store` de `AppStore` (`ChangeNotifier`) con persistencia offline en `SharedPreferences`.
- **Datos personales**: se guardan solo en el dispositivo; nunca se envían a un servidor.
- **IA local**: en web se usa ONNX Runtime Web (WASM); en móvil/escritorio se usa un analizador clásico de color.

---

## 3. Estructura de archivos

| Ruta | Responsabilidad |
| --- | --- |
| `lib/main.dart` | Entrada, tema, shell de navegación |
| `lib/store.dart` | Estado global y persistencia |
| `lib/models.dart` | `Product`, `Sale`, `Order`, `OrderLine`, formato de pesos |
| `lib/theme.dart` | Paleta (`AppColors`) y `ThemeData` |
| `lib/widgets.dart` | Componentes compartidos y diálogo de QR |
| `lib/payments.dart` | Métodos de cobro y diálogos |
| `lib/screens/cobrar.dart` | Cobro y configuración del negocio |
| `lib/screens/pedidos.dart` | Productos y pedidos |
| `lib/screens/calidad.dart` | Foto, inferencia, resultado y opinión |
| `lib/screens/asistente.dart` | Chat, voz y sugerencias |
| `lib/screens/aprender.dart` | Progreso y consejos |
| `lib/services/modelo.dart` | Contrato del modelo, etiquetas y regla de duda |
| `lib/services/modelo_web.dart` | Preprocesamiento e interop con ORT Web |
| `lib/services/modelo_stub.dart` | Respaldo no web |
| `lib/services/asesor.dart` | Opinión comercial |
| `lib/services/knowledge.dart` | FAQs y respuestas del asistente |
| `lib/services/freshness.dart` | Análisis clásico de color (segunda opinión) |
| `web/index.html` | Título, metadatos y scripts de ORT |
| `web/ort_helper.js` | Sesión ONNX y predicción en JavaScript |
| `web/modelo_limon.onnx` | Modelo servido |
| `vercel.json` | Configuración de despliegue |
| `build/web/` | Artefacto versionado que sirve Vercel |

---

## 4. Pantallas

### 4.1 Cobrar

Pantalla de inicio. Muestra el hero **CODI-UNCA**, métricas del día y las últimas 8 ventas.

- Campo de monto y concepto (por defecto «Venta de limón»).
- Botón **Cobrar** → `startPayment(...)` → confirmación → `store.addSale`.
- Engrane **Mi negocio**: nombre, celular o CLABE ligada a CoDi/DiMo y datos bancarios de **simulación local**.
- Advertencia visible: «Solo demostración. No escribas datos reales.»

### 4.2 Pedidos

- Presets **Limón persa** y **Limón mexicano**, más **+ Otro**.
- Unidades: `kg`, `costal`, `caja`, `bolsa`. Paso de 0.5 para kg y 1 para el resto, tope 999.
- Hoja «Nuevo pedido»: comprador y cantidades → **Crear y cobrar {importe}**.
- Los pedidos impagos muestran botón **Cobrar**; al pagarse `markOrderPaid` crea también una venta.

### 4.3 Calidad

Flujo principal de IA:

1. Botón de cámara o galería (`ImagePicker`, `maxWidth: 640`, `imageQuality: 80`).
2. `predecirModelo(bytes)`:
   - **Web**: carga `modelo_limon.onnx` con ORT Web, redimensiona a 224×224, normaliza con ImageNet, produce logits y aplica softmax.
   - **No web o fallo**: `analyzeFreshness(bytes)` (HSV) como respaldo.
3. Si el resultado es dudoso, muestra **«Resultado dudoso»** en vez de afirmar «Sin limón».
4. Guarda el contexto en `store.setLastPhoto(...)`.
5. Muestra etiqueta, confianza, probabilidades y el panel **«Mi opinión: …»**.

### 4.4 Asistente

- Chat con sugerencias (`ActionChip`) y respuesta por texto o voz.
- Voz: `FlutterTts` en `es-MX`, velocidad 0.95, volumen 1.0, tono 1.0; `SpeechToText` en `es_MX`.
- Botón **Hablar** y toggle **Silenciar voz** / **Activar voz**.
- Diez chips, entre ellos los nuevos:
  - «¿Vendo este limón?»
  - «¿Cumple para vender?»
  - «Ayúdame a venderlo»

### 4.5 Aprender

- Barra de progreso hacia 105 000 MXN digitales mensuales (meta de la Cuenta Nivel 2 Bis; tope de referencia 130 000 MXN ≈ 15 000 UDIs).
- Desglose por método de pago y kilos vendidos del mes.
- Consejos: «La ley no te obliga», «Cobra sin comisión», «Cada venta cuenta», «Vende por kilo, costal o caja», «Pide un taller».

---

## 5. Servicios

### 5.1 `modelo.dart` — contrato del modelo

```dart
export 'modelo_stub.dart' if (dart.library.js_interop) 'modelo_web.dart';
```

- `ModelResult`: `clase`, `confianza`, `probabilidades`, `desdeModelo`.
- `esDudoso`:

```dart
confianza < 0.60 || (clase == 'sin_limon' && (1 - pSinLimon) > pSinLimon)
```

- `etiqueta`: `Resultado dudoso`, `Maduro`, `Podrido o dañado`, `Sin limón`, `Verde (inmaduro)`.
- `clasesModelo`: `['maduro', 'podrido', 'sin_limon', 'verde']` (orden del ONNX).

### 5.2 `modelo_web.dart` — inferencia

1. Decodifica la imagen con `image`.
2. `copyResize` a 224×224 con interpolación lineal.
3. Normalización ImageNet:
   - `mean = [0.485, 0.456, 0.406]`
   - `std  = [0.229, 0.224, 0.225]`
   - layout **NCHW** en `Float32List(3*224*224)`.
4. `LimonORT.predict(input)` devuelve 4 logits.
5. Softmax estable (resta el máximo) → clase ganadora y confianza.

`ort_helper.js` crea la sesión una sola vez con `executionProviders: ['wasm']`, `numThreads: 1` y `wasmPaths` del CDN 1.23.2.

### 5.3 `asesor.dart` — opinión comercial

`evaluarVenta({clase, confianza, dudoso, color})` devuelve un `VeredictoVenta`:

| Situación | Título |
| --- | --- |
| Sin foto | Aún no tengo una foto |
| Dudoso | No lo vendas aún |
| Podrido | No cumple para vender |
| Sin limón | Sin limón detectado |
| Verde + amarillando | Casi maduro |
| Verde | Aún verde |
| Maduro + manchas | Revisa antes de vender |
| Maduro, confianza < 0.75 | Probablemente sí, pero revisa |
| Maduro, confianza alta | Sí, véndelo |

`getter paraChat` concatena título, opinión y ayuda para el chat.

### 5.4 `knowledge.dart` — FAQs

Doce entradas sobre ley de comercio digital, CoDi/DiMo, Cuenta Nivel 2 Bis, QR, comisiones, unidades de venta, pedidos, frescura, tipos de limón y datos bancarios simulados. `answerFor(question, {contexto})` normaliza texto (sin tildes ni ñ), puntúa coincidencias y antepone el contexto de la última foto cuando corresponde.

### 5.5 `freshness.dart` — segunda opinión

`analyzeFreshness(bytes)` reduce a 64 px, calcula HSV y estima:

- `dr >= 0.20` → **Con manchas o dañado** (`pasado`).
- `yr >= 0.25 || dr >= 0.08` → **Amarillando** (`regular`).
- Otro caso → **Verde y firme** (`fresco`).

El texto de color se guarda en `store.lastPhotoColor` y matiza el veredicto comercial.

### 5.6 `payments.dart` — cobros

| Método | Comportamiento |
| --- | --- |
| QR | Muestra el QR generado por `qr_flutter` |
| SPEI | Valida CLABE de 18 dígitos, la copia al portapapeles |
| Link | Genera un mensaje de ejemplo para WhatsApp/SMS |
| Tarjeta | Confirmación manual «Ya cobré» |
| Efectivo | Calcula cambio o muestra «Faltan …» |

`paymentPayload` usa el formato propio `ledpago://cobro?v=1...`; **no es un QR CoDi/DiMo real**.

---

## 6. Estado global (`store.dart`)

`AppStore` persiste con `SharedPreferences`; `_commit()` notifica y guarda sin bloquear la UI.

| Grupo | Campos |
| --- | --- |
| Negocio | `businessName`, `accountRef` |
| Banco (simulación) | `bankName`, `bankClabe`, `bankHolder` |
| Contexto de foto | `lastPhotoClase`, `lastPhotoConfianza`, `lastPhotoDudoso`, `lastPhotoColor` |
| Datos | `products`, `sales`, `orders` |

Agregaciones: `todayTotal`, `todayCount`, `monthDigital`, `monthByMethod`, `monthKg`.

Métodos principales: `load`, `setBusiness`, `setBankData`, `setLastPhoto`, `addProduct`, `removeProduct`, `addSale`, `addOrder`, `markOrderPaid`, `newId`, `paymentPayload`.

**Privacidad:** en el chat solo se mentionan los últimos 4 dígitos de la CLABE.

---

## 7. Flujo completo: foto → opinión → chat

```
Cámara/Galería
   │
   ▼
predecirModelo(bytes) ──(web)──▶ ORT Web ──▶ logits ──▶ softmax
   │
   └──(no web / error)──▶ analyzeFreshness ──▶ verde / maduro / podrido
   │
   ▼
ModelResult ──▶ esDudoso ? "Resultado dudoso" : etiqueta
   │
   ├──▶ store.setLastPhoto(clase, confianza, dudoso, color)
   │
   ├──▶ UI: confianza + probabilidades + panel "Mi opinión"
   │
   └──▶ Asistente:
          ¿Pregunta de venta? ──▶ evaluarVenta(...).paraChat
          Otra pregunta ───────▶ knowledge.answerFor(q, contexto: ...)
```

Ejemplo: si el modelo dice `verde` con 72 % y el analizador clásico dice «amarillando», el veredicto es **«Casi maduro»** y la ayuda recomienda registrarlo en Pedidos y generar el QR al cobrar.

---

## 8. Dependencias

| Paquete | Uso |
| --- | --- |
| `shared_preferences` ^2.5.6 | Persistencia local |
| `qr_flutter` ^4.1.0 | QR de cobro |
| `image_picker` ^1.2.4 | Cámara y galería |
| `image` ^4.13.1 | Decodificación y resize |
| `flutter_tts` ^4.2.5 | Voz en el asistente |
| `speech_to_text` ^7.5.0 | Dictado |
| `cupertino_icons` ^1.0.8 | Iconos |
| `flutter_lints` ^6.0.0 | Análisis estático |

ONNX Runtime **no** es dependencia Dart: se carga desde CDN en `web/index.html`.

---

## 9. Configuración web y despliegue

`vercel.json`:

```json
{
  "outputDirectory": "build/web",
  "buildCommand": "",
  "installCommand": "",
  "framework": null,
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

- Vercel **no compila** Flutter: sirve el artefacto versionado `build/web`.
- `web/index.html` carga `onnxruntime-web@1.23.2` desde jsDelivr y `ort_helper.js`.
- `numThreads = 1` evita la necesidad de headers COOP/COEP.
- Los archivos de `build/` están forzados en Git aunque `.gitignore` los ignore.

### Procedimiento de actualización

```bash
flutter pub get
flutter analyze
flutter build web --release
git add .
git commit -m "Describir el cambio"
git push origin main     # código
git push vercel main    # despliegue
```

---

## 10. Solución de problemas

| Síntoma | Causa probable | Acción |
| --- | --- | --- |
| «No se cargó ONNX Runtime Web» | Sin conexión o CDN bloqueado | Revisar red y recargar |
| «No se pudo leer la imagen seleccionada» | Imagen corrupta o formato no soportado | Repetir la foto |
| **Resultado dudoso** | Confianza < 60 % o `sin_limon` confundido con fruta | Repetir con el limón centrado y fondo claro |
| «Análisis clásico» | El modelo ONNX no está disponible en esa plataforma | Comportamiento esperado en móvil/escritorio |
| «No se pudo activar el micrófono» | Permiso denegado | Habilitar permiso en el navegador |
| Voz no se escucha | Navegador silenciado o TTS sin voces | Activar **Activar voz** y subir volumen |
| Pantalla en blanco tras deploy | `build/web` no actualizado | Recompilar y hacer push a `vercel main` |

---

## 11. Glosario

| Término | Significado |
| --- | --- |
| **Cuenta Nivel 2 Bis** | Cuenta bancaria simplificada; referencia de 15 000 UDIs y 105 000 MXN digitales anuales |
| **CoDi / DiMo** | Sistemas de cobro digital de Banxico |
| **SPEI** | Transferencia electrónica interbancaria |
| **CLABE** | Clave bancaria estandarizada de 18 dígitos |
| **ONNX** | Formato de modelos de aprendizaje automático |
| **ORT Web** | ONNX Runtime en el navegador, usando WASM |
| **Softmax** | Convierte logits en probabilidades que suman 1 |
| **AMP FP16** | Entrenamiento en precisión mixta para aprovechar la GPU |
| **Resultado dudoso** | Estados en que el modelo no afirma una clase con seguridad |

---

## 12. Referencias

- Reporte detallado: `docs/REPORTE_DETALLADO.md`
- README del proyecto: `README.md`
- Notebook de entrenamiento: `control_calidad_limon/control_calidad_limon.ipynb` (fuente local; no incluido en este repositorio)
- Dataset público: `ritikb2211/final-dataset` (Kaggle)
