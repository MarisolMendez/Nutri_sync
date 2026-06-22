import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget reutilizable para grabar una nota de voz corta.
/// Se usa en las cards de "No lo voy a comer, ¿Qué comiste?"
/// como alternativa al campo de texto.
///
/// Devuelve la ruta del archivo grabado via [onRecorded].
/// Si el usuario borra la grabación, llama [onRecorded] con null.
class VoiceNoteRecorder extends StatefulWidget {
  final void Function(String? audioPath) onRecorded;

  const VoiceNoteRecorder({super.key, required this.onRecorded});

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitas dar permiso de micrófono'),
            backgroundColor: NutriColors.error,
          ),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(), path: path);

    setState(() {
      _isRecording = true;
      _audioPath = null;
      _elapsed = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _audioPath = path;
    });

    widget.onRecorded(path);
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null) return;

    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlaying = true);
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  void _deleteRecording() {
    setState(() {
      _audioPath = null;
      _elapsed = Duration.zero;
    });
    widget.onRecorded(null);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Estado: ya hay una grabación guardada — mostrar reproductor
    if (_audioPath != null && !_isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NutriColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NutriColors.border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: NutriColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nota de voz · ${_formatDuration(_elapsed)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: NutriColors.textSecondary),
              onPressed: _deleteRecording,
            ),
          ],
        ),
      );
    }

    // Estado: grabando
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAECE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD85A30)),
        ),
        child: Row(
          children: [
            const _PulsingDot(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Grabando... ${_formatDuration(_elapsed)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF712B13),
                    ),
              ),
            ),
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFD85A30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );
    }

    // Estado inicial: botón para empezar a grabar
    return OutlinedButton.icon(
      onPressed: _startRecording,
      icon: const Icon(Icons.mic_none_outlined, size: 18),
      label: const Text('Grabar nota de voz'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        foregroundColor: NutriColors.textSecondary,
        side: const BorderSide(color: NutriColors.border),
      ),
    );
  }
}

/// Punto rojo pulsante que indica grabación activa
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFFD85A30),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}