// Evidencias ejecutables de la aplicación (casos normales, errores y datos inválidos).
// Uso: dart run docs/evidencias/verificar_app.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/models.dart';
import 'package:flutter_application_1/services/asesor.dart';
import 'package:flutter_application_1/services/knowledge.dart';
import 'package:flutter_application_1/services/modelo.dart';

final casos = <Map<String, dynamic>>[];

void registrar(String id, String nombre, String tipo, dynamic esperado, dynamic obtenido) {
  final ok = esperado.toString() == obtenido.toString();
  casos.add({
    'id': id,
    'caso': nombre,
    'tipo': tipo,
    'esperado': esperado.toString(),
    'obtenido': obtenido.toString(),
    'resultado': ok ? 'paso' : 'fallo',
  });
}

void main() {
  // 1. Caso normal: formato de importe.
  registrar('APP-01', 'Formatear importe de venta', 'normal', r'$180.50', mxn(180.5));

  // 2. Caso normal: total y resumen de pedido.
  final pedido = Order(
    id: 'o1',
    customer: 'Comprador de prueba',
    lines: [
      OrderLine(name: 'Limón persa', unit: 'kg', price: 28, qty: 12.5),
    ],
  );
  registrar('APP-02', 'Calcular total de pedido', 'normal', 350.0, pedido.total);
  registrar('APP-03', 'Resumen de pedido', 'normal', '12.5 kg de Limón persa', pedido.summary);

  // 4. Error: aún no hay foto.
  final sinFoto = evaluarVenta(clase: '', confianza: 0, dudoso: false);
  registrar('APP-04', 'Opinión sin foto', 'error', 'Aún no tengo una foto', sinFoto.titulo);

  // 5. Error controlado: confianza baja se marca como dudoso.
  final baja = ModelResult(
    clase: 'sin_limon',
    confianza: 0.45,
    probabilidades: {
      'maduro': 0.20,
      'podrido': 0.10,
      'sin_limon': 0.45,
      'verde': 0.25,
    },
  );
  registrar('APP-05', 'Confianza baja se abstiene', 'error', 'Resultado dudoso', baja.etiqueta);

  // 6. Dato dudoso: gana sin_limon pero las clases con fruta suman más.
  final falsoNegativo = ModelResult(
    clase: 'sin_limon',
    confianza: 0.70,
    probabilidades: {
      'maduro': 0.40,
      'podrido': 0.05,
      'sin_limon': 0.45,
      'verde': 0.10,
    },
  );
  registrar('APP-06', 'Posible falso negativo de sin_limon', 'dato_invalido', true, falsoNegativo.esDudoso);
  registrar('APP-07', 'Etiqueta de falso negativo', 'dato_invalido', 'Resultado dudoso', falsoNegativo.etiqueta);

  // 7. No cumple para vender.
  final podrido = evaluarVenta(clase: 'podrido', confianza: 0.93, dudoso: false);
  registrar('APP-08', 'Limón dañado', 'normal', 'No cumple para vender', podrido.titulo);

  // 8. Segunda opinión por color: verde amarillando.
  final casi = evaluarVenta(clase: 'verde', confianza: 0.82, dudoso: false, color: 'amarillando');
  registrar('APP-09', 'Verde amarillando', 'normal', 'Casi maduro', casi.titulo);

  // 9. Segunda opinión por color: maduro con manchas.
  final manchado = evaluarVenta(clase: 'maduro', confianza: 0.91, dudoso: false, color: 'con manchas');
  registrar('APP-10', 'Maduro con manchas', 'dato_invalido', 'Revisa antes de vender', manchado.titulo);

  // 10. Confianza intermedia.
  final probable = evaluarVenta(clase: 'maduro', confianza: 0.70, dudoso: false);
  registrar('APP-11', 'Maduro con confianza intermedia', 'normal', 'Probablemente sí, pero revisa', probable.titulo);

  // 11. Pregunta fuera de dominio → respuesta por defecto.
  final fueraDeDominio = answerFor('como esta el clima en marte');
  registrar(
    'APP-12',
    'Pregunta fuera de dominio',
    'error',
    true,
    fueraDeDominio.startsWith('No estoy seguro de eso.'),
  );

  final pasos = casos.where((c) => c['resultado'] == 'paso').length;
  final resultado = <String, dynamic>{
    'total_casos': casos.length,
    'casos_pasados': pasos,
    'casos_fallidos': casos.length - pasos,
    'incluye': ['casos normales', 'errores', 'datos invalidos'],
    'casos': casos,
  };

  final json = const JsonEncoder.withIndent('  ').convert(resultado);
  stdout.writeln(json);
  File('docs/evidencias/resultados_app.json').writeAsStringSync('$json\n', encoding: utf8);
}
