// create_table_temoin.dart
// Android/iOS → sqflite natif
// Version 6 — ajout user_id dans info_perso_temoin

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CreateTableTemoin {
  static Database? _db;

  static Database get db {
    if (_db == null) throw Exception('Base de données non initialisée');
    return _db!;
  }

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'mon_app.db');

    _db = await openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        await _createInfoPersoTemoin(db);
        await _createLoginUser(db);
        await _createCollectInfoFromTemoin(db);
        await _insertTestUsers(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE info_perso_temoin ADD COLUMN img_temoin TEXT');
        }
        if (oldVersion < 3) {
          await _createLoginUser(db);
          await _createCollectInfoFromTemoin(db);
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN synced INTEGER NOT NULL DEFAULT 0",
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            "ALTER TABLE info_perso_temoin ADD COLUMN contacts TEXT NOT NULL DEFAULT '[]'",
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            "ALTER TABLE info_perso_temoin ADD COLUMN user_id TEXT",
          );
        }
        if (oldVersion < 7) {
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN duree_audio INTEGER NOT NULL DEFAULT 0",
          );
        }
        if (oldVersion < 8) {
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN signature_url TEXT",
          );
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN accepte_rgpd INTEGER NOT NULL DEFAULT 0",
          );
        }
        if (oldVersion < 8) {
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN signature_url TEXT",
          );
          await db.execute(
            "ALTER TABLE collect_info_from_temoin ADD COLUMN accepte_rgpd INTEGER NOT NULL DEFAULT 0",
          );
        }
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await _insertTestUsers(db);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILISATEURS DE TEST
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _insertTestUsers(Database db) async {
    // Utilisateur 1 — login: user1 / code: 1234
    await db.execute('''
      INSERT OR IGNORE INTO login_user (id, identifiant, password, created_at)
      VALUES ('user_id_001', 'user1', '1234', '2024-01-01T00:00:00.000')
    ''');
    // Utilisateur 2 — login: user2 / code: 5678
    await db.execute('''
      INSERT OR IGNORE INTO login_user (id, identifiant, password, created_at)
      VALUES ('user_id_002', 'user2', '5678', '2024-01-01T00:00:00.000')
    ''');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRÉATION DES TABLES
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _createInfoPersoTemoin(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS info_perso_temoin (
        id             TEXT PRIMARY KEY,
        user_id        TEXT,
        nom            TEXT NOT NULL,
        prenom         TEXT NOT NULL,
        date_naissance TEXT,
        departement    TEXT,
        region         TEXT,
        img_temoin     TEXT,
        contacts       TEXT NOT NULL DEFAULT '[]',
        date_creation  TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES login_user(id)
      )
    ''');
  }

  static Future<void> _createLoginUser(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS login_user (
        id          TEXT PRIMARY KEY,
        identifiant TEXT NOT NULL UNIQUE,
        password    TEXT NOT NULL,
        created_at  TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createCollectInfoFromTemoin(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS collect_info_from_temoin (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL,
        questionnaire TEXT NOT NULL DEFAULT '[]',
        url_audio     TEXT,
        duree_audio   INTEGER NOT NULL DEFAULT 0,
        signature_url TEXT,
        accepte_rgpd  INTEGER NOT NULL DEFAULT 0,
        synced        INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES login_user(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS info_perso_temoin_collect (
        id          TEXT PRIMARY KEY,
        collect_id  TEXT NOT NULL,
        created_at  TEXT NOT NULL,
        FOREIGN KEY (collect_id) REFERENCES collect_info_from_temoin(id)
      )
    ''');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN USER — CRUD
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserByIdentifiant(
      String identifiant) async {
    final result = await _db!.query(
      'login_user',
      where:     'identifiant = ?',
      whereArgs: [identifiant],
      limit:     1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<Map<String, dynamic>?> login(
      String identifiant, String password) async {
    final result = await _db!.query(
      'login_user',
      where:     'identifiant = ? AND password = ?',
      whereArgs: [identifiant, password],
      limit:     1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
