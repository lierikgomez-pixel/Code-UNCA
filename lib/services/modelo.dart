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

  /// El modelo no llegó a una conclusión firme.
  ///
  /// Además de la confianza baja, se marca como dudoso el caso en el que gana
  /// `sin_limon` pero la probabilidad de que haya fruta (el resto de clases)
  /// suma más que la de "sin fruta". Evita afirmar que no hay limón cuando el
  /// propio modelo dice lo contrario en conjunto.
  bool get esDudoso {
    if (!desdeModelo) return false;
    final pSinLimon = probabilidades['sin_limon'] ?? 0.0;
    final pConLimon = 1.0 - pSinLimon;
    return confianza < 0.60 || (clase == 'sin_limon' && pConLimon > pSinLimon);
  }

  String get etiqueta {
    if (esDudoso) return 'Resultado dudoso';
    return switch (clase) {
      'maduro' => 'Maduro',
      'podrido' => 'Podrido o dañado',
      'sin_limon' => 'Sin limón',
      'verde' => 'Verde (inmaduro)',
      _ => clase,
    };
  }

  String get consejo {
    if (esDudoso) {
      return 'El modelo no está seguro de que no haya fruta. Repite la foto con el limón centrado y sobre fondo claro.';
    }
    return switch (clase) {
      'maduro' => 'Buen punto de madurez. Prioriza su venta.',
      'podrido' => 'Separa esta pieza y revísala antes de venderla.',
      'sin_limon' => 'No se detectó fruta. Repite la foto sobre fondo claro.',
      'verde' => 'Aún está verde. Déjalo madurar antes de venderlo.',
      _ => 'Revisa la pieza manualmente.',
    };
  }
}

/// Clases en el mismo orden en que fue exportado el modelo.
const List<String> clasesModelo = ['maduro', 'podrido', 'sin_limon', 'verde'];
