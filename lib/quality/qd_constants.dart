// All tunable coefficients for the Quality Diagnosis engine.
// Every formula function reads from here — nothing is hardcoded inline.
// Centralised so a single edit propagates everywhere.

class QDConstants {
  // ── App 1: Yarn IPI from HVI ────────────────────────────────────────────
  static const double ipiBaseA0 = 15.1;
  static const double ipiBaseA1 = -1.68; // logFine coefficient
  static const double ipiBaseA2 = -0.65; // SL50 coefficient
  static const double ipiBaseA3 = 53.6; // Trash coefficient
  static const double ipiBaseA4 = 7.58; // Neps coefficient
  static const double ipiCountSqrDivisor = 25.0;
  static const double ipiSfiSqrtFactor = 0.2;

  // Yarn-type IPI reduction multipliers (applied as: TotalIPI = baseIPI - baseIPI*factor)
  // Index 0 = carded hosiery (no reduction), 1 = combed hosiery, 2 = carded weaving,
  // 3 = combed weaving.
  static const List<double> ipiReductionByYtype = [0.0, 0.89, 0.07, 0.90];

  // ── App 2: FQI / SCI / PQI ────────────────────────────────────────────────
  // SCI colour mode — length coefficient is 49.47 (live workbook value).
  // The documented value 49.17 is noted here for reference; expose to make it
  // easy to change if the mill confirms 49.17 was intended.
  static const double sciLengthCoeffLive = 49.47; // implemented value
  static const double sciLengthCoeffDoc = 49.17; // documented value (use sciLengthCoeffLive)

  // SCI mode 1 (HVI-HVI with colour)
  static const double sci1Intercept = -414.67;
  static const double sci1Str = 2.9;
  static const double sci1Length = sciLengthCoeffLive;
  static const double sci1UI = 4.74;
  static const double sci1Mic = -9.32;
  static const double sci1Rd = 0.65;
  static const double sci1Yb = 0.36;

  // SCI mode 2 (HVI-ICC with colour) — same except str coefficient
  static const double sci2Str = 3.74;

  // SCI mode 3 (HVI-HVI no colour) / divisor
  static const double sci3Intercept = -322.98;
  static const double sci3Str = 2.89;
  static const double sci3Mic = -9.02;
  static const double sci3Length = 43.53;
  static const double sci3UI = 7.79;
  static const double sci3Divisor = 3.1;

  // SCI mode 4 (HVI-ICC no colour)
  static const double sci4Str = 3.74;
  static const double sci4Divisor = 2.82;

  // PQI population means and SDs
  static const double pqiMeanL = 1.06;
  static const double pqiSdL = 0.047;
  static const double pqiMeanUI = 81.57;
  static const double pqiSdUI = 0.971;
  static const double pqiMeanFs = 29.05;
  static const double pqiSdFs = 1.477;
  static const double pqiMeanFF = 4.23;
  static const double pqiSdFF = 0.453;
  static const double pqiMeanFE = 6.27;
  static const double pqiSdFE = 0.458;
  static const double pqiMeanSFC = 9.77;
  static const double pqiSdSFC = 3.043;

  // PQI coefficients
  static const double pqiCoefFs = 22.15;
  static const double pqiCoefFE = -4.75;
  static const double pqiCoefL = 4.37;
  static const double pqiCoefUI = 11.19;
  static const double pqiCoefSFC = -20.78;
  static const double pqiCoefFF = -7.8;
  static const double pqiBase = 75.0;

  // ── App 3: Yarn Quality Prediction ─────────────────────────────────────
  // Tenacity — HVI route coefficients
  static const double tenHviUI = 0.31;
  static const double tenHviStr = 0.8;
  static const double tenHviElong = -0.7;
  static const double tenHviCountTex = 0.062; // × (590.5/count)
  static const double tenHviTM = 0.7;
  static const double tenHviIntercept = -21.8;
  static const double tenHviMic = -0.73;

  // Tenacity — AFIS route
  static const double tenAfisIntercept = 61.515;
  static const double tenAfisDm = -4.577;
  static const double tenAfisNeps = -0.0017;
  static const double tenAfisTex = 0.303;
  static const double tenAfisTPM = 0.01;
  static const double tenAfisUQLw = 0.175;
  static const double tenAfisDust = -0.009;

  // Tenacity yarn-type multipliers [combed normal, combed compact, carded normal, carded compact]
  static const List<double> tenacityMultiplier = [0.68, 0.75, 0.58, 0.65];

  // Elongation — HVI route (ytype multipliers)
  static const double elongHviBase = 630.0;
  static const double elongHviTmSq = 1.0; // TM^2
  static const double elongHviK = 0.11;
  static const List<double> elongMultiplier = [1.10, 1.20, 0.95, 1.05];

  // Elongation — AFIS route
  static const double elongAfisIntercept = -5.039;
  static const double elongAfisTex = 0.167;
  static const double elongAfisRovCV = 0.97;
  static const double elongAfisUQLw = 0.089;
  static const double elongAfisTPM = 0.003;
  static const double elongAfisRovCVm = -0.203;
  static const double elongAfisDm = -0.211;

  // Evenness U% — HVI route (ytype multipliers)
  static const List<double> uPctMultiplier = [1.05, 1.00, 1.15, 1.10];
  static const double uHviRovCvmCoef = 0.577;
  static const double uHviRovHankCoef = -0.5;
  static const double uHviSfiCoef = 1 / 5.5;
  static const double uHviLimitingDivisor = 1.2;

  // Evenness U% — AFIS route
  static const double uAfisIntercept = -7.737;
  static const double uAfisDust = 0.011;
  static const double uAfisNeps = 0.015;
  static const double uAfisDm = 1.557;
  static const double uAfisSFCw = 0.162;
  static const double uAfisRovTex = 0.002;
  static const double uAfisRovCVm = 0.577;
  static const double uAfisYarnTex = -0.245;
  static const double uAfisRouteDivisor = 1.6;

  // Hairiness Uster — AFIS route yarn-type adjustments
  // Stored as: multiply factor (1 = no change), so 0.86 = base*(1-0.14), etc.
  static const List<double> hairAfisMultiplier = [0.86, 0.69, 1.06, 0.81];

  // Hairiness Uster — HVI route base formula divisor
  static const double hairHviBaseDivisor = 1.1;
  static const double hairHviSpindleCoef = 0.02;
  static const double hairHviSpindleMicFactor = 3.3; // Mic*3.3 used as proxy for Dm
  static const double hairHviNepsProxy = 80.0;
  static const double hairHviSfiCoef = 0.05;

  // Hairiness HVI → Uster h62 reference + multipliers
  static const double hairHviH62Divisor = 1.45;
  static const List<double> hairHviUsterMultiplier = [0.80, 0.60, 1.00, 0.75];

  // Hairiness S3 (Zweigle)
  static const double hairS3Base = 275.0;
  static const double hairS3V75Factor = 0.35;
  static const double hairS3V74BoostFactor = 1.60; // v74 = v75 + v75*0.60
  static const double hairS3V76Factor = 1.1;
  static const double hairS3V77ReductionFactor = 0.40;

  // RovCV regression
  static const double rovCvA0 = 10.16;
  static const double rovCvA1 = -0.015;
  static const double rovCvA2 = 0.000012;

  // ── App 6: Yarn quality tier multipliers ────────────────────────────────
  // Applied to move from Best (base) → Good → Average
  // Structure: {from: 'best', to: 'good', property: string, factor}

  // Good mill COPS from Best COPS
  static const double goodCopsUAdd = 1.0;
  static const double goodCopsCvmAdd = 1.0;
  static const double goodCopsThin30 = 2.0;
  static const double goodCopsThin40 = 2.0;
  static const double goodCopsThin50 = 4.0;
  static const double goodCopsThick35 = 2.0;
  static const double goodCopsThick50 = 3.0;
  static const double goodCopsNeps140 = 2.6;
  static const double goodCopsNeps200 = 3.0;
  static const double goodCopsHairiness = 1.2;
  static const double goodCopsDensity = 0.9;

  // Average mill COPS from Good COPS
  static const double avgCopsUAdd = 1.0;
  static const double avgCopsCvmAdd = 1.0;
  static const double avgCopsThin30 = 2.0;
  static const double avgCopsThin40 = 2.0;
  static const double avgCopsThin50 = 3.0;
  static const double avgCopsThick35 = 2.0;
  static const double avgCopsThick50 = 2.0;
  static const double avgCopsNeps140 = 2.5;
  static const double avgCopsNeps200 = 2.6;
  static const double avgCopsHairiness = 1.25;
  static const double avgCopsDensity = 0.9;

  // ── Mix optimiser: yarn strength formula ────────────────────────────────
  static const double mixStrUI = 0.31;
  static const double mixStrStrength = 0.8;
  static const double mixStrElong = -1.1;
  static const double mixStrCountTex = 0.062; // × (590.5/count)
  static const double mixStrTM = 0.35;
  static const double mixStrIntercept = -21.8;
  static const double mixStrMic = -0.73;
  static const double mixStrDivisor = 1.1;

  // ── App 4: SFI formulas ────────────────────────────────────────────────
  static const double sfiA0 = 122.56;
  static const double sfiA1 = -12.87; // UHM inches
  static const double sfiA2 = -1.22; // UI

  static const double sfiBb0 = 90.34;
  static const double sfiBb1 = -37.47; // SL2 inches (2.5% span)
  static const double sfiBb2 = -0.90; // UR
}
