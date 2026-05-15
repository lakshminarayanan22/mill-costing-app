import 'count_bracket.dart';

enum YarnType { single, tfoDoubled, oe, wrapper }

class MillProfile {
  final String id;
  final String name;

  // ── Ring frame ──────────────────────────────────────────────────────────────
  final int ringFrameCount; // number of frames installed
  final int spindlesPerFrame;

  // ── Simplex ─────────────────────────────────────────────────────────────────
  final int simplexMachines;
  final int simplexSpindlesPerMachine;

  // ── Drawing ─────────────────────────────────────────────────────────────────
  final int finDrawingMachines;
  final int finDrawingDeliveriesPerMachine;
  final int preComberDrawingMachines;
  final int preComberDeliveriesPerMachine;

  // ── Comber & lap former ─────────────────────────────────────────────────────
  final int combers;
  final int lapFormers;

  // ── Carding & blow room ─────────────────────────────────────────────────────
  final int cards;
  final int blowRoomLines;

  // ── Winding ─────────────────────────────────────────────────────────────────
  final int windingMachines;
  final int drumsPerWindingMachine;

  // ── TFO ─────────────────────────────────────────────────────────────────────
  final int tfoSpindles;
  final double tfoInstalledKw;
  final double tfoSpindleSpeedRpm;

  // ── Ring frame machine specs ────────────────────────────────────────────────
  final double ringDiaMm;
  final double spindleLiftInches;
  final bool compactSpinning;

  // ── Overhead power loads (kW) ────────────────────────────────────────────────
  final double humidificationKw;
  final double compressorKw;
  final double lightingKw;
  final double generalKw; // YCP, cable losses, misc

  // ── Financial (in ₹ lakhs/year unless noted) ────────────────────────────────
  final double workingCapitalLakhs;
  final double annualDepreciationLakhs;
  final double annualOverheadsLakhs;
  final double interestRatePct; // annual % e.g. 12.0

  // ── Staff & wages ────────────────────────────────────────────────────────────
  final int staffCount;
  final double monthlyStaffSalary;
  final double dailyWageRate;
  final int indirectStaff; // sweeping, fitters, electrical etc.

  // ── Labour norms (kg per shift per operative, or machines per operative) ────
  final double windingDrumsPerSider;
  final double rfSpindlesPerSider;
  final double copWeightKg;

  // ── Waste rates (defaults, user can override per run) ───────────────────────
  final double blowRoomWastePct; // e.g. 5.0
  final double cardingWastePct; // e.g. 6.65
  final double yarnWastePct; // e.g. 1.09 (ring + winding)
  final double invisibleLossPct; // e.g. 1.5

  // ── Waste sale rates (₹/kg) ─────────────────────────────────────────────────
  final double blowRoomWasteRate;
  final double cardingWasteRate;
  final double comberNoilRate;
  final double yarnWasteRate;

  // ── Count brackets (11 slots) ───────────────────────────────────────────────
  final List<CountBracket> brackets;

  const MillProfile({
    required this.id,
    required this.name,
    required this.ringFrameCount,
    required this.spindlesPerFrame,
    required this.simplexMachines,
    required this.simplexSpindlesPerMachine,
    required this.finDrawingMachines,
    required this.finDrawingDeliveriesPerMachine,
    required this.preComberDrawingMachines,
    required this.preComberDeliveriesPerMachine,
    required this.combers,
    required this.lapFormers,
    required this.cards,
    required this.blowRoomLines,
    required this.windingMachines,
    required this.drumsPerWindingMachine,
    required this.tfoSpindles,
    required this.tfoInstalledKw,
    required this.tfoSpindleSpeedRpm,
    required this.ringDiaMm,
    required this.spindleLiftInches,
    required this.compactSpinning,
    required this.humidificationKw,
    required this.compressorKw,
    required this.lightingKw,
    required this.generalKw,
    required this.workingCapitalLakhs,
    required this.annualDepreciationLakhs,
    required this.annualOverheadsLakhs,
    required this.interestRatePct,
    required this.staffCount,
    required this.monthlyStaffSalary,
    required this.dailyWageRate,
    required this.indirectStaff,
    required this.windingDrumsPerSider,
    required this.rfSpindlesPerSider,
    required this.copWeightKg,
    required this.blowRoomWastePct,
    required this.cardingWastePct,
    required this.yarnWastePct,
    required this.invisibleLossPct,
    required this.blowRoomWasteRate,
    required this.cardingWasteRate,
    required this.comberNoilRate,
    required this.yarnWasteRate,
    required this.brackets,
  });

  // ── Derived convenience getters ──────────────────────────────────────────────
  int get totalSpindles => ringFrameCount * spindlesPerFrame;
  int get simplexSpindlesInstalled => simplexMachines * simplexSpindlesPerMachine;
  int get finDrawingDeliveriesInstalled =>
      finDrawingMachines * finDrawingDeliveriesPerMachine;
  int get preComberDeliveriesInstalled =>
      preComberDrawingMachines * preComberDeliveriesPerMachine;
  int get windingDrumsInstalled => windingMachines * drumsPerWindingMachine;

  CountBracket? bracketFor(double count) {
    try {
      return brackets.firstWhere((b) => b.contains(count));
    } catch (_) {
      return null;
    }
  }

  MillProfile copyWith({
    String? id,
    String? name,
    int? ringFrameCount,
    int? spindlesPerFrame,
    int? simplexMachines,
    int? simplexSpindlesPerMachine,
    int? finDrawingMachines,
    int? finDrawingDeliveriesPerMachine,
    int? preComberDrawingMachines,
    int? preComberDeliveriesPerMachine,
    int? combers,
    int? lapFormers,
    int? cards,
    int? blowRoomLines,
    int? windingMachines,
    int? drumsPerWindingMachine,
    int? tfoSpindles,
    double? tfoInstalledKw,
    double? tfoSpindleSpeedRpm,
    double? ringDiaMm,
    double? spindleLiftInches,
    bool? compactSpinning,
    double? humidificationKw,
    double? compressorKw,
    double? lightingKw,
    double? generalKw,
    double? workingCapitalLakhs,
    double? annualDepreciationLakhs,
    double? annualOverheadsLakhs,
    double? interestRatePct,
    int? staffCount,
    double? monthlyStaffSalary,
    double? dailyWageRate,
    int? indirectStaff,
    double? windingDrumsPerSider,
    double? rfSpindlesPerSider,
    double? copWeightKg,
    double? blowRoomWastePct,
    double? cardingWastePct,
    double? yarnWastePct,
    double? invisibleLossPct,
    double? blowRoomWasteRate,
    double? cardingWasteRate,
    double? comberNoilRate,
    double? yarnWasteRate,
    List<CountBracket>? brackets,
  }) {
    return MillProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      ringFrameCount: ringFrameCount ?? this.ringFrameCount,
      spindlesPerFrame: spindlesPerFrame ?? this.spindlesPerFrame,
      simplexMachines: simplexMachines ?? this.simplexMachines,
      simplexSpindlesPerMachine:
          simplexSpindlesPerMachine ?? this.simplexSpindlesPerMachine,
      finDrawingMachines: finDrawingMachines ?? this.finDrawingMachines,
      finDrawingDeliveriesPerMachine:
          finDrawingDeliveriesPerMachine ?? this.finDrawingDeliveriesPerMachine,
      preComberDrawingMachines:
          preComberDrawingMachines ?? this.preComberDrawingMachines,
      preComberDeliveriesPerMachine:
          preComberDeliveriesPerMachine ?? this.preComberDeliveriesPerMachine,
      combers: combers ?? this.combers,
      lapFormers: lapFormers ?? this.lapFormers,
      cards: cards ?? this.cards,
      blowRoomLines: blowRoomLines ?? this.blowRoomLines,
      windingMachines: windingMachines ?? this.windingMachines,
      drumsPerWindingMachine:
          drumsPerWindingMachine ?? this.drumsPerWindingMachine,
      tfoSpindles: tfoSpindles ?? this.tfoSpindles,
      tfoInstalledKw: tfoInstalledKw ?? this.tfoInstalledKw,
      tfoSpindleSpeedRpm: tfoSpindleSpeedRpm ?? this.tfoSpindleSpeedRpm,
      ringDiaMm: ringDiaMm ?? this.ringDiaMm,
      spindleLiftInches: spindleLiftInches ?? this.spindleLiftInches,
      compactSpinning: compactSpinning ?? this.compactSpinning,
      humidificationKw: humidificationKw ?? this.humidificationKw,
      compressorKw: compressorKw ?? this.compressorKw,
      lightingKw: lightingKw ?? this.lightingKw,
      generalKw: generalKw ?? this.generalKw,
      workingCapitalLakhs: workingCapitalLakhs ?? this.workingCapitalLakhs,
      annualDepreciationLakhs:
          annualDepreciationLakhs ?? this.annualDepreciationLakhs,
      annualOverheadsLakhs: annualOverheadsLakhs ?? this.annualOverheadsLakhs,
      interestRatePct: interestRatePct ?? this.interestRatePct,
      staffCount: staffCount ?? this.staffCount,
      monthlyStaffSalary: monthlyStaffSalary ?? this.monthlyStaffSalary,
      dailyWageRate: dailyWageRate ?? this.dailyWageRate,
      indirectStaff: indirectStaff ?? this.indirectStaff,
      windingDrumsPerSider: windingDrumsPerSider ?? this.windingDrumsPerSider,
      rfSpindlesPerSider: rfSpindlesPerSider ?? this.rfSpindlesPerSider,
      copWeightKg: copWeightKg ?? this.copWeightKg,
      blowRoomWastePct: blowRoomWastePct ?? this.blowRoomWastePct,
      cardingWastePct: cardingWastePct ?? this.cardingWastePct,
      yarnWastePct: yarnWastePct ?? this.yarnWastePct,
      invisibleLossPct: invisibleLossPct ?? this.invisibleLossPct,
      blowRoomWasteRate: blowRoomWasteRate ?? this.blowRoomWasteRate,
      cardingWasteRate: cardingWasteRate ?? this.cardingWasteRate,
      comberNoilRate: comberNoilRate ?? this.comberNoilRate,
      yarnWasteRate: yarnWasteRate ?? this.yarnWasteRate,
      brackets: brackets ?? this.brackets,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ringFrameCount': ringFrameCount,
        'spindlesPerFrame': spindlesPerFrame,
        'simplexMachines': simplexMachines,
        'simplexSpindlesPerMachine': simplexSpindlesPerMachine,
        'finDrawingMachines': finDrawingMachines,
        'finDrawingDeliveriesPerMachine': finDrawingDeliveriesPerMachine,
        'preComberDrawingMachines': preComberDrawingMachines,
        'preComberDeliveriesPerMachine': preComberDeliveriesPerMachine,
        'combers': combers,
        'lapFormers': lapFormers,
        'cards': cards,
        'blowRoomLines': blowRoomLines,
        'windingMachines': windingMachines,
        'drumsPerWindingMachine': drumsPerWindingMachine,
        'tfoSpindles': tfoSpindles,
        'tfoInstalledKw': tfoInstalledKw,
        'tfoSpindleSpeedRpm': tfoSpindleSpeedRpm,
        'ringDiaMm': ringDiaMm,
        'spindleLiftInches': spindleLiftInches,
        'compactSpinning': compactSpinning,
        'humidificationKw': humidificationKw,
        'compressorKw': compressorKw,
        'lightingKw': lightingKw,
        'generalKw': generalKw,
        'workingCapitalLakhs': workingCapitalLakhs,
        'annualDepreciationLakhs': annualDepreciationLakhs,
        'annualOverheadsLakhs': annualOverheadsLakhs,
        'interestRatePct': interestRatePct,
        'staffCount': staffCount,
        'monthlyStaffSalary': monthlyStaffSalary,
        'dailyWageRate': dailyWageRate,
        'indirectStaff': indirectStaff,
        'windingDrumsPerSider': windingDrumsPerSider,
        'rfSpindlesPerSider': rfSpindlesPerSider,
        'copWeightKg': copWeightKg,
        'blowRoomWastePct': blowRoomWastePct,
        'cardingWastePct': cardingWastePct,
        'yarnWastePct': yarnWastePct,
        'invisibleLossPct': invisibleLossPct,
        'blowRoomWasteRate': blowRoomWasteRate,
        'cardingWasteRate': cardingWasteRate,
        'comberNoilRate': comberNoilRate,
        'yarnWasteRate': yarnWasteRate,
        'brackets': brackets.map((b) => b.toJson()).toList(),
      };

  factory MillProfile.fromJson(Map<String, dynamic> j) => MillProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        ringFrameCount: j['ringFrameCount'] as int,
        spindlesPerFrame: j['spindlesPerFrame'] as int,
        simplexMachines: j['simplexMachines'] as int,
        simplexSpindlesPerMachine: j['simplexSpindlesPerMachine'] as int,
        finDrawingMachines: j['finDrawingMachines'] as int,
        finDrawingDeliveriesPerMachine:
            j['finDrawingDeliveriesPerMachine'] as int,
        preComberDrawingMachines: j['preComberDrawingMachines'] as int,
        preComberDeliveriesPerMachine:
            j['preComberDeliveriesPerMachine'] as int,
        combers: j['combers'] as int,
        lapFormers: j['lapFormers'] as int,
        cards: j['cards'] as int,
        blowRoomLines: j['blowRoomLines'] as int,
        windingMachines: j['windingMachines'] as int,
        drumsPerWindingMachine: j['drumsPerWindingMachine'] as int,
        tfoSpindles: j['tfoSpindles'] as int,
        tfoInstalledKw: (j['tfoInstalledKw'] as num).toDouble(),
        tfoSpindleSpeedRpm: (j['tfoSpindleSpeedRpm'] as num).toDouble(),
        ringDiaMm: (j['ringDiaMm'] as num).toDouble(),
        spindleLiftInches: (j['spindleLiftInches'] as num).toDouble(),
        compactSpinning: j['compactSpinning'] as bool,
        humidificationKw: (j['humidificationKw'] as num).toDouble(),
        compressorKw: (j['compressorKw'] as num).toDouble(),
        lightingKw: (j['lightingKw'] as num).toDouble(),
        generalKw: (j['generalKw'] as num).toDouble(),
        workingCapitalLakhs: (j['workingCapitalLakhs'] as num).toDouble(),
        annualDepreciationLakhs:
            (j['annualDepreciationLakhs'] as num).toDouble(),
        annualOverheadsLakhs: (j['annualOverheadsLakhs'] as num).toDouble(),
        interestRatePct: (j['interestRatePct'] as num).toDouble(),
        staffCount: j['staffCount'] as int,
        monthlyStaffSalary: (j['monthlyStaffSalary'] as num).toDouble(),
        dailyWageRate: (j['dailyWageRate'] as num).toDouble(),
        indirectStaff: j['indirectStaff'] as int,
        windingDrumsPerSider: (j['windingDrumsPerSider'] as num).toDouble(),
        rfSpindlesPerSider: (j['rfSpindlesPerSider'] as num).toDouble(),
        copWeightKg: (j['copWeightKg'] as num).toDouble(),
        blowRoomWastePct: (j['blowRoomWastePct'] as num).toDouble(),
        cardingWastePct: (j['cardingWastePct'] as num).toDouble(),
        yarnWastePct: (j['yarnWastePct'] as num).toDouble(),
        invisibleLossPct: (j['invisibleLossPct'] as num).toDouble(),
        blowRoomWasteRate: (j['blowRoomWasteRate'] as num).toDouble(),
        cardingWasteRate: (j['cardingWasteRate'] as num).toDouble(),
        comberNoilRate: (j['comberNoilRate'] as num).toDouble(),
        yarnWasteRate: (j['yarnWasteRate'] as num).toDouble(),
        brackets: (j['brackets'] as List)
            .map((e) => CountBracket.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // RST 2 reference mill — matches costing1_16.xlsx exactly
  static MillProfile get rst2 => MillProfile(
        id: 'rst2',
        name: 'RST 2',
        ringFrameCount: 14,
        spindlesPerFrame: 1200,
        simplexMachines: 4,
        simplexSpindlesPerMachine: 120,
        finDrawingMachines: 2,
        finDrawingDeliveriesPerMachine: 2,
        preComberDrawingMachines: 1,
        preComberDeliveriesPerMachine: 2,
        combers: 7,
        lapFormers: 7,
        cards: 7,
        blowRoomLines: 1,
        windingMachines: 14,
        drumsPerWindingMachine: 26,
        tfoSpindles: 4176,
        tfoInstalledKw: 560,
        tfoSpindleSpeedRpm: 10000,
        ringDiaMm: 38,
        spindleLiftInches: 7,
        compactSpinning: true,
        humidificationKw: 98,
        compressorKw: 24,
        lightingKw: 35,
        generalKw: 7,
        workingCapitalLakhs: 625,
        annualDepreciationLakhs: 200,
        annualOverheadsLakhs: 200,
        // Derived from reference: ₹62,154/day interest on ₹62.5M WC × 362 days = 36%
        interestRatePct: 36.0,
        staffCount: 17,
        monthlyStaffSalary: 30000,
        dailyWageRate: 300,
        indirectStaff: 70,
        windingDrumsPerSider: 30,
        rfSpindlesPerSider: 1864,
        copWeightKg: 0.045,
        blowRoomWastePct: 5.0,
        cardingWastePct: 6.65,
        yarnWastePct: 1.09,
        invisibleLossPct: 1.5,
        blowRoomWasteRate: 25,
        cardingWasteRate: 35,
        comberNoilRate: 90,
        yarnWasteRate: 20,
        brackets: kDefaultBrackets,
      );
}
