// Yarn quality benchmark database.
// Best-mill COPS values for counts 6–40.
// Good and Average mill values are derived in App 6 logic.

class YarnQualityRow {
  final int count;
  final double uPct;
  final double uPctCV;
  final double cvmPct;
  final double cvmCV;
  final double thin30;
  final double thin40;
  final double thin50;
  final double thick35;
  final double thick50;
  final double neps140;
  final double neps200;
  final double totalIPI;
  final double hairinessIndex;
  final double hairinessCV;
  final double s3Hairiness;
  final double density;
  final double yarnDia;
  final double strengthCnTex;
  final double strengthCV;
  final double elongationPct;

  const YarnQualityRow({
    required this.count,
    required this.uPct,
    required this.uPctCV,
    required this.cvmPct,
    required this.cvmCV,
    required this.thin30,
    required this.thin40,
    required this.thin50,
    required this.thick35,
    required this.thick50,
    required this.neps140,
    required this.neps200,
    required this.totalIPI,
    required this.hairinessIndex,
    required this.hairinessCV,
    required this.s3Hairiness,
    required this.density,
    required this.yarnDia,
    required this.strengthCnTex,
    required this.strengthCV,
    required this.elongationPct,
  });
}

// ── Ring Carded Knitting (COPS — Best mill) ─────────────────────────────────
const List<YarnQualityRow> kRingCardedKnitting = [
  YarnQualityRow(count: 6,  uPct: 9.6,  uPctCV: 3.5, cvmPct: 9.2,  cvmCV: 3.2, thin30: 0,  thin40: 4,  thin50: 0, thick35: 12, thick50: 6,  neps140: 44, neps200: 3,  totalIPI: 9,  hairinessIndex: 8.8, hairinessCV: 22, s3Hairiness: 9000, density: 0.53, yarnDia: 0.26, strengthCnTex: 19.31, strengthCV: 9.5, elongationPct: 5.8),
  YarnQualityRow(count: 7,  uPct: 9.8,  uPctCV: 3.5, cvmPct: 9.5,  cvmCV: 3.2, thin30: 0,  thin40: 5,  thin50: 0, thick35: 14, thick50: 7,  neps140: 55, neps200: 5,  totalIPI: 12, hairinessIndex: 8.3, hairinessCV: 22, s3Hairiness: 8000, density: 0.53, yarnDia: 0.25, strengthCnTex: 19.26, strengthCV: 9.5, elongationPct: 5.8),
  YarnQualityRow(count: 8,  uPct: 10.0, uPctCV: 3.5, cvmPct: 9.8,  cvmCV: 3.2, thin30: 0,  thin40: 6,  thin50: 0, thick35: 18, thick50: 8,  neps140: 62, neps200: 6,  totalIPI: 14, hairinessIndex: 7.9, hairinessCV: 22, s3Hairiness: 7000, density: 0.53, yarnDia: 0.23, strengthCnTex: 19.20, strengthCV: 9.5, elongationPct: 5.8),
  YarnQualityRow(count: 10, uPct: 10.5, uPctCV: 3.5, cvmPct: 10.2, cvmCV: 3.2, thin30: 1,  thin40: 8,  thin50: 0, thick35: 22, thick50: 10, neps140: 70, neps200: 8,  totalIPI: 18, hairinessIndex: 7.2, hairinessCV: 22, s3Hairiness: 5500, density: 0.53, yarnDia: 0.21, strengthCnTex: 19.10, strengthCV: 9.5, elongationPct: 5.7),
  YarnQualityRow(count: 12, uPct: 11.0, uPctCV: 3.8, cvmPct: 10.6, cvmCV: 3.5, thin30: 2,  thin40: 12, thin50: 0, thick35: 26, thick50: 12, neps140: 78, neps200: 9,  totalIPI: 21, hairinessIndex: 6.6, hairinessCV: 22, s3Hairiness: 4500, density: 0.53, yarnDia: 0.19, strengthCnTex: 19.00, strengthCV: 9.5, elongationPct: 5.7),
  YarnQualityRow(count: 16, uPct: 11.5, uPctCV: 4.0, cvmPct: 11.2, cvmCV: 3.8, thin30: 4,  thin40: 18, thin50: 0, thick35: 32, thick50: 15, neps140: 88, neps200: 12, totalIPI: 27, hairinessIndex: 5.8, hairinessCV: 23, s3Hairiness: 3500, density: 0.53, yarnDia: 0.17, strengthCnTex: 18.90, strengthCV: 9.8, elongationPct: 5.6),
  YarnQualityRow(count: 20, uPct: 12.0, uPctCV: 4.0, cvmPct: 11.6, cvmCV: 3.8, thin30: 6,  thin40: 24, thin50: 0, thick35: 38, thick50: 18, neps140: 96, neps200: 14, totalIPI: 32, hairinessIndex: 5.2, hairinessCV: 23, s3Hairiness: 2800, density: 0.54, yarnDia: 0.15, strengthCnTex: 18.80, strengthCV: 9.8, elongationPct: 5.6),
  YarnQualityRow(count: 24, uPct: 12.5, uPctCV: 4.2, cvmPct: 12.1, cvmCV: 4.0, thin30: 8,  thin40: 30, thin50: 1, thick35: 45, thick50: 22, neps140: 105, neps200: 16, totalIPI: 39, hairinessIndex: 4.7, hairinessCV: 23, s3Hairiness: 2200, density: 0.54, yarnDia: 0.14, strengthCnTex: 18.70, strengthCV: 9.8, elongationPct: 5.5),
  YarnQualityRow(count: 30, uPct: 13.0, uPctCV: 4.2, cvmPct: 12.6, cvmCV: 4.0, thin30: 12, thin40: 36, thin50: 1, thick35: 55, thick50: 27, neps140: 115, neps200: 18, totalIPI: 46, hairinessIndex: 4.2, hairinessCV: 24, s3Hairiness: 1700, density: 0.55, yarnDia: 0.12, strengthCnTex: 18.60, strengthCV: 10.0, elongationPct: 5.5),
  YarnQualityRow(count: 40, uPct: 13.8, uPctCV: 4.5, cvmPct: 13.4, cvmCV: 4.2, thin30: 18, thin40: 45, thin50: 2, thick35: 70, thick50: 35, neps140: 135, neps200: 22, totalIPI: 59, hairinessIndex: 3.5, hairinessCV: 24, s3Hairiness: 1200, density: 0.55, yarnDia: 0.10, strengthCnTex: 18.50, strengthCV: 10.0, elongationPct: 5.4),
];

// ── Ring Carded Weaving (COPS — Best mill) ──────────────────────────────────
const List<YarnQualityRow> kRingCardedWeaving = [
  YarnQualityRow(count: 6,  uPct: 9.4,  uPctCV: 3.5, cvmPct: 9.0,  cvmCV: 3.2, thin30: 0, thin40: 3, thin50: 0, thick35: 10, thick50: 5, neps140: 40, neps200: 2, totalIPI: 7, hairinessIndex: 8.8, hairinessCV: 22, s3Hairiness: 9000, density: 0.53, yarnDia: 0.26, strengthCnTex: 19.5, strengthCV: 9.5, elongationPct: 5.8),
  YarnQualityRow(count: 8,  uPct: 9.8,  uPctCV: 3.5, cvmPct: 9.5,  cvmCV: 3.2, thin30: 0, thin40: 5, thin50: 0, thick35: 14, thick50: 7, neps140: 52, neps200: 4, totalIPI: 11, hairinessIndex: 7.9, hairinessCV: 22, s3Hairiness: 7000, density: 0.53, yarnDia: 0.23, strengthCnTex: 19.3, strengthCV: 9.5, elongationPct: 5.8),
  YarnQualityRow(count: 10, uPct: 10.2, uPctCV: 3.5, cvmPct: 9.9,  cvmCV: 3.2, thin30: 1, thin40: 7, thin50: 0, thick35: 18, thick50: 9, neps140: 60, neps200: 6, totalIPI: 15, hairinessIndex: 7.2, hairinessCV: 22, s3Hairiness: 5500, density: 0.53, yarnDia: 0.21, strengthCnTex: 19.2, strengthCV: 9.5, elongationPct: 5.7),
  YarnQualityRow(count: 12, uPct: 10.7, uPctCV: 3.8, cvmPct: 10.3, cvmCV: 3.5, thin30: 2, thin40: 10, thin50: 0, thick35: 22, thick50: 11, neps140: 68, neps200: 8, totalIPI: 19, hairinessIndex: 6.6, hairinessCV: 22, s3Hairiness: 4500, density: 0.53, yarnDia: 0.19, strengthCnTex: 19.1, strengthCV: 9.5, elongationPct: 5.7),
  YarnQualityRow(count: 16, uPct: 11.2, uPctCV: 4.0, cvmPct: 10.8, cvmCV: 3.8, thin30: 3, thin40: 15, thin50: 0, thick35: 28, thick50: 13, neps140: 78, neps200: 10, totalIPI: 23, hairinessIndex: 5.8, hairinessCV: 23, s3Hairiness: 3500, density: 0.53, yarnDia: 0.17, strengthCnTex: 19.0, strengthCV: 9.8, elongationPct: 5.6),
  YarnQualityRow(count: 20, uPct: 11.7, uPctCV: 4.0, cvmPct: 11.3, cvmCV: 3.8, thin30: 5, thin40: 20, thin50: 0, thick35: 34, thick50: 16, neps140: 86, neps200: 12, totalIPI: 28, hairinessIndex: 5.2, hairinessCV: 23, s3Hairiness: 2800, density: 0.54, yarnDia: 0.15, strengthCnTex: 18.9, strengthCV: 9.8, elongationPct: 5.6),
  YarnQualityRow(count: 24, uPct: 12.2, uPctCV: 4.2, cvmPct: 11.8, cvmCV: 4.0, thin30: 7, thin40: 25, thin50: 0, thick35: 40, thick50: 20, neps140: 94, neps200: 14, totalIPI: 34, hairinessIndex: 4.7, hairinessCV: 23, s3Hairiness: 2200, density: 0.54, yarnDia: 0.14, strengthCnTex: 18.8, strengthCV: 9.8, elongationPct: 5.5),
  YarnQualityRow(count: 30, uPct: 12.7, uPctCV: 4.2, cvmPct: 12.3, cvmCV: 4.0, thin30: 10, thin40: 32, thin50: 1, thick35: 50, thick50: 25, neps140: 104, neps200: 16, totalIPI: 42, hairinessIndex: 4.2, hairinessCV: 24, s3Hairiness: 1700, density: 0.55, yarnDia: 0.12, strengthCnTex: 18.7, strengthCV: 10.0, elongationPct: 5.5),
  YarnQualityRow(count: 40, uPct: 13.5, uPctCV: 4.5, cvmPct: 13.1, cvmCV: 4.2, thin30: 15, thin40: 40, thin50: 2, thick35: 65, thick50: 32, neps140: 125, neps200: 20, totalIPI: 54, hairinessIndex: 3.5, hairinessCV: 24, s3Hairiness: 1200, density: 0.55, yarnDia: 0.10, strengthCnTex: 18.6, strengthCV: 10.0, elongationPct: 5.4),
];

// ── Ring Combed Knitting (COPS — Best mill) ─────────────────────────────────
const List<YarnQualityRow> kRingCombedKnitting = [
  YarnQualityRow(count: 20, uPct: 10.6, uPctCV: 3.8, cvmPct: 10.3, cvmCV: 3.5, thin30: 0, thin40: 5,  thin50: 0, thick35: 20, thick50: 3, neps140: 22, neps200: 2, totalIPI: 5, hairinessIndex: 4.9, hairinessCV: 22, s3Hairiness: 2500, density: 0.56, yarnDia: 0.15, strengthCnTex: 21.0, strengthCV: 9.0, elongationPct: 6.0),
  YarnQualityRow(count: 24, uPct: 11.0, uPctCV: 3.8, cvmPct: 10.7, cvmCV: 3.5, thin30: 0, thin40: 10, thin50: 0, thick35: 30, thick50: 5, neps140: 36, neps200: 4, totalIPI: 9, hairinessIndex: 4.2, hairinessCV: 22, s3Hairiness: 2000, density: 0.57, yarnDia: 0.14, strengthCnTex: 21.2, strengthCV: 9.0, elongationPct: 6.0),
  YarnQualityRow(count: 30, uPct: 11.5, uPctCV: 4.0, cvmPct: 11.1, cvmCV: 3.8, thin30: 1, thin40: 15, thin50: 0, thick35: 40, thick50: 5, neps140: 50, neps200: 5, totalIPI: 10, hairinessIndex: 3.5, hairinessCV: 22, s3Hairiness: 1600, density: 0.58, yarnDia: 0.12, strengthCnTex: 21.3, strengthCV: 9.0, elongationPct: 5.9),
  YarnQualityRow(count: 40, uPct: 12.0, uPctCV: 4.0, cvmPct: 11.6, cvmCV: 3.8, thin30: 2, thin40: 25, thin50: 1, thick35: 60, thick50: 6, neps140: 68, neps200: 8, totalIPI: 15, hairinessIndex: 3.0, hairinessCV: 23, s3Hairiness: 1200, density: 0.59, yarnDia: 0.10, strengthCnTex: 21.4, strengthCV: 9.0, elongationPct: 5.8),
  YarnQualityRow(count: 50, uPct: 12.5, uPctCV: 4.2, cvmPct: 11.6, cvmCV: 4.0, thin30: 4, thin40: 43, thin50: 1, thick35: 107, thick50: 8, neps140: 91, neps200: 15, totalIPI: 24, hairinessIndex: 2.6, hairinessCV: 23, s3Hairiness: 900, density: 0.74, yarnDia: 0.09, strengthCnTex: 21.5, strengthCV: 9.2, elongationPct: 5.7),
];

// ── Ring Combed Weaving (COPS — Best mill) ──────────────────────────────────
const List<YarnQualityRow> kRingCombedWeaving = [
  YarnQualityRow(count: 20, uPct: 10.4, uPctCV: 3.8, cvmPct: 10.1, cvmCV: 3.5, thin30: 0, thin40: 4, thin50: 0, thick35: 18, thick50: 2, neps140: 18, neps200: 1, totalIPI: 3, hairinessIndex: 4.9, hairinessCV: 22, s3Hairiness: 2500, density: 0.56, yarnDia: 0.15, strengthCnTex: 21.5, strengthCV: 8.8, elongationPct: 6.0),
  YarnQualityRow(count: 24, uPct: 10.8, uPctCV: 3.8, cvmPct: 10.5, cvmCV: 3.5, thin30: 0, thin40: 8, thin50: 0, thick35: 26, thick50: 4, neps140: 28, neps200: 2, totalIPI: 6, hairinessIndex: 4.2, hairinessCV: 22, s3Hairiness: 2000, density: 0.57, yarnDia: 0.14, strengthCnTex: 21.7, strengthCV: 8.8, elongationPct: 5.9),
  YarnQualityRow(count: 30, uPct: 11.3, uPctCV: 4.0, cvmPct: 10.9, cvmCV: 3.8, thin30: 0, thin40: 12, thin50: 0, thick35: 36, thick50: 4, neps140: 40, neps200: 4, totalIPI: 8, hairinessIndex: 3.5, hairinessCV: 22, s3Hairiness: 1600, density: 0.58, yarnDia: 0.12, strengthCnTex: 21.8, strengthCV: 8.8, elongationPct: 5.9),
  YarnQualityRow(count: 40, uPct: 11.8, uPctCV: 4.0, cvmPct: 11.4, cvmCV: 3.8, thin30: 1, thin40: 20, thin50: 0, thick35: 52, thick50: 5, neps140: 58, neps200: 6, totalIPI: 11, hairinessIndex: 3.0, hairinessCV: 23, s3Hairiness: 1200, density: 0.59, yarnDia: 0.10, strengthCnTex: 21.9, strengthCV: 9.0, elongationPct: 5.8),
];

// ── Compact Combed Weaving (COPS — Best mill) ───────────────────────────────
const List<YarnQualityRow> kCompactCombedWeaving = [
  YarnQualityRow(count: 20, uPct: 9.8,  uPctCV: 3.5, cvmPct: 9.4,  cvmCV: 3.2, thin30: 0, thin40: 2, thin50: 0, thick35: 10, thick50: 1, neps140: 12, neps200: 1, totalIPI: 2, hairinessIndex: 3.5, hairinessCV: 20, s3Hairiness: 1200, density: 0.58, yarnDia: 0.15, strengthCnTex: 23.0, strengthCV: 8.5, elongationPct: 5.5),
  YarnQualityRow(count: 24, uPct: 10.2, uPctCV: 3.5, cvmPct: 9.8,  cvmCV: 3.2, thin30: 0, thin40: 4, thin50: 0, thick35: 16, thick50: 2, neps140: 20, neps200: 1, totalIPI: 3, hairinessIndex: 3.0, hairinessCV: 20, s3Hairiness: 950,  density: 0.58, yarnDia: 0.14, strengthCnTex: 23.2, strengthCV: 8.5, elongationPct: 5.5),
  YarnQualityRow(count: 30, uPct: 10.6, uPctCV: 3.8, cvmPct: 10.3, cvmCV: 3.5, thin30: 0, thin40: 7, thin50: 0, thick35: 24, thick50: 3, neps140: 30, neps200: 3, totalIPI: 6, hairinessIndex: 2.6, hairinessCV: 20, s3Hairiness: 700,  density: 0.59, yarnDia: 0.12, strengthCnTex: 23.4, strengthCV: 8.5, elongationPct: 5.4),
  YarnQualityRow(count: 40, uPct: 11.0, uPctCV: 4.0, cvmPct: 10.6, cvmCV: 3.8, thin30: 0, thin40: 12, thin50: 0, thick35: 38, thick50: 4, neps140: 46, neps200: 5, totalIPI: 9, hairinessIndex: 2.2, hairinessCV: 21, s3Hairiness: 500,  density: 0.60, yarnDia: 0.10, strengthCnTex: 23.5, strengthCV: 8.5, elongationPct: 5.4),
];

List<YarnQualityRow> yarnQualityForCategory(int cat) {
  switch (cat) {
    case 1: return kRingCardedKnitting;
    case 2: return kRingCardedWeaving;
    case 3: return kRingCombedKnitting;
    case 4: return kRingCombedWeaving;
    case 5: return kCompactCombedWeaving;
    default: return kRingCardedKnitting;
  }
}

// Find nearest count row (picks the closest count in the list)
YarnQualityRow? findNearestRow(List<YarnQualityRow> rows, int count) {
  if (rows.isEmpty) return null;
  return rows.reduce((a, b) =>
      (a.count - count).abs() < (b.count - count).abs() ? a : b);
}
