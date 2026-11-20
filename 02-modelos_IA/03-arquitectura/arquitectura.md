# Arquitectura de CODI-UNCA

## Vista general

```text
Usuario (productor/acopiador)
        │
        ▼
Flutter Web (UI + estado local)
        │
 ├── Cobro / pedidos / historial ──► SharedPreferences (offline-first)
 ├── Calidad ──► cámara/galería ──► preprocesamiento Dart ──► ONNX Runtime Web (WASM)
 │                                   │
 │                                   ▼
 │                            modelo_limon.onnx (local)
 │
 └── Asistente ──► knowledge.dart (RAG local + few-shot)
                    │
                    ▼
             asesor.dart (opinión comercial) + voz es-MX
```

## Decisiones técnicas

| Decisión | Justificación |
| --- | --- |
| Inferencia local en el navegador | No requiere servidor GPU ni API remota; funciona con conectividad limitada. |
| ONNX Runtime Web 1.23.2, WASM, 1 hilo | Compatible con Flutter Web; evita dependencias de GPU en el cliente. |
| Resultado dudoso | Evita clasificar como «Sin limón» cuando hay fruta parcial o confianza baja. |
| RAG local + few-shot | Trazable, sin servicios externos y suficiente para 12 FAQs. |
| SharedPreferences | Historial y datos de demostración sin backend. |
| CLABE nunca en chat | Solo últimos 4 dígitos; datos bancarios son simulación local. |

## Artefactos del modelo

- `web/modelo_limon.onnx` — hash SHA-256 `E243791EFA3755440B6FAD171DEEA67AD85915E33C940B3E79B26EA2EA72F810`.
- Entrada: `images` `[1,3,224,224]`.
- Salida: `logits`.

## Despliegue

Vercel sirve directamente `build/web` con `buildCommand` e `installCommand` vacíos. `vercel.json` contiene la configuración y el rewrite a `index.html`.
