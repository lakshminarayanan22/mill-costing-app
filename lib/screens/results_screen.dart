import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/calculation_result.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat('#,##0.00', 'en_IN');
final _fmtInt = NumberFormat('#,##0', 'en_IN');

class ResultsScreen extends StatelessWidget {
  final CalculationResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isProfit = result.profitPerKg >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/analytics', extra: result),
            icon: const Icon(Icons.bar_chart, size: 18),
            label: const Text('Analytics'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── P&L Summary Card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isProfit ? AppTheme.successLight : AppTheme.dangerLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isProfit ? AppTheme.success : AppTheme.danger,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isProfit ? Icons.trending_up : Icons.trending_down,
                        color: isProfit ? AppTheme.success : AppTheme.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isProfit ? 'Profitable' : 'Loss-Making',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isProfit ? AppTheme.success : AppTheme.danger,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_fmt.format(result.profitPerKg.abs())}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isProfit ? AppTheme.success : AppTheme.danger,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isProfit ? 'profit/kg' : 'loss/kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: isProfit
                                ? AppTheme.success
                                : AppTheme.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ProfitChip(
                        label: 'Net',
                        value: result.netProfitPct,
                        isProfit: isProfit,
                      ),
                      const SizedBox(width: 8),
                      _ProfitChip(
                        label: 'Cash',
                        value: result.cashProfitPct,
                        isProfit: isProfit,
                      ),
                      const SizedBox(width: 8),
                      _ProfitChip(
                        label: 'Operating',
                        value: result.operatingProfitPct,
                        isProfit: isProfit,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Key numbers ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Cost/kg',
                    value: '₹${_fmt.format(result.totalCostPerKg)}',
                    sub: 'Single: ₹${_fmt.format(result.singleYarnCostPerKg)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Selling Price/kg',
                    value: '₹${_fmt.format(result.sellingPricePerKg)}',
                    sub: 'Break-even: ₹${_fmt.format(result.breakEvenPrice)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Daily Production',
                    value: '${_fmtInt.format(result.netKgPerDay)} kg',
                    sub: 'Realisation: ${result.realisationPct.toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Mill P&L / Day',
                    value:
                        '₹${_fmtInt.format(result.totalMillProfitPerDay.abs())}',
                    sub: isProfit ? 'Profit' : 'Loss',
                    valueColor: isProfit ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── 8 Cost Components ─────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COST BREAKDOWN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CostPieChart(result: result),
                    const SizedBox(height: 16),
                    ...result.costComponents
                        .asMap()
                        .entries
                        .map((e) => _CostRow(
                              color: AppTheme.componentColors[
                                  e.key % AppTheme.componentColors.length],
                              name: e.value.name,
                              value: e.value.value,
                              total: result.totalCostPerKg,
                            )),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '₹${_fmt.format(result.totalCostPerKg)}/kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Spin Plan / Production ────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SPIN PLAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow('TPI',
                        result.tpi.toStringAsFixed(2)),
                    _InfoRow('g/spindle/8hr',
                        result.gPerSpindle8Hr.toStringAsFixed(2)),
                    _InfoRow('kg/spindle/day',
                        result.kgPerSpindleDay.toStringAsFixed(4)),
                    _InfoRow('Gross Production',
                        '${_fmt.format(result.grossKgPerDay)} kg/day'),
                    _InfoRow('Net Production',
                        '${_fmt.format(result.netKgPerDay)} kg/day'),
                    _InfoRow('Raw Cotton Input',
                        '${_fmt.format(result.rawCottonKgPerDay)} kg/day'),
                    _InfoRow('Yarn Realisation',
                        '${result.realisationPct.toStringAsFixed(2)}%'),
                    _InfoRow('Total UKG',
                        result.totalUkg.toStringAsFixed(2)),
                    _InfoRow('Total Operatives/day',
                        result.totalOperativesPerDay.toStringAsFixed(1)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Capacity Check ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'CAPACITY CHECK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (result.hasCapacityShortfall)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SHORTFALL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.danger,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CapacityRow(
                      'Simplex Spindles',
                      result.simplexSpindlesRequired,
                      result.simplexSpindlesInstalled.toDouble(),
                      result.simplexCapacityRatio,
                    ),
                    _CapacityRow(
                      'Fin. Drawing Deliveries',
                      result.finDrawingDeliveriesRequired,
                      result.finDrawingDeliveriesInstalled.toDouble(),
                      result.finDrawingCapacityRatio,
                    ),
                    _CapacityRow(
                      'Combers',
                      result.combersRequired,
                      result.combersInstalled.toDouble(),
                      result.comberCapacityRatio,
                    ),
                    _CapacityRow(
                      'Lap Formers',
                      result.lapFormersRequired,
                      result.lapFormersInstalled.toDouble(),
                      result.lapFormerCapacityRatio,
                    ),
                    _CapacityRow(
                      'Pre-Comber Deliveries',
                      result.preComberDeliveriesRequired,
                      result.preComberDeliveriesInstalled.toDouble(),
                      result.preComberCapacityRatio,
                    ),
                    _CapacityRow(
                      'Cards',
                      result.cardsRequired,
                      result.cardsInstalled.toDouble(),
                      result.cardCapacityRatio,
                    ),
                    _CapacityRow(
                      'Blow Room Lines',
                      result.blowRoomLinesRequired,
                      result.blowRoomLinesInstalled.toDouble(),
                      result.blowRoomCapacityRatio,
                    ),
                    _CapacityRow(
                      'Winding Drums',
                      result.windingDrumsRequired,
                      result.windingDrumsInstalled.toDouble(),
                      result.windingCapacityRatio,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfitChip extends StatelessWidget {
  final String label;
  final double value;
  final bool isProfit;

  const _ProfitChip(
      {required this.label, required this.value, required this.isProfit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isProfit ? AppTheme.success : AppTheme.danger,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  const _StatCard(
      {required this.label, required this.value, this.sub, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppTheme.textPrimary,
                )),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final Color color;
  final String name;
  final double value;
  final double total;

  const _CostRow(
      {required this.color,
      required this.name,
      required this.value,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (value / total * 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${_fmt.format(value)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CostPieChart extends StatefulWidget {
  final CalculationResult result;
  const _CostPieChart({required this.result});

  @override
  State<_CostPieChart> createState() => _CostPieChartState();
}

class _CostPieChartState extends State<_CostPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final components = widget.result.costComponents;
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: components.asMap().entries.map((e) {
            final i = e.key;
            final comp = e.value;
            final isTouched = i == _touched;
            final pct = comp.value / widget.result.totalCostPerKg * 100;
            return PieChartSectionData(
              color: AppTheme.componentColors[i % AppTheme.componentColors.length],
              value: comp.value,
              title: isTouched
                  ? '${comp.name}\n${pct.toStringAsFixed(1)}%'
                  : pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
              radius: isTouched ? 80 : 64,
              titleStyle: TextStyle(
                fontSize: isTouched ? 11 : 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            );
          }).toList(),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response?.touchedSection == null) {
                  _touched = -1;
                  return;
                }
                _touched = response!.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          centerSpaceRadius: 38,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

class _CapacityRow extends StatelessWidget {
  final String label;
  final double required;
  final double installed;
  final double ratio;

  const _CapacityRow(this.label, this.required, this.installed, this.ratio);

  @override
  Widget build(BuildContext context) {
    final ok = ratio >= 0;
    final critical = ratio < 0.05 && ratio >= 0;
    final pctFull = (required / installed).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 13))),
              Text(
                '${required.toStringAsFixed(1)} / ${installed.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ok
                      ? (critical
                          ? AppTheme.warningLight
                          : AppTheme.successLight)
                      : AppTheme.dangerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ok
                      ? (critical
                          ? 'CRITICAL'
                          : '${(ratio * 100).toStringAsFixed(0)}% spare')
                      : 'SHORTFALL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ok
                        ? (critical ? AppTheme.warning : AppTheme.success)
                        : AppTheme.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pctFull,
              minHeight: 6,
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                ok
                    ? (critical ? AppTheme.warning : AppTheme.success)
                    : AppTheme.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
