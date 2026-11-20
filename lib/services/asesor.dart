/// Opinión comercial basada en el resultado de Calidad.
///
/// No sustituye la revisión visual del productor: es una guía rápida para
/// decidir si un limón se ofrece, se aparta o se vuelve a fotografiar.
class VeredictoVenta {
  final String titulo;
  final String opinion;
  final String ayuda;
  final bool vendible;
  final bool dudoso;

  const VeredictoVenta({
    required this.titulo,
    required this.opinion,
    required this.ayuda,
    required this.vendible,
    required this.dudoso,
  });

  /// Texto listo para el chat, con la ayuda para venderlo incluida.
  String get paraChat => '$titulo. $opinion $ayuda';
}

/// Sugerencia de venta que no depende del tipo de limón.
String ayudaVender() =>
    'Para venderlo mejor: regístralo en Pedidos con el precio del día, genera un QR en Cobrar '
    'para que te paguen al instante y destaca que está limpio y revisado. Si es persa, menciona '
    'que es jugoso y sin semilla; si es mexicano, menciona su acidez típica de la Sierra.';

VeredictoVenta evaluarVenta({
  required String clase,
  required double confianza,
  required bool dudoso,
  String? color,
}) {
  final pct = (confianza * 100).round();

  if (clase.isEmpty) {
    return VeredictoVenta(
      titulo: 'Aún no tengo una foto',
      opinion:
          'Entra a Calidad y toma una foto del limón sobre fondo claro. '
          'Con esa imagen te doy mi opinión.',
      ayuda: ayudaVender(),
      vendible: false,
      dudoso: true,
    );
  }

  if (dudoso) {
    return VeredictoVenta(
      titulo: 'No lo vendas aún',
      opinion:
          'La foto salió dudosa ($pct% de confianza). No me atrevo a aprobarlo '
          'ni a descartarlo todavía.',
      ayuda:
          'Repite la foto con buena luz y el limón centrado. ${ayudaVender()}',
      vendible: false,
      dudoso: true,
    );
  }

  if (clase == 'podrido') {
    return VeredictoVenta(
      titulo: 'No cumple para vender',
      opinion:
          'El modelo lo ve dañado, así que no lo pongas a la venta. Sepáralo '
          'del lote y revísalo antes de desecharlo.',
      ayuda: 'Vende solo las piezas sanas. ${ayudaVender()}',
      vendible: false,
      dudoso: false,
    );
  }

  if (clase == 'sin_limon') {
    return VeredictoVenta(
      titulo: 'Sin limón detectado',
      opinion: 'No veo fruta en la foto, así que no puedo darte una opinión de venta.',
      ayuda: 'Repite la foto con el limón centrado. ${ayudaVender()}',
      vendible: false,
      dudoso: true,
    );
  }

  if (clase == 'verde') {
    final madurando = color != null && color.contains('amarillando');
    return VeredictoVenta(
      titulo: madurando ? 'Casi maduro' : 'Aún verde',
      opinion: madurando
          ? 'El modelo lo ve verde, pero el color ya empieza a amarillear. '
                'Déjalo uno o dos días más antes de venderlo como maduro.'
          : 'El modelo lo ve verde. No lo vendas como maduro todavía; déjalo madurar.',
      ayuda:
          'Cuando esté amarillo, regístralo en Pedidos y cobra con QR. ${ayudaVender()}',
      vendible: false,
      dudoso: false,
    );
  }

  // clase == 'maduro'
  final colorDudoso = color != null && color.contains('manchas');
  if (colorDudoso) {
    return VeredictoVenta(
      titulo: 'Revisa antes de vender',
      opinion:
          'El modelo lo ve maduro, pero el color sugiere manchas o daño. '
          'No lo aprobaría para venta sin revisarlo bien.',
      ayuda: 'Separa las piezas con manchas y repite la foto. ${ayudaVender()}',
      vendible: false,
      dudoso: true,
    );
  }

  if (confianza < 0.75) {
    return VeredictoVenta(
      titulo: 'Probablemente sí, pero revisa',
      opinion:
          'El modelo lo ve maduro con $pct% de confianza. Yo lo vendería, '
          'pero confirmando que no tenga golpes ni manchas.',
      ayuda: ayudaVender(),
      vendible: true,
      dudoso: false,
    );
  }

  return VeredictoVenta(
    titulo: 'Sí, véndelo',
    opinion:
        'Mi opinión: está en buen punto de madurez ($pct% de confianza) '
        'y cumple para ofrecerlo.',
    ayuda: ayudaVender(),
    vendible: true,
    dudoso: false,
  );
}
