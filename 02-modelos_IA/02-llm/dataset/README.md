# Dataset del asistente

El conocimiento del asistente es un conjunto local de **12 FAQs** en `knowledge_base.json`.

## Temas cubiertos

- Tipos de limón: persa y mexicano.
- Frescura y madurez, incluido `amarillando`.
- Ley de comercio digital.
- CoDi y Cuenta Nivel 2 Bis.
- Cobro SPEI/tarjeta y QR de demostración.
- Datos bancarios simulados y CLABE.
- Opinión comercial: vender, ayudar a vender o no vender.

## Reglas de privacidad

- La CLABE completa **nunca** aparece en el chat.
- Solo se menciona el último tramo de 4 dígitos cuando el usuario pregunta por el estado de sus datos.
- Los datos bancarios son simulación local en SharedPreferences; no se envían a ningún servidor.

## Uso

La base se consulta en `lib/services/knowledge.dart` con coincidencia por palabras clave. Si no hay coincidencia, el asistente responde que no tiene información suficiente en lugar de inventar.
