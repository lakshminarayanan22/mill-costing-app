import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/calculation_result.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat('#,##0.00', 'en_IN');

class AnalyticsScreen extends StatefulWidget {
  final CalculationResult result;

  const AnalyticsScreen({super.key, required this.result});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _touchedDonutIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Cost Mix'),
            Tab(text: 'Waterfall'),
            Tab(text: 'Sensitivity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _DonutTab(
            result: widget.result,
            touchedIndex: _touchedDonutIndex,
            onTouch: (i) => setState(() => _touchedDonutIndex = i),
          ),
          _WaterfallTab(result: widget.result),
          _SensitivityTab(result: widget.result),
        ],
      ),
    );
  }
}

// ── Donut chart: cost component breakdown ──────────────────────────────────

class _DonutTab extends StatelessWidget {
  final CalculationResult result;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _DonutTab(
      {required this.result,
      required this.touchedIndex,
      required this.onTouch});

  @override
  Widget build(BuildContext context) {
    final components = result.costComponents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sections: components.asMap().entries.map((e) {
                  final i = e.key;
                  final comp = e.value;
                  final isTouched = i == touchedIndex;
                  final pct = comp.value / result.totalCostPerKg * 100;
                  return PieChartSectionData(
                    color: AppTheme.componentColors[
                        i % AppTheme.componentColors.length],
                    value: comp.value,
                    title: isTouched
                        ? '${comp.name}\n${pct.toStringAsFixed(1)}%'
                        : '${pct.toStringAsFixed(0)}%',
                    radius: isTouched ? 90 : 75,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 13 : 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      onTouch(-1);
                      return;
                    }
                    onTouch(response!.touchedSection!.touchedSectionIndex);
                  },
                ),
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: components.asMap().entries.map((e) {
              final color = AppTheme.componentColors[
                  e.key % AppTheme.componentColors.length];
              final pct = e.value.value / result.totalCostPerKg * 100;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.value.name} ${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Bar chart alongside
          const Text(
            '₹/kg by component',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: components.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: AppTheme.componentColors[
                            e.key % AppTheme.componentColors.length],
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (v, _) => Text(
                        '₹${v.toInt()}',
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= components.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            components[i].name.split(' ').first,
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                  drawVerticalLine: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waterfall: selling price → profit/loss ─────────────────────────────────

class _WaterfallTab extends StatelessWidget {
  final CalculationResult result;

  const _WaterfallTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    final components = [
      ('Selling Price', r.sellingPricePerKg, true),
      ('Material', -r.materialCost, false),
      ('Power', -r.powerCost, false),
      ('Interest', -r.interestCost, false),
      ('Depreciation', -r.depreciationCost, false),
      ('Labour', -r.labourCost, false),
      ('Overhead', -r.overheadCost, false),
      ('Packing', -r.packingCost, false),
      ('Yarn Waste', -r.yarnWasteCost, false),
      if (r.tfoConversionCost > 0) ('TFO Conv.', -r.tfoConversionCost, false),
      ('Net P&L', r.profitPerKg, true),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selling Price → Net Profit/Loss',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Each bar shows the ₹/kg contribution of each cost component.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ...components.map((c) {
            final label = c.$1;
            final value = c.$2;
            final isTotal = c.$3;
            final isPositive = value >= 0;
            final maxVal = r.sellingPricePerKg;
            final barWidth = (value.abs() / maxVal).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: barWidth,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: isTotal
                                  ? (isPositive
                                      ? AppTheme.success
                                      : AppTheme.danger)
                                  : (isPositive
                                      ? AppTheme.primary
                                      : AppTheme.warning.withValues(alpha: 0.8)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '₹${_fmt.format(value.abs())}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                        color: isTotal
                            ? (isPositive ? AppTheme.success : AppTheme.danger)
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Sensitivity: how cost changes with key inputs ──────────────────────────

class _SensitivityTab extends StatelessWidget {
  final CalculationResult result;

  const _SensitivityTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;

    // Sensitivity estimates based on the reference weights from cost-components.md
    // Cotton: ₹10,000/candy change → ~₹28/kg (at 70% realisation)
    // Electricity: ₹1/kWh → ~₹13/kg (at 12.93 UKG)
    // Realisation: 1% → ~₹4/kg

    // cottonImpact kept for reference: r.materialCost / 100 * 13.3
    final powerImpact = r.totalUkg; // ₹/kg per ₹1/kWh change
    final realisationImpact = r.materialCost * 0.014; // 1% realisation change

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensitivity Analysis',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Impact on total cost per kg for a unit change in each input.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          _SensRow(
            rank: 1,
            label: 'Cotton price',
            unit: '+₹10,000/candy',
            impact: r.materialCost / (r.materialCost + r.powerCost) * 28,
            color: AppTheme.componentColors[0],
            totalCost: r.totalCostPerKg,
          ),
          _SensRow(
            rank: 2,
            label: 'Electricity rate',
            unit: '+₹1/kWh',
            impact: powerImpact,
            color: AppTheme.componentColors[1],
            totalCost: r.totalCostPerKg,
          ),
          _SensRow(
            rank: 3,
            label: 'Yarn realisation',
            unit: '-1%',
            impact: realisationImpact,
            color: AppTheme.componentColors[4],
            totalCost: r.totalCostPerKg,
          ),
          _SensRow(
            rank: 4,
            label: 'Comber noil %',
            unit: '+1%',
            impact: r.materialCost * 0.008,
            color: AppTheme.componentColors[6],
            totalCost: r.totalCostPerKg,
          ),
          _SensRow(
            rank: 5,
            label: 'Daily wage rate',
            unit: '+₹50/day',
            impact: r.labourCost * 0.17,
            color: AppTheme.componentColors[4],
            totalCost: r.totalCostPerKg,
          ),
          const SizedBox(height: 24),
          // Key thresholds
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Thresholds',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _ThresholdRow(
                  label: 'Break-even selling price',
                  value: '₹${_fmt.format(r.breakEvenPrice)}/kg',
                ),
                _ThresholdRow(
                  label: 'Current selling price',
                  value: '₹${_fmt.format(r.sellingPricePerKg)}/kg',
                ),
                _ThresholdRow(
                  label: 'Gap to break-even',
                  value:
                      '₹${_fmt.format((r.sellingPricePerKg - r.breakEvenPrice).abs())}/kg',
                  isWarning: r.sellingPricePerKg < r.breakEvenPrice,
                ),
                _ThresholdRow(
                  label: 'Total UKG',
                  value: '${r.totalUkg.toStringAsFixed(2)} kWh/kg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SensRow extends StatelessWidget {
  final int rank;
  final String label;
  final String unit;
  final double impact;
  final Color color;
  final double totalCost;

  const _SensRow({
    required this.rank,
    required this.label,
    required this.unit,
    required this.impact,
    required this.color,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final pctImpact = impact / totalCost * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(unit,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(
                '+₹${_fmt.format(impact)}/kg',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Text(
                '(${pctImpact.toStringAsFixed(1)}%)',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pctImpact / 5).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _ThresholdRow(
      {required this.label, required this.value, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.primary))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isWarning ? AppTheme.danger : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
