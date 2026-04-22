// signature_screen.dart
// Écran de signature manuscrite — stocké en image PNG.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:signature/signature.dart';
import '../../widgets/global/app_styles.dart';

class SignatureScreen extends StatefulWidget {
  final void Function(String signaturePath) onSave;

  const SignatureScreen({super.key, required this.onSave});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2.5,
    penColor:       Colors.white,
    exportBackgroundColor: Colors.black,
  );

  bool _isSaving = false;

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) {
      _snack('Veuillez signer avant de valider');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Uint8List? imageData = await _controller.toPngBytes();
      if (imageData == null) throw Exception('Impossible de générer la signature');

      final dir  = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path,
          'signature_${DateTime.now().millisecondsSinceEpoch}.png');

      await File(path).writeAsBytes(imageData);

      if (!mounted) return;
      widget.onSave(path);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _snack('Erreur : ${e.toString()}');
      }
    }
  }

  void _clear() => _controller.clear();

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.surface,
      behavior:        SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color:        Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ── Titre ─────────────────────────────────────────────────────────
          const Text(
            'Signature du témoin',
            style: TextStyle(
              fontSize:   17,
              fontWeight: FontWeight.w700,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Signez dans la zone ci-dessous',
            style: AppTextStyles.label.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ── Zone de signature ─────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:        AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: const Color(0xFF333333)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller:  _controller,
                  backgroundColor: AppColors.inputFill,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Boutons ───────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: Color(0xFF333333)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon:  const Icon(Icons.refresh, size: 18),
                  label: const Text('Effacer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSignature,
                  style: AppButtonStyle.primary,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.check, size: 18),
                  label: Text(_isSaving ? 'Sauvegarde...' : 'Valider la signature'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
