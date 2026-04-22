// display_info_collect_widget.dart
// Widgets du bottom sheet display_info_collect_screen.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../global/app_styles.dart';

// ── Poignée + flèche retour ────────────────────────────────────────────────────

class CollectSheetHeader extends StatelessWidget {
  final String date;

  const CollectSheetHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flèche retour + titre
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:        AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border:       Border.all(color: const Color(0xFF333333)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size:  16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Icon(Icons.article_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Témoignage du $date',
                  style: AppTextStyles.input
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
      ],
    );
  }
}

// ── Ligne d'info questionnaire ─────────────────────────────────────────────────

class CollectInfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const CollectInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label : ',
              style: AppTextStyles.label.copyWith(fontSize: 13)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.input.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Grille de thèmes ───────────────────────────────────────────────────────────

class CollectThemesRow extends StatelessWidget {
  final String themes;

  const CollectThemesRow({super.key, required this.themes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Thèmes', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: themes.split(',').map((t) => Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        AppColors.inputFill,
              borderRadius: BorderRadius.circular(6),
              border:       Border.all(color: const Color(0xFF444444)),
            ),
            child: Text(t.trim(),
                style: AppTextStyles.label.copyWith(fontSize: 12)),
          )).toList(),
        ),
      ],
    );
  }
}

// ── Lecteur audio ──────────────────────────────────────────────────────────────

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();

  PlayerState _playerState = PlayerState.stopped;
  Duration    _duration    = Duration.zero;
  Duration    _position    = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioPath));
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _position = Duration.zero);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        const SizedBox(height: 20),
        Text('Enregistrement audio', style: AppTextStyles.label),
        const SizedBox(height: 16),

        // Barre de progression
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 12),
            trackHeight:        3,
            activeTrackColor:   AppColors.textPrimary,
            inactiveTrackColor: const Color(0xFF333333),
            thumbColor:         AppColors.textPrimary,
          ),
          child: Slider(
            value: _duration.inSeconds > 0
                ? _position.inSeconds
                    .clamp(0, _duration.inSeconds)
                    .toDouble()
                : 0,
            min: 0,
            max: _duration.inSeconds > 0
                ? _duration.inSeconds.toDouble()
                : 1,
            onChanged: (v) async =>
                await _player.seek(Duration(seconds: v.toInt())),
          ),
        ),

        // Temps écoulé / total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_position),
                  style: AppTextStyles.label.copyWith(fontSize: 11)),
              Text(_fmt(_duration),
                  style: AppTextStyles.label.copyWith(fontSize: 11)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Boutons stop + play/pause
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _stop,
              icon:      const Icon(Icons.stop_rounded),
              color:     AppColors.textMuted,
              iconSize:  32,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _playPause,
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary,
                  border: Border.all(color: const Color(0xFF444444)),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.background,
                  size:  36,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── État sans audio ────────────────────────────────────────────────────────────

class NoAudioWidget extends StatelessWidget {
  const NoAudioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_off_outlined,
              size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('Aucun enregistrement audio.',
              style: AppTextStyles.label),
        ],
      ),
    );
  }
}
