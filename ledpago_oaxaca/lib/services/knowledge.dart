/// Base de conocimiento local del asistente (funciona sin internet).
/// Más adelante puede sustituirse por RAG sobre el texto completo de la ley.
class _Faq {
  final List<String> keys;
  final String answer;
  const _Faq(this.keys, this.answer);
}

const _faqs = <_Faq>[
  _Faq(['obligatorio', 'obliga', 'obligan', 'tarjeta', 'ley', 'multa', 'castigo'],
      'No. La ley busca promover que más negocios acepten pagos digitales, pero no prohíbe el efectivo. '
      'Si aceptas QR, tus compradores de limón pueden pagarte al instante y empiezas a tener historial.'),
  _Faq(['codi', 'dimo', 'comision', 'comisiones', 'gratis', 'cuesta'],
      'CoDi y DiMo son pagos desde el celular del comprador, a cualquier hora. '
      'Según la información del proyecto, no pagas comisión por recibirlos. '
      'Confirma las condiciones con tu banco.'),
  _Faq(['cuenta', 'nivel', 'bis', 'limite', 'udi', 'udis', 'historial', 'banco'],
      'La Cuenta Nivel 2 Bis es para pequeños comercios. Permite recibir hasta 15,000 UDIs al mes '
      '(unos 130,000 pesos), y al menos 105,000 pesos deben venir de pagos digitales. '
      'Cada venta de limón con QR cuenta. Confirma las reglas vigentes con tu banco o con Banxico.'),
  _Faq(['cobrar', 'cobro', 'qr', 'como', 'comprador', 'cliente', 'acopiador'],
      'Para cobrar: 1) Entra a Cobrar. 2) Escribe el monto. 3) Toca Generar QR. '
      '4) El comprador escanea. 5) Toca Ya me pagaron.'),
  _Faq(['precio', 'precios', 'kilo', 'kilos', 'costal', 'caja', 'bolsa', 'vender'],
      'El precio del limón cambia seguido. En Pedidos, agrega cada producto con su unidad '
      '(kilo, costal, caja o bolsa) y actualiza el precio cuando cambie.'),
  _Faq(['pedido', 'pedidos', 'catalogo', 'producto', 'productos'],
      'En Pedidos agregas tus productos de limón con precio. Cuando alguien te hace un pedido, '
      'eliges cuánto lleva y le muestras el QR para que pague.'),
  _Faq(['fresco', 'fresca', 'calidad', 'color', 'verde', 'amarillo', 'manchas', 'foto', 'camara', 'maduro', 'pasado'],
      'Entra a Calidad y toma una foto del limón sobre un fondo claro y con buena luz. '
      'Te dice si está verde y firme, amarillando o con manchas. Es una guía; la decisión final es tuya.'),
  _Faq(['hola', 'ayuda', 'buenas', 'puedes'],
      'Puedo explicarte cómo cobrar con QR, cómo registrar tus pedidos de limón, '
      'qué es CoDi, la Cuenta Nivel 2 Bis y qué dice la ley de pagos digitales.'),
];

String _norm(String s) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  var out = s.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
}

String answerFor(String question) {
  final words = _norm(question).split(RegExp(r'\s+')).toSet();
  _Faq? best;
  var bestScore = 0;
  for (final f in _faqs) {
    final score = f.keys.where(words.contains).length;
    if (score > bestScore) {
      best = f;
      bestScore = score;
    }
  }
  return best?.answer ??
      'No estoy seguro de eso. Puedes preguntarme cómo cobrar con QR, cómo registrar pedidos de limón, '
      'qué es CoDi o la Cuenta Nivel 2 Bis.';
}
