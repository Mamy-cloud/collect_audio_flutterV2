// transfert_data_to_cloud_screen.dart
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

  bool            _isConnected = false;
  bool            _isLoading   = false;
  TransfertStatus _status      = TransfertStatus.idle;
  String?         _errorMessage;

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
        if (mounted) {
          setState(() => _isConnected = connected);
        }
      },
      onProgress: (done, total) {
        // gardé pour compatibilité, plus affiché
      },
      onItemStatus: (label, status) {
        // gardé pour compatibilité, plus affiché
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _status    = TransfertStatus.done;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _status       = TransfertStatus.error;
            _errorMessage = error;
            _isLoading    = false;
          });
        }
      },
    );

    _transfertService.startListening();
  }

  Future<void> _checkConnectivity() async {
    final connected = await TransfertDataToCloudDb.isConnected();
    if (mounted) {
      setState(() => _isConnected = connected);
    }
  }

  Future<void> _startTransfert() async {
    if (!_isConnected || _isLoading) return;

    setState(() {
      _status       = TransfertStatus.transferring;
      _isLoading    = true;
      _errorMessage = null;
    });

    // Lance en arrière-plan — bouton désactivé jusqu'à onComplete/onError
    _transfertService.transferAll();
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
            TransfertAnimationWidget(status: _status),

            const SizedBox(height: 32),

            // ── Message d'erreur ───────────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE53935).withValues(alpha: 0.4),
                  ),
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
                          fontSize: 12,
                          color: const Color(0xFFE57373),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Bouton transfert ───────────────────────────────────────────
            TransfertButton(
              isLoading: _isLoading,
              onPressed: _isConnected && !_isLoading
                  ? _startTransfert
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
