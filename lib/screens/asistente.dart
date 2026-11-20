import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/knowledge.dart';
import '../theme.dart';
import '../widgets.dart';

class _Msg {
  final String text;
  final bool mine;
  _Msg(this.text, this.mine);
}

class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});
  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final _tts = FlutterTts();
  final _stt = SpeechToText();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg(
      'Hola, soy tu asistente. Pregúntame cómo cobrar tu limón con QR, qué es CoDi o qué dice la ley.',
      false,
    ),
  ];
  bool _speak = true;
  bool _sttReady = false;
  bool _listening = false;

  static const _sugerencias = <String>[
    '¿Cómo cobro con QR?',
    '¿Es obligatorio aceptar tarjeta?',
    '¿Qué es CoDi?',
    '¿Cómo cuido la calidad?',
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('es-MX');
    _tts.setSpeechRate(0.95);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty) return;
    final a = answerFor(q);
    setState(() {
      _msgs.add(_Msg(q, true));
      _msgs.add(_Msg(a, false));
      _listening = false;
    });
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
    if (_speak) await _tts.speak(a);
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    if (!_sttReady) {
      _sttReady = await _stt.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
      );
    }
    if (!_sttReady) {
      if (mounted) snack(context, 'No se pudo activar el micrófono');
      return;
    }
    await _tts.stop();
    setState(() => _listening = true);
    await _stt.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_MX'),
      onResult: (r) {
        if (r.finalResult) _send(r.recognizedWords);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente'),
        actions: [
          IconButton(
            tooltip: _speak ? 'Silenciar voz' : 'Activar voz',
            icon: Icon(_speak ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() => _speak = !_speak);
              if (!_speak) _tts.stop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                return Align(
                  alignment: m.mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: m.mine ? AppColors.limon : AppColors.panel,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        fontSize: 17,
                        color: m.mine ? AppColors.bosqueProfundo : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final q in _sugerencias)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(q),
                              onPressed: () => _send(q),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton.filled(
                        iconSize: 32,
                        onPressed: _toggleMic,
                        style: IconButton.styleFrom(
                          backgroundColor: _listening
                              ? const Color(0xFFFF8A80)
                              : AppColors.limon,
                          foregroundColor: AppColors.bosqueProfundo,
                        ),
                        icon: Icon(_listening ? Icons.stop : Icons.mic),
                        tooltip: 'Hablar',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _input,
                          decoration: const InputDecoration(
                            hintText: 'O escribe aquí',
                          ),
                          onSubmitted: _send,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _send(_input.text),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
