import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class QdHomeScreen extends StatelessWidget {
  const QdHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quality Diagnosis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF1C64F2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Healthy fibres produce\nhealthy yarn.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Predict yarn quality from fibre test data,\noptimise blends for cost, track mixing quality.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Prediction Apps'),
            _AppTile(
              number: '1',
              title: 'Yarn IPI from HVI',
              subtitle: 'Predict imperfections/km from fibre data',
              icon: Icons.auto_graph,
              color: AppTheme.primary,
              route: '/quality/app1',
            ),
            _AppTile(
              number: '2',
              title: 'Fibre Quality Index',
              subtitle: 'FQI / SCI / PQI — score your cotton mixing',
              icon: Icons.grade_outlined,
              color: const Color(0xFF057A55),
              route: '/quality/app2',
            ),
            _AppTile(
              number: '3',
              title: 'Yarn Quality Prediction',
              subtitle: 'Full yarn quality set from AFIS or HVI',
              icon: Icons.science_outlined,
              color: const Color(0xFF9061F9),
              route: '/quality/app3',
            ),
            const SizedBox(height: 12),
            const _SectionHeader('Reference Tables'),
            _AppTile(
              number: '4',
              title: 'Cotton Quality Standards',
              subtitle: 'Length, uniformity, mic, strength reference',
              icon: Icons.table_chart_outlined,
              color: AppTheme.warning,
              route: '/quality/app4',
            ),
            _AppTile(
              number: '5',
              title: 'Fibre Parameters by Variety',
              subtitle: 'Look up any Indian or foreign cotton variety',
              icon: Icons.grass_outlined,
              color: const Color(0xFF0E9F6E),
              route: '/quality/app5',
            ),
            _AppTile(
              number: '6',
              title: 'Yarn Quality by Count',
              subtitle: 'Best / Good / Average mill benchmarks',
              icon: Icons.bar_chart,
              color: const Color(0xFFFF5A1F),
              route: '/quality/app6',
            ),
            const SizedBox(height: 12),
            const _SectionHeader('Blend Optimiser'),
            _AppTile(
              number: '',
              title: 'Mix Selection',
              subtitle: 'Optimise cotton blend for cost and strength',
              icon: Icons.tune,
              color: AppTheme.danger,
              route: '/quality/mix',
            ),
            const SizedBox(height: 12),
            const _SectionHeader('Tracking'),
            _AppTile(
              number: '',
              title: 'Mixing Quality Tracker',
              subtitle: 'Daily log, weighted-average index, trend chart',
              icon: Icons.timeline,
              color: const Color(0xFF1A56DB),
              route: '/quality/tracker',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _AppTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: number.isNotEmpty
                      ? Center(
                          child: Text(
                            number,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          )),
                      Text(subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
