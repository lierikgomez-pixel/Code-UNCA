@JS('LimonORT')
library;

import 'dart:math' as math;
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'modelo.dart' show ModelResult, clasesModelo;

@JS('init')
external JSPromise<JSAny?> _init();

@JS('predict')
external JSPromise<JSAny?> _predict(JSFloat32Array input);

@JS('status')
external JSAny? _status();

Future<void> _ensureReady() async {
  final status = _status();
  if (status == null) {
    throw StateError(
      'No se cargó ONNX Runtime Web. Verifica tu conexión e intenta de nuevo.',
    );
  }
  await _init().toDart;
}

/// Preprocesa la foto y ejecuta EfficientNet-B0 ONNX dentro del navegador.
///
/// El entrenamiento usó resize directo a 224x224, RGB, normalización ImageNet
/// y formato NCHW. La conversión a Float32List ocurre en Dart; el helper JS
/// solamente crea el tensor y llama a `session.run`.
Future<ModelResult> predecirModelo(Uint8List bytes) async {
  await _ensureReady();

  final original = img.decodeImage(bytes);
  if (original == null) {
    throw StateError('No se pudo leer la imagen seleccionada.');
  }

  final resized = img.copyResize(
    original,
    width: 224,
    height: 224,
    interpolation: img.Interpolation.linear,
  );

  const mean = <double>[0.485, 0.456, 0.406];
  const std = <double>[0.229, 0.224, 0.225];
  final input = Float32List(3 * 224 * 224);
  var offset = 0;

  for (var channel = 0; channel < 3; channel++) {
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        final value = channel == 0
            ? pixel.r
            : channel == 1
                ? pixel.g
                : pixel.b;
        input[offset++] = (value / 255.0 - mean[channel]) / std[channel];
      }
    }
  }

  final output = await _predict(input.toJS).toDart;
  final logits = (output as JSFloat32Array).toDart;
  if (logits.length != clasesModelo.length) {
    throw StateError('Salida inesperada del modelo (${logits.length} clases).');
  }

  var max = double.negativeInfinity;
  var winner = 0;
  for (var i = 0; i < logits.length; i++) {
    if (logits[i] > max) {
      max = logits[i];
      winner = i;
    }
  }
  var sum = 0.0;
  for (final value in logits) {
    sum += math.exp(value - max);
  }

  final probabilidades = <String, double>{
    for (var i = 0; i < clasesModelo.length; i++)
      clasesModelo[i]: math.exp(logits[i] - max) / sum,
  };

  return ModelResult(
    clase: clasesModelo[winner],
    confianza: probabilidades[clasesModelo[winner]]!,
    probabilidades: probabilidades,
  );
}
