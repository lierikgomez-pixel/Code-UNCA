import 'dart:typed_data';

import 'modelo.dart' show ModelResult;

/// En móvil/escritorio se mantiene el analizador clásico existente.
/// La integración del modelo ONNX está disponible solamente en Flutter Web.
Future<ModelResult> predecirModelo(Uint8List bytes) async {
  throw UnsupportedError(
    'El modelo ONNX sólo está disponible en la versión web de la aplicación.',
  );
}
