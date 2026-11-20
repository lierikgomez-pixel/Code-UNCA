import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/freshness.dart';
import '../theme.dart';
import '../widgets.dart';

class CalidadScreen extends StatefulWidget {
  const CalidadScreen({super.key});
  @override
  State<CalidadScreen> createState() => _CalidadScreenState();
}

class _CalidadScreenState extends State<CalidadScreen> {
  Uint8List? _bytes;
  FreshnessResult? _result;
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
      final r = await compute(analyzeFreshness, bytes);
      if (!mounted) return;
      setState(() {
        _result = r;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      snack(context, 'No se pudo analizar la foto');
    }
  }

  Color _color(Freshness f) => switch (f) {
    Freshness.fresco => AppColors.menta,
    Freshness.regular => AppColors.limon,
    Freshness.pasado => const Color(0xFFFF8A80),
  };

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Calidad del limón')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Toma la foto con buena luz y sobre un fondo claro. Funciona sin internet.',
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
                  Text(
                    r.label,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _color(r.level),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(r.advice, style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 12),
                  const Text(
                    'Es una segunda opinión aproximada. La decisión final es tuya.',
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
