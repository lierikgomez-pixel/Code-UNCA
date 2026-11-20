export 'modelo_stub.dart' if (dart.library.js_interop) 'modelo_web.dart';

/// Resultado de la clasificación con el modelo EfficientNet-B0 exportado a ONNX.
class ModelResult {
  /// Etiqueta del dataset: maduro, podrido, sin_limon o verde.
  final String clase;

  /// Confianza de la clase ganadora (0..1, tras softmax).
  final double confianza;

  /// Probabilidades por clase (0..1).
  final Map<String, double> probabilidades;

  /// true cuando lo predijo el modelo; false cuando se usó el método clásico.
  final bool desdeModelo;

  const ModelResult({
    required this.clase,
    required this.confianza,
    required this.probabilidades,
    this.desdeModelo = true,
  });

  String get etiqueta => switch (clase) {
        'maduro' => 'Maduro',
        'podrido' => 'Podrido o dañado',
        'sin_limon' => 'Sin limón',
        'verde' => 'Verde (inmaduro)',
        _ => clase,
      };

  String get consejo => switch (clase) {
        'maduro' => 'Buen punto de madurez. Prioriza su venta.',
        'podrido' => 'Separa esta pieza y revísala antes de venderla.',
        'sin_limon' => 'No se detectó fruta. Repite la foto sobre fondo claro.',
        'verde' => 'Aún está verde. Déjalo madurar antes de venderlo.',
        _ => 'Revisa la pieza manualmente.',
      };
}

/// Clases en el mismo orden en que fue exportado el modelo.
const List<String> clasesModelo = ['maduro', 'podrido', 'sin_limon', 'verde'];
