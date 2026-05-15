class BlendPreset {
  final String id;
  final String name;
  final double blend1Pct;      // cotton / fibre 1 %
  final double blend2Pct;      // fibre 2 %
  final double blend2PricePerKg;
  final double blend2WastePct;
  final String blend2Label;    // e.g. "Viscose", "Polyester"

  const BlendPreset({
    required this.id,
    required this.name,
    required this.blend1Pct,
    required this.blend2Pct,
    required this.blend2PricePerKg,
    required this.blend2WastePct,
    required this.blend2Label,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'blend1Pct': blend1Pct,
        'blend2Pct': blend2Pct,
        'blend2PricePerKg': blend2PricePerKg,
        'blend2WastePct': blend2WastePct,
        'blend2Label': blend2Label,
      };

  factory BlendPreset.fromJson(Map<String, dynamic> j) => BlendPreset(
        id: j['id'] as String,
        name: j['name'] as String,
        blend1Pct: (j['blend1Pct'] as num).toDouble(),
        blend2Pct: (j['blend2Pct'] as num).toDouble(),
        blend2PricePerKg: (j['blend2PricePerKg'] as num).toDouble(),
        blend2WastePct: (j['blend2WastePct'] as num).toDouble(),
        blend2Label: j['blend2Label'] as String,
      );

  BlendPreset copyWith({
    String? id,
    String? name,
    double? blend1Pct,
    double? blend2Pct,
    double? blend2PricePerKg,
    double? blend2WastePct,
    String? blend2Label,
  }) =>
      BlendPreset(
        id: id ?? this.id,
        name: name ?? this.name,
        blend1Pct: blend1Pct ?? this.blend1Pct,
        blend2Pct: blend2Pct ?? this.blend2Pct,
        blend2PricePerKg: blend2PricePerKg ?? this.blend2PricePerKg,
        blend2WastePct: blend2WastePct ?? this.blend2WastePct,
        blend2Label: blend2Label ?? this.blend2Label,
      );
}
