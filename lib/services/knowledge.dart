/// Base de conocimiento local del asistente (funciona sin internet).
/// Más adelante puede sustituirse por RAG sobre el texto completo de la ley.
class _Faq {
  final List<String> keys;
  final String answer;
  const _Faq(this.keys, this.answer);
}

const _faqs = <_Faq>[
  _Faq(
    ['obligatorio', 'obliga', 'obligan', 'tarjeta', 'ley', 'multa', 'castigo'],
    'No. La ley busca promover que más negocios acepten pagos digitales, pero no prohíbe el efectivo. '
    'Si aceptas QR, tus compradores de limón pueden pagarte al instante y empiezas a tener historial.',
  ),
  _Faq(
    ['codi', 'dimo', 'comision', 'comisiones', 'gratis', 'cuesta'],
    'CoDi y DiMo son pagos desde el celular del comprador, a cualquier hora. '
    'Según la información del proyecto, no pagas comisión por recibirlos. '
    'Confirma las condiciones con tu banco.',
  ),
  _Faq(
    ['cuenta', 'nivel', 'bis', 'limite', 'udi', 'udis', 'historial', 'banco'],
    'La Cuenta Nivel 2 Bis es para pequeños comercios. Permite recibir hasta 15,000 UDIs al mes '
    '(unos 130,000 pesos), y al menos 105,000 pesos deben venir de pagos digitales. '
    'Cada venta de limón con QR cuenta. Confirma las reglas vigentes con tu banco o con Banxico.',
  ),
  _Faq(
    ['cobrar', 'cobro', 'qr', 'como', 'comprador', 'cliente', 'acopiador'],
    'Para cobrar: 1) Entra a Cobrar. 2) Escribe el monto. 3) Toca Generar QR. '
    '4) El comprador escanea. 5) Toca Ya me pagaron.',
  ),
  _Faq(
    [
      'metodo',
      'metodos',
      'pago',
      'pagos',
      'spei',
      'transferencia',
      'link',
      'efectivo',
      'tarjeta',
      'cambio',
    ],
    'En Cobrar eliges cómo te paga el comprador: QR, transferencia SPEI a tu CLABE, link de pago, '
    'tarjeta en tu terminal o efectivo con cálculo de cambio. Todo lo digital cuenta para tu historial.',
  ),
  _Faq(
    ['precio', 'precios', 'kilo', 'kilos', 'costal', 'caja', 'bolsa', 'vender'],
    'El precio del limón cambia seguido. En Pedidos, agrega cada producto con su unidad '
    '(kilo, costal, caja o bolsa) y actualiza el precio cuando cambie.',
  ),
  _Faq(
    ['pedido', 'pedidos', 'catalogo', 'producto', 'productos'],
    'En Pedidos agregas tus productos de limón con precio. Cuando alguien te hace un pedido, '
    'eliges cuánto lleva y le muestras el QR para que pague.',
  ),
  _Faq(
    [
      'fresco',
      'fresca',
      'calidad',
      'color',
      'verde',
      'amarillo',
      'amarillando',
      'limon',
      'limones',
      'manchas',
      'foto',
      'camara',
      'maduro',
      'pasado',
    ],
    'Entra a Calidad y toma una foto del limón sobre un fondo claro y con buena luz. '
    'Te dice si está verde y firme, amarillando o con manchas. Es una guía; la decisión final es tuya.',
  ),
  _Faq(
    [
      'tipo',
      'tipos',
      'variedad',
      'variedades',
      'persa',
      'mexicano',
      'criollo',
      'semilla',
      'jugo',
    ],
    'Los principales son el limón persa y el limón mexicano. El persa es más grande, sin semilla y '
    'muy jugoso; el mexicano es más pequeño, ácido y típico de la Sierra de Flores Magón. '
    'En Pedidos puedes registrar ambos con su precio del día.',
  ),
  _Faq(
    [
      'ley',
      'comercio',
      'digital',
      'pagos digitales',
      'banxico',
      'nivel 2 bis',
      'reglas',
    ],
    'La ley de comercio digital promueve que más negocios acepten pagos digitales, pero no prohíbe '
    'el efectivo. Para pequeños comercios existe la Cuenta Nivel 2 Bis, que te ayuda a construir '
    'historial con cada venta. Confirma montos y reglas vigentes con Banxico o tu banco.',
  ),
  _Faq(
    [
      'banco',
      'clabe',
      'datos',
      'bancarios',
      'titular',
      'agregar',
      'agrego',
      'simulacion',
      'simular',
    ],
    'En CODE UNCA puedes agregar tus datos bancarios como simulación desde el botón de '
    'configuración de Cobrar. Guarda banco, CLABE y titular solo en tu dispositivo. '
    'No escribas datos reales ni los compartas.',
  ),
  _Faq(
    ['hola', 'ayuda', 'buenas', 'puedes'],
    'Puedo explicarte cómo cobrar con QR, cómo registrar tus pedidos de limón, '
    'qué es CoDi, la Cuenta Nivel 2 Bis y qué dice la ley de pagos digitales.',
  ),
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

String answerFor(String question, {String? contexto}) {
  const stopwords = <String>{
    'como',
    'que',
    'el',
    'la',
    'los',
    'las',
    'de',
    'para',
    'es',
    'un',
    'una',
    'por',
    'con',
    'en',
    'y',
    'o',
  };
  final words = _norm(question)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !stopwords.contains(w))
      .toSet();
  _Faq? best;
  var bestScore = 0;
  for (final f in _faqs) {
    final score = f.keys.where(words.contains).length;
    if (score > bestScore) {
      best = f;
      bestScore = score;
    }
  }
  final base =
      best?.answer ??
      'No estoy seguro de eso. Puedes preguntarme cómo cobrar con QR, cómo registrar pedidos de limón, '
          'qué es CoDi o la Cuenta Nivel 2 Bis.';

  final q = _norm(question);
  final pideContexto =
      contexto != null &&
      contexto.isNotEmpty &&
      (q.contains('foto') ||
          q.contains('calidad') ||
          q.contains('resultado') ||
          q.contains('banco') ||
          q.contains('clabe') ||
          q.contains('datos'));
  return pideContexto ? '$contexto $base' : base;
}
