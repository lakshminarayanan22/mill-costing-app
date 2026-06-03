import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../quality/data/fibre_parameters.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App5VarietyScreen extends StatefulWidget {
  const App5VarietyScreen({super.key});

  @override
  State<App5VarietyScreen> createState() => _App5VarietyScreenState();
}

class _App5VarietyScreenState extends State<App5VarietyScreen> {
  FibreVariety? _selected;
  final _all = kAllVarieties;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 5 — Fibre Parameters by Variety')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdInfoCard(
              'Displays maximum / typical reference values for each cotton variety '
              'from the built-in database.',
            ),
            const SizedBox(height: 14),
            const QdSectionLabel('Select Cotton Variety'),
            DropdownButtonFormField<FibreVariety>(
              decoration: const InputDecoration(labelText: 'Cotton variety'),
              // ignore: deprecated_member_use
              value: _selected,
              items: _all.map((v) => DropdownMenuItem(
                value: v,
                child: Text('${v.slNo}. ${v.varietyName} (${v.group})'),
              )).toList(),
              onChanged: (v) => setState(() => _selected = v),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 16),
              _VarietyChart(variety: _selected!),
              const SizedBox(height: 12),
              const QdSectionLabel('Fibre Parameters (Maximum Values)'),
              Expanded(
                child: SingleChildScrollView(
                  child: QdResultCard(children: [
                    _row('Group', _selected!.group),
                    _row('Variety Name', _selected!.varietyName),
                    const Divider(height: 12),
                    _row('2.5% span length (mm)', _fmt(_selected!.span25mm)),
                    _row('50% span length (mm)', _fmt(_selected!.span50mm)),
                    _row('Uniformity Index', _fmt(_selected!.uniformityIndex)),
                    _row('Uniformity Ratio', _fmt(_selected!.uniformityRatio)),
                    const Divider(height: 12),
                    _row('Strength 1/8" (g/tex)', _fmt(_selected!.strength18Gtex)),
                    _row('Strength (cN/tex)', _fmt(_selected!.strengthCnTex)),
                    _row('Micronaire', _fmt(_selected!.mic)),
                    _row('Breaking Elongation %', _fmt(_selected!.breakingElongPct)),
                    _row('Short Fibre Content', _fmt(_selected!.shortFibreContent)),
                    const Divider(height: 12),
                    _row('Reflectance Rd', _fmt(_selected!.reflectanceRd)),
                    _row('Yellowness +b', _fmt(_selected!.yellownessB)),
                    const Divider(height: 12),
                    _row('Neps / g', _fmt(_selected!.nepsPerG)),
                    _row('Neps size (µm)', _fmt(_selected!.nepsSizeUm)),
                    _row('Seed coat neps / g', _fmt(_selected!.seedCoatNepsPerG)),
                    _row('SCN size (µm)', _fmt(_selected!.scnSizeUm)),
                    _row('SFC(n) %', _fmt(_selected!.sfcN)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return QdResultRow(label, value);
  }

  String _fmt(double? v) => v == null ? '—' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
}

// ── Variety parameter bar chart ───────────────────────────────────────────────
// Normalises 5 key parameters to 0–100 scale for visual comparison.

class _VarietyChart extends StatelessWidget {
  final FibreVariety variety;
  const _VarietyChart({required this.variety});

  static const _labels = ['UHML\n(mm)', 'Strength\n(cN/tex)', 'Mic', 'UI\n(%)', 'Rd\n(refl.)'];
  static const _maxVals = [42.0, 60.0, 6.0, 92.0, 90.0];
  static const _colors = [
    Color(0xFF1A56DB),
    Color(0xFF057A55),
    Color(0xFFE3A008),
    Color(0xFF9061F9),
    Color(0xFFFF5A1F),
  ];

  List<double?> get _rawVals => [
    variety.span25mm,
    variety.strengthCnTex,
    variety.mic,
    variety.uniformityIndex,
    variety.reflectanceRd,
  ];

  @override
  Widget build(BuildContext context) {
    final vals = _rawVals;
    final normalised = List.generate(
      vals.length,
      (i) => vals[i] != null
          ? ((vals[i]! / _maxVals[i]) * 100).clamp(0.0, 100.0)
          : 0.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${variety.varietyName} — Key Parameters',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(
              'Normalised to maximum typical value (higher = better)',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(5, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: normalised[i],
                          color: _colors[i],
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5)),
                          rodStackItems: [],
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= _labels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _labels[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}%',
                          style: const TextStyle(
                              fontSize: 9, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.textPrimary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final raw = vals[groupIndex];
                        return BarTooltipItem(
                          '${_labels[groupIndex].replaceAll('\n', ' ')}\n${raw?.toStringAsFixed(1) ?? '—'}',
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
