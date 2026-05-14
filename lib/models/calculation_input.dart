import 'count_bracket.dart';

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
  final double resultantCount; // Ne, user-entered (e.g. 94)
  final YarnType yarnType;
  final int plies; // 1 for single, 2 for doubled

  // ── Machine params (auto-filled from bracket, editable) ─────────────────────
  final CountBracket bracket;
  final double spindleSpeedRpm; // ring frame
  final double twistMultiplier; // TM
  final double utilisationPct; // ring frame utilisation %

  // ── Material ────────────────────────────────────────────────────────────────
  final double cottonPricePerCandy; // ₹/candy (1 candy = 356 kg)
  final bool isBlend;
  final double blend1Pct; // % of cotton (blend 1)
  final double blend2PricePerKg; // ₹/kg
  final double blend2WastePct; // % waste of blend 2
  final double blend2Pct; // % of blend 2

  // ── Waste rates (overridable per run) ────────────────────────────────────────
  final double blowRoomWastePct;
  final double cardingWastePct;
  final double comberNoilPct;
  final double yarnWastePct;

  // ── Energy & packing ────────────────────────────────────────────────────────
  final double electricityRatePerKwh;
  final double packingRatePerKg;
  final double additionalPackingForPlied;

  // ── Price / margin ──────────────────────────────────────────────────────────
  // priceMode: 'price' → user enters sellingPrice → app shows profit
  //            'margin' → user enters targetMarginPct → app shows required price
  final String priceMode; // 'price' | 'margin'
  final double sellingPricePerKg; // used when priceMode == 'price'
  final double targetMarginPct; // used when priceMode == 'margin'

  const CalculationInput({
    required this.resultantCount,
    required this.yarnType,
    required this.plies,
    required this.bracket,
    required this.spindleSpeedRpm,
    required this.twistMultiplier,
    required this.utilisationPct,
    required this.cottonPricePerCandy,
    required this.isBlend,
    required this.blend1Pct,
    required this.blend2PricePerKg,
    required this.blend2WastePct,
    required this.blend2Pct,
    required this.blowRoomWastePct,
    required this.cardingWastePct,
    required this.comberNoilPct,
    required this.yarnWastePct,
    required this.electricityRatePerKwh,
    required this.packingRatePerKg,
    required this.additionalPackingForPlied,
    required this.priceMode,
    required this.sellingPricePerKg,
    required this.targetMarginPct,
  });

  // Actual spinning count (halved for 2-ply)
  double get actualCount => resultantCount / plies;

  // Default input from RST 2 reference scenario
  static CalculationInput reference(CountBracket bracket) => CalculationInput(
        resultantCount: 94,
        yarnType: YarnType.tfoDoubled,
        plies: 2,
        bracket: bracket,
        spindleSpeedRpm: 16500,
        twistMultiplier: 4.2,
        utilisationPct: 98,
        cottonPricePerCandy: 75000,
        isBlend: false,
        blend1Pct: 100,
        blend2PricePerKg: 0,
        blend2WastePct: 0,
        blend2Pct: 0,
        blowRoomWastePct: 5.0,
        cardingWastePct: 6.65,
        comberNoilPct: 15.9,
        yarnWastePct: 1.09,
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
    CountBracket? bracket,
    double? spindleSpeedRpm,
    double? twistMultiplier,
    double? utilisationPct,
    double? cottonPricePerCandy,
    bool? isBlend,
    double? blend1Pct,
    double? blend2PricePerKg,
    double? blend2WastePct,
    double? blend2Pct,
    double? blowRoomWastePct,
    double? cardingWastePct,
    double? comberNoilPct,
    double? yarnWastePct,
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
      bracket: bracket ?? this.bracket,
      spindleSpeedRpm: spindleSpeedRpm ?? this.spindleSpeedRpm,
      twistMultiplier: twistMultiplier ?? this.twistMultiplier,
      utilisationPct: utilisationPct ?? this.utilisationPct,
      cottonPricePerCandy: cottonPricePerCandy ?? this.cottonPricePerCandy,
      isBlend: isBlend ?? this.isBlend,
      blend1Pct: blend1Pct ?? this.blend1Pct,
      blend2PricePerKg: blend2PricePerKg ?? this.blend2PricePerKg,
      blend2WastePct: blend2WastePct ?? this.blend2WastePct,
      blend2Pct: blend2Pct ?? this.blend2Pct,
      blowRoomWastePct: blowRoomWastePct ?? this.blowRoomWastePct,
      cardingWastePct: cardingWastePct ?? this.cardingWastePct,
      comberNoilPct: comberNoilPct ?? this.comberNoilPct,
      yarnWastePct: yarnWastePct ?? this.yarnWastePct,
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
