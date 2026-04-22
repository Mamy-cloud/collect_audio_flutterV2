import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/conserve_data/conserve_data_to_sqlite.dart';
import '../database/update_delete/modify_info_temoin.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/formulaire_creer_temoin_widgets.dart';
import '../widgets/screens_widgets/rgpd_widget.dart';
import 'signature_screen.dart';

class FormulaireCreerTemoinScreen extends StatefulWidget {
  final Map<String, dynamic>? temoin;
  const FormulaireCreerTemoinScreen({super.key, this.temoin});

  @override
  State<FormulaireCreerTemoinScreen> createState() =>
      _FormulaireCreerTemoinScreenState();
}

class _FormulaireCreerTemoinScreenState
    extends State<FormulaireCreerTemoinScreen> {
  final _nomCtrl    = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _dateCtrl   = TextEditingController();

  String? _deptId;
  String? _regionId;
  String? _deptNom;
  String? _regionNom;
  String? _imgPath;
  bool    _isLoading  = false;
  bool    _accepteRgpd = false;
  String? _signatureUrl;
  List<Map<String, String>> _contacts = [];

  bool get _isEditMode => widget.temoin != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.temoin!;
      _nomCtrl.text    = t['nom']            as String? ?? '';
      _prenomCtrl.text = t['prenom']         as String? ?? '';
      _dateCtrl.text   = t['date_naissance'] as String? ?? '';
      final deptNom    = t['departement']    as String?;
      final regionNom  = t['region']         as String?;
      _deptNom         = deptNom;
      _regionNom       = regionNom;
      _deptId = deptNom != null
          ? kDepartements.firstWhere(
              (d) => d['nom'] == deptNom,
              orElse: () => {'id': deptNom},
            )['id'] as String?
          : null;
      _regionId = regionNom != null
          ? kRegions.firstWhere(
              (r) => r['nom'] == regionNom,
              orElse: () => {'id': regionNom},
            )['id'] as String?
          : null;
      _imgPath      = t['img_temoin']   as String?;
      _signatureUrl = t['signature_url'] as String?;
      _accepteRgpd  = (t['accepte_rgpd'] as int? ?? 0) == 1;

      try {
        final raw = t['contacts'];
        if (raw is List) {
          _contacts = raw.map((c) =>
              Map<String, String>.from(c as Map)).toList();
        } else if (raw is String) {
          final decoded = jsonDecode(raw) as List;
          _contacts = decoded.map((c) =>
              Map<String, String>.from(c as Map)).toList();
        }
      } catch (_) {
        _contacts = [];
      }
    }
  }

  void _onDeptChanged(String? id) {
    final nom = id != null
        ? kDepartements.firstWhere(
            (d) => d['id'] == id,
            orElse: () => {'nom': id},
          )['nom'] as String?
        : null;
    setState(() {
      _deptId    = id;
      _deptNom   = nom;
      _regionId  = null;
      _regionNom = null;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context:     context,
      initialDate: DateTime(1950),
      firstDate:   DateTime(1900),
      lastDate:    DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      _dateCtrl.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickImage() async {
    await Permission.photos.request();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) setState(() => _imgPath = picked.path);
  }

  Future<void> _takePhoto() async {
    await Permission.camera.request();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (picked != null && mounted) setState(() => _imgPath = picked.path);
  }

  void _removeImage() => setState(() => _imgPath = null);

  Future<void> _submit() async {
    final nom    = _nomCtrl.text.trim();
    final prenom = _prenomCtrl.text.trim();

    if (nom.isEmpty || prenom.isEmpty) {
      _snack('Nom et prénom obligatoires'); return;
    }
    if (_deptId == null) {
      _snack('Sélectionnez un département'); return;
    }
    if (_regionId == null) {
      _snack('Sélectionnez une région'); return;
    }
    if (!_accepteRgpd) {
      _snack('Le témoin doit accepter la politique RGPD'); return;
    }
    if (_signatureUrl == null) {
      _snack('La signature du témoin est requise'); return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        await ModifyInfoTemoin.update(
          id:            widget.temoin!['id'] as String,
          nom:           nom,
          prenom:        prenom,
          dateNaissance: _dateCtrl.text.trim().isEmpty
                             ? null : _dateCtrl.text.trim(),
          departement:   _deptNom,
          region:        _regionNom,
          imgTemoin:     _imgPath,
          contacts:      _contacts,
          signatureUrl:  _signatureUrl,
          accepteRgpd:   _accepteRgpd,
        );
      } else {
        await ConserveDataToSqlite.insertInfoPersoTemoin(
          nom:           nom,
          prenom:        prenom,
          dateNaissance: _dateCtrl.text.trim().isEmpty
                             ? null : _dateCtrl.text.trim(),
          departement:   _deptNom,
          region:        _regionNom,
          imgTemoinPath: _imgPath,
          contacts:      _contacts,
          signatureUrl:  _signatureUrl,
          accepteRgpd:   _accepteRgpd,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      context.go('/notification_add_temoin', extra: {
        'success': true,
        'message': null,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      context.go('/notification_add_temoin', extra: {
        'success': false,
        'message': e.toString(),
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.surface,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:         const BorderSide(color: Colors.white24),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Center(
              child: Container(
                width: 40, height: 4,
                margin:     const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color:        Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              _isEditMode ? 'Modifier le témoin' : 'Créer un témoin',
              style: const TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w700,
                color:      AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            _imgPath == null
                ? _buildImagePicker(context)
                : _buildImagePreview(context),

            const SizedBox(height: 14),

            FormulaireTextField(
              controller: _nomCtrl, label: 'Nom *', hint: 'ex. Ferracci'),
            const SizedBox(height: 14),

            FormulaireTextField(
              controller: _prenomCtrl, label: 'Prénom *', hint: 'ex. Maria'),
            const SizedBox(height: 14),

            FormulaireTextField(
              controller: _dateCtrl,
              label:      'Date de naissance',
              hint:       'Sélectionner',
              readOnly:   true,
              onTap:      _pickDate,
              suffix: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.textMuted, size: 18),
            ),
            const SizedBox(height: 14),

            DepartementDropdown(value: _deptId, onChanged: _onDeptChanged),
            const SizedBox(height: 14),

            RegionDropdown(
              value:         _regionId,
              departementId: _deptId,
              onChanged:     (v) {
                final nom = v != null
                    ? kRegions.firstWhere(
                        (r) => r['id'] == v,
                        orElse: () => {'nom': v},
                      )['nom'] as String?
                    : null;
                setState(() { _regionId = v; _regionNom = nom; });
              },
            ),
            const SizedBox(height: 14),

            ContactsField(
              contacts:  _contacts,
              onChanged: (updated) => setState(() => _contacts = updated),
            ),

            const SizedBox(height: 24),

            // ── RGPD ─────────────────────────────────────────────────────
            RgpdCheckbox(
              accepted:  _accepteRgpd,
              onChanged: (v) => setState(() => _accepteRgpd = v ?? false),
            ),

            const SizedBox(height: 14),

            // ── Signature ─────────────────────────────────────────────────
            _SignatureButton(
              signatureUrl: _signatureUrl,
              onTap: () => showModalBottomSheet(
                context:            context,
                isScrollControlled: true,
                backgroundColor:    Colors.transparent,
                builder: (_) => SignatureScreen(
                  onSave: (path) =>
                      setState(() => _signatureUrl = path),
                ),
              ),
              onRemove: () => setState(() => _signatureUrl = null),
            ),

            const SizedBox(height: 28),

            AjouterTemoinButton(
              onPressed: _submit,
              isLoading: _isLoading,
              label:     _isEditMode ? 'Enregistrer les modifications' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final zoneHeight = MediaQuery.of(context).size.height * 0.20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prendre une photo ou télécharger une image',
          style: TextStyle(
            fontSize:      12,
            fontWeight:    FontWeight.w500,
            color:         AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: zoneHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _imgBtn(
                icon: Icons.camera_alt_outlined, label: 'Caméra',
                onPressed: _takePhoto)),
              const SizedBox(width: 12),
              Expanded(child: _imgBtn(
                icon: Icons.photo_library_outlined, label: 'Galerie',
                onPressed: _pickImage)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imgBtn({
    required IconData icon, required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        side:    const BorderSide(color: Color(0xFF333333)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon:  Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final zoneHeight = MediaQuery.of(context).size.height * 0.20;
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(_imgPath!),
            height: zoneHeight, width: double.infinity, fit: BoxFit.cover),
      ),
      Positioned(
        top: 6, right: 6,
        child: GestureDetector(
          onTap: _removeImage,
          child: Container(
            padding:    const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _dateCtrl.dispose();
    super.dispose();
  }
}

// ── Bouton / aperçu signature ──────────────────────────────────────────────────

class _SignatureButton extends StatelessWidget {
  final String?      signatureUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SignatureButton({
    required this.signatureUrl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Signature du témoin *', style: AppTextStyles.label),
            const SizedBox(width: 8),
            if (signatureUrl != null)
              const Icon(Icons.check_circle_outline,
                  size: 14, color: Color(0xFF4CAF50)),
          ],
        ),
        const SizedBox(height: 8),

        if (signatureUrl == null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width:  double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color:        AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.draw_outlined,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text('Appuyez pour signer',
                      style: AppTextStyles.label.copyWith(fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              Container(
                height: 100, width: double.infinity,
                decoration: BoxDecoration(
                  color:        AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF4CAF50), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(signatureUrl!), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
              Positioned(
                bottom: 4, left: 4,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:        Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Modifier',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
