import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/create_table/create_table_temoin.dart';
import '../services/session_service.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifiantCtrl = TextEditingController();
  final _codeCtrl        = TextEditingController();
  bool  _isLoading       = false;

  Future<void> _onLogin() async {
    final identifiant = _identifiantCtrl.text.trim();
    final password    = _codeCtrl.text.trim();

    if (identifiant.isEmpty || password.isEmpty) {
      _snack('Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    // Vérifie les identifiants en DB
    final user = await CreateTableTemoin.login(identifiant, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      _snack('Identifiant ou code d\'accès incorrect');
      return;
    }

    // Sauvegarde la session en mémoire
    SessionService.login(
      user['id'] as String,
      user['identifiant'] as String,
    );

    context.go('/list_temoin');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 40),
                  const Center(child: LoginTitle()),
                  const SizedBox(height: 20),
                  const LoginHeroImage(assetPath: 'assets/img/logo_essai.png'),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Connectez-vous pour continuer',
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 36),

                  IdentifiantField(controller: _identifiantCtrl),
                  const SizedBox(height: 16),
                  CodeAccesField(controller: _codeCtrl),
                  const SizedBox(height: 28),

                  LoginButton(
                    onPressed: _onLogin,
                    isLoading: _isLoading,
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifiantCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }
}
