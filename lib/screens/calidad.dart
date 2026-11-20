import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/freshness.dart'
    show Freshness, FreshnessResult, analyzeFreshness;
import '../services/modelo.dart' show ModelResult, predecirModelo;
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class CalidadScreen extends StatefulWidget {
  const CalidadScreen({super.key});
  @override
  State<CalidadScreen> createState() => _CalidadScreenState();
}

class _CalidadScreenState extends State<CalidadScreen> {
  Uint8List? _bytes;
  ModelResult? _result;
  bool _busy = false;

  Future<void> _capture(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _bytes = bytes;
        _result = null;
        _busy = true;
      });

      ModelResult result;
      try {
        result = await predecirModelo(bytes);
      } catch (_) {
        // Si el modelo no está disponible (móvil, sin conexión o fallo de carga),
        // se mantiene el analizador clásico para no dejar la función vacía.
        result = _resultadoClasico(analyzeFreshness(bytes));
      }

      store.setLastPhoto(
        clase: result.clase,
        confianza: result.confianza,
        dudoso: result.esDudoso,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      snack(context, 'No se pudo analizar la foto');
    }
  }

  ModelResult _resultadoClasico(FreshnessResult classic) {
    final clase = switch (classic.level) {
      Freshness.fresco => 'verde',
      Freshness.regular => 'maduro',
      Freshness.pasado => 'podrido',
    };
    return ModelResult(
      clase: clase,
      confianza: 0,
      probabilidades: const {},
      desdeModelo: false,
    );
  }

  Color _color(ModelResult r) => r.esDudoso
      ? const Color(0xFFFFD54F)
      : switch (r.clase) {
          'verde' => AppColors.menta,
          'maduro' => AppColors.limon,
          'podrido' => const Color(0xFFFF8A80),
          _ => Colors.white70,
        };

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final classic = _bytes == null ? null : analyzeFreshness(_bytes!);
    return Scaffold(
      appBar: AppBar(title: const Text('Calidad del limón')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Toma la foto con buena luz y sobre un fondo claro. El análisis se hace con el modelo entrenado directamente en tu navegador.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          PillButton(
            label: 'Tomar foto',
            icon: Icons.photo_camera,
            filled: true,
            onPressed: _busy ? null : () => _capture(ImageSource.camera),
          ),
          const SizedBox(height: 10),
          PillButton(
            label: 'Elegir de la galería',
            icon: Icons.photo_library_outlined,
            onPressed: _busy ? null : () => _capture(ImageSource.gallery),
          ),
          const SizedBox(height: 16),
          if (_bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.memory(
                _bytes!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (r != null) ...[
            const SizedBox(height: 16),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.etiqueta,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _color(r),
                          ),
                        ),
                      ),
                      if (r.desdeModelo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.hoja,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'IA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.consejo, style: const TextStyle(fontSize: 17)),
                  if (r.desdeModelo) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Confianza: ${(r.confianza * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final entry in r.probabilidades.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Análisis clásico (modelo no disponible en este dispositivo).',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                  if (r.esDudoso && classic != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Sugerencia por color: ${switch (classic.level) {
                          Freshness.fresco => 'verde y firme',
                          Freshness.regular => 'amarillando',
                          Freshness.pasado => 'con manchas o daño',
                        }}. Repite la foto con mejor luz.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Es una segunda opinión. La decisión final es tuya.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
