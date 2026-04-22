// audio_record.dart — VERSION ANDROID/iOS
// flutter_sound pour l'enregistrement
// Kotlin platform channel pour le choix du micro
// Ondes sonores animées style magnétophone

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_device_service.dart';
import '../widgets/global/app_styles.dart';

class AudioRecordSheet extends StatefulWidget {
  final void Function(String audioPath, int dureeSecondes) onSave;
  const AudioRecordSheet({super.key, required this.onSave});

  @override
  State<AudioRecordSheet> createState() => _AudioRecordSheetState();
}

class _AudioRecordSheetState extends State<AudioRecordSheet>
    with TickerProviderStateMixin {
  _Status               _status       = _Status.idle;
  Duration              _elapsed      = Duration.zero;
  Timer?                _timer;
  String?               _finalPath;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool                  _recorderOpen = false;

  // ── Ondes sonores ──────────────────────────────────────────────────────────
  late AnimationController _waveController;
  final List<double>       _waveBars = List.filled(28, 0.15);
  Timer?                   _waveTimer;
  final _random = Random();

  // ── Appareils audio ────────────────────────────────────────────────────────
  List<AudioDevice> _devices       = [];
  AudioDevice?      _selectedDevice;
  bool              _loadingDevices = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadDevices();
  }

  void _startWaveAnimation() {
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _waveBars.length; i++) {
          _waveBars[i] = 0.1 + _random.nextDouble() * 0.9;
        }
      });
    });
  }

  void _stopWaveAnimation() {
    _waveTimer?.cancel();
    if (mounted) {
      setState(() {
        for (int i = 0; i < _waveBars.length; i++) {
          _waveBars[i] = 0.15;
        }
      });
    }
  }

  void _pauseWaveAnimation() {
    _waveTimer?.cancel();
    if (mounted) {
      setState(() {
        for (int i = 0; i < _waveBars.length; i++) {
          final center = _waveBars.length / 2;
          final dist   = (i - center).abs() / center;
          _waveBars[i] = 0.15 + (1 - dist) * 0.3;
        }
      });
    }
  }

  Future<void> _loadDevices() async {
    final devices = await AudioDeviceService.getInputDevices();
    if (mounted) {
      setState(() {
        _devices        = devices;
        _selectedDevice = devices.isNotEmpty ? devices.first : null;
        _loadingDevices = false;
      });
    }
  }

  Future<void> _openRecorder() async {
    if (!_recorderOpen) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) throw Exception('Permission microphone refusée');
      await _recorder.openRecorder();
      _recorderOpen = true;
    }
  }

  Future<String> _newPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path,
        'temoignage_${DateTime.now().millisecondsSinceEpoch}.aac');
  }

  Future<void> _startRecording() async {
    await _openRecorder();
    _elapsed   = Duration.zero;
    _finalPath = await _newPath();

    await _recorder.startRecorder(
      toFile: _finalPath,
      codec:  Codec.aacADTS,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    _startWaveAnimation();
    setState(() => _status = _Status.recording);
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    await _recorder.pauseRecorder();
    _pauseWaveAnimation();
    setState(() => _status = _Status.paused);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resumeRecorder();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    _startWaveAnimation();
    setState(() => _status = _Status.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorder.stopRecorder();
    _stopWaveAnimation();
    setState(() => _status = _Status.done);
  }

  void _saveTestimony() {
    if (_finalPath != null) {
      widget.onSave(_finalPath!, _elapsed.inSeconds);
      Navigator.of(context).pop();
    }
  }

  void _reset() {
    _timer?.cancel();
    _stopWaveAnimation();
    if (_finalPath != null) {
      try { File(_finalPath!).deleteSync(); } catch (_) {}
    }
    setState(() {
      _status    = _Status.idle;
      _elapsed   = Duration.zero;
      _finalPath = null;
    });
  }

  String get _elapsedLabel {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _waveController.dispose();
    if (_recorderOpen) _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          const Text('Témoignage oral',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),

          const SizedBox(height: 20),

          _buildDeviceSelector(),

          const SizedBox(height: 20),

          _buildMagnetophone(),

          const SizedBox(height: 24),

          if (_status == _Status.idle)
            _CtrlButton(
              icon:  Icons.fiber_manual_record,
              label: "Démarrer l'enregistrement",
              color: const Color(0xFFE53935),
              onTap: _startRecording,
            ),

          if (_status == _Status.recording) ...[
            _CtrlButton(icon: Icons.pause, label: 'Pause',
                color: AppColors.textMuted, onTap: _pauseRecording),
            const SizedBox(height: 12),
            _CtrlButton(icon: Icons.stop, label: 'Arrêter',
                color: const Color(0xFFE53935), onTap: _stopRecording),
          ],

          if (_status == _Status.paused) ...[
            _CtrlButton(icon: Icons.play_arrow, label: 'Reprendre',
                color: AppColors.textPrimary, onTap: _resumeRecording),
            const SizedBox(height: 12),
            _CtrlButton(icon: Icons.stop, label: 'Arrêter',
                color: const Color(0xFFE53935), onTap: _stopRecording),
          ],

          if (_status == _Status.done) ...[
            _CtrlButton(
              icon:   Icons.save_alt,
              label:  'Enregistrer le témoignage',
              color:  AppColors.textPrimary,
              onTap:  _saveTestimony,
              filled: true,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _reset,
              icon:  const Icon(Icons.refresh, size: 16,
                  color: AppColors.textMuted),
              label: const Text('Recommencer',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMagnetophone() {
    final isRecording = _status == _Status.recording;
    final isPaused    = _status == _Status.paused;
    final isDone      = _status == _Status.done;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          // ── Ondes sonores ────────────────────────────────────────────────
          SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_waveBars.length, (i) {
                final barColor = isRecording
                    ? const Color(0xFFE53935)
                    : isPaused
                        ? const Color(0xFFE53935).withOpacity(0.4)
                        : isDone
                            ? AppColors.textMuted.withOpacity(0.6)
                            : AppColors.textMuted.withOpacity(0.3);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width:  3,
                  height: 56 * _waveBars[i],
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color:        barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // ── Timer ────────────────────────────────────────────────────────
          Text(_elapsedLabel,
              style: const TextStyle(
                fontSize:     36,
                fontWeight:   FontWeight.w300,
                color:        AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              )),

          const SizedBox(height: 8),

          // ── Statut ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935), shape: BoxShape.circle),
                ),
              Text(_statusLabel(_status),
                  style: TextStyle(
                    fontSize: 12,
                    color: isRecording
                        ? const Color(0xFFE53935)
                        : AppColors.textMuted,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(_Status s) {
    switch (s) {
      case _Status.idle:      return 'Prêt à enregistrer';
      case _Status.recording: return 'Enregistrement en cours';
      case _Status.paused:    return 'En pause';
      case _Status.done:      return 'Enregistrement terminé';
    }
  }

  Widget _buildDeviceSelector() {
    if (_loadingDevices) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.textMuted),
          ),
        ),
      );
    }

    if (_devices.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_outlined, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AudioDevice>(
                value:         _selectedDevice,
                dropdownColor: AppColors.inputFill,
                style:         AppTextStyles.input.copyWith(fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textMuted, size: 18),
                isExpanded: true,
                items: _devices.map((d) => DropdownMenuItem<AudioDevice>(
                  value: d,
                  child: Row(
                    children: [
                      Icon(
                        d.isUsb
                            ? Icons.usb_outlined
                            : d.isBluetooth
                                ? Icons.bluetooth_outlined
                                : Icons.mic_outlined,
                        size:  14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(d.name, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                )).toList(),
                onChanged: _status == _Status.idle
                    ? (d) => setState(() => _selectedDevice = d)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtrlButton extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final VoidCallback onTap; final bool filled;
  const _CtrlButton({
    required this.icon, required this.label,
    required this.color, required this.onTap, this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? color : Colors.transparent,
          foregroundColor: filled ? AppColors.background : color,
          side: BorderSide(color: filled ? color : const Color(0xFF444444)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        icon:  Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

enum _Status { idle, recording, paused, done }
