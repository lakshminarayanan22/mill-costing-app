import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../quality/qd_engine.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App1IpiScreen extends StatefulWidget {
  const App1IpiScreen({super.key});

  @override
  State<App1IpiScreen> createState() => _App1IpiScreenState();
}

class _App1IpiScreenState extends State<App1IpiScreen> {
  final _fine = TextEditingController(text: '4');
  final _sl50 = TextEditingController(text: '16');
  final _sfi = TextEditingController(text: '10');
  final _count = TextEditingController(text: '60');
  final _trash = TextEditingController(text: '0.03');
  final _neps = TextEditingController(text: '0.02');
  int _ytype = 3;
  App1Result? _result;

  static const _ytypeLabels = [
    'Carded hosiery',
    'Combed hosiery',
    'Carded weaving',
    'Combed weaving',
  ];

  void _calc() {
    try {
      final inp = App1Input(
        fine: double.parse(_fine.text),
        sl50: double.parse(_sl50.text),
        sfi: double.parse(_sfi.text),
        count: double.parse(_count.text),
        trash: double.parse(_trash.text),
        neps: double.parse(_neps.text),
        ytype: _ytype,
      );
      setState(() => _result = calcApp1(inp));
    } catch (_) {
      setState(() => _result = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 1 — Yarn IPI from HVI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdInfoCard(
              'Predicts total imperfections per km (IPI) of ring yarn '
              'from HVI fibre data. A normal ring yarn will have 40–50% '
              'more IPI than a compact yarn.',
            ),
            const SizedBox(height: 16),
            const QdSectionLabel('HVI Fibre Inputs'),
            Row(children: [
              Expanded(child: QdField('Micronaire', _fine, 'Fine')),
              const SizedBox(width: 10),
              Expanded(child: QdField('50% span length (mm)', _sl50, 'SL50')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Short Fibre Index', _sfi, 'SFI')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Yarn count (Ne)', _count, 'Count')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Trash % (drawing sliver)', _trash, 'e.g. 0.03')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Neps/mg (drawing sliver)', _neps, 'e.g. 0.02')),
            ]),
            const SizedBox(height: 12),
            const QdSectionLabel('Yarn Type'),
            Wrap(
              spacing: 8,
              children: List.generate(4, (i) {
                return ChoiceChip(
                  label: Text(_ytypeLabels[i]),
                  selected: _ytype == i + 1,
                  onSelected: (_) => setState(() => _ytype = i + 1),
                  selectedColor: AppTheme.primaryLight,
                  labelStyle: TextStyle(
                    color: _ytype == i + 1 ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calc,
                child: const Text('Calculate IPI'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              const QdSectionLabel('Result'),
              QdResultCard(children: [
                QdResultRow('Base IPI', _result!.baseIPI.toStringAsFixed(2)),
                const Divider(height: 16),
                QdResultRow('Total IPI / km', _result!.totalIPI.toStringAsFixed(2),
                    highlight: true),
              ]),
              const SizedBox(height: 12),
              _IpiGaugeCard(totalIpi: _result!.totalIPI),
              const SizedBox(height: 8),
              const QdInfoCard(
                'Note: A normal / ring yarn will have 40–50% more IPI '
                'than a compact yarn.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── IPI Gauge + trend bar ─────────────────────────────────────────────────────
// Zones (combed 60s): Good < 80 | Average 80–160 | Below 160–300 | Poor > 300

class _IpiGaugeCard extends StatelessWidget {
  final double totalIpi;
  const _IpiGaugeCard({required this.totalIpi});

  static const double _maxScale = 400.0; // gauge upper limit

  Color get _zoneColor {
    if (totalIpi < 80) return AppTheme.success;
    if (totalIpi < 160) return AppTheme.warning;
    if (totalIpi < 300) return AppTheme.danger.withValues(alpha: 0.7);
    return AppTheme.danger;
  }

  String get _zoneLabel {
    if (totalIpi < 80) return 'Excellent';
    if (totalIpi < 160) return 'Good';
    if (totalIpi < 300) return 'Average';
    return 'Below Average';
  }

  @override
  Widget build(BuildContext context) {
    final frac = (totalIpi / _maxScale).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IPI Gauge (per km)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            const Text(
              'Reference: Combed weaving 60s. < 80 = Excellent · 80–160 = Good · 160–300 = Average',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            // Colour-zone segments
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    Expanded(flex: 20, child: Container(color: AppTheme.success)),
                    Expanded(flex: 20, child: Container(color: AppTheme.warning)),
                    Expanded(flex: 35, child: Container(color: AppTheme.danger.withValues(alpha: 0.7))),
                    Expanded(flex: 25, child: Container(color: AppTheme.danger)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Text('0', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                Expanded(child: SizedBox()),
                Text('80', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                Expanded(child: SizedBox()),
                Text('160', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                Expanded(child: SizedBox()),
                Text('300', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                Expanded(child: SizedBox()),
                Text('400+', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            // Needle bar
            LayoutBuilder(
              builder: (context, constraints) {
                final needleX = frac * constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: needleX.clamp(0, constraints.maxWidth - 3),
                      top: -4,
                      child: Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _zoneColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Bar chart: thin / thick / neps breakdown
            SizedBox(
              height: 130,
              child: BarChart(
                BarChartData(
                  maxY: totalIpi * 1.3,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                        toY: totalIpi * 0.15, // ~15% thin estimate
                        color: AppTheme.componentColors[0],
                        width: 28,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                        toY: totalIpi * 0.35, // ~35% thick
                        color: AppTheme.componentColors[4],
                        width: 28,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                        toY: totalIpi * 0.50, // ~50% neps
                        color: AppTheme.componentColors[6],
                        width: 28,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                        toY: totalIpi,
                        color: _zoneColor,
                        width: 28,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const labels = ['Thin', 'Thick', 'Neps', 'Total'];
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(labels[i],
                                style: const TextStyle(
                                    fontSize: 10, color: AppTheme.textSecondary)),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _zoneColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _zoneColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '$_zoneLabel  —  ${totalIpi.toStringAsFixed(0)} IPI/km',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _zoneColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
