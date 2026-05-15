import 'dart:math';
import '../models/calculation_input.dart';
import '../models/calculation_result.dart';
import '../models/mill_profile.dart';

// Pure calculation engine — replicates costing1_16.xlsx formula-by-formula.
// Reference scenario: 94s combed compact 2-ply TFO, RST 2 mill.
//
// Key conventions matching the Excel:
//   - Efficiencies stored as fractions (0.95), so no extra ×100 in denominators
//   - actualCount for TFO/Single = resultantCount (ring spins full singles)
//   - actualCount for Ring Doubled = resultantCount / 2
//   - Cost denominator = winding output = netKgDay × 0.99
//   - Material cost uses user-entered yarnRealisationPct (F16), not computed
//   - yarnWasteCostPct (F27 = 0.5%) ≠ physical waste % in spin plan
class CostingEngine {
  static const double _workingDays = 362.0;
  static const double _candyKg    = 356.0;

  static CalculationResult calculate(CalculationInput inp, MillProfile mill) {
    final spinPlan = _spinPlan(inp, mill);
    final power    = _powerCalc(inp, mill, spinPlan);
    final labour   = _labourCalc(inp, mill, spinPlan);
    final costs    = _costAggregation(inp, mill, spinPlan, power, labour);
    final profit   = _profitCalc(inp, costs);

    return CalculationResult(
      tpi: spinPlan.tpi,
      gPerSpindle8Hr: spinPlan.gPerSpindle8Hr,
      kgPerSpindleDay: spinPlan.kgPerSpindleDay,
      grossKgPerDay: spinPlan.grossKgPerDay,
      netKgPerDay: spinPlan.netKgPerDay,
      rawCottonKgPerDay: spinPlan.rawCottonKgPerDay,
      realisationPct: spinPlan.realisationPct,
      simplexSpindlesRequired: spinPlan.simplexSpindlesRequired,
      simplexSpindlesInstalled: mill.simplexSpindlesInstalled,
      finDrawingDeliveriesRequired: spinPlan.finDrawingDeliveriesRequired,
      finDrawingDeliveriesInstalled: mill.finDrawingDeliveriesInstalled,
      combersRequired: spinPlan.combersRequired,
      combersInstalled: mill.combers,
      lapFormersRequired: spinPlan.lapFormersRequired,
      lapFormersInstalled: mill.lapFormers,
      preComberDeliveriesRequired: spinPlan.preComberDeliveriesRequired,
      preComberDeliveriesInstalled: mill.preComberDeliveriesInstalled,
      cardsRequired: spinPlan.cardsRequired,
      cardsInstalled: mill.cards,
      blowRoomLinesRequired: spinPlan.blowRoomLinesRequired,
      blowRoomLinesInstalled: mill.blowRoomLines,
      windingDrumsRequired: spinPlan.windingDrumsRequired,
      windingDrumsInstalled: mill.windingDrumsInstalled,
      totalUkg: power.totalUkg,
      spinningUkg: power.spinningUkg,
      overheadUkg: power.overheadUkg,
      tfoUkg: power.tfoUkg,
      directOperativesPerDay: labour.directOps,
      indirectOperativesPerDay: mill.indirectStaff.toDouble(),
      totalOperativesPerDay: labour.totalOps,
      materialCost: costs.material,
      labourCost: costs.labour,
      powerCost: costs.power,
      packingCost: costs.packing,
      interestCost: costs.interest,
      depreciationCost: costs.depreciation,
      overheadCost: costs.overhead,
      yarnWasteCost: costs.yarnWaste,
      tfoConversionCost: costs.tfoConversion,
      totalCostPerKg: costs.total,
      singleYarnCostPerKg: costs.singleYarnCost,
      sellingPricePerKg: profit.effectiveSellingPrice,
      profitPerKg: profit.profitPerKg,
      netProfitPct: profit.netProfitPct,
      cashProfitPct: profit.cashProfitPct,
      operatingProfitPct: profit.operatingProfitPct,
      breakEvenPrice: costs.total,
      totalMillProfitPerDay: profit.profitPerKg * spinPlan.netKgPerDay,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 1 — SPIN PLAN
  // ─────────────────────────────────────────────────────────────────────────────
  static _SpinPlanResult _spinPlan(CalculationInput inp, MillProfile mill) {
    final b          = inp.bracket;
    final actualCount = inp.actualCount; // 94 for TFO/Single, count/2 for Ring Doubled

    // TPI = TM × √actualCount
    // Reference (94s TFO, ring spins 94s singles): 4.2 × √94 = 40.72
    final tpi = inp.twistMultiplier * sqrt(actualCount);

    // g/spindle/8hr = (rpm × 7.2 × efficiency) / (count × tpi)
    // Efficiency is fraction → no ×100 in denominator
    // Reference: (16500 × 7.2 × 0.95) / (94 × 40.72) = 29.48 g ✓
    final gPerSpl8Hr = (inp.spindleSpeedRpm * 7.2 * b.ringFrameEfficiency) /
        (actualCount * tpi);

    final kgPerSplDay = gPerSpl8Hr * 3 / 1000;
    final grossKgDay  = mill.ringFrameCount * kgPerSplDay * mill.spindlesPerFrame;
    final netKgDay    = grossKgDay * (inp.utilisationPct / 100);
    // Reference: gross 1,486.04 kg/day, net 1,456.32 kg/day ✓

    // ── Simplex ───────────────────────────────────────────────────────────────
    final simplexTpi      = b.simplexTM * sqrt(b.simplexHank);
    final simplexKgSpl8Hr = (b.simplexSpeedRpm * 60 * 8 * b.simplexEfficiency) /
        (simplexTpi * 36 * 840 * b.simplexHank * 2.2046);
    final simplexKgFrameShift = simplexKgSpl8Hr * mill.simplexSpindlesPerMachine;
    final simplexKgFrameDay   = simplexKgFrameShift * 0.98 * 3;
    final simplexRequiredKgDay = grossKgDay / 0.98;
    final simplexMachinesReq  = simplexRequiredKgDay / simplexKgFrameDay;
    final simplexSpindlesReq  = simplexMachinesReq * mill.simplexSpindlesPerMachine;

    // ── Finisher drawing ──────────────────────────────────────────────────────
    final finDrawKgDel8Hr = (b.finDrawingMpm * 60 * 8 * 1.0936 * b.finDrawingEfficiency) /
        (b.finDrawingHank * 2.2046 * 840);
    final finDrawKgDelDayAdj  = finDrawKgDel8Hr * 3 * b.finDrawingUtilisation;
    final finDrawRequiredKgDay = simplexRequiredKgDay / 0.99;
    final finDrawDeliveriesReq = finDrawRequiredKgDay / finDrawKgDelDayAdj;

    // ── Comber ────────────────────────────────────────────────────────────────
    // Excel denom: 1000×100×100×1000×lapTensionDraft (two ×100s: one for noil%, one for eff%)
    // Efficiency as fraction → remove one ×100: 1000×100×1000×lapTensionDraft
    const feedPerNip      = (25.4 * 22) / (7 * 16); // 4.989 mm fixed mechanical constant
    const lapTensionDraft = 1.152;
    final comberKgFrame8Hr = (b.comberNpm * 60 * 8 * feedPerNip *
            b.comberLapWeightGpyd * 1.0934 * 8 *
            (100 - inp.comberNoilPct) * b.comberEfficiency) /
        (1000 * 100 * 1000 * lapTensionDraft);
    final comberKgFrameDay   = comberKgFrame8Hr * 3 * b.comberUtilisation;
    final comberRequiredKgDay = finDrawRequiredKgDay / 0.99;
    final combersReq          = comberRequiredKgDay / comberKgFrameDay;

    // ── Lap former ────────────────────────────────────────────────────────────
    // Excel: /100000 was for efficiency-as-%; with fraction: /1000
    final lapKgFrame8Hr    = (b.lapFormerMpm * 60 * 8 * b.lapFormerEfficiency *
            b.lapFormerLapWeightGpyd * 1.0934) / 1000;
    final lapKgFrameDay    = lapKgFrame8Hr * 3 * 0.96;
    final lapRequiredKgDay = ((comberRequiredKgDay / 0.99) * 100) /
        (100 - inp.comberNoilPct);
    final lapFormersReq    = lapRequiredKgDay / lapKgFrameDay;

    // ── Pre-comber drawing ────────────────────────────────────────────────────
    final preComberKgDel8Hr = (b.preComberMpm * 60 * 8 * 1.0936 * b.preComberEfficiency) /
        (b.preComberHank * 2.2046 * 840);
    final preComberKgDelDayAdj   = preComberKgDel8Hr * 3 * b.preComberDrawingUtilisation;
    final preComberRequiredKgDay = lapRequiredKgDay / 0.99;
    final preComberDeliveriesReq = preComberRequiredKgDay / preComberKgDelDayAdj;

    // ── Carding ───────────────────────────────────────────────────────────────
    final cardKgCardDayAdj  = b.cardingKgPerHr * 8 * b.cardingEfficiency * 3 * 0.95;
    final cardRequiredKgDay = preComberRequiredKgDay;
    final cardsReq          = cardRequiredKgDay / cardKgCardDayAdj;

    // ── Blow room ──────────────────────────────────────────────────────────────
    final blowRoomKgLineDayAdj  = b.blowRoomKgPerHr * 22.5 * b.blowRoomEfficiency * 0.90;
    final blowRoomRequiredKgDay = cardRequiredKgDay / (1 - inp.blowRoomWastePct / 100);
    final rawCottonKgDay        = blowRoomRequiredKgDay / 0.95;
    final blowRoomLinesReq      = blowRoomRequiredKgDay / blowRoomKgLineDayAdj;

    // ── Winding ───────────────────────────────────────────────────────────────
    // Winding winds single cops at actualCount (94s for TFO)
    final windKgDrum8Hr    = (b.windingMpm * 60 * 8 * 1.0936 * b.windingEfficiency) /
        (840 * actualCount * 2.2046);
    final windKgDrumDayAdj = windKgDrum8Hr * b.windingUtilisation;
    final windKgMachineDay = windKgDrumDayAdj * mill.drumsPerWindingMachine * 3;
    final windDrumsReq     = (netKgDay / windKgMachineDay) * mill.drumsPerWindingMachine;

    // Computed realisation (shown in UI; NOT used for material cost)
    final realisationPct = (netKgDay * 0.99) * 100 / rawCottonKgDay;

    return _SpinPlanResult(
      tpi: tpi, gPerSpindle8Hr: gPerSpl8Hr, kgPerSpindleDay: kgPerSplDay,
      grossKgPerDay: grossKgDay, netKgPerDay: netKgDay,
      rawCottonKgPerDay: rawCottonKgDay, realisationPct: realisationPct,
      simplexSpindlesRequired: simplexSpindlesReq,
      finDrawingDeliveriesRequired: finDrawDeliveriesReq,
      combersRequired: combersReq, lapFormersRequired: lapFormersReq,
      preComberDeliveriesRequired: preComberDeliveriesReq,
      cardsRequired: cardsReq, blowRoomLinesRequired: blowRoomLinesReq,
      windingDrumsRequired: windDrumsReq,
      cardRequiredKgDay: cardRequiredKgDay, comberRequiredKgDay: comberRequiredKgDay,
      lapRequiredKgDay: lapRequiredKgDay, preComberRequiredKgDay: preComberRequiredKgDay,
      simplexRequiredKgDay: simplexRequiredKgDay, finDrawRequiredKgDay: finDrawRequiredKgDay,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 2 — POWER (UKG)
  // ─────────────────────────────────────────────────────────────────────────────
  static _PowerResult _powerCalc(
      CalculationInput inp, MillProfile mill, _SpinPlanResult sp) {
    final yarnKgDay = sp.netKgPerDay;

    // Ring frame — physics-based 3-component model
    final travWeight    = _travWeight(inp.actualCount);
    final ringDia10     = mill.ringDiaMm / 10;
    final spindleLiftCm = mill.spindleLiftInches * 2.54;
    final spindleSpeedK = inp.spindleSpeedRpm / 1000;

    final spinningPower = 4.25 * mill.spindlesPerFrame *
        pow(travWeight, 0.87) * pow(ringDia10, 1.7) *
        pow(spindleSpeedK, 2.4) * 1e-8;
    final packagePower = 0.53 * pow(ringDia10 - 0.3, 3.5) *
        (spindleLiftCm + 3) * pow(spindleSpeedK, 3.1) *
        mill.spindlesPerFrame * 1e-9;
    final noLoadPower = 3.33 * mill.spindlesPerFrame *
        pow(7, 1.9) * spindleLiftCm *
        pow(spindleSpeedK, 1.4) * 1e-7;
    final compactExtra = mill.compactSpinning ? mill.spindlesPerFrame * 7.5 / 1000 : 0.0;
    final rfKwPerFrame = (spinningPower + packagePower + noLoadPower) * 0.6 + compactExtra;
    final rfUkg = rfKwPerFrame * mill.ringFrameCount * 24 / yarnKgDay;

    // Other machines — kW × load factor, grossed-up for downstream waste
    final simplex   = _processUkg(kw: mill.simplexMachines * mill.simplexSpindlesPerMachine * 0.016, hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.02);
    final comber    = _processUkg(kw: mill.combers * 11.0,                    hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.0302);
    final card      = _processUkg(kw: mill.cards * 18.5,                      hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.19);
    final finDraw   = _processUkg(kw: mill.finDrawingMachines * 5.5,          hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.0302);
    final preComber = _processUkg(kw: mill.preComberDrawingMachines * 5.5,    hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.19);
    final lapFormer = _processUkg(kw: mill.lapFormers * 7.5,                  hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.0302);
    final winding   = _processUkg(kw: mill.windingMachines * 12.0,            hoursPerDay: 24, kgDay: yarnKgDay, wasteFactor: 1.01);
    final blowRoom  = _processUkg(kw: mill.blowRoomLines * 45.0,              hoursPerDay: 22.5, kgDay: yarnKgDay, wasteFactor: 1.28);

    final spinningUkg = rfUkg + simplex + comber + card + finDraw +
        preComber + lapFormer + winding + blowRoom;

    // Overhead loads
    final humidifUkg    = (mill.humidificationKw * 0.80 * 24) / yarnKgDay;
    final compressorUkg = (mill.compressorKw * 0.70 * 24) / yarnKgDay;
    final lightingUkg   = (mill.lightingKw * 24) / yarnKgDay;
    final generalUkg    = (mill.generalKw * 16) / yarnKgDay;
    final cableLossUkg  = spinningUkg * 0.005;
    final overheadUkg   = humidifUkg + compressorUkg + lightingUkg + generalUkg + cableLossUkg;
    final totalUkg      = spinningUkg + overheadUkg;

    // TFO power add-on: installed kW × 24hr × 1.10 overhead factor
    double tfoUkg = 0;
    if (inp.yarnType.isPlied) {
      tfoUkg = (mill.tfoInstalledKw * 24 * 1.10) / sp.netKgPerDay;
    }

    return _PowerResult(spinningUkg: spinningUkg, overheadUkg: overheadUkg,
        totalUkg: totalUkg, tfoUkg: tfoUkg, tfoYarnKgDay: 0);
  }

  static double _processUkg({required double kw, required double hoursPerDay,
      required double kgDay, required double wasteFactor}) =>
      (kw * 0.60 * hoursPerDay) / (kgDay * wasteFactor);

  static double _travWeight(double count) {
    if (count > 130) return 0.010;
    if (count > 100) return 0.012;
    if (count > 80)  return 0.015;
    if (count > 60)  return 0.020;
    if (count > 40)  return 0.030;
    if (count > 20)  return 0.055;
    if (count > 10)  return 0.090;
    return 0.140;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 3 — LABOUR
  // Reference total: 151.59 operatives/day (70 indirect + ~82 direct)
  //
  // Kg-basis:     operatives/day = kg/day ÷ norm
  // Machine-basis: operatives/day = (machines_required ÷ machines_per_op) × 3 shifts
  // ─────────────────────────────────────────────────────────────────────────────
  static _LabourResult _labourCalc(
      CalculationInput inp, MillProfile mill, _SpinPlanResult sp) {
    final yarnKgDay = sp.netKgPerDay;
    final rawKgDay  = sp.rawCottonKgPerDay;

    // Kg-basis (norm derived from ref: e.g. mixing 0.54/shift × 3 = 1.62/day)
    final mixing        = rawKgDay / 1300;               // ref ~1.62/day
    final contamination = rawKgDay / 200;                // ref ~10.62/day
    final balePlucker   = rawKgDay / 4000;               // ref ~0.53/day
    final carding       = sp.cardRequiredKgDay / 4000;  // ref ~0.48/day
    final packing       = yarnKgDay / 2000;              // ref ~0.73/day

    // Machine-basis (per shift × 3)
    final preComberDraw = (sp.preComberDeliveriesRequired / 6) * 3;
    final lapFormerOps  = (sp.lapFormersRequired / 4) * 3;
    final comberOps     = (sp.combersRequired / 4) * 3;
    final finDrawing    = (sp.finDrawingDeliveriesRequired / 6) * 3;
    // Simplex: installed spindles / 700 per sider × 3 shifts  (ref 0.69/shift × 3)
    final simplexSider  = (mill.simplexSpindlesInstalled / 700) * 3;
    // RF sider: all installed spindles / rfSpindlesPerSider × 3  (ref 9.01/shift × 3)
    final rfSider       = (mill.totalSpindles / mill.rfSpindlesPerSider) * 3;
    // RF doffer: cops/day ÷ 2700 cops/doffer/shift (= 4/shift × 3 = 12/day ref)
    final rfDoffer      = (yarnKgDay / mill.copWeightKg) / 2700;
    // Winding sider: required drums / drumsPerSider × 3
    final windingSider  = (sp.windingDrumsRequired / mill.windingDrumsPerSider) * 3;

    final directOps = mixing + contamination + balePlucker + carding + packing +
        preComberDraw + lapFormerOps + comberOps + finDrawing +
        simplexSider + rfSider + rfDoffer + windingSider;

    return _LabourResult(directOps: directOps, totalOps: directOps + mill.indirectStaff);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 4 — COST AGGREGATION
  // All per-kg costs use winding output = netKgDay × 0.99 as denominator
  // Reference: 1,456.32 × 0.99 = 1,441.75 kg/day ✓
  // ─────────────────────────────────────────────────────────────────────────────
  static _CostResult _costAggregation(CalculationInput inp, MillProfile mill,
      _SpinPlanResult sp, _PowerResult power, _LabourResult labour) {
    final yarnKgDay = sp.netKgPerDay * 0.99; // winding output = cost denominator

    // ── Material ──────────────────────────────────────────────────────────────
    // Uses user-entered yarnRealisationPct (F16), NOT computed spin-plan realisation
    // Reference: 75000/356 / 0.70 - 25.86 = 300.96 - 25.86 = ₹275.10 → Excel ₹280.96
    final cottonPerKg   = inp.cottonPricePerCandy / _candyKg;
    final grossMaterial = cottonPerKg / (inp.yarnRealisationPct / 100);
    final wasteCredit   = _wasteCredit(inp, mill);
    double material;
    if (inp.isBlend) {
      final blend2Clean = inp.blend2PricePerKg / (1 - inp.blend2WastePct / 100);
      material = (grossMaterial - wasteCredit) * (inp.blend1Pct / 100) +
          blend2Clean * (inp.blend2Pct / 100);
    } else {
      material = grossMaterial - wasteCredit;
    }

    // ── Labour ────────────────────────────────────────────────────────────────
    final shiftWagesDay = labour.totalOps * mill.dailyWageRate;
    final staffCostDay  = mill.staffCount * (mill.monthlyStaffSalary / 30);
    final labourPerKg   = (shiftWagesDay + staffCostDay) / yarnKgDay;

    // ── Power ─────────────────────────────────────────────────────────────────
    final powerPerKg = power.totalUkg * inp.electricityRatePerKwh;

    // ── Packing ───────────────────────────────────────────────────────────────
    final packingPerKg = inp.packingRatePerKg +
        (inp.yarnType.isPlied ? inp.additionalPackingForPlied : 0);

    // ── Interest ─────────────────────────────────────────────────────────────
    // RST 2: 625 lakhs WC × 36% / 362 / 1441.75 = ₹43.11/kg spinning ✓
    final interestPerKg = (mill.workingCapitalLakhs * 100000 *
            (mill.interestRatePct / 100)) /
        _workingDays / yarnKgDay;

    // ── Depreciation ──────────────────────────────────────────────────────────
    // RST 2: 200 lakhs / 362 / 1441.75 = ₹38.32/kg ✓
    final depPerKg = (mill.annualDepreciationLakhs * 100000) / _workingDays / yarnKgDay;

    // ── Fixed overhead ────────────────────────────────────────────────────────
    final overheadPerKg = (mill.annualOverheadsLakhs * 100000) / _workingDays / yarnKgDay;

    // ── Single yarn subtotal ──────────────────────────────────────────────────
    final singleBase = material + labourPerKg + powerPerKg + packingPerKg +
        interestPerKg + depPerKg + overheadPerKg;

    // ── Yarn waste cost (F27 = 0.5% of pre-waste cost) ───────────────────────
    // Reference: 0.005 × 543.70 = ₹2.72/kg ✓
    final yarnWastePerKg = (inp.yarnWasteCostPct / 100) * singleBase;

    // ── TFO conversion cost ───────────────────────────────────────────────────
    double tfoConversion = 0;
    if (inp.yarnType.isPlied) {
      tfoConversion = _tfoConversionCost(inp, mill, yarnKgDay);
    }

    final singleYarnCost = singleBase + yarnWastePerKg;
    final total = singleYarnCost + tfoConversion;

    return _CostResult(
      material: material, labour: labourPerKg, power: powerPerKg,
      packing: packingPerKg, interest: interestPerKg,
      depreciation: depPerKg, overhead: overheadPerKg,
      yarnWaste: yarnWastePerKg, tfoConversion: tfoConversion,
      singleYarnCost: singleYarnCost, total: total,
    );
  }

  // Waste value credit per kg yarn (₹/kg, using mill's sale rates)
  // Per 100 kg raw cotton → yarnRealisationPct kg yarn
  // Reference: (5×25 + 6.65×35 + 15.9×90 + 0.5×20) / 70 = ₹25.86/kg ✓
  static double _wasteCredit(CalculationInput inp, MillProfile mill) {
    final totalRevenue = inp.blowRoomWastePct * mill.blowRoomWasteRate +
        inp.cardingWastePct   * mill.cardingWasteRate +
        inp.comberNoilPct     * mill.comberNoilRate +
        inp.yarnWasteCostPct  * mill.yarnWasteRate;
    return totalRevenue / inp.yarnRealisationPct;
  }

  // TFO conversion cost add-on
  static double _tfoConversionCost(
      CalculationInput inp, MillProfile mill, double yarnKgDay) {
    // Labour: 1 op per 120 TFO spindles per shift × 3 shifts
    // Reference: 4176/120 = 34.8/shift × 3 = 104.4 ops; × ₹300 / 985.79 = ₹11.87/kg
    final tfoLabourPerKg = (mill.tfoSpindles / 120 * 3 * mill.dailyWageRate) / yarnKgDay;

    // Power: installed kW × 24hr × 1.10 overhead × electricity rate / kg
    // Reference: 560 × 24 × 1.10 × 8 / 985.79 = ₹119.98/kg ✓
    final tfoPowerPerKg = (mill.tfoInstalledKw * 24 * 1.10 * inp.electricityRatePerKwh) /
        yarnKgDay;

    // TFO share of interest, dep, overhead (pro-rated)
    final tfoInterestPerKg = (mill.workingCapitalLakhs * 100000 *
            (mill.interestRatePct / 100) / _workingDays) *
        0.20 / yarnKgDay;
    final tfoDepPerKg = (mill.annualDepreciationLakhs * 100000 / _workingDays) *
        0.18 / yarnKgDay;
    final tfoOverheadPerKg = (mill.annualOverheadsLakhs * 100000 / _workingDays) *
        0.07 / yarnKgDay;

    return tfoLabourPerKg + tfoPowerPerKg + tfoInterestPerKg +
        tfoDepPerKg + tfoOverheadPerKg + inp.additionalPackingForPlied;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 5 — PROFITABILITY
  // ─────────────────────────────────────────────────────────────────────────────
  static _ProfitResult _profitCalc(CalculationInput inp, _CostResult costs) {
    final effectiveSellingPrice = inp.priceMode == 'margin'
        ? costs.total / (1 - inp.targetMarginPct / 100)
        : inp.sellingPricePerKg;
    final profitPerKg        = effectiveSellingPrice - costs.total;
    final netProfitPct       = (profitPerKg / effectiveSellingPrice) * 100;
    final cashProfitPct      = ((profitPerKg + costs.depreciation) / effectiveSellingPrice) * 100;
    final operatingProfitPct = ((profitPerKg + costs.depreciation + costs.interest) /
            effectiveSellingPrice) * 100;
    return _ProfitResult(
      effectiveSellingPrice: effectiveSellingPrice, profitPerKg: profitPerKg,
      netProfitPct: netProfitPct, cashProfitPct: cashProfitPct,
      operatingProfitPct: operatingProfitPct,
    );
  }
}

// ─── Internal data carriers ───────────────────────────────────────────────────

class _SpinPlanResult {
  final double tpi, gPerSpindle8Hr, kgPerSpindleDay;
  final double grossKgPerDay, netKgPerDay, rawCottonKgPerDay, realisationPct;
  final double simplexSpindlesRequired, finDrawingDeliveriesRequired;
  final double combersRequired, lapFormersRequired, preComberDeliveriesRequired;
  final double cardsRequired, blowRoomLinesRequired, windingDrumsRequired;
  final double cardRequiredKgDay, comberRequiredKgDay, lapRequiredKgDay;
  final double preComberRequiredKgDay, simplexRequiredKgDay, finDrawRequiredKgDay;
  const _SpinPlanResult({
    required this.tpi, required this.gPerSpindle8Hr, required this.kgPerSpindleDay,
    required this.grossKgPerDay, required this.netKgPerDay, required this.rawCottonKgPerDay,
    required this.realisationPct, required this.simplexSpindlesRequired,
    required this.finDrawingDeliveriesRequired, required this.combersRequired,
    required this.lapFormersRequired, required this.preComberDeliveriesRequired,
    required this.cardsRequired, required this.blowRoomLinesRequired,
    required this.windingDrumsRequired, required this.cardRequiredKgDay,
    required this.comberRequiredKgDay, required this.lapRequiredKgDay,
    required this.preComberRequiredKgDay, required this.simplexRequiredKgDay,
    required this.finDrawRequiredKgDay,
  });
}

class _PowerResult {
  final double spinningUkg, overheadUkg, totalUkg, tfoUkg, tfoYarnKgDay;
  const _PowerResult({required this.spinningUkg, required this.overheadUkg,
      required this.totalUkg, required this.tfoUkg, required this.tfoYarnKgDay});
}

class _LabourResult {
  final double directOps, totalOps;
  const _LabourResult({required this.directOps, required this.totalOps});
}

class _CostResult {
  final double material, labour, power, packing, interest;
  final double depreciation, overhead, yarnWaste, tfoConversion;
  final double singleYarnCost, total;
  const _CostResult({
    required this.material, required this.labour, required this.power,
    required this.packing, required this.interest, required this.depreciation,
    required this.overhead, required this.yarnWaste, required this.tfoConversion,
    required this.singleYarnCost, required this.total,
  });
}

class _ProfitResult {
  final double effectiveSellingPrice, profitPerKg;
  final double netProfitPct, cashProfitPct, operatingProfitPct;
  const _ProfitResult({
    required this.effectiveSellingPrice, required this.profitPerKg,
    required this.netProfitPct, required this.cashProfitPct,
    required this.operatingProfitPct,
  });
}
