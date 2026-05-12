// lib/repositories/jurnal_repository.dart

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/food_journal.dart';

class JurnalRepository {
  final _db = DatabaseHelper.instance;

  // ── Simpan entri baru ke food_log ──────────────
  Future<void> simpan(JurnalMakanan jurnal) async {
    final db = await _db.database;
    await db.insert(
      DatabaseHelper.tableFoodLog,
      jurnal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Ambil semua log (untuk halaman riwayat) ────
  // Diurutkan dari terbaru
  Future<List<JurnalMakanan>> ambilSemua() async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableFoodLog,
      orderBy: 'dicatat_pada DESC',
    );
    return rows.map(JurnalMakanan.fromMap).toList();
  }

  // ── Ambil log hari ini saja ────────────────────
  Future<List<JurnalMakanan>> ambilHariIni() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT * FROM ${DatabaseHelper.tableFoodLog}
      WHERE date(dicatat_pada) = date('now', 'localtime')
      ORDER BY dicatat_pada DESC
    ''');
    return rows.map(JurnalMakanan.fromMap).toList();
  }

  // ── Summary total kalori & karbo hari ini ─────
  // Dipakai untuk banner biru di atas riwayat
  Future<Map<String, double>> summaryHariIni() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(kalori), 0) AS total_kalori,
        COALESCE(SUM(karbo),  0) AS total_karbo,
        COUNT(*)                  AS total_entri
      FROM ${DatabaseHelper.tableFoodLog}
      WHERE date(dicatat_pada) = date('now', 'localtime')
    ''');
    final r = rows.first;
    return {
      'kalori': (r['total_kalori'] as num).toDouble(),
      'karbo':  (r['total_karbo']  as num).toDouble(),
      'entri':  (r['total_entri']  as num).toDouble(),
    };
  }

  // ── Cari makanan dari tabel foods (master) ────
  // untuk dropdown / autocomplete di halaman input
  Future<List<Map<String, dynamic>>> cariFoods(String query) async {
    final db = await _db.database;
    return db.query(
      DatabaseHelper.tableFoods,
      where: 'nama LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nama ASC',
      limit: 10,
    );
  }

  // ── Ambil satu food dari master berdasarkan nama persis ─
  Future<Map<String, dynamic>?> ambilFoodByNama(String nama) async {
    final db = await _db.database;
    // Coba exact match dulu
    var rows = await db.query(
      DatabaseHelper.tableFoods,
      where: 'LOWER(nama) = LOWER(?)',
      whereArgs: [nama],
      limit: 1,
    );
    // Kalau tidak ketemu, coba LIKE
    if (rows.isEmpty) {
      rows = await db.query(
        DatabaseHelper.tableFoods,
        where: 'nama LIKE ?',
        whereArgs: ['%$nama%'],
        orderBy: 'nama ASC',
        limit: 1,
      );
    }
    return rows.isEmpty ? null : rows.first;
  }

  // ── Hapus satu entri ──────────────────────────
  Future<void> hapus(String id) async {
    final db = await _db.database;
    await db.delete(
      DatabaseHelper.tableFoodLog,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Hapus semua log hari ini ──────────────────
  Future<void> hapusHariIni() async {
    final db = await _db.database;
    await db.rawDelete('''
      DELETE FROM ${DatabaseHelper.tableFoodLog}
      WHERE date(dicatat_pada) = date('now', 'localtime')
    ''');
  }
}