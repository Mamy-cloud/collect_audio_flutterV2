// api_config.dart
// Configuration centralisée des URLs de l'API FastAPI
// ⚠️  Modifier uniquement _baseUrl lors d'un changement de domaine

class ApiConfig {
  // ─── URL de base ───────────────────────────────────────────────────────────
  // 🔧 Dev Android émulateur  : 'http://10.0.2.2:8000'
  // 🔧 Dev appareil physique  : 'http://192.168.43.213:8000'
  // 🚀 Production             : 'https://ton-domaine.com'
  static const String baseUrl = 'http://192.168.43.213:8000';

  // ─── Login ─────────────────────────────────────────────────────────────────
  static const String statusLogin = '$baseUrl/mobile/verif/status/login/mobile';
  static const String postLogin   = '$baseUrl/mobile/verif/login/post/mobile';

  // ─── Transfert cloud ───────────────────────────────────────────────────────
  static const String healthCloud  = '$baseUrl/mobile/transfert/cloud/health';
  static const String syncCloud    = '$baseUrl/mobile/transfert/cloud/sync';
  static const String collectes    = '$baseUrl/mobile/transfert/cloud/collectes';
}
