import 'dart:math';
import 'qd_constants.dart';
import 'lp_solver.dart';

// ────────────────────────────────────────────────────────────────────────────
// App 1 — Yarn IPI from HVI
// ────────────────────────────────────────────────────────────────────────────

class App1Input {
  final double fine; // Micronaire
  final double sl50; // 50% span length mm
  final double sfi; // Short Fibre Index
  final double count; // Ne
  final double trash; // Trash % in drawing sliver
  final double neps; // Neps/mg in drawing sliver
  final int ytype; // 1–4

  const App1Input({
    required this.fine,
    required this.sl50,
    required this.sfi,
    required this.count,
    required this.trash,
    required this.neps,
    required this.ytype,
  });
}

class App1Result {
  final double baseIPI;
  final double totalIPI;

  const App1Result({required this.baseIPI, required this.totalIPI});
}

App1Result calcApp1(App1Input i) {
  final logFine = log(i.fine) / ln10;
  final logSfi = log(i.sfi) / ln10;

  final base = (QDConstants.ipiBaseA0 +
          QDConstants.ipiBaseA1 * logFine +
          QDConstants.ipiBaseA2 * i.sl50 +
          QDConstants.ipiBaseA3 * i.trash +
          QDConstants.ipiBaseA4 * i.neps) *
      (pow(i.count, 2) * (1 + QDConstants.ipiSfiSqrtFactor * sqrt(logSfi))) /
      QDConstants.ipiCountSqrDivisor;

  final idx = (i.ytype - 1).clamp(0, 3);
  final reduction = QDConstants.ipiReductionByYtype[idx];
  final total = base - base * reduction;
  return App1Result(baseIPI: base, totalIPI: total);
}

// ────────────────────────────────────────────────────────────────────────────
// App 2 — FQI / SCI / PQI
// ────────────────────────────────────────────────────────────────────────────

class App2Input {
  final double uhmlMm; // Upper Half Mean Length mm
  final double sl50; // 50% span length mm
  final double ui; // Uniformity Index  (or UR*2 if UR entered)
  final double str; // Fibre strength cN/tex
  final double mic; // Micronaire
  final double rd; // Reflectance
  final double yb; // Yellowness +b
  final double elong; // Breaking elongation %
  final double sfi; // Short Fibre Index
  final double mat; // Maturity coefficient
  final int indexSel; // 1=FQI, 2=SCI, 3=PQI
  final int sciMode; // 1–4 (only for indexSel=2)

  const App2Input({
    required this.uhmlMm,
    required this.sl50,
    required this.str,
    required this.ui,
    required this.mic,
    required this.rd,
    required this.yb,
    required this.elong,
    required this.sfi,
    required this.mat,
    required this.indexSel,
    required this.sciMode,
  });
}

class App2Result {
  final double uhmlIn;
  final double fqi;
  final double sci;
  final double pqi;
  final double dL, dUI, dFs, dFF, dFE, dSFC;

  const App2Result({
    required this.uhmlIn,
    required this.fqi,
    required this.sci,
    required this.pqi,
    required this.dL,
    required this.dUI,
    required this.dFs,
    required this.dFF,
    required this.dFE,
    required this.dSFC,
  });
}

App2Result calcApp2(App2Input i) {
  final uhmlIn = i.uhmlMm / 25.4;

  // FQI
  final fqi = (i.sl50 * i.str * i.mat) / i.mic;

  // SCI
  double sci;
  switch (i.sciMode) {
    case 1:
      sci = QDConstants.sci1Intercept +
          QDConstants.sci1Str * i.str +
          QDConstants.sci1Length * uhmlIn +
          QDConstants.sci1UI * i.ui +
          QDConstants.sci1Mic * i.mic +
          QDConstants.sci1Rd * i.rd +
          QDConstants.sci1Yb * i.yb;
    case 2:
      sci = QDConstants.sci1Intercept +
          QDConstants.sci2Str * i.str +
          QDConstants.sci1Length * uhmlIn +
          QDConstants.sci1UI * i.ui +
          QDConstants.sci1Mic * i.mic +
          QDConstants.sci1Rd * i.rd +
          QDConstants.sci1Yb * i.yb;
    case 3:
      sci = (QDConstants.sci3Intercept +
              QDConstants.sci3Str * i.str +
              QDConstants.sci3Mic * i.mic +
              QDConstants.sci3Length * uhmlIn +
              QDConstants.sci3UI * i.ui) /
          QDConstants.sci3Divisor;
    case 4:
      sci = (QDConstants.sci3Intercept +
              QDConstants.sci4Str * i.str +
              QDConstants.sci3Mic * i.mic +
              QDConstants.sci3Length * uhmlIn +
              QDConstants.sci3UI * i.ui) /
          QDConstants.sci4Divisor;
    default:
      sci = 0;
  }

  // PQI
  final dL = (uhmlIn - QDConstants.pqiMeanL) / QDConstants.pqiSdL;
  final dUI = (i.ui - QDConstants.pqiMeanUI) / QDConstants.pqiSdUI;
  final dFs = (i.str - QDConstants.pqiMeanFs) / QDConstants.pqiSdFs;
  final dFF = (i.mic - QDConstants.pqiMeanFF) / QDConstants.pqiSdFF;
  final dFE = (i.elong - QDConstants.pqiMeanFE) / QDConstants.pqiSdFE;
  final dSFC = (i.sfi - QDConstants.pqiMeanSFC) / QDConstants.pqiSdSFC;

  final pqi = QDConstants.pqiCoefFs * dFs +
      QDConstants.pqiCoefFE * dFE +
      QDConstants.pqiCoefL * dL +
      QDConstants.pqiCoefUI * dUI +
      QDConstants.pqiCoefSFC * dSFC +
      QDConstants.pqiCoefFF * dFF +
      QDConstants.pqiBase;

  return App2Result(
    uhmlIn: uhmlIn,
    fqi: fqi,
    sci: sci,
    pqi: pqi,
    dL: dL,
    dUI: dUI,
    dFs: dFs,
    dFF: dFF,
    dFE: dFE,
    dSFC: dSFC,
  );
}

// ────────────────────────────────────────────────────────────────────────────
// App 3 — Yarn Quality Prediction
// ────────────────────────────────────────────────────────────────────────────

class AfisInput {
  final double neps;
  final double lw;
  final double sfcw;
  final double uqlw;
  final double ln;
  final double sfcn;
  final double uqln;
  final double dm; // fibre diameter µm
  final double span25n;
  final double dust;
  final double trash;
  final double vfm;

  const AfisInput({
    required this.neps,
    required this.lw,
    required this.sfcw,
    required this.uqlw,
    required this.ln,
    required this.sfcn,
    required this.uqln,
    required this.dm,
    required this.span25n,
    required this.dust,
    required this.trash,
    required this.vfm,
  });
}

class HviInput {
  final double uhmlMm;
  final double str;
  final double mic;
  final double ui;
  final double rd;
  final double yb;
  final double elong;
  final double sfi;

  const HviInput({
    required this.uhmlMm,
    required this.str,
    required this.mic,
    required this.ui,
    required this.rd,
    required this.yb,
    required this.elong,
    required this.sfi,
  });
}

class App3ProcessInput {
  final double count;
  final double tm;
  final double rovHank;
  final double rovUm;
  final double rovCVm;
  final double rovCV1m;
  final double spindle;

  const App3ProcessInput({
    required this.count,
    required this.tm,
    required this.rovHank,
    required this.rovUm,
    required this.rovCVm,
    required this.rovCV1m,
    required this.spindle,
  });
}

class App3Result {
  final double yarnTex;
  final double tpm;
  final double rovTex;
  final double rovCV;
  final double cottonPropensity;
  final double propensityIndex2;
  final double fibresInCrossSection;
  final double limitingU;

  final double tenacity;
  final double elongation;
  final double uPct;
  final double hairinessUster;
  final double? hairinessS3; // null for AFIS route
  final double s3Base;
  final double v74;
  final double v75;
  final double v76;
  final double v77;

  const App3Result({
    required this.yarnTex,
    required this.tpm,
    required this.rovTex,
    required this.rovCV,
    required this.cottonPropensity,
    required this.propensityIndex2,
    required this.fibresInCrossSection,
    required this.limitingU,
    required this.tenacity,
    required this.elongation,
    required this.uPct,
    required this.hairinessUster,
    this.hairinessS3,
    required this.s3Base,
    required this.v74,
    required this.v75,
    required this.v76,
    required this.v77,
  });
}

App3Result calcApp3({
  required int route, // 1=HVI, 2=AFIS
  required int ytype, // 1–4
  AfisInput? afis,
  HviInput? hvi,
  required App3ProcessInput proc,
}) {
  final count = proc.count;
  final tm = proc.tm;
  final rovHank = proc.rovHank;
  final spindle = proc.spindle;

  final yarnTex = 590.5 / count;
  final tpm = tm * sqrt(count) * 39.3;
  final rovTex = 590.5 / rovHank;
  final rovCV = QDConstants.rovCvA0 +
      QDConstants.rovCvA1 * rovTex +
      QDConstants.rovCvA2 * pow(rovTex, 2);

  // Always need HVI fields for some derived quantities
  final uhmlMm = hvi?.uhmlMm ?? 0.0;
  final str = hvi?.str ?? 0.0;
  final mic = hvi?.mic ?? 0.0;
  final ui = hvi?.ui ?? 0.0;
  final elong = hvi?.elong ?? 0.0;
  final sfi = hvi?.sfi ?? 0.0;

  final cottonPropensity = (uhmlMm * str * elong) / (mic * (sfi / 2));
  final propensityIndex2 = (mic * (sfi / 2)) / uhmlMm;

  final micConv = mic * 1e-6 / (2.54e-5);
  final fibresInCrossSection = yarnTex / micConv;
  final limitingU = 106 / sqrt(fibresInCrossSection * 2);

  final ytIdx = (ytype - 1).clamp(0, 3);

  // Tenacity
  double tenacity;
  if (route == 2 && afis != null) {
    tenacity = QDConstants.tenAfisIntercept +
        QDConstants.tenAfisDm * afis.dm +
        QDConstants.tenAfisNeps * afis.neps +
        QDConstants.tenAfisTex * yarnTex +
        QDConstants.tenAfisTPM * tpm +
        QDConstants.tenAfisUQLw * afis.uqlw +
        QDConstants.tenAfisDust * afis.dust;
  } else {
    final tenBase = QDConstants.tenHviUI * ui +
        QDConstants.tenHviStr * str +
        QDConstants.tenHviElong * elong +
        QDConstants.tenHviCountTex * (590.5 / count) +
        QDConstants.tenHviTM * tm +
        QDConstants.tenHviIntercept +
        QDConstants.tenHviMic * mic;
    tenacity = tenBase * QDConstants.tenacityMultiplier[ytIdx];
  }

  // Elongation
  double elongation;
  if (route == 2 && afis != null) {
    elongation = QDConstants.elongAfisIntercept +
        QDConstants.elongAfisTex * yarnTex +
        QDConstants.elongAfisRovCV * rovCV +
        QDConstants.elongAfisUQLw * afis.uqlw +
        QDConstants.elongAfisTPM * tpm +
        QDConstants.elongAfisRovCVm * proc.rovCVm +
        QDConstants.elongAfisDm * afis.dm;
  } else {
    elongation = cottonPropensity *
        QDConstants.elongHviBase *
        (pow(tm, 2) * (QDConstants.elongHviK / sqrt(count)) * (1 / spindle)) *
        QDConstants.elongMultiplier[ytIdx];
  }

  // Evenness U%
  double uPct;
  if (route == 2 && afis != null) {
    uPct = (QDConstants.uAfisIntercept +
            QDConstants.uAfisDust * afis.dust +
            QDConstants.uAfisNeps * afis.neps +
            QDConstants.uAfisDm * afis.dm +
            QDConstants.uAfisSFCw * afis.sfcw +
            QDConstants.uAfisRovTex * rovTex +
            QDConstants.uAfisRovCVm * proc.rovCVm +
            QDConstants.uAfisYarnTex * yarnTex) /
        QDConstants.uAfisRouteDivisor;
  } else {
    uPct = (limitingU / QDConstants.uHviLimitingDivisor +
            QDConstants.uHviRovCvmCoef * proc.rovCVm +
            QDConstants.uHviRovHankCoef * rovHank +
            sfi * QDConstants.uHviSfiCoef) *
        QDConstants.uPctMultiplier[ytIdx];
  }

  // Hairiness base (shared formula)
  double hairBase;
  double hairinessUster;
  if (route == 2 && afis != null) {
    hairBase = -0.361 -
        0.003 * tpm +
        0.56 * afis.dm +
        0.005 * afis.neps +
        0.311 * proc.rovCVm +
        0.001 * rovTex +
        0.021 * yarnTex -
        0.058 * afis.uqlw;
    hairinessUster = hairBase * QDConstants.hairAfisMultiplier[ytIdx];
  } else {
    hairBase = ((-0.361 -
                0.003 * tpm +
                0.56 * (mic * QDConstants.hairHviSpindleMicFactor) +
                0.005 * QDConstants.hairHviNepsProxy +
                0.311 * proc.rovCVm +
                0.001 * rovTex +
                0.021 * yarnTex -
                0.058 * uhmlMm +
                QDConstants.hairHviSfiCoef * sfi) /
            QDConstants.hairHviBaseDivisor) +
        QDConstants.hairHviSpindleCoef * sqrt(spindle);
    final h62 = hairBase / QDConstants.hairHviH62Divisor;
    final h60 = h62 - h62 * 0.20; // combed normal
    final h61 = h62 - h62 * 0.40; // combed compact
    // h62 itself = carded normal
    final h63 = h62 - h62 * 0.25; // carded compact
    final hValues = [h60, h61, h62, h63];
    hairinessUster = hValues[ytIdx];
  }

  // Hairiness S3 (HVI only)
  final s3Base =
      QDConstants.hairS3Base * (sqrt(propensityIndex2) * sqrt(spindle) * (1 / tm) * (1 / sqrt(count)));
  final v75 = s3Base * QDConstants.hairS3V75Factor;
  final v74 = v75 + v75 * QDConstants.hairS3V74BoostFactor;
  final v76 = s3Base * QDConstants.hairS3V76Factor;
  final v77 = s3Base - s3Base * QDConstants.hairS3V77ReductionFactor;

  double? hairinessS3;
  if (route == 1) {
    final s3Values = [v74, v75, v76, v77];
    hairinessS3 = s3Values[ytIdx];
  }

  return App3Result(
    yarnTex: yarnTex,
    tpm: tpm,
    rovTex: rovTex,
    rovCV: rovCV,
    cottonPropensity: cottonPropensity,
    propensityIndex2: propensityIndex2,
    fibresInCrossSection: fibresInCrossSection,
    limitingU: limitingU,
    tenacity: tenacity,
    elongation: elongation,
    uPct: uPct,
    hairinessUster: hairinessUster,
    hairinessS3: hairinessS3,
    s3Base: s3Base,
    v74: v74,
    v75: v75,
    v76: v76,
    v77: v77,
  );
}

// ────────────────────────────────────────────────────────────────────────────
// App 4 — SFI live calculations
// ────────────────────────────────────────────────────────────────────────────

double calcSfiFromUhm(double uhmMm, double ui) {
  final uhmIn = uhmMm / 25.4;
  return QDConstants.sfiA0 + QDConstants.sfiA1 * uhmIn + QDConstants.sfiA2 * ui;
}

double calcSfiFromSl2(double sl2Mm, double ur) {
  final sl2In = sl2Mm / 25.4;
  return QDConstants.sfiBb0 + QDConstants.sfiBb1 * sl2In + QDConstants.sfiBb2 * ur;
}

// ────────────────────────────────────────────────────────────────────────────
// Tracker — weighted average index
// ────────────────────────────────────────────────────────────────────────────

class TrackerLot {
  final String variety;
  final String lotNo;
  final int bales;
  final double qualityIndex;

  const TrackerLot({
    required this.variety,
    required this.lotNo,
    required this.bales,
    required this.qualityIndex,
  });
}

double calcWeightedAvgIndex(List<TrackerLot> lots) {
  if (lots.isEmpty) return 0;
  final totalBales = lots.fold<int>(0, (s, l) => s + l.bales);
  if (totalBales == 0) return 0;
  final weighted = lots.fold<double>(0, (s, l) => s + l.bales * l.qualityIndex);
  return weighted / totalBales;
}

// ────────────────────────────────────────────────────────────────────────────
// Mix Optimiser — per-cotton yarn strength + LP solver
// ────────────────────────────────────────────────────────────────────────────

class MixCotton {
  final String name;
  final double uhmlMm;
  final double strengthGtex;
  final double mic;
  final double ui;
  final double fibreElongation;
  final double priceRsPerCandy;
  final double yarnRealisationPct;

  const MixCotton({
    required this.name,
    required this.uhmlMm,
    required this.strengthGtex,
    required this.mic,
    required this.ui,
    required this.fibreElongation,
    required this.priceRsPerCandy,
    required this.yarnRealisationPct,
  });
}

double cottonYarnStrength(MixCotton c, double count, double tm) {
  return (QDConstants.mixStrUI * c.ui +
          QDConstants.mixStrStrength * c.strengthGtex +
          QDConstants.mixStrElong * c.fibreElongation +
          QDConstants.mixStrCountTex * (590.5 / count) +
          QDConstants.mixStrTM * tm +
          QDConstants.mixStrIntercept +
          QDConstants.mixStrMic * c.mic) /
      QDConstants.mixStrDivisor;
}

class MixResult {
  final List<double> ratios; // % for each cotton
  final double blendStrength; // RKM
  final double blendCostPerCandy;
  final bool targetMet; // false → target unachievable, showing best possible blend

  const MixResult({
    required this.ratios,
    required this.blendStrength,
    required this.blendCostPerCandy,
    this.targetMet = true,
  });
}

/// Solves the blend optimisation LP by simplex (Big-M method):
///
///   Minimize   Σ price_i · x_i             (cotton cost)
///   subject to Σ strength_i · x_i ≥ target · 100
///              Σ x_i = 100
///              x_i ≥ 0
///
/// Exact for any number of cottons. If no blend can meet [targetStrength],
/// returns the maximum-strength blend with [MixResult.targetMet] = false.
MixResult? optimiseMix({
  required List<MixCotton> cottons,
  required double count,
  required double tm,
  required double targetStrength,
}) {
  if (cottons.isEmpty) return null;
  final strengths = cottons.map((c) => cottonYarnStrength(c, count, tm)).toList();
  final prices = cottons.map((c) => c.priceRsPerCandy).toList();

  final (:ratios, :blendStrength, :blendCostPerCandy, :feasible) = solveBlendLP(
    prices: prices,
    strengths: strengths,
    targetStrength: targetStrength,
  );

  return MixResult(
    ratios: ratios,
    blendStrength: blendStrength,
    blendCostPerCandy: blendCostPerCandy,
    targetMet: feasible,
  );
}

/// Expose the LP formulation as a human-readable string for display.
String blendLpFormulation({
  required List<MixCotton> cottons,
  required double count,
  required double tm,
  required double targetStrength,
}) {
  final n = cottons.length;
  final strengths = cottons.map((c) => cottonYarnStrength(c, count, tm)).toList();
  final prices = cottons.map((c) => c.priceRsPerCandy).toList();

  final varNames = List.generate(n, (i) => 'x${i + 1}');

  // Objective line
  final objTerms = List.generate(n, (i) => '${prices[i].toStringAsFixed(0)} ${varNames[i]}').join(' + ');
  // Strength constraint
  final strTerms = List.generate(n, (i) => '${strengths[i].toStringAsFixed(3)} ${varNames[i]}').join(' + ');
  // Blend closure
  final blendTerms = varNames.join(' + ');
  // Cotton labels
  final labels = List.generate(n, (i) => '  ${varNames[i]} = ${cottons[i].name}').join('\n');

  return 'Minimize Z = $objTerms\n\n'
      'subject to\n'
      '  $strTerms ≥ ${(targetStrength * 100).toStringAsFixed(1)}  (strength ≥ $targetStrength RKM)\n'
      '  $blendTerms = 100  (blend closes to 100 %)\n'
      '  ${varNames.join(', ')} ≥ 0\n\n'
      'Where:\n$labels';
}
