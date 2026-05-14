// Bracket-specific machine constants for one of the 11 count ranges.
// All values sourced directly from costing1_16.xlsx spin plan columns D–N.
class CountBracket {
  final int minCount; // exclusive lower bound
  final int maxCount; // inclusive upper bound

  // Ring frame
  final double ringFrameEfficiency;

  // Simplex
  final double simplexHank;
  final double simplexSpeedRpm;
  final double simplexTM;
  final double simplexEfficiency;
  // simplexUtilisation is 98% for all brackets — hardcoded in engine

  // Finisher drawing
  final double finDrawingMpm;
  final double finDrawingHank;
  final double finDrawingEfficiency;
  final double finDrawingUtilisation; // 95% for brackets 1–10, 90% for bracket 11

  // Pre-comber drawing
  final double preComberMpm;
  final double preComberHank;
  final double preComberEfficiency;
  final double preComberDrawingUtilisation; // 95% for brackets 1–10, 90% for bracket 11

  // Comber
  final double comberNpm; // nips per minute
  final double comberLapWeightGpyd;
  final double comberNoilPct; // 18% for all brackets
  final double comberEfficiency;
  final double comberUtilisation; // 98% brackets 1–7, 95% brackets 8–11

  // Lap former
  final double lapFormerMpm;
  final double lapFormerLapWeightGpyd; // same as comberLapWeightGpyd
  final double lapFormerEfficiency;
  // lapFormerUtilisation is 96% for all brackets — hardcoded in engine

  // Carding
  final double cardingKgPerHr;
  final double cardingEfficiency;
  // cardingUtilisation is 95% for all brackets — hardcoded in engine

  // Blow room
  final double blowRoomKgPerHr;
  final double blowRoomEfficiency; // 0.85 for all brackets
  // blowRoomUtilisation is 90% for all brackets — hardcoded in engine

  // Winding
  final double windingMpm;
  final double windingEfficiency;
  final double windingUtilisation; // 97% for brackets 1–10, 90% for bracket 11

  const CountBracket({
    required this.minCount,
    required this.maxCount,
    required this.ringFrameEfficiency,
    required this.simplexHank,
    required this.simplexSpeedRpm,
    required this.simplexTM,
    required this.simplexEfficiency,
    required this.finDrawingMpm,
    required this.finDrawingHank,
    required this.finDrawingEfficiency,
    required this.finDrawingUtilisation,
    required this.preComberMpm,
    required this.preComberHank,
    required this.preComberEfficiency,
    required this.preComberDrawingUtilisation,
    required this.comberNpm,
    required this.comberLapWeightGpyd,
    required this.comberNoilPct,
    required this.comberEfficiency,
    required this.comberUtilisation,
    required this.lapFormerMpm,
    required this.lapFormerLapWeightGpyd,
    required this.lapFormerEfficiency,
    required this.cardingKgPerHr,
    required this.cardingEfficiency,
    required this.blowRoomKgPerHr,
    required this.blowRoomEfficiency,
    required this.windingMpm,
    required this.windingEfficiency,
    required this.windingUtilisation,
  });

  bool contains(double count) => count > minCount && count <= maxCount;

  CountBracket copyWith({
    int? minCount,
    int? maxCount,
    double? ringFrameEfficiency,
    double? simplexHank,
    double? simplexSpeedRpm,
    double? simplexTM,
    double? simplexEfficiency,
    double? finDrawingMpm,
    double? finDrawingHank,
    double? finDrawingEfficiency,
    double? finDrawingUtilisation,
    double? preComberMpm,
    double? preComberHank,
    double? preComberEfficiency,
    double? preComberDrawingUtilisation,
    double? comberNpm,
    double? comberLapWeightGpyd,
    double? comberNoilPct,
    double? comberEfficiency,
    double? comberUtilisation,
    double? lapFormerMpm,
    double? lapFormerLapWeightGpyd,
    double? lapFormerEfficiency,
    double? cardingKgPerHr,
    double? cardingEfficiency,
    double? blowRoomKgPerHr,
    double? blowRoomEfficiency,
    double? windingMpm,
    double? windingEfficiency,
    double? windingUtilisation,
  }) {
    return CountBracket(
      minCount: minCount ?? this.minCount,
      maxCount: maxCount ?? this.maxCount,
      ringFrameEfficiency: ringFrameEfficiency ?? this.ringFrameEfficiency,
      simplexHank: simplexHank ?? this.simplexHank,
      simplexSpeedRpm: simplexSpeedRpm ?? this.simplexSpeedRpm,
      simplexTM: simplexTM ?? this.simplexTM,
      simplexEfficiency: simplexEfficiency ?? this.simplexEfficiency,
      finDrawingMpm: finDrawingMpm ?? this.finDrawingMpm,
      finDrawingHank: finDrawingHank ?? this.finDrawingHank,
      finDrawingEfficiency: finDrawingEfficiency ?? this.finDrawingEfficiency,
      finDrawingUtilisation: finDrawingUtilisation ?? this.finDrawingUtilisation,
      preComberMpm: preComberMpm ?? this.preComberMpm,
      preComberHank: preComberHank ?? this.preComberHank,
      preComberEfficiency: preComberEfficiency ?? this.preComberEfficiency,
      preComberDrawingUtilisation:
          preComberDrawingUtilisation ?? this.preComberDrawingUtilisation,
      comberNpm: comberNpm ?? this.comberNpm,
      comberLapWeightGpyd: comberLapWeightGpyd ?? this.comberLapWeightGpyd,
      comberNoilPct: comberNoilPct ?? this.comberNoilPct,
      comberEfficiency: comberEfficiency ?? this.comberEfficiency,
      comberUtilisation: comberUtilisation ?? this.comberUtilisation,
      lapFormerMpm: lapFormerMpm ?? this.lapFormerMpm,
      lapFormerLapWeightGpyd:
          lapFormerLapWeightGpyd ?? this.lapFormerLapWeightGpyd,
      lapFormerEfficiency: lapFormerEfficiency ?? this.lapFormerEfficiency,
      cardingKgPerHr: cardingKgPerHr ?? this.cardingKgPerHr,
      cardingEfficiency: cardingEfficiency ?? this.cardingEfficiency,
      blowRoomKgPerHr: blowRoomKgPerHr ?? this.blowRoomKgPerHr,
      blowRoomEfficiency: blowRoomEfficiency ?? this.blowRoomEfficiency,
      windingMpm: windingMpm ?? this.windingMpm,
      windingEfficiency: windingEfficiency ?? this.windingEfficiency,
      windingUtilisation: windingUtilisation ?? this.windingUtilisation,
    );
  }

  Map<String, dynamic> toJson() => {
        'minCount': minCount,
        'maxCount': maxCount,
        'ringFrameEfficiency': ringFrameEfficiency,
        'simplexHank': simplexHank,
        'simplexSpeedRpm': simplexSpeedRpm,
        'simplexTM': simplexTM,
        'simplexEfficiency': simplexEfficiency,
        'finDrawingMpm': finDrawingMpm,
        'finDrawingHank': finDrawingHank,
        'finDrawingEfficiency': finDrawingEfficiency,
        'finDrawingUtilisation': finDrawingUtilisation,
        'preComberMpm': preComberMpm,
        'preComberHank': preComberHank,
        'preComberEfficiency': preComberEfficiency,
        'preComberDrawingUtilisation': preComberDrawingUtilisation,
        'comberNpm': comberNpm,
        'comberLapWeightGpyd': comberLapWeightGpyd,
        'comberNoilPct': comberNoilPct,
        'comberEfficiency': comberEfficiency,
        'comberUtilisation': comberUtilisation,
        'lapFormerMpm': lapFormerMpm,
        'lapFormerLapWeightGpyd': lapFormerLapWeightGpyd,
        'lapFormerEfficiency': lapFormerEfficiency,
        'cardingKgPerHr': cardingKgPerHr,
        'cardingEfficiency': cardingEfficiency,
        'blowRoomKgPerHr': blowRoomKgPerHr,
        'blowRoomEfficiency': blowRoomEfficiency,
        'windingMpm': windingMpm,
        'windingEfficiency': windingEfficiency,
        'windingUtilisation': windingUtilisation,
      };

  factory CountBracket.fromJson(Map<String, dynamic> j) => CountBracket(
        minCount: j['minCount'] as int,
        maxCount: j['maxCount'] as int,
        ringFrameEfficiency: (j['ringFrameEfficiency'] as num).toDouble(),
        simplexHank: (j['simplexHank'] as num).toDouble(),
        simplexSpeedRpm: (j['simplexSpeedRpm'] as num).toDouble(),
        simplexTM: (j['simplexTM'] as num).toDouble(),
        simplexEfficiency: (j['simplexEfficiency'] as num).toDouble(),
        finDrawingMpm: (j['finDrawingMpm'] as num).toDouble(),
        finDrawingHank: (j['finDrawingHank'] as num).toDouble(),
        finDrawingEfficiency: (j['finDrawingEfficiency'] as num).toDouble(),
        finDrawingUtilisation: (j['finDrawingUtilisation'] as num).toDouble(),
        preComberMpm: (j['preComberMpm'] as num).toDouble(),
        preComberHank: (j['preComberHank'] as num).toDouble(),
        preComberEfficiency: (j['preComberEfficiency'] as num).toDouble(),
        preComberDrawingUtilisation:
            (j['preComberDrawingUtilisation'] as num).toDouble(),
        comberNpm: (j['comberNpm'] as num).toDouble(),
        comberLapWeightGpyd: (j['comberLapWeightGpyd'] as num).toDouble(),
        comberNoilPct: (j['comberNoilPct'] as num).toDouble(),
        comberEfficiency: (j['comberEfficiency'] as num).toDouble(),
        comberUtilisation: (j['comberUtilisation'] as num).toDouble(),
        lapFormerMpm: (j['lapFormerMpm'] as num).toDouble(),
        lapFormerLapWeightGpyd:
            (j['lapFormerLapWeightGpyd'] as num).toDouble(),
        lapFormerEfficiency: (j['lapFormerEfficiency'] as num).toDouble(),
        cardingKgPerHr: (j['cardingKgPerHr'] as num).toDouble(),
        cardingEfficiency: (j['cardingEfficiency'] as num).toDouble(),
        blowRoomKgPerHr: (j['blowRoomKgPerHr'] as num).toDouble(),
        blowRoomEfficiency: (j['blowRoomEfficiency'] as num).toDouble(),
        windingMpm: (j['windingMpm'] as num).toDouble(),
        windingEfficiency: (j['windingEfficiency'] as num).toDouble(),
        windingUtilisation: (j['windingUtilisation'] as num).toDouble(),
      );
}

// ── Exact values from costing1_16.xlsx spin plan columns D–N ─────────────────
// Brackets are ordered finest→coarsest: 1=240–300s … 11=5–10s
//
// Utilisation exceptions (all others use the column-standard value):
//   Fin Drawing:    bracket 11 = 90%  (others 95%)
//   Pre-Cbr Draw:  bracket 11 = 90%  (others 95%)
//   Comber:        brackets 8–11 = 95%  (others 98%)
//   Winding:       bracket 11 = 90%  (others 97%)
//
// Lap Former Efficiency bracket 11 (5–10s): extrapolated as 77%
// (only 10 values supplied; pattern: 70% fine → 77% coarse)

const List<CountBracket> kDefaultBrackets = [
  // ── Bracket 1: 240–300s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 240, maxCount: 300,
    ringFrameEfficiency: 0.95,
    simplexHank: 3.2,  simplexSpeedRpm: 900,  simplexTM: 1.25, simplexEfficiency: 0.84,
    finDrawingMpm: 300,  finDrawingHank: 0.32, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 650,   preComberHank: 0.32,  preComberEfficiency: 0.95, preComberDrawingUtilisation: 0.95,
    comberNpm: 400, comberLapWeightGpyd: 60, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 60, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 10, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 350, blowRoomEfficiency: 0.85,
    windingMpm: 900,  windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 2: 200–240s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 200, maxCount: 240,
    ringFrameEfficiency: 0.95,
    simplexHank: 2.8,  simplexSpeedRpm: 900,  simplexTM: 1.25, simplexEfficiency: 0.84,
    finDrawingMpm: 325,  finDrawingHank: 0.28, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 700,   preComberHank: 0.28,  preComberEfficiency: 0.95, preComberDrawingUtilisation: 0.95,
    comberNpm: 400, comberLapWeightGpyd: 60, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 60, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 15, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 350, blowRoomEfficiency: 0.85,
    windingMpm: 950,  windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 3: 160–200s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 160, maxCount: 200,
    ringFrameEfficiency: 0.95,
    simplexHank: 2.4,  simplexSpeedRpm: 900,  simplexTM: 1.20, simplexEfficiency: 0.84,
    finDrawingMpm: 375,  finDrawingHank: 0.24, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 750,   preComberHank: 0.24,  preComberEfficiency: 0.93, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 65, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 65, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 20, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 350, blowRoomEfficiency: 0.85,
    windingMpm: 1000, windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 4: 130–160s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 130, maxCount: 160,
    ringFrameEfficiency: 0.95,
    simplexHank: 2.2,  simplexSpeedRpm: 950,  simplexTM: 1.20, simplexEfficiency: 0.84,
    finDrawingMpm: 400,  finDrawingHank: 0.22, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 750,   preComberHank: 0.22,  preComberEfficiency: 0.93, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 65, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 65, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 22, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 400, blowRoomEfficiency: 0.85,
    windingMpm: 1100, windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 5: 100–130s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 100, maxCount: 130,
    ringFrameEfficiency: 0.95,
    simplexHank: 2.0,  simplexSpeedRpm: 1000, simplexTM: 1.20, simplexEfficiency: 0.84,
    finDrawingMpm: 450,  finDrawingHank: 0.20, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 750,   preComberHank: 0.20,  preComberEfficiency: 0.92, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 68, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 68, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 30, cardingEfficiency: 0.95,
    blowRoomKgPerHr: 400, blowRoomEfficiency: 0.85,
    windingMpm: 1200, windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 6: 80–100s ← REFERENCE (94s lands here) ──────────────────────
  CountBracket(
    minCount: 80, maxCount: 100,
    ringFrameEfficiency: 0.95,
    simplexHank: 1.8,  simplexSpeedRpm: 1000, simplexTM: 1.20, simplexEfficiency: 0.84,
    finDrawingMpm: 450,  finDrawingHank: 0.18, finDrawingEfficiency: 0.88, finDrawingUtilisation: 0.95,
    preComberMpm: 750,   preComberHank: 0.18,  preComberEfficiency: 0.92, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 68, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 160, lapFormerLapWeightGpyd: 68, lapFormerEfficiency: 0.70,
    cardingKgPerHr: 35, cardingEfficiency: 0.95,
    blowRoomKgPerHr: 450, blowRoomEfficiency: 0.85,
    windingMpm: 1200, windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 7: 60–80s ─────────────────────────────────────────────────────
  CountBracket(
    minCount: 60, maxCount: 80,
    ringFrameEfficiency: 0.95,
    simplexHank: 1.6,  simplexSpeedRpm: 1100, simplexTM: 1.20, simplexEfficiency: 0.80,
    finDrawingMpm: 450,  finDrawingHank: 0.16, finDrawingEfficiency: 0.85, finDrawingUtilisation: 0.95,
    preComberMpm: 750,   preComberHank: 0.16,  preComberEfficiency: 0.90, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 70, comberNoilPct: 18, comberEfficiency: 0.912, comberUtilisation: 0.98,
    lapFormerMpm: 180, lapFormerLapWeightGpyd: 70, lapFormerEfficiency: 0.75,
    cardingKgPerHr: 40, cardingEfficiency: 0.95,
    blowRoomKgPerHr: 450, blowRoomEfficiency: 0.85,
    windingMpm: 1300, windingEfficiency: 0.75, windingUtilisation: 0.97,
  ),
  // ── Bracket 8: 40–60s ─────────────────────────────────────────────────────
  CountBracket(
    minCount: 40, maxCount: 60,
    ringFrameEfficiency: 0.96,
    simplexHank: 1.2,  simplexSpeedRpm: 1150, simplexTM: 1.20, simplexEfficiency: 0.80,
    finDrawingMpm: 450,  finDrawingHank: 0.12, finDrawingEfficiency: 0.83, finDrawingUtilisation: 0.95,
    preComberMpm: 800,   preComberHank: 0.12,  preComberEfficiency: 0.90, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 70, comberNoilPct: 18, comberEfficiency: 0.88, comberUtilisation: 0.95,
    lapFormerMpm: 180, lapFormerLapWeightGpyd: 70, lapFormerEfficiency: 0.75,
    cardingKgPerHr: 45, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 450, blowRoomEfficiency: 0.85,
    windingMpm: 1300, windingEfficiency: 0.70, windingUtilisation: 0.97,
  ),
  // ── Bracket 9: 20–40s ─────────────────────────────────────────────────────
  CountBracket(
    minCount: 20, maxCount: 40,
    ringFrameEfficiency: 0.96,
    simplexHank: 1.0,  simplexSpeedRpm: 1150, simplexTM: 1.25, simplexEfficiency: 0.80,
    finDrawingMpm: 450,  finDrawingHank: 0.10, finDrawingEfficiency: 0.82, finDrawingUtilisation: 0.95,
    preComberMpm: 850,   preComberHank: 0.10,  preComberEfficiency: 0.90, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 70, comberNoilPct: 18, comberEfficiency: 0.88, comberUtilisation: 0.95,
    lapFormerMpm: 180, lapFormerLapWeightGpyd: 70, lapFormerEfficiency: 0.76,
    cardingKgPerHr: 60, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 500, blowRoomEfficiency: 0.85,
    windingMpm: 1300, windingEfficiency: 0.65, windingUtilisation: 0.97,
  ),
  // ── Bracket 10: 10–20s ────────────────────────────────────────────────────
  CountBracket(
    minCount: 10, maxCount: 20,
    ringFrameEfficiency: 0.95,
    simplexHank: 0.7,  simplexSpeedRpm: 1100, simplexTM: 1.25, simplexEfficiency: 0.80,
    finDrawingMpm: 450,  finDrawingHank: 0.07, finDrawingEfficiency: 0.80, finDrawingUtilisation: 0.95,
    preComberMpm: 850,   preComberHank: 0.07,  preComberEfficiency: 0.90, preComberDrawingUtilisation: 0.95,
    comberNpm: 450, comberLapWeightGpyd: 70, comberNoilPct: 18, comberEfficiency: 0.88, comberUtilisation: 0.95,
    lapFormerMpm: 180, lapFormerLapWeightGpyd: 70, lapFormerEfficiency: 0.77,
    cardingKgPerHr: 75, cardingEfficiency: 0.98,
    blowRoomKgPerHr: 500, blowRoomEfficiency: 0.85,
    windingMpm: 1300, windingEfficiency: 0.65, windingUtilisation: 0.97,
  ),
  // ── Bracket 11: 5–10s ─────────────────────────────────────────────────────
  // Lap Former Efficiency extrapolated as 77% (10 values supplied; continues bracket 10)
  CountBracket(
    minCount: 5, maxCount: 10,
    ringFrameEfficiency: 0.95,
    simplexHank: 0.4,  simplexSpeedRpm: 1000, simplexTM: 1.30, simplexEfficiency: 0.80,
    finDrawingMpm: 550,  finDrawingHank: 0.04, finDrawingEfficiency: 0.80, finDrawingUtilisation: 0.90,
    preComberMpm: 850,   preComberHank: 0.04,  preComberEfficiency: 0.90, preComberDrawingUtilisation: 0.90,
    comberNpm: 450, comberLapWeightGpyd: 70, comberNoilPct: 18, comberEfficiency: 0.88, comberUtilisation: 0.95,
    lapFormerMpm: 180, lapFormerLapWeightGpyd: 70, lapFormerEfficiency: 0.77,
    cardingKgPerHr: 85, cardingEfficiency: 0.95,
    blowRoomKgPerHr: 500, blowRoomEfficiency: 0.85,
    windingMpm: 1300, windingEfficiency: 0.60, windingUtilisation: 0.90,
  ),
];
