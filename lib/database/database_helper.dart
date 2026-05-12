import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class DatabaseHelper {
  // ==================== KONSTANTA ====================
  static const String _dbName = 'glucoguide.db';
  static const int _dbVersion = 3;

  // Nama tabel
  static const String tableFoods = 'foods';
  static const String tableFoodLog = 'food_log';
  static const String tableGulaDarah = 'gula_darah';
  static const String tableGlucose = 'glucose';
  static const String tableMedication = 'medication';
  static const String tableUser = 'user';

  static Database? _db;

  // ==================== SINGLETON ====================
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  factory DatabaseHelper() => instance;

  // ==================== INISIALISASI DATABASE ====================
  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  
Future<Database> _initDB() async {
  if (kIsWeb) {
    throw UnsupportedError("Database tidak support di Web");
  }

  final path = join(await getDatabasesPath(), _dbName);
  return await openDatabase(
    path,
    version: _dbVersion,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

  // ==================== MEMBUAT TABEL ====================
  Future<void> _onCreate(Database db, int version) async {
    // Tabel 1: foods (master data makanan)
    await db.execute('''
      CREATE TABLE $tableFoods (
        id               TEXT PRIMARY KEY,
        nama             TEXT NOT NULL,
        emoji            TEXT NOT NULL DEFAULT '',
        kalori_100g      REAL NOT NULL,
        karbo_100g       REAL NOT NULL,
        protein_100g     REAL NOT NULL,
        lemak_100g       REAL NOT NULL,
        serat_100g       REAL NOT NULL DEFAULT 0,
        gula_100g        REAL NOT NULL DEFAULT 0,
        kategori         TEXT NOT NULL DEFAULT 'umum',
        indeks_glikemik  INTEGER NOT NULL DEFAULT 50,
        dibuat_pada      TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Tabel 2: food_log (jurnal makanan harian)
    await db.execute('''
      CREATE TABLE $tableFoodLog (
        id           TEXT PRIMARY KEY,
        food_id      TEXT NOT NULL,
        gram         REAL NOT NULL,
        waktu_makan  TEXT NOT NULL,
        foto_bytes   BLOB,
        dicatat_pada TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (food_id) REFERENCES $tableFoods(id) ON DELETE CASCADE
      )
    ''');

    // Tabel 3: gula_darah
    await db.execute('''
      CREATE TABLE $tableGulaDarah (
        id          TEXT PRIMARY KEY,
        nilai_mgdl  REAL NOT NULL,
        kondisi     TEXT NOT NULL DEFAULT 'sewaktu',
        catatan     TEXT,
        dicatat_pada TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Tabel 4: glucose (alternatif)
    await db.execute('''
      CREATE TABLE $tableGlucose (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nilai REAL NOT NULL,
        waktu TEXT NOT NULL,
        konteks_makan TEXT NOT NULL,
        catatan TEXT DEFAULT ""
      )
    ''');

    // Tabel 5: medication (pengingat obat)
    await db.execute('''
      CREATE TABLE $tableMedication (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_obat TEXT NOT NULL,
        dosis TEXT NOT NULL,
        frekuensi TEXT NOT NULL,
        waktu_konsumsi TEXT NOT NULL,
        tipe TEXT NOT NULL,
        catatan TEXT DEFAULT "",
        dibuat_pada TEXT NOT NULL
      )
    ''');

    // Tabel 6: user
    await db.execute('''
      CREATE TABLE $tableUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'pasien',
        dibuat_pada TEXT NOT NULL
      )
    ''');

    // Index untuk query cepat
    await db.execute('CREATE INDEX idx_log_tanggal ON $tableFoodLog (date(dicatat_pada))');
    await db.execute('CREATE INDEX idx_log_waktu ON $tableFoodLog (waktu_makan, date(dicatat_pada))');

    // Seed data awal
    await _seedAllFoods(db);
    await _seedDefaultUsers(db);
  }

  // ==================== UPGRADE DATABASE ====================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $tableUser ADD COLUMN role TEXT DEFAULT 'pasien'");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE $tableFoodLog ADD COLUMN foto_bytes BLOB");
    }
  }

  // ==================== SEED DATA MAKANAN ====================
  Future<void> _seedAllFoods(Database db) async {
    final batch = db.batch();

    // Makanan Pokok
    final makananPokok = [
      {'id': 'nasi_putih', 'nama': 'Nasi Putih', 'emoji': '🍚', 'kategori': 'makanan_pokok', 'kalori_100g': 130, 'karbo_100g': 28.2, 'protein_100g': 2.7, 'lemak_100g': 0.3, 'serat_100g': 0.4, 'gula_100g': 0.1, 'indeks_glikemik': 72},
      {'id': 'nasi_merah', 'nama': 'Nasi Merah', 'emoji': '🍚', 'kategori': 'makanan_pokok', 'kalori_100g': 111, 'karbo_100g': 23.0, 'protein_100g': 2.6, 'lemak_100g': 0.9, 'serat_100g': 1.8, 'gula_100g': 0.4, 'indeks_glikemik': 55},
      {'id': 'kentang', 'nama': 'Kentang', 'emoji': '🥔', 'kategori': 'makanan_pokok', 'kalori_100g': 77, 'karbo_100g': 17.0, 'protein_100g': 2.0, 'lemak_100g': 0.1, 'serat_100g': 2.2, 'gula_100g': 0.8, 'indeks_glikemik': 78},
      {'id': 'ubi', 'nama': 'Ubi Jalar', 'emoji': '🍠', 'kategori': 'makanan_pokok', 'kalori_100g': 86, 'karbo_100g': 20.1, 'protein_100g': 1.6, 'lemak_100g': 0.1, 'serat_100g': 3.0, 'gula_100g': 4.2, 'indeks_glikemik': 44},
      {'id': 'singkong', 'nama': 'Singkong', 'emoji': '🥔', 'kategori': 'makanan_pokok', 'kalori_100g': 146, 'karbo_100g': 34.0, 'protein_100g': 1.4, 'lemak_100g': 0.3, 'serat_100g': 1.8, 'gula_100g': 1.7, 'indeks_glikemik': 46},
      {'id': 'jagung', 'nama': 'Jagung', 'emoji': '🌽', 'kategori': 'makanan_pokok', 'kalori_100g': 86, 'karbo_100g': 19.0, 'protein_100g': 3.2, 'lemak_100g': 1.2, 'serat_100g': 2.7, 'gula_100g': 3.2, 'indeks_glikemik': 52},
      {'id': 'roti_putih', 'nama': 'Roti Putih', 'emoji': '🍞', 'kategori': 'makanan_pokok', 'kalori_100g': 265, 'karbo_100g': 49.0, 'protein_100g': 9.0, 'lemak_100g': 3.2, 'serat_100g': 2.7, 'gula_100g': 5.0, 'indeks_glikemik': 70},
      {'id': 'mie', 'nama': 'Mie', 'emoji': '🍜', 'kategori': 'makanan_pokok', 'kalori_100g': 138, 'karbo_100g': 25.0, 'protein_100g': 4.5, 'lemak_100g': 2.0, 'serat_100g': 1.0, 'gula_100g': 0.5, 'indeks_glikemik': 55},
      {'id': 'bihun', 'nama': 'Bihun', 'emoji': '🍜', 'kategori': 'makanan_pokok', 'kalori_100g': 360, 'karbo_100g': 88.0, 'protein_100g': 1.0, 'lemak_100g': 0.5, 'serat_100g': 1.0, 'gula_100g': 0.0, 'indeks_glikemik': 58},
    ];

    for (final f in makananPokok) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Protein Hewani
    final proteinHewani = [
      {'id': 'ayam_goreng', 'nama': 'Ayam Goreng', 'emoji': '🍗', 'kategori': 'protein', 'kalori_100g': 250, 'karbo_100g': 5.0, 'protein_100g': 25.0, 'lemak_100g': 15.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'ayam_bakar', 'nama': 'Ayam Bakar', 'emoji': '🍗', 'kategori': 'protein', 'kalori_100g': 200, 'karbo_100g': 2.0, 'protein_100g': 28.0, 'lemak_100g': 8.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'daging_sapi', 'nama': 'Daging Sapi', 'emoji': '🥩', 'kategori': 'protein', 'kalori_100g': 250, 'karbo_100g': 0, 'protein_100g': 26.0, 'lemak_100g': 15.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'daging_kambing', 'nama': 'Daging Kambing', 'emoji': '🐐', 'kategori': 'protein', 'kalori_100g': 154, 'karbo_100g': 0, 'protein_100g': 27.0, 'lemak_100g': 5.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'ikan_goreng', 'nama': 'Ikan Goreng', 'emoji': '🐟', 'kategori': 'protein', 'kalori_100g': 200, 'karbo_100g': 3.0, 'protein_100g': 22.0, 'lemak_100g': 12.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'ikan_bakar', 'nama': 'Ikan Bakar', 'emoji': '🐟', 'kategori': 'protein', 'kalori_100g': 150, 'karbo_100g': 0, 'protein_100g': 25.0, 'lemak_100g': 5.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'telur', 'nama': 'Telur Ayam', 'emoji': '🥚', 'kategori': 'protein', 'kalori_100g': 155, 'karbo_100g': 1.1, 'protein_100g': 12.8, 'lemak_100g': 11.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
      {'id': 'udang', 'nama': 'Udang', 'emoji': '🦐', 'kategori': 'protein', 'kalori_100g': 91, 'karbo_100g': 1.0, 'protein_100g': 21.0, 'lemak_100g': 1.0, 'serat_100g': 0, 'gula_100g': 0, 'indeks_glikemik': 0},
    ];

    for (final f in proteinHewani) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Protein Nabati
    final proteinNabati = [
      {'id': 'tempe', 'nama': 'Tempe', 'emoji': '🟫', 'kategori': 'protein', 'kalori_100g': 193, 'karbo_100g': 13.0, 'protein_100g': 20.0, 'lemak_100g': 9.0, 'serat_100g': 1.4, 'gula_100g': 0, 'indeks_glikemik': 30},
      {'id': 'tahu', 'nama': 'Tahu', 'emoji': '⬜', 'kategori': 'protein', 'kalori_100g': 76, 'karbo_100g': 1.9, 'protein_100g': 8.0, 'lemak_100g': 4.0, 'serat_100g': 0.3, 'gula_100g': 0, 'indeks_glikemik': 15},
      {'id': 'tempe_goreng', 'nama': 'Tempe Goreng', 'emoji': '🟫', 'kategori': 'protein', 'kalori_100g': 250, 'karbo_100g': 10.0, 'protein_100g': 18.0, 'lemak_100g': 15.0, 'serat_100g': 1.0, 'gula_100g': 0, 'indeks_glikemik': 30},
      {'id': 'tahu_goreng', 'nama': 'Tahu Goreng', 'emoji': '🟨', 'kategori': 'protein', 'kalori_100g': 115, 'karbo_100g': 5.0, 'protein_100g': 7.0, 'lemak_100g': 7.0, 'serat_100g': 0.5, 'gula_100g': 0, 'indeks_glikemik': 20},
      {'id': 'kacang_tanah', 'nama': 'Kacang Tanah', 'emoji': '🥜', 'kategori': 'protein', 'kalori_100g': 567, 'karbo_100g': 16.0, 'protein_100g': 25.0, 'lemak_100g': 49.0, 'serat_100g': 8.5, 'gula_100g': 4.0, 'indeks_glikemik': 14},
    ];

    for (final f in proteinNabati) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Sayuran
    final sayuran = [
      {'id': 'bayam', 'nama': 'Bayam', 'emoji': '🥬', 'kategori': 'sayuran', 'kalori_100g': 23, 'karbo_100g': 3.6, 'protein_100g': 2.9, 'lemak_100g': 0.4, 'serat_100g': 2.2, 'gula_100g': 0.4, 'indeks_glikemik': 15},
      {'id': 'kangkung', 'nama': 'Kangkung', 'emoji': '🥬', 'kategori': 'sayuran', 'kalori_100g': 19, 'karbo_100g': 3.1, 'protein_100g': 2.6, 'lemak_100g': 0.3, 'serat_100g': 2.1, 'gula_100g': 0.2, 'indeks_glikemik': 15},
      {'id': 'brokoli', 'nama': 'Brokoli', 'emoji': '🥦', 'kategori': 'sayuran', 'kalori_100g': 34, 'karbo_100g': 7.0, 'protein_100g': 2.8, 'lemak_100g': 0.4, 'serat_100g': 2.6, 'gula_100g': 1.7, 'indeks_glikemik': 10},
      {'id': 'wortel', 'nama': 'Wortel', 'emoji': '🥕', 'kategori': 'sayuran', 'kalori_100g': 41, 'karbo_100g': 10.0, 'protein_100g': 0.9, 'lemak_100g': 0.2, 'serat_100g': 2.8, 'gula_100g': 4.7, 'indeks_glikemik': 35},
      {'id': 'buncis', 'nama': 'Buncis', 'emoji': '🟢', 'kategori': 'sayuran', 'kalori_100g': 31, 'karbo_100g': 7.0, 'protein_100g': 1.8, 'lemak_100g': 0.1, 'serat_100g': 2.7, 'gula_100g': 1.4, 'indeks_glikemik': 15},
      {'id': 'kacang_panjang', 'nama': 'Kacang Panjang', 'emoji': '🟢', 'kategori': 'sayuran', 'kalori_100g': 47, 'karbo_100g': 8.0, 'protein_100g': 2.1, 'lemak_100g': 0.5, 'serat_100g': 2.0, 'gula_100g': 1.5, 'indeks_glikemik': 20},
      {'id': 'terong', 'nama': 'Terong', 'emoji': '🍆', 'kategori': 'sayuran', 'kalori_100g': 25, 'karbo_100g': 6.0, 'protein_100g': 1.0, 'lemak_100g': 0.2, 'serat_100g': 3.0, 'gula_100g': 3.5, 'indeks_glikemik': 15},
    ];

    for (final f in sayuran) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Buah
    final buah = [
      {'id': 'pisang', 'nama': 'Pisang', 'emoji': '🍌', 'kategori': 'buah', 'kalori_100g': 89, 'karbo_100g': 23.0, 'protein_100g': 1.1, 'lemak_100g': 0.3, 'serat_100g': 2.6, 'gula_100g': 12.2, 'indeks_glikemik': 51},
      {'id': 'apel', 'nama': 'Apel', 'emoji': '🍎', 'kategori': 'buah', 'kalori_100g': 52, 'karbo_100g': 14.0, 'protein_100g': 0.3, 'lemak_100g': 0.2, 'serat_100g': 2.4, 'gula_100g': 10.4, 'indeks_glikemik': 36},
      {'id': 'jeruk', 'nama': 'Jeruk', 'emoji': '🍊', 'kategori': 'buah', 'kalori_100g': 47, 'karbo_100g': 12.0, 'protein_100g': 0.9, 'lemak_100g': 0.1, 'serat_100g': 2.4, 'gula_100g': 9.4, 'indeks_glikemik': 43},
      {'id': 'mangga', 'nama': 'Mangga', 'emoji': '🥭', 'kategori': 'buah', 'kalori_100g': 60, 'karbo_100g': 15.0, 'protein_100g': 0.8, 'lemak_100g': 0.4, 'serat_100g': 1.6, 'gula_100g': 13.7, 'indeks_glikemik': 56},
      {'id': 'semangka', 'nama': 'Semangka', 'emoji': '🍉', 'kategori': 'buah', 'kalori_100g': 30, 'karbo_100g': 7.6, 'protein_100g': 0.6, 'lemak_100g': 0.2, 'serat_100g': 0.4, 'gula_100g': 6.2, 'indeks_glikemik': 72},
      {'id': 'pepaya', 'nama': 'Pepaya', 'emoji': '🍈', 'kategori': 'buah', 'kalori_100g': 43, 'karbo_100g': 11.0, 'protein_100g': 0.5, 'lemak_100g': 0.1, 'serat_100g': 1.7, 'gula_100g': 8.0, 'indeks_glikemik': 60},
      {'id': 'alpukat', 'nama': 'Alpukat', 'emoji': '🥑', 'kategori': 'buah', 'kalori_100g': 160, 'karbo_100g': 9.0, 'protein_100g': 2.0, 'lemak_100g': 15.0, 'serat_100g': 7.0, 'gula_100g': 0.7, 'indeks_glikemik': 10},
    ];

    for (final f in buah) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Makanan Siap Saji / Masakan
    final makananSiapSaji = [
      {'id': 'nasi_goreng', 'nama': 'Nasi Goreng', 'emoji': '🍳', 'kategori': 'masakan', 'kalori_100g': 187, 'karbo_100g': 26.0, 'protein_100g': 5.7, 'lemak_100g': 7.0, 'serat_100g': 0.8, 'gula_100g': 1.2, 'indeks_glikemik': 70},
      {'id': 'mie_goreng', 'nama': 'Mie Goreng', 'emoji': '🍜', 'kategori': 'masakan', 'kalori_100g': 200, 'karbo_100g': 30.0, 'protein_100g': 6.0, 'lemak_100g': 7.0, 'serat_100g': 1.0, 'gula_100g': 2.0, 'indeks_glikemik': 73},
      {'id': 'soto', 'nama': 'Soto Ayam', 'emoji': '🍲', 'kategori': 'masakan', 'kalori_100g': 68, 'karbo_100g': 4.5, 'protein_100g': 6.0, 'lemak_100g': 2.5, 'serat_100g': 0.5, 'gula_100g': 0.8, 'indeks_glikemik': 40},
      {'id': 'gado_gado', 'nama': 'Gado-gado', 'emoji': '🥗', 'kategori': 'masakan', 'kalori_100g': 148, 'karbo_100g': 12.0, 'protein_100g': 6.5, 'lemak_100g': 9.0, 'serat_100g': 2.5, 'gula_100g': 2.0, 'indeks_glikemik': 45},
      {'id': 'rendang', 'nama': 'Rendang', 'emoji': '🍖', 'kategori': 'masakan', 'kalori_100g': 193, 'karbo_100g': 6.2, 'protein_100g': 19.3, 'lemak_100g': 10.7, 'serat_100g': 0.5, 'gula_100g': 1.0, 'indeks_glikemik': 25},
      {'id': 'bakso', 'nama': 'Bakso', 'emoji': '🍡', 'kategori': 'masakan', 'kalori_100g': 86, 'karbo_100g': 5.2, 'protein_100g': 8.3, 'lemak_100g': 3.4, 'serat_100g': 0.2, 'gula_100g': 0.5, 'indeks_glikemik': 48},
    ];

    for (final f in makananSiapSaji) {
      batch.insert(tableFoods, f, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }

  // ==================== SEED DEFAULT USERS ====================
  Future<void> _seedDefaultUsers(Database db) async {
    await db.insert(tableUser, {
      'nama': 'Admin',
      'email': 'admin@gmail.com',
      'password': 'admin130306.',
      'role': 'admin',
      'dibuat_pada': DateTime.now().toString(),
    });

    await db.insert(tableUser, {
      'nama': 'User',
      'email': 'user@gmail.com',
      'password': 'Gi130306.',
      'role': 'pasien',
      'dibuat_pada': DateTime.now().toString(),
    });
  }

  // ==================== QUERY TABLE FOODS ====================

  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return await db.query(tableFoods, orderBy: 'nama ASC');
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final db = await database;
    if (query.isEmpty) return [];
    return await db.query(
      tableFoods,
      where: 'nama LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nama ASC',
      limit: 20,
    );
  }

  Future<Map<String, dynamic>?> getFoodById(String id) async {
    final db = await database;
    final result = await db.query(
      tableFoods,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getFoodsByCategory(String kategori) async {
    final db = await database;
    return await db.query(
      tableFoods,
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'nama ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getFoodsLowGI() async {
    final db = await database;
    return await db.query(
      tableFoods,
      where: 'indeks_glikemik > 0 AND indeks_glikemik < 55',
      orderBy: 'indeks_glikemik ASC',
    );
  }

  // ==================== QUERY TABLE FOOD_LOG ====================

  Future<int> insertFoodLog(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableFoodLog, data);
  }

  Future<List<Map<String, dynamic>>> getAllFoodLog() async {
    final db = await database;
    return await db.query(
      tableFoodLog,
      orderBy: 'dicatat_pada DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getFoodLogByDate(String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT l.*, f.nama, f.emoji, f.kalori_100g, f.karbo_100g, 
             f.protein_100g, f.lemak_100g, f.indeks_glikemik
      FROM $tableFoodLog l
      JOIN $tableFoods f ON l.food_id = f.id
      WHERE date(l.dicatat_pada) = ?
      ORDER BY l.waktu_makan ASC
    ''', [date]);
  }

  Future<double> getTotalKaloriByDate(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(f.kalori_100g * l.gram / 100) as total
      FROM $tableFoodLog l
      JOIN $tableFoods f ON l.food_id = f.id
      WHERE date(l.dicatat_pada) = ?
    ''', [date]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> deleteFoodLog(String id) async {
    final db = await database;
    return await db.delete(
      tableFoodLog,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== QUERY TABLE GULA_DARAH ====================

  Future<int> insertGulaDarah(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableGulaDarah, data);
  }

  Future<List<Map<String, dynamic>>> getAllGulaDarah() async {
    final db = await database;
    return await db.query(
      tableGulaDarah,
      orderBy: 'dicatat_pada DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getGulaDarahByDate(String date) async {
    final db = await database;
    return await db.query(
      tableGulaDarah,
      where: 'date(dicatat_pada) = ?',
      whereArgs: [date],
      orderBy: 'dicatat_pada ASC',
    );
  }

  Future<int> deleteGulaDarah(String id) async {
    final db = await database;
    return await db.delete(
      tableGulaDarah,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== QUERY TABLE GLUCOSE ====================

  Future<int> insertGlucose(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableGlucose, data);
  }

  Future<List<Map<String, dynamic>>> getAllGlucose() async {
    final db = await database;
    return await db.query(tableGlucose, orderBy: 'waktu DESC');
  }

  Future<int> deleteGlucose(int id) async {
    final db = await database;
    return await db.delete(tableGlucose, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== QUERY TABLE MEDICATION ====================

  Future<int> insertMedication(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableMedication, data);
  }

  Future<List<Map<String, dynamic>>> getAllMedication() async {
    final db = await database;
    return await db.query(tableMedication, orderBy: 'dibuat_pada DESC');
  }

  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.delete(tableMedication, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== QUERY TABLE USER ====================

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final result = await db.query(
      tableUser,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableUser, data);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      tableUser,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(tableUser);
  }

  Future<int> updateUserRole(int userId, String role) async {
    final db = await database;
    return await db.update(
      tableUser,
      {'role': role},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== UTILITY ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}