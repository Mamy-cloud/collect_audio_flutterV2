import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Titre Accueil ─────────────────────────────────────────────────────────────

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('', style: AppTextStyles.headline);
  }
}

// ── Image hero — 20% de l'écran ───────────────────────────────────────────────

class LoginHeroImage extends StatelessWidget {
  final String assetPath;
  const LoginHeroImage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.30;
    return SizedBox(
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: const Icon(Icons.image_outlined,
              size: 64, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

// ── Champ identifiant interviewer ─────────────────────────────────────────────

class IdentifiantField extends StatelessWidget {
  final TextEditingController controller;
  const IdentifiantField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      style:        AppTextStyles.input,
      keyboardType: TextInputType.text,
      decoration:   AppInputDecoration.of(
        'Identifiant interviewer',
        hint: 'ex. interviewer_01',
      ),
    );
  }
}

// ── Champ code d'accès ────────────────────────────────────────────────────────

class CodeAccesField extends StatefulWidget {
  final TextEditingController controller;
  const CodeAccesField({super.key, required this.controller});

  @override
  State<CodeAccesField> createState() => _CodeAccesFieldState();
}

class _CodeAccesFieldState extends State<CodeAccesField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   widget.controller,
      style:        AppTextStyles.input,
      obscureText:  _obscure,
      keyboardType: TextInputType.visiblePassword,
      decoration:   AppInputDecoration.of('Code d\'accès').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textMuted, size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ── Bouton Se connecter ───────────────────────────────────────────────────────

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool          isLoading;
  const LoginButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:     AppButtonStyle.primary,
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black),
              )
            : const Text('Se connecter', style: AppTextStyles.button),
      ),
    );
  }
}

// ── Lien Mode invité ──────────────────────────────────────────────────────────

class GuestModeLink extends StatelessWidget {
  final VoidCallback? onTap;
  const GuestModeLink({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Text('', style: AppTextStyles.guestLink),
    );
  }
}
