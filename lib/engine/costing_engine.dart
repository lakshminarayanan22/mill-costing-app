import 'dart:math';
import '../models/calculation_input.dart';
import '../models/calculation_result.dart';
import '../models/mill_profile.dart';

// Pure calculation engine — no Flutter/UI dependencies.
// Replicates costing1_16.xlsx formula-by-formula.
// Reference scenario: 94s combed compact 2-ply TFO, RST 2 mill.
class CostingEngine {
  static const double _workingDays = 362; // Excel uses 362, not 365
  static const double _candyKg = 356.0;

  static CalculationResult calculate(
      CalculationInput inp, MillProfile mill) {
    // ── Step 1: Spin plan (ring frame → winding) ────────────────────────────
    final spinPlan = _spinPlan(inp, mill);

    // ── Step 2: Power (UKG) ─────────────────────────────────────────────────
    final power = _powerCalc(inp, mill, spinPlan);

    // ── Step 3: Labour ───────────────────────────────────────────────────────
    final labour = _labourCalc(inp, mill, spinPlan);

    // ── Step 4: Cost aggregation ─────────────────────────────────────────────
    final costs = _costAggregation(inp, mill, spinPlan, power, labour);

    // ── Step 5: Profitability ────────────────────────────────────────────────
    final profit = _profitCalc(inp, costs);

    return CalculationResult(
      // Spin plan
      tpi: spinPlan.tpi,
      gPerSpindle8Hr: spinPlan.gPerSpindle8Hr,
      kgPerSpindleDay: spinPlan.kgPerSpindleDay,
      grossKgPerDay: spinPlan.grossKgPerDay,
      netKgPerDay: spinPlan.netKgPerDay,
      rawCottonKgPerDay: spinPlan.rawCottonKgPerDay,
      realisationPct: spinPlan.realisationPct,
      // Capacity
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
      // Power
      totalUkg: power.totalUkg,
      spinningUkg: power.spinningUkg,
      overheadUkg: power.overheadUkg,
      tfoUkg: power.tfoUkg,
      // Labour
      directOperativesPerDay: labour.directOps,
      indirectOperativesPerDay: mill.indirectStaff.toDouble(),
      totalOperativesPerDay: labour.totalOps,
      // Costs
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
      // Profitability
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
  // Backward chain: ring frame → simplex → drawing → comber → lap former →
  //                 pre-comber drawing → carding → blow room → winding
  // ─────────────────────────────────────────────────────────────────────────────
  static _SpinPlanResult _spinPlan(CalculationInput inp, MillProfile mill) {
    final b = inp.bracket;
    final actualCount = inp.actualCount;

    // ── Ring frame ────────────────────────────────────────────────────────────
    // TPI = TM × √(actualCount)
    final tpi = inp.twistMultiplier * sqrt(actualCount);

    // g/spindle/8hr = (speedRpm × 1000 × 7.2 × efficiency) / (actualCount × tpi × 100)
    // 7.2 is the unit-conversion constant for 8-hr production in grams
    final gPerSpl8Hr =
        (inp.spindleSpeedRpm * 7.2 * b.ringFrameEfficiency) /
            (actualCount * tpi * 100);

    // kg/spindle/day (3 shifts)
    final kgPerSplDay = gPerSpl8Hr * 3 / 1000;

    // Daily gross production
    final grossKgDay =
        mill.ringFrameCount * kgPerSplDay * mill.spindlesPerFrame;

    // After utilisation
    final netKgDay = grossKgDay * (inp.utilisationPct / 100);

    // ── Simplex ───────────────────────────────────────────────────────────────
    // kg/spindle/8hr at simplex
    final simplexTpi = b.simplexTM * sqrt(b.simplexHank);
    final simplexKgSpl8Hr =
        (b.simplexSpeedRpm * 60 * 8 * b.simplexEfficiency) /
            (simplexTpi * 36 * 840 * b.simplexHank * 2.2046 * 100);
    final simplexKgFrameShift =
        simplexKgSpl8Hr * mill.simplexSpindlesPerMachine;
    final simplexKgFrameDay = simplexKgFrameShift * 0.98 * 3;

    // Required at simplex (ring frame needs netKgDay, simplex runs at 98%)
    final simplexRequiredKgDay = grossKgDay / 0.98;
    final simplexMachinesReq = simplexRequiredKgDay / simplexKgFrameDay;
    final simplexSpindlesReq = simplexMachinesReq * mill.simplexSpindlesPerMachine;

    // ── Finisher drawing ──────────────────────────────────────────────────────
    // kg/delivery/8hr at finisher drawing
    final finDrawKgDel8Hr =
        (b.finDrawingMpm * 60 * 8 * 1.0936 * b.finDrawingEfficiency) /
            (b.finDrawingHank * 2.2046 * 840 * 100);
    final finDrawKgDelDay = finDrawKgDel8Hr * 3;
    final finDrawKgDelDayAdj = finDrawKgDelDay * b.finDrawingUtilisation;

    // Required at finisher drawing (adds back 1% simplex→ring waste)
    final finDrawRequiredKgDay = simplexRequiredKgDay / 0.99;
    final finDrawDeliveriesReq = finDrawRequiredKgDay / finDrawKgDelDayAdj;

    // ── Comber ────────────────────────────────────────────────────────────────
    // Feed per nip (mm): fixed mechanical constant
    const feedPerNip = (25.4 * 22) / (7 * 16); // = 4.989 mm
    const lapTensionDraft = 1.152;

    final comberKgFrame8Hr =
        (b.comberNpm * 60 * 8 * feedPerNip * b.comberLapWeightGpyd *
            1.0934 * 8 * (100 - inp.comberNoilPct) * b.comberEfficiency) /
            (1000 * 100 * 100 * 1000 * lapTensionDraft);
    final comberKgFrameDay = comberKgFrame8Hr * 3 * b.comberUtilisation;

    // Required at comber (adds 1% finisher drawing → comber waste)
    final comberRequiredKgDay = finDrawRequiredKgDay / 0.99;
    final combersReq = comberRequiredKgDay / comberKgFrameDay;

    // ── Lap former ────────────────────────────────────────────────────────────
    final lapKgFrame8Hr =
        (b.lapFormerMpm * 60 * 8 * b.lapFormerEfficiency *
            b.lapFormerLapWeightGpyd * 1.0934) / 100000;
    final lapKgFrameDay = lapKgFrame8Hr * 3 * 0.96;

    // CRITICAL: gross up for both 1% waste and comber noil removal
    final lapRequiredKgDay =
        ((comberRequiredKgDay / 0.99) * 100) / (100 - inp.comberNoilPct);
    final lapFormersReq = lapRequiredKgDay / lapKgFrameDay;

    // ── Pre-comber drawing ────────────────────────────────────────────────────
    final preComberKgDel8Hr =
        (b.preComberMpm * 60 * 8 * 1.0936 * b.preComberEfficiency) /
            (b.preComberHank * 2.2046 * 840 * 100);
    final preComberKgDelDay = preComberKgDel8Hr * 3;
    final preComberKgDelDayAdj = preComberKgDelDay * b.preComberDrawingUtilisation;

    final preComberRequiredKgDay = lapRequiredKgDay / 0.99;
    final preComberDeliveriesReq =
        preComberRequiredKgDay / preComberKgDelDayAdj;

    // ── Carding ───────────────────────────────────────────────────────────────
    final cardKgCard8Hr = b.cardingKgPerHr * 8 * b.cardingEfficiency;
    final cardKgCardDay = cardKgCard8Hr * 3;
    final cardKgCardDayAdj = cardKgCardDay * 0.95;

    // Combed yarn: carding feeds pre-comber drawing
    final cardRequiredKgDay = preComberRequiredKgDay;
    final cardsReq = cardRequiredKgDay / cardKgCardDayAdj;

    // ── Blow room ──────────────────────────────────────────────────────────────
    final blowRoomKgLineDay =
        b.blowRoomKgPerHr * 22.5 * b.blowRoomEfficiency;
    final blowRoomKgLineDayAdj = blowRoomKgLineDay * 0.90;

    // 5% blow room waste → carding
    final blowRoomRequiredKgDay = cardRequiredKgDay / (1 - inp.blowRoomWastePct / 100);
    // Raw cotton mix input (5% invisible loss on top)
    final rawCottonKgDay = blowRoomRequiredKgDay / 0.95;
    final blowRoomLinesReq = blowRoomRequiredKgDay / blowRoomKgLineDayAdj;

    // ── Winding ───────────────────────────────────────────────────────────────
    final windKgDrum8Hr =
        (b.windingMpm * 60 * 8 * 1.0936 * b.windingEfficiency) /
            (840 * actualCount * 2.2046 * 100);
    final windKgDrumDayAdj = windKgDrum8Hr * b.windingUtilisation;
    final windKgMachineDay =
        windKgDrumDayAdj * mill.drumsPerWindingMachine * 3;
    final windDrumsReq =
        (netKgDay / windKgMachineDay) * mill.drumsPerWindingMachine;

    // Yarn realisation (1% yarn waste at winding)
    final realisationPct =
        (netKgDay * 0.99) * 100 / rawCottonKgDay;

    return _SpinPlanResult(
      tpi: tpi,
      gPerSpindle8Hr: gPerSpl8Hr,
      kgPerSpindleDay: kgPerSplDay,
      grossKgPerDay: grossKgDay,
      netKgPerDay: netKgDay,
      rawCottonKgPerDay: rawCottonKgDay,
      realisationPct: realisationPct,
      simplexSpindlesRequired: simplexSpindlesReq,
      finDrawingDeliveriesRequired: finDrawDeliveriesReq,
      combersRequired: combersReq,
      lapFormersRequired: lapFormersReq,
      preComberDeliveriesRequired: preComberDeliveriesReq,
      cardsRequired: cardsReq,
      blowRoomLinesRequired: blowRoomLinesReq,
      windingDrumsRequired: windDrumsReq,
      // Pass through for power/labour modules
      cardRequiredKgDay: cardRequiredKgDay,
      comberRequiredKgDay: comberRequiredKgDay,
      lapRequiredKgDay: lapRequiredKgDay,
      preComberRequiredKgDay: preComberRequiredKgDay,
      simplexRequiredKgDay: simplexRequiredKgDay,
      finDrawRequiredKgDay: finDrawRequiredKgDay,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 2 — POWER (UKG)
  // ─────────────────────────────────────────────────────────────────────────────
  static _PowerResult _powerCalc(
      CalculationInput inp, MillProfile mill, _SpinPlanResult sp) {
    final yarnKgDay = sp.netKgPerDay;

    // ── Ring frame: physics-based 3-component model ──────────────────────────
    // traveller weight lookup: rough approximation by count
    final travWeight = _travWeight(inp.actualCount);
    final ringDia10 = mill.ringDiaMm / 10;
    final spindleLiftCm = mill.spindleLiftInches * 2.54;
    final spindleSpeedK = inp.spindleSpeedRpm / 1000;

    final spinningPower = 4.25 *
        mill.spindlesPerFrame *
        pow(travWeight, 0.87) *
        pow(ringDia10, 1.7) *
        pow(spindleSpeedK, 2.4) *
        1e-8;
    final packagePower = 0.53 *
        pow(ringDia10 - 0.3, 3.5) *
        (spindleLiftCm + 3) *
        pow(spindleSpeedK, 3.1) *
        mill.spindlesPerFrame *
        1e-9;
    final noLoadPower = 3.33 *
        mill.spindlesPerFrame *
        pow(7, 1.9) *
        spindleLiftCm *
        pow(spindleSpeedK, 1.4) *
        1e-7;

    final compactExtra = mill.compactSpinning
        ? mill.spindlesPerFrame * 7.5 / 1000
        : 0.0;
    final rfKwPerFrame =
        (spinningPower + packagePower + noLoadPower) * 0.6 + compactExtra;

    final rfTotalKw = rfKwPerFrame * mill.ringFrameCount;
    final rfUnitsPerDay = rfTotalKw * 24;
    final rfUkg = rfUnitsPerDay / yarnKgDay;

    // ── Other spinning machines (simple kW × load factor model) ──────────────
    // kW values approximate from master data; gross-up for downstream waste
    final simplex = _processUkg(
        kw: mill.simplexMachines * mill.simplexSpindlesPerMachine * 0.016,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.02);
    final comber = _processUkg(
        kw: mill.combers * 11.0,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.02 * 1.01);
    final card = _processUkg(
        kw: mill.cards * 18.5,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.19);
    final finDraw = _processUkg(
        kw: mill.finDrawingMachines * 5.5,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.02 * 1.01);
    final preComber = _processUkg(
        kw: mill.preComberDrawingMachines * 5.5,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.19);
    final lapFormer = _processUkg(
        kw: mill.lapFormers * 7.5,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.02 * 1.01);
    final winding = _processUkg(
        kw: mill.windingMachines * 12.0,
        hoursPerDay: 24,
        kgDay: yarnKgDay,
        wasteFactor: 1.01);
    final blowRoom = _processUkg(
        kw: mill.blowRoomLines * 45.0,
        hoursPerDay: 22.5,
        kgDay: yarnKgDay,
        wasteFactor: 1.28);

    final spinningUkg =
        rfUkg + simplex + comber + card + finDraw + preComber + lapFormer +
            winding + blowRoom;

    // ── Overhead loads ────────────────────────────────────────────────────────
    final humidifUkg = (mill.humidificationKw * 0.80 * 24) / yarnKgDay;
    final compressorUkg = (mill.compressorKw * 0.70 * 24) / yarnKgDay;
    final lightingUkg = (mill.lightingKw * 24) / yarnKgDay;
    final generalUkg = (mill.generalKw * 16) / yarnKgDay;
    final cableLossUkg = spinningUkg * 0.005;
    final overheadUkg =
        humidifUkg + compressorUkg + lightingUkg + generalUkg + cableLossUkg;

    final totalUkg = spinningUkg + overheadUkg;

    // ── TFO power add-on (for plied yarn) ────────────────────────────────────
    double tfoUkg = 0;
    double tfoYarnKgDay = 0;
    if (inp.yarnType.isPlied) {
      tfoYarnKgDay = sp.netKgPerDay / 2; // TFO output = half (feeds 2→1)
      final tfoUnitsDay = mill.tfoInstalledKw * 24;
      // 10% overhead for humidification + lighting at TFO
      tfoUkg = (tfoUnitsDay * 1.10 * inp.electricityRatePerKwh) /
          sp.netKgPerDay /
          inp.electricityRatePerKwh;
    }

    return _PowerResult(
      spinningUkg: spinningUkg,
      overheadUkg: overheadUkg,
      totalUkg: totalUkg,
      tfoUkg: tfoUkg,
      tfoYarnKgDay: tfoYarnKgDay,
    );
  }

  static double _processUkg({
    required double kw,
    required double hoursPerDay,
    required double kgDay,
    required double wasteFactor,
  }) {
    return (kw * 0.60 * hoursPerDay) / (kgDay * wasteFactor);
  }

  // Traveller weight lookup by count (approximate from Excel traveller table)
  static double _travWeight(double count) {
    if (count > 130) return 0.010;
    if (count > 100) return 0.012;
    if (count > 80) return 0.015; // bracket 6 reference
    if (count > 60) return 0.020;
    if (count > 40) return 0.030;
    if (count > 20) return 0.055;
    if (count > 10) return 0.090;
    return 0.140;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 3 — LABOUR
  // ─────────────────────────────────────────────────────────────────────────────
  static _LabourResult _labourCalc(
      CalculationInput inp, MillProfile mill, _SpinPlanResult sp) {
    final yarnKgDay = sp.netKgPerDay;

    // Kg-basis jobs (operatives = kg_required / (workload × 3 shifts))
    final mixing = sp.rawCottonKgPerDay / (5000 * 3);
    final contamination = sp.rawCottonKgPerDay / (800 * 3);
    final balePlucker = sp.rawCottonKgPerDay / (4000 * 3);
    final carding = sp.cardRequiredKgDay / (800 * 3);
    final packing = yarnKgDay / 3 / 600;

    // Machine-basis jobs
    final preComberDraw =
        sp.preComberDeliveriesRequired / 6;
    final lapFormer = sp.lapFormersRequired / 4;
    final comber = sp.combersRequired / 4;
    final finDrawing = sp.finDrawingDeliveriesRequired / 6;
    final simplexSider = sp.simplexSpindlesRequired / 300;

    // Ring frame: sider (spindles basis, uses installed)
    final rfSider =
        (mill.ringFrameCount * mill.spindlesPerFrame) / mill.rfSpindlesPerSider;

    // Ring frame: doffer (converts kg to cops)
    final rfDoffer =
        (yarnKgDay / mill.copWeightKg) / (200 * 3);

    // Winding sider (drums basis)
    final windingSider =
        sp.windingDrumsRequired / mill.windingDrumsPerSider;

    final directOps = mixing +
        contamination +
        balePlucker +
        carding +
        packing +
        preComberDraw +
        lapFormer +
        comber +
        finDrawing +
        simplexSider +
        rfSider +
        rfDoffer +
        windingSider;

    final totalOps = directOps + mill.indirectStaff;

    return _LabourResult(directOps: directOps, totalOps: totalOps);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 4 — COST AGGREGATION
  // ─────────────────────────────────────────────────────────────────────────────
  static _CostResult _costAggregation(CalculationInput inp, MillProfile mill,
      _SpinPlanResult sp, _PowerResult power, _LabourResult labour) {
    final yarnKgDay = sp.netKgPerDay;

    // ── Material ──────────────────────────────────────────────────────────────
    final cottonPerKg = inp.cottonPricePerCandy / _candyKg;
    final grossMaterial = cottonPerKg / (sp.realisationPct / 100);

    // Waste credit per kg yarn
    final wasteCredit = _wasteCredit(inp, sp.realisationPct);

    double material;
    if (inp.isBlend) {
      final blend2Clean =
          inp.blend2PricePerKg / (1 - inp.blend2WastePct / 100);
      final cottonNet = grossMaterial - wasteCredit;
      material = cottonNet * (inp.blend1Pct / 100) +
          blend2Clean * (inp.blend2Pct / 100);
    } else {
      material = grossMaterial - wasteCredit;
    }

    // ── Labour ────────────────────────────────────────────────────────────────
    final shiftWagesDay = labour.totalOps * mill.dailyWageRate;
    final staffCostDay =
        mill.staffCount * (mill.monthlyStaffSalary / 30);
    final labourPerKg = (shiftWagesDay + staffCostDay) / yarnKgDay;

    // ── Power ────────────────────────────────────────────────────────────────
    final powerPerKg = power.totalUkg * inp.electricityRatePerKwh;

    // ── Packing ───────────────────────────────────────────────────────────────
    final packingPerKg = inp.packingRatePerKg +
        (inp.yarnType.isPlied ? inp.additionalPackingForPlied : 0);

    // ── Interest ─────────────────────────────────────────────────────────────
    final workingCapital = mill.workingCapitalLakhs * 100000;
    final interestPerDay =
        workingCapital * (mill.interestRatePct / 100) / _workingDays;
    final interestPerKg = interestPerDay / yarnKgDay;

    // ── Depreciation ──────────────────────────────────────────────────────────
    final depPerDay =
        (mill.annualDepreciationLakhs * 100000) / _workingDays;
    final depPerKg = depPerDay / yarnKgDay;

    // ── Fixed overhead ────────────────────────────────────────────────────────
    final overheadPerDay =
        (mill.annualOverheadsLakhs * 100000) / _workingDays;
    final overheadPerKg = overheadPerDay / yarnKgDay;

    // ── Single yarn total (before TFO) ────────────────────────────────────────
    final singleYarnCost = material + labourPerKg + powerPerKg + packingPerKg +
        interestPerKg + depPerKg + overheadPerKg;

    // ── Yarn waste cost (0.5% × pre-waste cost — breaks circularity) ──────────
    final yarnWastePerKg = (inp.yarnWastePct / 100) * singleYarnCost;

    // ── TFO conversion cost (for plied yarn) ─────────────────────────────────
    double tfoConversion = 0;
    if (inp.yarnType.isPlied) {
      tfoConversion = _tfoConversionCost(inp, mill, power, sp);
    }

    final total =
        singleYarnCost + yarnWastePerKg + tfoConversion;

    return _CostResult(
      material: material,
      labour: labourPerKg,
      power: powerPerKg,
      packing: packingPerKg,
      interest: interestPerKg,
      depreciation: depPerKg,
      overhead: overheadPerKg,
      yarnWaste: yarnWastePerKg,
      tfoConversion: tfoConversion,
      singleYarnCost: singleYarnCost + yarnWastePerKg,
      total: total,
    );
  }

  // Waste value credit per kg of yarn
  static double _wasteCredit(CalculationInput inp, double realisationPct) {
    // Per 100 kg raw cotton input, yarn output = realisationPct kg
    final yarnPer100kgInput = realisationPct; // e.g. ~70 kg

    final blowRevenue =
        inp.blowRoomWastePct * 25; // using mill default waste rates
    final cardRevenue = inp.cardingWastePct * 35;
    final noilRevenue = inp.comberNoilPct * 90;
    final yarnRevenue = inp.yarnWastePct * 20;
    final totalRevenue = blowRevenue + cardRevenue + noilRevenue + yarnRevenue;

    return totalRevenue / yarnPer100kgInput;
  }

  // TFO conversion cost add-on block
  static double _tfoConversionCost(CalculationInput inp, MillProfile mill,
      _PowerResult power, _SpinPlanResult sp) {
    final tfoYarnKgDay = sp.netKgPerDay / 2; // TFO takes 2 single cones → 1

    // TFO labour: operatives at TFO ÷ TFO yarn per day
    // Rough norm: 1 operative per 120 TFO spindles per shift
    final tfoOpsPerShift = mill.tfoSpindles / 120;
    final tfoLabourDay = tfoOpsPerShift * 3 * mill.dailyWageRate;
    final tfoLabourPerKg = tfoLabourDay / tfoYarnKgDay;

    // TFO power: installed kW × 24hr × 1.10 overhead factor
    final tfoPowerDay =
        mill.tfoInstalledKw * 24 * 1.10 * inp.electricityRatePerKwh;
    final tfoPowerPerKg = tfoPowerDay / tfoYarnKgDay;

    // TFO interest, dep, overhead (same structure as spinning, pro-rated)
    final tfoInterestPerKg =
        (mill.workingCapitalLakhs * 100000 * (mill.interestRatePct / 100) /
                _workingDays) *
            0.20 /
            tfoYarnKgDay;
    final tfoDepPerKg =
        (mill.annualDepreciationLakhs * 100000 / _workingDays) *
            0.18 /
            tfoYarnKgDay;
    final tfoOverheadPerKg =
        (mill.annualOverheadsLakhs * 100000 / _workingDays) *
            0.07 /
            tfoYarnKgDay;

    final tfoPackingPerKg = inp.additionalPackingForPlied;

    return tfoLabourPerKg +
        tfoPowerPerKg +
        tfoInterestPerKg +
        tfoDepPerKg +
        tfoOverheadPerKg +
        tfoPackingPerKg;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODULE 5 — PROFITABILITY
  // ─────────────────────────────────────────────────────────────────────────────
  static _ProfitResult _profitCalc(CalculationInput inp, _CostResult costs) {
    double effectiveSellingPrice;

    if (inp.priceMode == 'margin') {
      // Back-calculate: sellingPrice = totalCost / (1 - marginPct/100)
      effectiveSellingPrice =
          costs.total / (1 - inp.targetMarginPct / 100);
    } else {
      effectiveSellingPrice = inp.sellingPricePerKg;
    }

    final profitPerKg = effectiveSellingPrice - costs.total;
    final netProfitPct =
        (profitPerKg / effectiveSellingPrice) * 100;
    final cashProfitPct =
        ((profitPerKg + costs.depreciation) / effectiveSellingPrice) * 100;
    final operatingProfitPct =
        ((profitPerKg + costs.depreciation + costs.interest) /
                effectiveSellingPrice) *
            100;

    return _ProfitResult(
      effectiveSellingPrice: effectiveSellingPrice,
      profitPerKg: profitPerKg,
      netProfitPct: netProfitPct,
      cashProfitPct: cashProfitPct,
      operatingProfitPct: operatingProfitPct,
    );
  }
}

// ─── Internal data carriers (not exposed outside engine) ────────────────────

class _SpinPlanResult {
  final double tpi;
  final double gPerSpindle8Hr;
  final double kgPerSpindleDay;
  final double grossKgPerDay;
  final double netKgPerDay;
  final double rawCottonKgPerDay;
  final double realisationPct;
  final double simplexSpindlesRequired;
  final double finDrawingDeliveriesRequired;
  final double combersRequired;
  final double lapFormersRequired;
  final double preComberDeliveriesRequired;
  final double cardsRequired;
  final double blowRoomLinesRequired;
  final double windingDrumsRequired;
  // Pass-through for power/labour
  final double cardRequiredKgDay;
  final double comberRequiredKgDay;
  final double lapRequiredKgDay;
  final double preComberRequiredKgDay;
  final double simplexRequiredKgDay;
  final double finDrawRequiredKgDay;

  const _SpinPlanResult({
    required this.tpi,
    required this.gPerSpindle8Hr,
    required this.kgPerSpindleDay,
    required this.grossKgPerDay,
    required this.netKgPerDay,
    required this.rawCottonKgPerDay,
    required this.realisationPct,
    required this.simplexSpindlesRequired,
    required this.finDrawingDeliveriesRequired,
    required this.combersRequired,
    required this.lapFormersRequired,
    required this.preComberDeliveriesRequired,
    required this.cardsRequired,
    required this.blowRoomLinesRequired,
    required this.windingDrumsRequired,
    required this.cardRequiredKgDay,
    required this.comberRequiredKgDay,
    required this.lapRequiredKgDay,
    required this.preComberRequiredKgDay,
    required this.simplexRequiredKgDay,
    required this.finDrawRequiredKgDay,
  });
}

class _PowerResult {
  final double spinningUkg;
  final double overheadUkg;
  final double totalUkg;
  final double tfoUkg;
  final double tfoYarnKgDay;

  const _PowerResult({
    required this.spinningUkg,
    required this.overheadUkg,
    required this.totalUkg,
    required this.tfoUkg,
    required this.tfoYarnKgDay,
  });
}

class _LabourResult {
  final double directOps;
  final double totalOps;

  const _LabourResult({required this.directOps, required this.totalOps});
}

class _CostResult {
  final double material;
  final double labour;
  final double power;
  final double packing;
  final double interest;
  final double depreciation;
  final double overhead;
  final double yarnWaste;
  final double tfoConversion;
  final double singleYarnCost;
  final double total;

  const _CostResult({
    required this.material,
    required this.labour,
    required this.power,
    required this.packing,
    required this.interest,
    required this.depreciation,
    required this.overhead,
    required this.yarnWaste,
    required this.tfoConversion,
    required this.singleYarnCost,
    required this.total,
  });
}

class _ProfitResult {
  final double effectiveSellingPrice;
  final double profitPerKg;
  final double netProfitPct;
  final double cashProfitPct;
  final double operatingProfitPct;

  const _ProfitResult({
    required this.effectiveSellingPrice,
    required this.profitPerKg,
    required this.netProfitPct,
    required this.cashProfitPct,
    required this.operatingProfitPct,
  });
}
