import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../quality/data/yarn_quality.dart';
import '../../quality/qd_constants.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App6BenchmarkScreen extends StatefulWidget {
  const App6BenchmarkScreen({super.key});

  @override
  State<App6BenchmarkScreen> createState() => _App6BenchmarkScreenState();
}

class _App6BenchmarkScreenState extends State<App6BenchmarkScreen> {
  int _cat = 3; // 1–5
  int _count = 50;
  final _countCtrl = TextEditingController(text: '50');

  static const _catLabels = [
    'Ring Carded Knitting',
    'Ring Carded Weaving',
    'Ring Combed Knitting',
    'Ring Combed Weaving',
    'Compact Combed Weaving',
  ];

  YarnQualityRow? get _bestRow {
    final rows = yarnQualityForCategory(_cat);
    return findNearestRow(rows, _count);
  }

  // Derive Good COPS from Best COPS
  _DerivedRow? _goodCops(YarnQualityRow b) {
    return _DerivedRow(
      uPct: b.uPct + QDConstants.goodCopsUAdd,
      cvmPct: b.cvmPct + QDConstants.goodCopsCvmAdd,
      thin30: b.thin30 * QDConstants.goodCopsThin30,
      thin40: b.thin40 * QDConstants.goodCopsThin40,
      thin50: b.thin50 * QDConstants.goodCopsThin50,
      thick35: b.thick35 * QDConstants.goodCopsThick35,
      thick50: b.thick50 * QDConstants.goodCopsThick50,
      neps140: b.neps140 * QDConstants.goodCopsNeps140,
      neps200: b.neps200 * QDConstants.goodCopsNeps200,
      hairiness: b.hairinessIndex * QDConstants.goodCopsHairiness,
      density: b.density * QDConstants.goodCopsDensity,
    );
  }

  // Derive Average COPS from Good COPS
  _DerivedRow? _avgCops(_DerivedRow g) {
    return _DerivedRow(
      uPct: g.uPct + QDConstants.avgCopsUAdd,
      cvmPct: g.cvmPct + QDConstants.avgCopsCvmAdd,
      thin30: g.thin30 * QDConstants.avgCopsThin30,
      thin40: g.thin40 * QDConstants.avgCopsThin40,
      thin50: g.thin50 * QDConstants.avgCopsThin50,
      thick35: g.thick35 * QDConstants.avgCopsThick35,
      thick50: g.thick50 * QDConstants.avgCopsThick50,
      neps140: g.neps140 * QDConstants.avgCopsNeps140,
      neps200: g.neps200 * QDConstants.avgCopsNeps200,
      hairiness: g.hairiness * QDConstants.avgCopsHairiness,
      density: g.density * QDConstants.avgCopsDensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final best = _bestRow;
    final good = best != null ? _goodCops(best) : null;
    final avg = good != null ? _avgCops(good) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('App 6 — Yarn Quality by Count')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdSectionLabel('Yarn Category'),
            QdDropdown<int>(
              label: 'Category',
              value: _cat,
              items: List.generate(5, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_catLabels[i]),
              )),
              onChanged: (v) => setState(() => _cat = v ?? 1),
            ),
            const SizedBox(height: 10),
            QdField('Count (Ne)', _countCtrl, '50'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _count = int.tryParse(_countCtrl.text) ?? 50;
                  });
                },
                child: const Text('Show Benchmarks'),
              ),
            ),
            if (best != null && good != null && avg != null) ...[
              const SizedBox(height: 16),
              const QdInfoCard(
                'Shows Best, Good, and Average mill benchmarks (COPS). '
                'Good and Average values are derived from Best-mill figures.',
              ),
              const SizedBox(height: 12),
              _benchmarkTable(best, good, avg),
              const SizedBox(height: 16),
              _BenchmarkBarChart(best: best, good: good, avg: avg),
            ],
          ],
        ),
      ),
    );
  }

  Widget _benchmarkTable(YarnQualityRow best, _DerivedRow good, _DerivedRow avg) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Count ${best.count} — ${_catLabels[_cat - 1]} (COPS)',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: AppTheme.divider, width: 0.5),
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
              children: [
                _headerRow(['Parameter', 'Best', 'Good', 'Average']),
                _dataRow('U%', best.uPct.toStringAsFixed(1), good.uPct.toStringAsFixed(1), avg.uPct.toStringAsFixed(1)),
                _dataRow('CVm%', best.cvmPct.toStringAsFixed(1), good.cvmPct.toStringAsFixed(1), avg.cvmPct.toStringAsFixed(1)),
                _dataRow('Thin -30%', best.thin30.toStringAsFixed(0), good.thin30.toStringAsFixed(0), avg.thin30.toStringAsFixed(0)),
                _dataRow('Thin -40%', best.thin40.toStringAsFixed(0), good.thin40.toStringAsFixed(0), avg.thin40.toStringAsFixed(0)),
                _dataRow('Thin -50%', best.thin50.toStringAsFixed(0), good.thin50.toStringAsFixed(0), avg.thin50.toStringAsFixed(0)),
                _dataRow('Thick +35%', best.thick35.toStringAsFixed(0), good.thick35.toStringAsFixed(0), avg.thick35.toStringAsFixed(0)),
                _dataRow('Thick +50%', best.thick50.toStringAsFixed(0), good.thick50.toStringAsFixed(0), avg.thick50.toStringAsFixed(0)),
                _dataRow('Neps +140%', best.neps140.toStringAsFixed(0), good.neps140.toStringAsFixed(0), avg.neps140.toStringAsFixed(0)),
                _dataRow('Neps +200%', best.neps200.toStringAsFixed(0), good.neps200.toStringAsFixed(0), avg.neps200.toStringAsFixed(0)),
                _dataRow('Total IPI', best.totalIPI.toStringAsFixed(0), (good.thin50 + good.thick50 + good.neps200).toStringAsFixed(0), (avg.thin50 + avg.thick50 + avg.neps200).toStringAsFixed(0)),
                _dataRow('Hairiness', best.hairinessIndex.toStringAsFixed(2), good.hairiness.toStringAsFixed(2), avg.hairiness.toStringAsFixed(2)),
                _dataRow('Density (g/cm³)', best.density.toStringAsFixed(2), good.density.toStringAsFixed(2), avg.density.toStringAsFixed(2)),
                _dataRow('Strength (cN/tex)', best.strengthCnTex.toStringAsFixed(2), '—', '—'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow(List<String> cells) {
    return TableRow(
      decoration: const BoxDecoration(color: AppTheme.primaryLight),
      children: cells.map((c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
      )).toList(),
    );
  }

  TableRow _dataRow(String label, String best, String good, String avg) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
      ...([best, good, avg].map((v) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ))),
    ]);
  }
}

class _DerivedRow {
  final double uPct, cvmPct, thin30, thin40, thin50, thick35, thick50, neps140, neps200, hairiness, density;
  const _DerivedRow({
    required this.uPct, required this.cvmPct,
    required this.thin30, required this.thin40, required this.thin50,
    required this.thick35, required this.thick50,
    required this.neps140, required this.neps200,
    required this.hairiness, required this.density,
  });
}

// ── Grouped bar chart: Best / Good / Average for 5 key parameters ─────────────

class _BenchmarkBarChart extends StatefulWidget {
  final YarnQualityRow best;
  final _DerivedRow good;
  final _DerivedRow avg;

  const _BenchmarkBarChart({
    required this.best,
    required this.good,
    required this.avg,
  });

  @override
  State<_BenchmarkBarChart> createState() => _BenchmarkBarChartState();
}

class _BenchmarkBarChartState extends State<_BenchmarkBarChart> {
  int _touchedGroup = -1;
  int _touchedRod = -1;

  // 5 key parameters shown: U%, CVm%, Thin-50%, Thick+50%, Neps+200%
  static const _paramLabels = ['U%', 'CVm%', 'Thin-50', 'Thick+50', 'Neps+200'];
  static const _bestColor = Color(0xFF057A55);
  static const _goodColor = Color(0xFF1A56DB);
  static const _avgColor  = Color(0xFFE3A008);

  List<double> _bestVals(YarnQualityRow b) =>
      [b.uPct, b.cvmPct, b.thin50, b.thick50, b.neps200];

  List<double> _goodVals(_DerivedRow g) =>
      [g.uPct, g.cvmPct, g.thin50, g.thick50, g.neps200];

  List<double> _avgVals(_DerivedRow a) =>
      [a.uPct, a.cvmPct, a.thin50, a.thick50, a.neps200];

  @override
  Widget build(BuildContext context) {
    final bv = _bestVals(widget.best);
    final gv = _goodVals(widget.good);
    final av = _avgVals(widget.avg);

    // Max across all for Y axis
    double maxY = 0;
    for (int i = 0; i < 5; i++) {
      if (av[i] > maxY) maxY = av[i];
    }
    maxY = (maxY * 1.2).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('COPS Comparison Chart',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              children: [
                _legend('Best', _bestColor),
                const SizedBox(width: 12),
                _legend('Good', _goodColor),
                const SizedBox(width: 12),
                _legend('Average', _avgColor),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 10,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response?.spot == null) {
                          _touchedGroup = -1;
                          _touchedRod = -1;
                          return;
                        }
                        _touchedGroup = response!.spot!.touchedBarGroupIndex;
                        _touchedRod = response.spot!.touchedRodDataIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.textPrimary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final tier = ['Best', 'Good', 'Avg'][rodIndex];
                        return BarTooltipItem(
                          '$tier\n${rod.toY.toStringAsFixed(1)}',
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(5, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bv[i],
                          color: (_touchedGroup == i && _touchedRod == 0)
                              ? _bestColor
                              : _bestColor.withValues(alpha: 0.85),
                          width: 10,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                        BarChartRodData(
                          toY: gv[i],
                          color: (_touchedGroup == i && _touchedRod == 1)
                              ? _goodColor
                              : _goodColor.withValues(alpha: 0.85),
                          width: 10,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                        BarChartRodData(
                          toY: av[i],
                          color: (_touchedGroup == i && _touchedRod == 2)
                              ? _avgColor
                              : _avgColor.withValues(alpha: 0.85),
                          width: 10,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= _paramLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _paramLabels[i],
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
