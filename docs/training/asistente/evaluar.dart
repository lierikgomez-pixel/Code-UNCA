// Evaluación reproducible del asistente.
// Uso: dart run docs/training/asistente/evaluar.dart
// Compara la respuesta base (sin adaptar) contra el asistente adaptado
// (RAG local + few-shot) en 10 casos reservados. Verifica además consistencia:
// cada pregunta se responde tres veces y se compara la respuesta obtenida.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/services/knowledge.dart';

const base =
    'No estoy seguro de eso. Puedes preguntarme cómo cobrar con QR, cómo registrar pedidos de limón, qué es CoDi o la Cuenta Nivel 2 Bis.';

const casos = <Map<String, String>>[
  {'pregunta': 'Es obligatorio aceptar tarjeta?', 'esperado': 'no prohíbe el efectivo', 'tema': 'Ley y efectivo'},
  {'pregunta': 'Que es CoDi y cuanto cuesta?', 'esperado': 'no pagas comisión', 'tema': 'CoDi'},
  {'pregunta': 'Cuenta Nivel 2 Bis limite de pagos digitales', 'esperado': '105,000', 'tema': 'Cuenta Nivel 2 Bis'},
  {'pregunta': 'Como cobro con QR a mi comprador?', 'esperado': 'Ya me pagaron', 'tema': 'Cobro con QR'},
  {'pregunta': 'Que metodos de pago puedo usar?', 'esperado': 'SPEI', 'tema': 'Métodos de pago'},
  {'pregunta': 'A cuanto vendo el kilo de limon?', 'esperado': 'Pedidos', 'tema': 'Precios y unidades'},
  {'pregunta': 'Como registro un pedido de limon?', 'esperado': 'Pedidos agregas', 'tema': 'Pedidos'},
  {'pregunta': 'Mi limon esta amarillando, sirve?', 'esperado': 'buena luz', 'tema': 'Frescura'},
  {'pregunta': 'Cual es la diferencia entre limon persa y mexicano?', 'esperado': 'Sierra de Flores Magón', 'tema': 'Tipos de limón'},
  {'pregunta': 'Donde agrego mis datos bancarios?', 'esperado': 'configuración de Cobrar', 'tema': 'Datos simulados'},
];

String norm(String s) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  var out = s.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
}

void main() {
  final filas = <Map<String, dynamic>>[];
  var aciertosBase = 0;
  var aciertosAdaptado = 0;
  var consistentes = 0;

  for (final c in casos) {
    final esperado = norm(c['esperado']!);
    final rBase = norm(base).contains(esperado);

    final respuestas = List.generate(3, (_) => answerFor(c['pregunta']!));
    final respuesta = respuestas.first;
    final rAdaptado = norm(respuesta).contains(esperado);
    final estable = respuestas.every((r) => r == respuesta);

    if (rBase) aciertosBase++;
    if (rAdaptado) aciertosAdaptado++;
    if (estable) consistentes++;

    filas.add({
      'tema': c['tema'],
      'pregunta': c['pregunta'],
      'base': rBase ? 'acierto' : 'error',
      'adaptado': rAdaptado ? 'acierto' : 'error',
      'consistente_3_repeticiones': estable,
      'fragmento_respuesta': respuesta.substring(0, respuesta.length > 90 ? 90 : respuesta.length),
    });
  }

  final resultado = <String, dynamic>{
    'enfoque': 'RAG local + prompt engineering con few-shot',
    'total_casos': casos.length,
    'aciertos_base': aciertosBase,
    'aciertos_adaptado': aciertosAdaptado,
    'casos_consistentes': consistentes,
    'casos': filas,
  };

  final json = const JsonEncoder.withIndent('  ').convert(resultado);
  stdout.writeln(json);
  File('docs/training/asistente/resultados_evaluacion.json').writeAsStringSync('$json\n', encoding: utf8);
}
