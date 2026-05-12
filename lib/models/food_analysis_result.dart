// lib/models/food_analysis_result.dart

import 'food_item.dart';

class FoodAnalysisResult {
  final FoodItem foodItem;
  final double gramPorsi;
  final String waktuMakan;
  final String? fotoPath;
  final DateTime dianalisisPada;

  FoodAnalysisResult({
    required this.foodItem,
    required this.gramPorsi,
    required this.waktuMakan,
    this.fotoPath,
    DateTime? dianalisisPada,
  }) : dianalisisPada = dianalisisPada ?? DateTime.now();

  // ── Hasil perhitungan nutrisi ────────────────
  double get kalori   => foodItem.kaloriUntukGram(gramPorsi);
  double get karbo    => foodItem.karboUntukGram(gramPorsi);
  double get protein  => foodItem.proteinUntukGram(gramPorsi);
  double get lemak    => foodItem.lemakUntukGram(gramPorsi);
  double get serat    => foodItem.seratUntukGram(gramPorsi);
  double get gula     => foodItem.gulaUntukGram(gramPorsi);

  // ── Ringkasan untuk ditampilkan di UI ────────
  String get kaloriDisplay   => kalori.toStringAsFixed(0);
  String get karboDisplay    => '${karbo.toStringAsFixed(1)}g';
  String get proteinDisplay  => '${protein.toStringAsFixed(1)}g';
  String get lemakDisplay    => '${lemak.toStringAsFixed(1)}g';

  // ── Level risiko gula darah ──────────────────
  String get levelRisiko     => foodItem.levelRisikoGula;
  String get pesanRisiko     => foodItem.pesanRisiko;

  bool get risikoTinggi      => levelRisiko == 'tinggi';
  bool get risikoSedang      => levelRisiko == 'sedang';
  bool get risikoRendah      => levelRisiko == 'rendah';
}