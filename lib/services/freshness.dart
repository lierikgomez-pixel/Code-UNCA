import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum Freshness { fresco, regular, pasado }

class FreshnessResult {
  final Freshness level;
  final double yellowRatio;
  final double damagedRatio;
  const FreshnessResult(this.level, this.yellowRatio, this.damagedRatio);

  String get label => switch (level) {
        Freshness.fresco => 'Verde y firme',
        Freshness.regular => 'Amarillando',
        Freshness.pasado => 'Con manchas o dañado',
      };

  String get advice => switch (level) {
        Freshness.fresco => 'Buen color. Ideal para vender a precio completo.',
        Freshness.regular => 'Ya está más maduro y dura menos. Véndelo primero.',
        Freshness.pasado => 'Sepáralo y revisa pieza por pieza antes de venderlo.',
      };
}

/// Clasificador de limón SIN modelo de IA: mide qué porción de la foto es
/// amarilla (maduro) u oscura/café (manchas, daño). Es un sustituto temporal
/// para probar el flujo. Para producción, reemplaza el cuerpo por un modelo
/// TFLite entrenado con fotos de limón (ver README).
/// Debe ser función de nivel superior para poder usarla con compute().
FreshnessResult analyzeFreshness(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('No se pudo leer la imagen');
  final small = img.copyResize(decoded, width: 64);

  var yellow = 0;
  var damaged = 0;
  var total = 0;
  for (var y = 0; y < small.height; y++) {
    for (var x = 0; x < small.width; x++) {
      final p = small.getPixel(x, y);
      final r = p.r / 255, g = p.g / 255, b = p.b / 255;
      final mx = math.max(r, math.max(g, b));
      final mn = math.min(r, math.min(g, b));
      final d = mx - mn;
      final s = mx == 0 ? 0.0 : d / mx;
      double h = 0;
      if (d != 0) {
        if (mx == r) {
          h = 60 * (((g - b) / d) % 6);
        } else if (mx == g) {
          h = 60 * ((b - r) / d + 2);
        } else {
          h = 60 * ((r - g) / d + 4);
        }
      }
      final oscuro = mx < 0.22;
      final cafe = h >= 10 && h <= 45 && s > 0.35 && mx < 0.55;
      final amarillo = h > 45 && h <= 70 && s > 0.4 && mx > 0.5;
      if (oscuro || cafe) {
        damaged++;
      } else if (amarillo) {
        yellow++;
      }
      total++;
    }
  }
  final yr = total == 0 ? 0.0 : yellow / total;
  final dr = total == 0 ? 0.0 : damaged / total;
  final level = dr >= 0.20
      ? Freshness.pasado
      : (yr >= 0.25 || dr >= 0.08)
          ? Freshness.regular
          : Freshness.fresco;
  return FreshnessResult(level, yr, dr);
}
