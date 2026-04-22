// audio_record.dart — VERSION ANDROID/iOS
// Utilise le package 'record' pour l'enregistrement avec choix du micro
// Sauvegarde la durée d'enregistrement en secondes

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/global/app_styles.dart';

class AudioRecordSheet extends StatefulWidget {
  // onSave retourne le chemin ET la durée en secondes
  final void Function(String audioPath, int dureeSecondes) onSave;
  const AudioRecordSheet({super.key, required this.onSave});

  @override
  State<AudioRecordSheet> createState() => _AudioRecordSheetState();
}

class _AudioRecordSheetState extends State<AudioRecordSheet> {
  _Status              _status       = _Status.idle;
  Duration             _elapsed      = Duration.zero;
  Timer?               _timer;
  String?              _finalPath;
  final AudioRecorder  _recorder     = AudioRecorder();

  List<InputDevice> _devices        = [];
  InputDevice?      _selectedDevice;
  bool              _loadingDevices = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      await Permission.microphone.request();
      final devices = await _recorder.listInputDevices();
      if (mounted) {
        setState(() {
          _devices        = devices;
          _selectedDevice = devices.isNotEmpty ? devices.first : null;
          _loadingDevices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDevices = false);
    }
  }

  Future<String> _newPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path,
        'temoignage_${DateTime.now().millisecondsSinceEpoch}.m4a');
  }

  Future<void> _startRecording() async {
    _elapsed   = Duration.zero;
    _finalPath = await _newPath();

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        device:  _selectedDevice,
      ),
      path: _finalPath!,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _status = _Status.recording);
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    await _recorder.pause();
    setState(() => _status = _Status.paused);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _status = _Status.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorder.stop();
    setState(() => _status = _Status.done);
  }

  void _saveTestimony() {
    if (_finalPath != null) {
      // Envoie chemin + durée en secondes
      widget.onSave(_finalPath!, _elapsed.inSeconds);
      Navigator.of(context).pop();
    }
  }

  void _reset() {
    _timer?.cancel();
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
    _recorder.dispose();
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
          const SizedBox(height: 24),

          _Magnetophone(status: _status, elapsedLabel: _elapsedLabel),

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

  Widget _buildDeviceSelector() {
    if (_loadingDevices) {
      return const SizedBox(
        height: 40,
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
              child: DropdownButton<InputDevice>(
                value:         _selectedDevice,
                dropdownColor: AppColors.inputFill,
                style:         AppTextStyles.input.copyWith(fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textMuted, size: 18),
                isExpanded: true,
                items: _devices.map((d) => DropdownMenuItem<InputDevice>(
                  value: d,
                  child: Row(
                    children: [
                      Icon(
                        d.label.toLowerCase().contains('usb')
                            ? Icons.usb_outlined
                            : Icons.mic_outlined,
                        size:  14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(d.label,
                            overflow: TextOverflow.ellipsis),
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

// ── Magnétophone visuel ────────────────────────────────────────────────────────

class _Magnetophone extends StatelessWidget {
  final _Status status;
  final String  elapsedLabel;
  const _Magnetophone({required this.status, required this.elapsedLabel});

  @override
  Widget build(BuildContext context) {
    final isRecording = status == _Status.recording;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935).withValues(alpha: 0.15),
                  ),
                ),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? const Color(0xFFE53935).withValues(alpha: 0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: isRecording
                        ? const Color(0xFFE53935)
                        : const Color(0xFF444444),
                  ),
                ),
                child: Icon(Icons.mic, size: 30,
                    color: isRecording
                        ? const Color(0xFFE53935)
                        : AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(elapsedLabel,
              style: const TextStyle(
                fontSize:     36,
                fontWeight:   FontWeight.w300,
                color:        AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 8),
          Text(_statusLabel(status),
              style: TextStyle(fontSize: 12,
                  color: isRecording
                      ? const Color(0xFFE53935)
                      : AppColors.textMuted)),
        ],
      ),
    );
  }

  String _statusLabel(_Status s) {
    switch (s) {
      case _Status.idle:      return 'Prêt à enregistrer';
      case _Status.recording: return '● Enregistrement en cours';
      case _Status.paused:    return 'En pause';
      case _Status.done:      return 'Enregistrement terminé';
    }
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
