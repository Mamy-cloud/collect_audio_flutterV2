// audio_record.dart — VERSION ANDROID/iOS
// flutter_sound pour l'enregistrement
// Waveform basé sur la vraie amplitude du microphone

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

class _AudioRecordSheetState extends State<AudioRecordSheet> {
  _Status                    _status       = _Status.idle;
  Duration                   _elapsed      = Duration.zero;
  Timer?                     _timer;
  String?                    _finalPath;
  final FlutterSoundRecorder _recorder     = FlutterSoundRecorder();
  bool                       _recorderOpen = false;

  // ── Waveform ──────────────────────────────────────────────────────────────
  final List<double> _waveData = [];
  double             _lastAmp  = 0.0;
  StreamSubscription? _recorderSub;

  // ── Calibration dynamique ─────────────────────────────────────────────────
  double _minDbObserved = 0.0;
  double _maxDbObserved = 0.0;
  bool   _calibrated    = false;

  // ── DEBUG ─────────────────────────────────────────────────────────────────
  double? _debugRawDb;
  double  _debugNormalized = 0.0;
  double  _debugSmoothed   = 0.0;
  int     _debugEventCount = 0;
  String  _debugStatus     = 'En attente...';

  // ── Appareils audio ────────────────────────────────────────────────────────
  List<AudioDevice> _devices       = [];
  AudioDevice?      _selectedDevice;
  bool              _loadingDevices = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _startAmplitudeListener() {
    _recorderSub = _recorder.onProgress!.listen((event) {
      if (!mounted) return;

      _debugEventCount++;
      final rawDb = event.decibels;

      setState(() {
        _debugRawDb  = rawDb;
        _debugStatus = rawDb == null ? '⚠️ NULL' : '✅ OK';
      });

      if (rawDb == null) return;

      final db = rawDb.toDouble();

      // ── Calibration dynamique ─────────────────────────────────────────
      if (!_calibrated) {
        _minDbObserved = db;
        _maxDbObserved = db;
        _calibrated    = true;
      } else {
        if (db < _minDbObserved) _minDbObserved = db;
        if (db > _maxDbObserved) _maxDbObserved = db;
      }

      final range          = (_maxDbObserved - _minDbObserved).abs();
      final effectiveRange = range < 15.0 ? 15.0 : range;

      // ── Normalise depuis le MAX vers le bas ───────────────────────────
      // Le silence est proche du max observé en idle
      // La voix pousse vers le haut → écart par rapport au max
      // On inverse : silence = bas de plage, voix = haut de plage
      final effectiveMax = _maxDbObserved;
      final effectiveMin = effectiveMax - effectiveRange;

      double normalized = ((db - effectiveMin) / effectiveRange).clamp(0.0, 1.0);

      // ── Seuil silence : silence mesuré à 0.59 → coupe à 0.62 ────────
      if (normalized < 0.62) {
        final smoothed = _lastAmp * 0.08;
        _lastAmp = smoothed;
        setState(() {
          _waveData.add(smoothed);
          _debugNormalized = 0.0;
          _debugSmoothed   = smoothed;
        });
        return;
      }

      // ── Remappe 0.62..1.0 → 0.0..1.0 ────────────────────────────────
      normalized = ((normalized - 0.62) / 0.38).clamp(0.0, 1.0);

      // ── Zone morte résiduelle ─────────────────────────────────────────
      if (normalized < 0.05) normalized = 0.0;

      // ── Boost voix ────────────────────────────────────────────────────
      if (normalized > 0.0) {
        normalized = pow(normalized, 0.5).toDouble();
      }

      // ── Lissage asymétrique ───────────────────────────────────────────
      final double alpha    = normalized > _lastAmp ? 0.8 : 0.15;
      final double smoothed = _lastAmp * (1 - alpha) + normalized * alpha;

      _lastAmp = smoothed;
      setState(() {
        _waveData.add(smoothed);
        _debugNormalized = normalized;
        _debugSmoothed   = smoothed;
      });
    });
  }

  void _stopAmplitudeListener() {
    _recorderSub?.cancel();
    _recorderSub = null;
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
      await _recorder.setSubscriptionDuration(
        const Duration(milliseconds: 80),
      );
      _recorderOpen = true;
    }
  }

  Future<String> _newPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
      dir.path,
      'temoignage_${DateTime.now().millisecondsSinceEpoch}.aac',
    );
  }

  Future<void> _startRecording() async {
    await _openRecorder();
    _elapsed       = Duration.zero;
    _lastAmp       = 0.0;
    _calibrated    = false;
    _minDbObserved = 0.0;
    _maxDbObserved = 0.0;
    _waveData.clear();
    _finalPath = await _newPath();

    await _recorder.startRecorder(
      toFile:      _finalPath,
      codec:       Codec.aacADTS,
      bitRate:     128000,
      numChannels: 1,
      sampleRate:  44100,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    _startAmplitudeListener();
    setState(() => _status = _Status.recording);
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    _stopAmplitudeListener();
    await _recorder.pauseRecorder();
    setState(() => _status = _Status.paused);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resumeRecorder();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    _startAmplitudeListener();
    setState(() => _status = _Status.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _stopAmplitudeListener();
    await _recorder.stopRecorder();
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
    _stopAmplitudeListener();
    if (_finalPath != null) {
      try { File(_finalPath!).deleteSync(); } catch (_) {}
    }
    _lastAmp    = 0.0;
    _calibrated = false;
    setState(() {
      _status          = _Status.idle;
      _elapsed         = Duration.zero;
      _finalPath       = null;
      _debugRawDb      = null;
      _debugNormalized = 0.0;
      _debugSmoothed   = 0.0;
      _debugEventCount = 0;
      _debugStatus     = 'En attente...';
      _waveData.clear();
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
    _stopAmplitudeListener();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Témoignage oral',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 20),
            _buildDeviceSelector(),
            const SizedBox(height: 20),
            _buildMagnetophone(),
            const SizedBox(height: 12),
            _buildDebugPanel(),
            const SizedBox(height: 24),

            if (_status == _Status.idle)
              _CtrlButton(
                icon:  Icons.fiber_manual_record,
                label: "Démarrer l'enregistrement",
                color: const Color(0xFFE53935),
                onTap: _startRecording,
              ),

            if (_status == _Status.recording) ...[
              _CtrlButton(
                icon:  Icons.pause,
                label: 'Pause',
                color: AppColors.textMuted,
                onTap: _pauseRecording,
              ),
              const SizedBox(height: 12),
              _CtrlButton(
                icon:  Icons.stop,
                label: 'Arrêter',
                color: const Color(0xFFE53935),
                onTap: _stopRecording,
              ),
            ],

            if (_status == _Status.paused) ...[
              _CtrlButton(
                icon:  Icons.play_arrow,
                label: 'Reprendre',
                color: AppColors.textPrimary,
                onTap: _resumeRecording,
              ),
              const SizedBox(height: 12),
              _CtrlButton(
                icon:  Icons.stop,
                label: 'Arrêter',
                color: const Color(0xFFE53935),
                onTap: _stopRecording,
              ),
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
                icon:  const Icon(Icons.refresh, size: 16, color: AppColors.textMuted),
                label: const Text(
                  'Recommencer',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report, size: 14, color: Color(0xFF58A6FF)),
              SizedBox(width: 6),
              Text('DEBUG — Amplitude micro',
                style: TextStyle(fontSize: 11, color: Color(0xFF58A6FF),
                    fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _debugRow('Status',       _debugStatus),
          _debugRow('Events reçus', '$_debugEventCount'),
          _debugRow('Raw dB',
            _debugRawDb == null ? 'null ⚠️' : _debugRawDb!.toStringAsFixed(2)),
          _debugRow('Min dB obs.',  _calibrated ? _minDbObserved.toStringAsFixed(2) : '-'),
          _debugRow('Max dB obs.',  _calibrated ? _maxDbObserved.toStringAsFixed(2) : '-'),
          _debugRow('Normalized',   _debugNormalized.toStringAsFixed(3)),
          _debugRow('Smoothed',     _debugSmoothed.toStringAsFixed(3)),
          _debugRow('Bars total',   '${_waveData.length}'),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value:           _debugSmoothed.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF21262D),
              valueColor:      AlwaysStoppedAnimation<Color>(
                _debugSmoothed > 0.01
                    ? const Color(0xFF3FB950)
                    : const Color(0xFF30363D),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E))),
          Text(value,
            style: const TextStyle(fontSize: 11, color: Color(0xFFE6EDF3),
                fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildMagnetophone() {
    final isRecording = _status == _Status.recording;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: ClipRect(
              child: CustomPaint(
                painter: _WaveformPainter(
                  waveData:    _waveData,
                  isRecording: isRecording,
                  isPaused:    _status == _Status.paused,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _elapsedLabel,
            style: const TextStyle(
              fontSize: 36, fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935), shape: BoxShape.circle,
                  ),
                ),
              Text(
                _statusLabel(_status),
                style: TextStyle(
                  fontSize: 12,
                  color: isRecording ? const Color(0xFFE53935) : AppColors.textMuted,
                ),
              ),
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
        child: Center(child: SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
        )),
      );
    }
    if (_devices.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_outlined, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AudioDevice>(
                value: _selectedDevice,
                dropdownColor: AppColors.inputFill,
                style: AppTextStyles.input.copyWith(fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
                isExpanded: true,
                items: _devices.map((d) => DropdownMenuItem<AudioDevice>(
                  value: d,
                  child: Row(children: [
                    Icon(
                      d.isUsb ? Icons.usb_outlined
                          : d.isBluetooth ? Icons.bluetooth_outlined
                          : Icons.mic_outlined,
                      size: 14, color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(d.name, overflow: TextOverflow.ellipsis)),
                  ]),
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

// ── Waveform Painter ──────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  final List<double> waveData;
  final bool         isRecording;
  final bool         isPaused;

  const _WaveformPainter({
    required this.waveData,
    required this.isRecording,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const barGap   = 2.0;
    const barStep  = barWidth + barGap;
    final centerY  = size.height / 2;
    final maxBars  = (size.width / barStep).floor();

    canvas.drawLine(
      Offset(0, centerY), Offset(size.width, centerY),
      Paint()..color = const Color(0xFF2A2A2A)..strokeWidth = 1,
    );

    if (waveData.isEmpty) return;

    final visible = waveData.length > maxBars
        ? waveData.sublist(waveData.length - maxBars) : waveData;

    final pastPaint = Paint()
      ..color = isRecording
          ? const Color(0xFFE53935).withValues(alpha: 0.45)
          : isPaused ? const Color(0xFFE53935).withValues(alpha: 0.25)
          : const Color(0xFF555555)
      ..strokeWidth = barWidth..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = isRecording ? const Color(0xFFE53935)
          : isPaused ? const Color(0xFFE53935).withValues(alpha: 0.6)
          : const Color(0xFF777777)
      ..strokeWidth = barWidth..strokeCap = StrokeCap.round;

    final futurePaint = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..strokeWidth = barWidth..strokeCap = StrokeCap.round;

    for (int i = 0; i < visible.length; i++) {
      final amp  = visible[i];
      final barH = amp < 0.01 ? 1.5 : max(2.0, amp * size.height * 0.9);
      final xPos = i * barStep + barWidth / 2;
      canvas.drawLine(
        Offset(xPos, centerY - barH / 2),
        Offset(xPos, centerY + barH / 2),
        i == visible.length - 1 ? activePaint : pastPaint,
      );
    }

    for (int i = visible.length; i < maxBars; i++) {
      final xPos = i * barStep + barWidth / 2;
      canvas.drawLine(
        Offset(xPos, centerY - 2), Offset(xPos, centerY + 2), futurePaint,
      );
    }

    if (isRecording || isPaused) {
      final cx = (visible.length * barStep).clamp(0.0, size.width).toDouble();
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height),
        Paint()..color = const Color(0xFFFF5252)..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.waveData.length != waveData.length ||
      old.isRecording != isRecording || old.isPaused != isPaused;
}

// ── Waveform statique pour la lecture ─────────────────────────────────────────

class WaveformDisplay extends StatelessWidget {
  final List<double> waveData;
  final double       progress;
  final bool         isPlaying;

  const WaveformDisplay({
    super.key, required this.waveData,
    required this.progress, required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: _WaveformPlaybackPainter(
          waveData: waveData, progress: progress, isPlaying: isPlaying,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WaveformPlaybackPainter extends CustomPainter {
  final List<double> waveData;
  final double       progress;
  final bool         isPlaying;

  const _WaveformPlaybackPainter({
    required this.waveData, required this.progress, required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 2.0;
    const barGap   = 1.0;
    const barStep  = barWidth + barGap;
    final maxBars  = (size.width / barStep).floor();
    final centerY  = size.height / 2;

    final data = waveData.isNotEmpty ? waveData
        : List.generate(maxBars, (i) {
            final x = i / maxBars;
            return 0.3 + 0.5 * sin(x * pi * 6) * sin(x * pi);
          });

    final visible   = data.length > maxBars ? data.sublist(0, maxBars) : data;
    final progressX = size.width * progress;

    for (int i = 0; i < visible.length; i++) {
      final x    = i * barStep + barWidth / 2;
      final amp  = visible[i];
      final barH = amp < 0.01 ? 1.5 : max(2.0, amp * size.height * 0.9);
      canvas.drawLine(
        Offset(x, centerY - barH / 2), Offset(x, centerY + barH / 2),
        Paint()
          ..color = x <= progressX ? const Color(0xFFE53935) : const Color(0xFF444444)
          ..strokeWidth = barWidth..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPlaybackPainter old) =>
      old.progress != progress || old.isPlaying != isPlaying ||
      old.waveData.length != waveData.length;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

enum _Status { idle, recording, paused, done }
