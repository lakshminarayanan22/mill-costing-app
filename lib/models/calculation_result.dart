// Output of the full costing calculation.
class CalculationResult {
  // ── Spin plan outputs ────────────────────────────────────────────────────────
  final double tpi;
  final double gPerSpindle8Hr;
  final double kgPerSpindleDay;
  final double grossKgPerDay; // before utilisation
  final double netKgPerDay; // after utilisation (ring yarn to winding)
  final double rawCottonKgPerDay;
  final double realisationPct;

  // ── Machine requirements vs installed ────────────────────────────────────────
  final double simplexSpindlesRequired;
  final int simplexSpindlesInstalled;

  final double finDrawingDeliveriesRequired;
  final int finDrawingDeliveriesInstalled;

  final double combersRequired;
  final int combersInstalled;

  final double lapFormersRequired;
  final int lapFormersInstalled;

  final double preComberDeliveriesRequired;
  final int preComberDeliveriesInstalled;

  final double cardsRequired;
  final int cardsInstalled;

  final double blowRoomLinesRequired;
  final int blowRoomLinesInstalled;

  final double windingDrumsRequired;
  final int windingDrumsInstalled;

  // ── Power ────────────────────────────────────────────────────────────────────
  final double totalUkg; // units (kWh) per kg yarn
  final double spinningUkg; // ring frame + prep machines only
  final double overheadUkg; // humidif + compressor + lighting + general
  final double tfoUkg; // TFO add-on (0 for single)

  // ── Labour ──────────────────────────────────────────────────────────────────
  final double directOperativesPerDay;
  final double indirectOperativesPerDay;
  final double totalOperativesPerDay;

  // ── 8 Cost components (₹/kg) ─────────────────────────────────────────────────
  final double materialCost;
  final double labourCost;
  final double powerCost;
  final double packingCost;
  final double interestCost;
  final double depreciationCost;
  final double overheadCost;
  final double yarnWasteCost;
  final double tfoConversionCost; // 0 for single yarn

  // ── Process route ────────────────────────────────────────────────────────────
  final bool isCombed; // false = carded (hides comber capacity rows)

  // ── Profitability ────────────────────────────────────────────────────────────
  final double totalCostPerKg;
  final double singleYarnCostPerKg; // before TFO add-on
  final double sellingPricePerKg; // actual or back-calculated
  final double profitPerKg;
  final double netProfitPct;
  final double cashProfitPct;
  final double operatingProfitPct;
  final double breakEvenPrice;
  final double totalMillProfitPerDay;

  const CalculationResult({
    required this.tpi,
    required this.gPerSpindle8Hr,
    required this.kgPerSpindleDay,
    required this.grossKgPerDay,
    required this.netKgPerDay,
    required this.rawCottonKgPerDay,
    required this.realisationPct,
    required this.simplexSpindlesRequired,
    required this.simplexSpindlesInstalled,
    required this.finDrawingDeliveriesRequired,
    required this.finDrawingDeliveriesInstalled,
    required this.combersRequired,
    required this.combersInstalled,
    required this.lapFormersRequired,
    required this.lapFormersInstalled,
    required this.preComberDeliveriesRequired,
    required this.preComberDeliveriesInstalled,
    required this.cardsRequired,
    required this.cardsInstalled,
    required this.blowRoomLinesRequired,
    required this.blowRoomLinesInstalled,
    required this.windingDrumsRequired,
    required this.windingDrumsInstalled,
    required this.totalUkg,
    required this.spinningUkg,
    required this.overheadUkg,
    required this.tfoUkg,
    required this.directOperativesPerDay,
    required this.indirectOperativesPerDay,
    required this.totalOperativesPerDay,
    required this.materialCost,
    required this.labourCost,
    required this.powerCost,
    required this.packingCost,
    required this.interestCost,
    required this.depreciationCost,
    required this.overheadCost,
    required this.yarnWasteCost,
    required this.tfoConversionCost,
    this.isCombed = true,
    required this.totalCostPerKg,
    required this.singleYarnCostPerKg,
    required this.sellingPricePerKg,
    required this.profitPerKg,
    required this.netProfitPct,
    required this.cashProfitPct,
    required this.operatingProfitPct,
    required this.breakEvenPrice,
    required this.totalMillProfitPerDay,
  });

  // Capacity ratio: positive = spare capacity, negative = shortfall
  double get simplexCapacityRatio =>
      1 - (simplexSpindlesRequired / simplexSpindlesInstalled);
  double get finDrawingCapacityRatio =>
      1 - (finDrawingDeliveriesRequired / finDrawingDeliveriesInstalled);
  double get comberCapacityRatio =>
      1 - (combersRequired / combersInstalled);
  double get lapFormerCapacityRatio =>
      1 - (lapFormersRequired / lapFormersInstalled);
  double get preComberCapacityRatio =>
      1 - (preComberDeliveriesRequired / preComberDeliveriesInstalled);
  double get cardCapacityRatio =>
      1 - (cardsRequired / cardsInstalled);
  double get blowRoomCapacityRatio =>
      1 - (blowRoomLinesRequired / blowRoomLinesInstalled);
  double get windingCapacityRatio =>
      1 - (windingDrumsRequired / windingDrumsInstalled);

  bool get hasCapacityShortfall {
    final base = [
      simplexCapacityRatio,
      finDrawingCapacityRatio,
      cardCapacityRatio,
      blowRoomCapacityRatio,
      windingCapacityRatio,
    ];
    if (isCombed) {
      base.addAll([comberCapacityRatio, lapFormerCapacityRatio, preComberCapacityRatio]);
    }
    return base.any((r) => r < 0);
  }

  // For the donut chart
  List<({String name, double value})> get costComponents => [
        (name: 'Material', value: materialCost),
        (name: 'Power', value: powerCost),
        (name: 'Interest', value: interestCost),
        (name: 'Depreciation', value: depreciationCost),
        (name: 'Labour', value: labourCost),
        (name: 'Overhead', value: overheadCost),
        (name: 'Packing', value: packingCost),
        (name: 'Yarn Waste', value: yarnWasteCost),
        if (tfoConversionCost > 0) (name: 'TFO Conv.', value: tfoConversionCost),
      ];
}
