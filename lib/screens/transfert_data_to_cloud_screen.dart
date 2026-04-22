// transfert_data_to_cloud_screen.dart
// Écran de transfert des données vers le cloud

import 'package:flutter/material.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/transfert_data_to_cloud_widget.dart';
import '../database/transfert/transfert_data_to_cloud_db.dart';

class TransfertDataToCloudScreen extends StatefulWidget {
  const TransfertDataToCloudScreen({super.key});

  @override
  State<TransfertDataToCloudScreen> createState() =>
      _TransfertDataToCloudScreenState();
}

class _TransfertDataToCloudScreenState
    extends State<TransfertDataToCloudScreen> {

  bool             _isConnected  = false;
  TransfertStatus  _status       = TransfertStatus.idle;
  int              _total        = 0;
  int              _transferred  = 0;
  String?          _errorMessage;

  // Liste des items avec leur statut individuel
  final List<Map<String, dynamic>> _items = [];

  late TransfertDataToCloudDb _transfertService;

  @override
  void initState() {
    super.initState();
    _initService();
    _checkConnectivity();
  }

  void _initService() {
    _transfertService = TransfertDataToCloudDb(
      onConnectivityChanged: (connected) {
        if (mounted) setState(() => _isConnected = connected);
      },
      onProgress: (done, total) {
        if (mounted) setState(() {
          _transferred = done;
          _total       = total;
        });
      },
      onItemStatus: (label, status) {
        if (!mounted) return;
        setState(() {
          final idx = _items.indexWhere((i) => i['label'] == label);
          if (idx >= 0) {
            _items[idx]['status'] = _parseItemStatus(status);
          } else {
            _items.add({
              'label':    label,
              'subLabel': _subLabelFromStatus(status),
              'status':   _parseItemStatus(status),
            });
          }
          // Met à jour le sous-label
          final i = _items.indexWhere((i) => i['label'] == label);
          if (i >= 0) {
            _items[i]['subLabel'] = _subLabelFromStatus(status);
          }
        });
      },
      onComplete: () {
        if (mounted) setState(() => _status = TransfertStatus.done);
      },
      onError: (error) {
        if (mounted) setState(() {
          _status       = TransfertStatus.error;
          _errorMessage = error;
        });
      },
    );

    _transfertService.startListening();
  }

  Future<void> _checkConnectivity() async {
    final connected = await TransfertDataToCloudDb.isConnected();
    if (mounted) setState(() => _isConnected = connected);
  }

  Future<void> _startTransfert() async {
    if (!_isConnected) {
      _showSnack('Pas de connexion Internet disponible.');
      return;
    }

    setState(() {
      _status      = TransfertStatus.transferring;
      _transferred = 0;
      _total       = 0;
      _items.clear();
      _errorMessage = null;
    });

    await _transfertService.transferAll();
  }

  void _showSnack(String msg) {
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

  ItemTransfertStatus _parseItemStatus(String s) {
    switch (s) {
      case 'uploading': return ItemTransfertStatus.uploading;
      case 'done':      return ItemTransfertStatus.done;
      case 'error':     return ItemTransfertStatus.error;
      default:          return ItemTransfertStatus.waiting;
    }
  }

  String _subLabelFromStatus(String s) {
    switch (s) {
      case 'uploading': return 'Envoi en cours...';
      case 'done':      return 'Synchronisé avec succès';
      case 'error':     return 'Échec de l\'envoi';
      default:          return 'En attente';
    }
  }

  @override
  void dispose() {
    _transfertService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Synchronisation Cloud',
          style: TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Statut connexion ───────────────────────────────────────────
            ConnexionStatusWidget(isConnected: _isConnected),

            const SizedBox(height: 40),

            // ── Animation centrale ─────────────────────────────────────────
            TransfertAnimationWidget(
              status:      _status,
              total:       _total,
              transferred: _transferred,
            ),

            const SizedBox(height: 32),

            // ── Message d'erreur ───────────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:        const Color(0xFFB71C1C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: Color(0xFFE53935)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.label.copyWith(
                            fontSize: 12, color: const Color(0xFFE57373)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Bouton transfert ───────────────────────────────────────────
            TransfertButton(
              isLoading: _status == TransfertStatus.transferring,
              onPressed: _isConnected &&
                      _status != TransfertStatus.transferring
                  ? _startTransfert
                  : null,
            ),

            const SizedBox(height: 32),

            // ── Liste des items transférés ─────────────────────────────────
            if (_items.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Détail du transfert',
                  style: AppTextStyles.label.copyWith(
                    fontSize:      12,
                    letterSpacing: 0.8,
                    fontWeight:    FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._items.map((item) => TransfertItemCard(
                label:    item['label'] as String,
                subLabel: item['subLabel'] as String,
                status:   item['status'] as ItemTransfertStatus,
              )),
            ],
          ],
        ),
      ),
    );
  }
}
