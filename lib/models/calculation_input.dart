import 'count_bracket.dart';

/// Spinning process route — independent of yarn type.
/// Carded: Blow Room → Cards → Drawing → Simplex → Ring
/// Combed: Blow Room → Cards → Pre-Comber Drawing → Lap Former → Comber → Finisher Drawing → Simplex → Ring
enum ProcessType {
  combed,
  carded;

  String get label => this == combed ? 'Combed' : 'Carded';
}

enum YarnType {
  single('Single'),
  tfoDoubled('TFO Doubled'),
  oe('OE (Open End)'),
  wrapper('Wrapper');

  final String label;
  const YarnType(this.label);

  bool get isCombed => this == single || this == tfoDoubled;
  bool get isPlied => this == tfoDoubled;
  bool get isOe => this == oe;
  bool get isWrapper => this == wrapper;
  bool get isAvailable => this == single || this == tfoDoubled;
}

class CalculationInput {
  // ── Yarn ────────────────────────────────────────────────────────────────────
  final double resultantCount; // Ne of final yarn delivered to customer (e.g. 94)
  final YarnType yarnType;
  final int plies; // 1 for single, 2 for doubled
  final ProcessType processType; // combed or carded spinning route

  // ── Machine params (auto-filled from bracket, editable) ─────────────────────
  final CountBracket bracket;
  final double spindleSpeedRpm; // ring frame
  final double twistMultiplier; // TM
  final double utilisationPct; // ring frame utilisation %

  // ── Material ────────────────────────────────────────────────────────────────
  final double cottonPricePerCandy; // ₹/candy (1 candy = 356 kg)
  // yarnRealisationPct: user-entered FRONT END F16 (e.g. 70.0)
  // Used for material cost formula. Separate from the spin-plan computed realisation.
  final double yarnRealisationPct;
  final bool isBlend;
  final double blend1Pct; // % of cotton (blend 1)
  final double blend2PricePerKg; // ₹/kg
  final double blend2WastePct; // % waste of blend 2
  final double blend2Pct; // % of blend 2

  // ── Waste rates used in waste-credit calculation ─────────────────────────────
  final double blowRoomWastePct;  // % of raw cotton input
  final double cardingWastePct;   // % of raw cotton input
  final double comberNoilPct;     // % removed by comber

  // yarnWasteCostPct: FRONT END F27 — fraction of cost attributed to yarn waste
  // For single yarn: 0.5%, for plied: also 0.5%. NOT the same as physical waste%.
  final double yarnWasteCostPct;

  // ── Energy & packing ────────────────────────────────────────────────────────
  final double electricityRatePerKwh;
  final double packingRatePerKg;
  final double additionalPackingForPlied;

  // ── Price / margin ──────────────────────────────────────────────────────────
  final String priceMode; // 'price' | 'margin'
  final double sellingPricePerKg;
  final double targetMarginPct;

  const CalculationInput({
    required this.resultantCount,
    required this.yarnType,
    required this.plies,
    this.processType = ProcessType.combed,
    required this.bracket,
    required this.spindleSpeedRpm,
    required this.twistMultiplier,
    required this.utilisationPct,
    required this.cottonPricePerCandy,
    required this.yarnRealisationPct,
    required this.isBlend,
    required this.blend1Pct,
    required this.blend2PricePerKg,
    required this.blend2WastePct,
    required this.blend2Pct,
    required this.blowRoomWastePct,
    required this.cardingWastePct,
    required this.comberNoilPct,
    required this.yarnWasteCostPct,
    required this.electricityRatePerKwh,
    required this.packingRatePerKg,
    required this.additionalPackingForPlied,
    required this.priceMode,
    required this.sellingPricePerKg,
    required this.targetMarginPct,
  });

  // Actual count being spun on the ring frame:
  // - TFO Doubled: ring spins full-count singles (94s), so actualCount = resultantCount
  // - Ring Doubled: ring itself plies, so each spindle runs at resultantCount/2
  // - Single:       actualCount = resultantCount
  double get actualCount {
    if (yarnType == YarnType.tfoDoubled || yarnType == YarnType.single) {
      return resultantCount;
    }
    return resultantCount / plies;
  }

  // Reference scenario: 94s combed compact 2-ply TFO, RST 2, MCU5 cotton
  static CalculationInput reference(CountBracket bracket) => CalculationInput(
        resultantCount: 94,
        yarnType: YarnType.tfoDoubled,
        plies: 2,
        bracket: bracket,
        spindleSpeedRpm: 16500,
        twistMultiplier: 4.2,
        utilisationPct: 98,
        cottonPricePerCandy: 75000,
        yarnRealisationPct: 70.0, // FRONT END F16, user-entered
        isBlend: false,
        blend1Pct: 100,
        blend2PricePerKg: 0,
        blend2WastePct: 0,
        blend2Pct: 0,
        blowRoomWastePct: 5.0,
        cardingWastePct: 6.65,
        comberNoilPct: 15.9,
        yarnWasteCostPct: 0.5, // FRONT END F27 — cost component %, not physical waste
        electricityRatePerKwh: 8.0,
        packingRatePerKg: 8.0,
        additionalPackingForPlied: 1.0,
        priceMode: 'price',
        sellingPricePerKg: 380,
        targetMarginPct: 10,
      );

  CalculationInput copyWith({
    double? resultantCount,
    YarnType? yarnType,
    int? plies,
    ProcessType? processType,
    CountBracket? bracket,
    double? spindleSpeedRpm,
    double? twistMultiplier,
    double? utilisationPct,
    double? cottonPricePerCandy,
    double? yarnRealisationPct,
    bool? isBlend,
    double? blend1Pct,
    double? blend2PricePerKg,
    double? blend2WastePct,
    double? blend2Pct,
    double? blowRoomWastePct,
    double? cardingWastePct,
    double? comberNoilPct,
    double? yarnWasteCostPct,
    double? electricityRatePerKwh,
    double? packingRatePerKg,
    double? additionalPackingForPlied,
    String? priceMode,
    double? sellingPricePerKg,
    double? targetMarginPct,
  }) {
    return CalculationInput(
      resultantCount: resultantCount ?? this.resultantCount,
      yarnType: yarnType ?? this.yarnType,
      plies: plies ?? this.plies,
      processType: processType ?? this.processType,
      bracket: bracket ?? this.bracket,
      spindleSpeedRpm: spindleSpeedRpm ?? this.spindleSpeedRpm,
      twistMultiplier: twistMultiplier ?? this.twistMultiplier,
      utilisationPct: utilisationPct ?? this.utilisationPct,
      cottonPricePerCandy: cottonPricePerCandy ?? this.cottonPricePerCandy,
      yarnRealisationPct: yarnRealisationPct ?? this.yarnRealisationPct,
      isBlend: isBlend ?? this.isBlend,
      blend1Pct: blend1Pct ?? this.blend1Pct,
      blend2PricePerKg: blend2PricePerKg ?? this.blend2PricePerKg,
      blend2WastePct: blend2WastePct ?? this.blend2WastePct,
      blend2Pct: blend2Pct ?? this.blend2Pct,
      blowRoomWastePct: blowRoomWastePct ?? this.blowRoomWastePct,
      cardingWastePct: cardingWastePct ?? this.cardingWastePct,
      comberNoilPct: comberNoilPct ?? this.comberNoilPct,
      yarnWasteCostPct: yarnWasteCostPct ?? this.yarnWasteCostPct,
      electricityRatePerKwh:
          electricityRatePerKwh ?? this.electricityRatePerKwh,
      packingRatePerKg: packingRatePerKg ?? this.packingRatePerKg,
      additionalPackingForPlied:
          additionalPackingForPlied ?? this.additionalPackingForPlied,
      priceMode: priceMode ?? this.priceMode,
      sellingPricePerKg: sellingPricePerKg ?? this.sellingPricePerKg,
      targetMarginPct: targetMarginPct ?? this.targetMarginPct,
    );
  }
}
