// Cotton variety reference database.
// Fields marked null are blank in the original workbook — treated as nullable.

class FibreVariety {
  final int slNo;
  final String group; // "Indian" | "Foreign"
  final String varietyName;
  final double? span25mm;
  final double? span50mm;
  final double? uniformityIndex;
  final double? uniformityRatio;
  final double? strength18Gtex;
  final double? strengthCnTex;
  final double? mic;
  final double? breakingElongPct;
  final double? shortFibreContent;
  final double? reflectanceRd;
  final double? yellownessB;
  final double? nepsPerG;
  final double? nepsSizeUm;
  final double? seedCoatNepsPerG;
  final double? scnSizeUm;
  final double? sfcN;

  const FibreVariety({
    required this.slNo,
    required this.group,
    required this.varietyName,
    this.span25mm,
    this.span50mm,
    this.uniformityIndex,
    this.uniformityRatio,
    this.strength18Gtex,
    this.strengthCnTex,
    this.mic,
    this.breakingElongPct,
    this.shortFibreContent,
    this.reflectanceRd,
    this.yellownessB,
    this.nepsPerG,
    this.nepsSizeUm,
    this.seedCoatNepsPerG,
    this.scnSizeUm,
    this.sfcN,
  });
}

// Indian varieties (slNo 1–30)
const List<FibreVariety> kIndianVarieties = [
  FibreVariety(slNo: 1, group: 'Indian', varietyName: 'Assam Comilla', span25mm: 18, strength18Gtex: 53, strengthCnTex: 16, breakingElongPct: 6.8),
  FibreVariety(slNo: 2, group: 'Indian', varietyName: 'Desi, RG-8, RST-9', span25mm: 19, strength18Gtex: 56, strengthCnTex: 17, breakingElongPct: 7.0),
  FibreVariety(slNo: 3, group: 'Indian', varietyName: 'Kalagin', span25mm: 19, strength18Gtex: 50, strengthCnTex: 16, breakingElongPct: 6.5),
  FibreVariety(slNo: 4, group: 'Indian', varietyName: 'Wagad', span25mm: 22, strength18Gtex: 50, strengthCnTex: 18, breakingElongPct: 5.8),
  FibreVariety(slNo: 5, group: 'Indian', varietyName: 'G-11', span25mm: 22, strength18Gtex: 52, strengthCnTex: 19, breakingElongPct: 5.2),
  FibreVariety(slNo: 6, group: 'Indian', varietyName: 'G-27 (Sankar-4)', span25mm: 25, span50mm: 13, uniformityIndex: 82, uniformityRatio: 43, strength18Gtex: 24, strengthCnTex: 27, mic: 4.3, breakingElongPct: 6.5, shortFibreContent: 16, reflectanceRd: 74, yellownessB: 9.5),
  FibreVariety(slNo: 7, group: 'Indian', varietyName: 'LRA 5166', span25mm: 25, span50mm: 13, uniformityIndex: 82, uniformityRatio: 43, strength18Gtex: 23, strengthCnTex: 26, mic: 4.5, breakingElongPct: 6.2, shortFibreContent: 16, reflectanceRd: 73, yellownessB: 9.8),
  FibreVariety(slNo: 8, group: 'Indian', varietyName: 'Digvijay (NHH-44)', span25mm: 25, span50mm: 13, uniformityIndex: 82, uniformityRatio: 43, strength18Gtex: 23, strengthCnTex: 25, mic: 4.3, breakingElongPct: 6.0, shortFibreContent: 16, reflectanceRd: 74, yellownessB: 9.5),
  FibreVariety(slNo: 9, group: 'Indian', varietyName: 'F-414 (Jayadhar)', span25mm: 25, span50mm: 13, uniformityIndex: 82, uniformityRatio: 43, strength18Gtex: 23, strengthCnTex: 26, mic: 4.5, breakingElongPct: 6.2, shortFibreContent: 16, reflectanceRd: 74, yellownessB: 9.5),
  FibreVariety(slNo: 10, group: 'Indian', varietyName: 'MCU-5', span25mm: 31, span50mm: 16, uniformityIndex: 84, uniformityRatio: 47, strength18Gtex: 28, strengthCnTex: 32, mic: 4.0, breakingElongPct: 6.5, shortFibreContent: 10, reflectanceRd: 76, yellownessB: 9.0, nepsPerG: 180, nepsSizeUm: 700, seedCoatNepsPerG: 8, scnSizeUm: 1200, sfcN: 15),
  FibreVariety(slNo: 11, group: 'Indian', varietyName: 'Sanjay (V-797)', span25mm: 26, span50mm: 14, uniformityIndex: 82, uniformityRatio: 44, strength18Gtex: 24, strengthCnTex: 27, mic: 4.5, breakingElongPct: 6.3, shortFibreContent: 14),
  FibreVariety(slNo: 12, group: 'Indian', varietyName: 'Supriya (Hybrid-4)', span25mm: 28, span50mm: 15, uniformityIndex: 83, uniformityRatio: 45, strength18Gtex: 25, strengthCnTex: 28, mic: 4.2, breakingElongPct: 6.4, shortFibreContent: 12),
  FibreVariety(slNo: 13, group: 'Indian', varietyName: 'Savita (Hybrid-6)', span25mm: 28, span50mm: 15, uniformityIndex: 83, uniformityRatio: 45, strength18Gtex: 26, strengthCnTex: 29, mic: 4.1, breakingElongPct: 6.5, shortFibreContent: 12),
  FibreVariety(slNo: 14, group: 'Indian', varietyName: 'JK-Hybrid-1', span25mm: 27, span50mm: 14, uniformityIndex: 82, uniformityRatio: 44, strength18Gtex: 24, strengthCnTex: 27, mic: 4.4, breakingElongPct: 6.2, shortFibreContent: 13),
  FibreVariety(slNo: 15, group: 'Indian', varietyName: 'Bunny / Brahma (Bt)', span25mm: 29, span50mm: 15, uniformityIndex: 83, uniformityRatio: 46, strength18Gtex: 26, strengthCnTex: 29, mic: 4.3, breakingElongPct: 6.3, shortFibreContent: 11),
  FibreVariety(slNo: 16, group: 'Indian', varietyName: 'Mallika (Bt)', span25mm: 29, span50mm: 15, uniformityIndex: 83, uniformityRatio: 46, strength18Gtex: 26, strengthCnTex: 29, mic: 4.2, breakingElongPct: 6.4, shortFibreContent: 11),
  FibreVariety(slNo: 17, group: 'Indian', varietyName: 'Ankur-651 (Bt)', span25mm: 28, span50mm: 14, uniformityIndex: 82, uniformityRatio: 45, strength18Gtex: 25, strengthCnTex: 28, mic: 4.4, breakingElongPct: 6.2),
  FibreVariety(slNo: 18, group: 'Indian', varietyName: 'Rasi-659 (Bt)', span25mm: 29, span50mm: 15, uniformityIndex: 83, uniformityRatio: 46, strength18Gtex: 26, strengthCnTex: 29, mic: 4.3, breakingElongPct: 6.3),
  FibreVariety(slNo: 19, group: 'Indian', varietyName: 'NCS-145 (Bt)', span25mm: 28, span50mm: 15, uniformityIndex: 83, uniformityRatio: 45, strength18Gtex: 25, strengthCnTex: 28, mic: 4.3, breakingElongPct: 6.3),
  FibreVariety(slNo: 20, group: 'Indian', varietyName: 'MRC-7301 (Bt)', span25mm: 29, span50mm: 15, uniformityIndex: 83, uniformityRatio: 46, strength18Gtex: 26, strengthCnTex: 29, mic: 4.2, breakingElongPct: 6.4),
  FibreVariety(slNo: 21, group: 'Indian', varietyName: 'S-6', span25mm: 29, span50mm: 15, uniformityIndex: 80, uniformityRatio: 43, strength18Gtex: 26, strengthCnTex: 30, mic: 4.3, breakingElongPct: 5.0, shortFibreContent: 13),
  FibreVariety(slNo: 22, group: 'Indian', varietyName: 'H-777 (Suvin)', span25mm: 38, span50mm: 20, uniformityIndex: 87, uniformityRatio: 51, strength18Gtex: 35, strengthCnTex: 41, mic: 3.2, breakingElongPct: 7.2, shortFibreContent: 5),
  FibreVariety(slNo: 23, group: 'Indian', varietyName: 'Suvin Bt', span25mm: 38, span50mm: 20, uniformityIndex: 87, uniformityRatio: 51, strength18Gtex: 34, strengthCnTex: 40, mic: 3.3, breakingElongPct: 7.0, shortFibreContent: 5),
  FibreVariety(slNo: 24, group: 'Indian', varietyName: 'TCH-213', span25mm: 36, span50mm: 19, uniformityIndex: 86, uniformityRatio: 50, strength18Gtex: 29, strengthCnTex: 34, mic: 3.2, breakingElongPct: 6.5, nepsPerG: 250, nepsSizeUm: 750, seedCoatNepsPerG: 20, scnSizeUm: 1400, sfcN: 25),
  FibreVariety(slNo: 25, group: 'Indian', varietyName: 'Varalakshmi', span25mm: 36, span50mm: 19, uniformityIndex: 86, uniformityRatio: 50, strength18Gtex: 29, strengthCnTex: 34, mic: 3.2, breakingElongPct: 6.2),
  FibreVariety(slNo: 26, group: 'Indian', varietyName: 'DCH 32', span25mm: 36, span50mm: 19, uniformityIndex: 86, uniformityRatio: 50, strength18Gtex: 29, strengthCnTex: 34, mic: 3.2, breakingElongPct: 6.2),
  FibreVariety(slNo: 27, group: 'Indian', varietyName: 'PCH-9 (DCH-32 Bt)', span25mm: 36, span50mm: 19, uniformityIndex: 86, uniformityRatio: 50, strength18Gtex: 29, strengthCnTex: 34, mic: 3.2, breakingElongPct: 6.2),
  FibreVariety(slNo: 28, group: 'Indian', varietyName: 'MCU-7', span25mm: 33, span50mm: 17, uniformityIndex: 85, uniformityRatio: 48, strength18Gtex: 29, strengthCnTex: 34, mic: 3.6, breakingElongPct: 6.5, shortFibreContent: 8),
  FibreVariety(slNo: 29, group: 'Indian', varietyName: 'DCH 32, Varalakshmi, TCH-213', span25mm: 36, strength18Gtex: 29, mic: 3.2, breakingElongPct: 6.2, nepsPerG: 250, nepsSizeUm: 750, seedCoatNepsPerG: 20, scnSizeUm: 1400, sfcN: 25),
  FibreVariety(slNo: 30, group: 'Indian', varietyName: 'MCU-5 (reference)', span25mm: 31, span50mm: 16, uniformityIndex: 84, uniformityRatio: 47, strength18Gtex: 28, strengthCnTex: 32, mic: 4.0, breakingElongPct: 6.5, shortFibreContent: 10, nepsPerG: 180, nepsSizeUm: 700, seedCoatNepsPerG: 8, scnSizeUm: 1200, sfcN: 15),
];

// Foreign varieties
const List<FibreVariety> kForeignVarieties = [
  FibreVariety(slNo: 1, group: 'Foreign', varietyName: 'Pima (USA)', span25mm: 35, span50mm: 18, uniformityIndex: 82, uniformityRatio: 46, strength18Gtex: 35, strengthCnTex: 41, mic: 4.1, breakingElongPct: 7.0, shortFibreContent: 5),
  FibreVariety(slNo: 2, group: 'Foreign', varietyName: 'Giza 86 (Egypt)', span25mm: 32, span50mm: 17, uniformityIndex: 81, uniformityRatio: 45, strength18Gtex: 34, strengthCnTex: 39, mic: 4.2, breakingElongPct: 6.5, shortFibreContent: 6),
  FibreVariety(slNo: 3, group: 'Foreign', varietyName: 'Giza 88 (Egypt)', span25mm: 35, span50mm: 18, uniformityIndex: 82, uniformityRatio: 46, strength18Gtex: 35, strengthCnTex: 40, mic: 4.0, breakingElongPct: 7.0, shortFibreContent: 5),
  FibreVariety(slNo: 4, group: 'Foreign', varietyName: 'Acala (USA)', span25mm: 29, span50mm: 15, uniformityIndex: 82, uniformityRatio: 44, strength18Gtex: 26, strengthCnTex: 30, mic: 4.2, breakingElongPct: 6.2, shortFibreContent: 10),
  FibreVariety(slNo: 5, group: 'Foreign', varietyName: 'SJA (Brazil)', span25mm: 29, span50mm: 15, uniformityIndex: 81, uniformityRatio: 44, strength18Gtex: 26, strengthCnTex: 30, mic: 4.0, breakingElongPct: 6.3, shortFibreContent: 10),
];

List<FibreVariety> get kAllVarieties => [...kIndianVarieties, ...kForeignVarieties];
