import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../quality/tracker_service.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(trackerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixing Quality Tracker'),
        actions: [
          if (records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all records',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all records?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: AppTheme.danger))),
                    ],
                  ),
                );
                if (ok == true) ref.read(trackerProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: records.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('No records yet.', style: TextStyle(color: AppTheme.textSecondary)),
                  SizedBox(height: 4),
                  Text('Use "Send to Tracker" in App 2.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrendChart(records: records),
                  const SizedBox(height: 16),
                  _WeightedAvgByDate(records: records),
                  const SizedBox(height: 16),
                  const QdSectionLabel('All Records'),
                  ...records.reversed.map((r) => _RecordCard(record: r, ref: ref)),
                ],
              ),
            ),
    );
  }
}

// ── Trend chart ──────────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<TrackerRecord> records;
  const _TrendChart({required this.records});

  @override
  Widget build(BuildContext context) {
    // Group by date and compute weighted avg
    final byDate = <DateTime, List<TrackerRecord>>{};
    for (final r in records) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      byDate.putIfAbsent(day, () => []).add(r);
    }
    final sorted = byDate.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (sorted.isEmpty) return const SizedBox.shrink();

    final spots = sorted.asMap().entries.map((e) {
      final avg = weightedAvg(e.value.value);
      return FlSpot(e.key.toDouble(), avg);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quality Index Trend', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text('Weighted average per day', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) =>
                        Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10))),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                          return Text(DateFormat('d/M').format(sorted[idx].key),
                              style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weighted average by date table ───────────────────────────────────────────

class _WeightedAvgByDate extends StatelessWidget {
  final List<TrackerRecord> records;
  const _WeightedAvgByDate({required this.records});

  @override
  Widget build(BuildContext context) {
    final byDate = <DateTime, List<TrackerRecord>>{};
    for (final r in records) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      byDate.putIfAbsent(day, () => []).add(r);
    }
    final sorted = byDate.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final label = records.isNotEmpty ? records.last.indexLabel : 'Index';

    return QdResultCard(children: [
      Text('Daily Weighted Average ($label)',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 8),
      Table(
        border: TableBorder.all(color: AppTheme.divider, width: 0.5),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppTheme.primaryLight),
            children: ['Date', 'Bales', 'Wtd Avg $label'].map((h) =>
              Padding(padding: const EdgeInsets.all(6), child:
                Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)))
            ).toList(),
          ),
          ...sorted.map((e) {
            final totalBales = e.value.fold<int>(0, (s, r) => s + r.balesOfThisLot);
            final avg = weightedAvg(e.value);
            return TableRow(children: [
              Padding(padding: const EdgeInsets.all(6), child: Text(DateFormat('d MMM yyyy').format(e.key), style: const TextStyle(fontSize: 11))),
              Padding(padding: const EdgeInsets.all(6), child: Text('$totalBales', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
              Padding(padding: const EdgeInsets.all(6), child: Text(avg.toStringAsFixed(2), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
            ]);
          }),
        ],
      ),
    ]);
  }
}

// ── Individual record card ───────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final TrackerRecord record;
  final WidgetRef ref;
  const _RecordCard({required this.record, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.varietyName} — Lot ${record.lotNo}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mix ${record.mixNumber} · ${DateFormat('d MMM yyyy').format(record.date)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.balesOfThisLot} bales · ${record.indexLabel}: ${record.qualityIndex.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
              onPressed: () => ref.read(trackerProvider.notifier).delete(record.id),
            ),
          ],
        ),
      ),
    );
  }
}
