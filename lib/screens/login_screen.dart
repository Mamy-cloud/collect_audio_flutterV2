// login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/session_service.dart';
import '../services/login_api_service.dart';
import '../database/create_table/create_table_temoin.dart';
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

  bool    _isLoading       = false;
  bool    _serverAvailable = false;
  String  _statusMessage   = 'Vérification du serveur...';

  // ── Debug logs affichés sur l'écran ───────────────────────────────────────
  final List<String> _debugLogs = [];

  void _log(String msg) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    setState(() => _debugLogs.add('[$time] $msg'));
  }

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    _log('→ checkServerStatus() démarré');
    final result = await LoginApiService.checkServerStatus();
    _log('internet: ${result.internetAvailable} | serveur: ${result.serverAvailable}');
    _log('message: ${result.message}');
    if (mounted) {
      setState(() {
        _serverAvailable = result.serverAvailable;
        _statusMessage   = result.message;
      });
    }
  }

  Future<void> _upsertUserInSqlite({
    required String id,
    required String identifiant,
    required String password,
  }) async {
    final db = CreateTableTemoin.db;
    final existing = await db.query(
      'login_user', where: 'id = ?', whereArgs: [id], limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('login_user', {
        'id':          id,
        'identifiant': identifiant,
        'password':    password,
        'last_login':  DateTime.now().toIso8601String(),
        'created_at':  DateTime.now().toIso8601String(),
      });
    } else {
      await db.update('login_user', {
        'identifiant': identifiant,
        'password':    password,
        'last_login':  DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> _onLogin() async {
    final identifiant = _identifiantCtrl.text.trim();
    final password    = _codeCtrl.text.trim();

    if (identifiant.isEmpty || password.isEmpty) {
      _snack('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading     = true;
      _statusMessage = 'Vérification du serveur...';
      _debugLogs.clear();
    });

    _log('→ Login cliqué');
    _log('→ checkServerStatus() démarré');

    final check = await LoginApiService.checkServerStatus();
    _log('internet: ${check.internetAvailable} | serveur: ${check.serverAvailable}');
    _log('message: ${check.message}');

    if (mounted) {
      setState(() {
        _serverAvailable = check.serverAvailable;
        _statusMessage   = check.message;
      });
    }

    if (!check.internetAvailable) {
      _log('❌ Pas internet');
      setState(() => _isLoading = false);
      _snack('Connexion Internet requise pour se connecter.');
      return;
    }

    if (!check.serverAvailable) {
      _log('❌ Serveur inaccessible');
      setState(() => _isLoading = false);
      _snack('Serveur inaccessible. Réessayez plus tard.');
      return;
    }

    _log('→ POST login...');
    final result = await LoginApiService.login(
      identifiant: identifiant,
      password:    password,
    );
    _log('success: ${result.success} | userId: ${result.userId}');
    _log('identifiantOk: ${result.identifiantOk} | passwordOk: ${result.passwordOk}');

    if (!mounted) return;

    if (!result.success) {
      setState(() => _isLoading = false);
      if (!result.identifiantOk) {
        _snack('Identifiant incorrect.');
      } else if (!result.passwordOk) {
        _snack('Mot de passe incorrect.');
      } else {
        _snack(result.message);
      }
      return;
    }

    _log('✅ Connexion réussie → upsert SQLite');
    await _upsertUserInSqlite(
      id:          result.userId!,
      identifiant: identifiant,
      password:    password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    await SessionService.login(result.userId!, identifiant);
    context.go('/list_temoin');
  }

  Future<void> _openMotDePasseOublie() async {
    final uri = Uri.parse(
      'https://react-web-transcriptor-conta.vercel.app/mot-de-passe-oublie',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  void dispose() {
    _identifiantCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
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

                  // ── Statut serveur ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _serverAvailable
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusMessage,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          color: _serverAvailable
                              ? const Color(0xFF4CAF50)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Connectez-vous pour continuer',
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Panel debug ──────────────────────────────────────────
                  if (_debugLogs.isNotEmpty)
                    Container(
                      width:   double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:        const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(8),
                        border:       Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bug_report,
                                  size: 13, color: Color(0xFF58A6FF)),
                              const SizedBox(width: 6),
                              const Text('DEBUG',
                                style: TextStyle(fontSize: 11,
                                    color: Color(0xFF58A6FF),
                                    fontWeight: FontWeight.w600)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _debugLogs.clear()),
                                child: const Icon(Icons.close,
                                    size: 14, color: Color(0xFF8B949E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ..._debugLogs.map((log) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(log,
                              style: const TextStyle(
                                fontSize:   10,
                                color:      Color(0xFFE6EDF3),
                                fontFamily: 'monospace',
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  IdentifiantField(controller: _identifiantCtrl),
                  const SizedBox(height: 16),
                  CodeAccesField(controller: _codeCtrl),
                  const SizedBox(height: 8),

                  // ── Mot de passe oublié ──────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _openMotDePasseOublie,
                      child: Text(
                        'Mot de passe oublié ? Cliquer ici',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          color:    Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  LoginButton(
                    onPressed: _isLoading ? null : _onLogin,
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
}
