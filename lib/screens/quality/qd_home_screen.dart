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
            // ── Hero header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.science_outlined,
                      color: Colors.white70, size: 28),
                  const SizedBox(height: 10),
                  const Text(
                    'Healthy fibres\nproduce healthy yarn.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Predict quality · optimise blends · track mixing',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Quick-access row
                  Row(
                    children: [
                      _HeroChip(
                          label: 'Mix Optimiser',
                          icon: Icons.tune,
                          onTap: () => context.push('/quality/mix')),
                      const SizedBox(width: 8),
                      _HeroChip(
                          label: 'Tracker',
                          icon: Icons.timeline,
                          onTap: () => context.push('/quality/tracker')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Prediction Apps — 2-column grid ──────────────────────────
            const _SectionHeader('Prediction Apps'),
            const SizedBox(height: 8),
            _AppGrid(tiles: const [
              _GridTile(
                number: '1',
                title: 'Yarn IPI',
                subtitle: 'Imperfections from HVI data',
                icon: Icons.auto_graph,
                color: AppTheme.primary,
                route: '/quality/app1',
              ),
              _GridTile(
                number: '2',
                title: 'Fibre Quality Index',
                subtitle: 'FQI / SCI / PQI scoring',
                icon: Icons.grade_outlined,
                color: Color(0xFF057A55),
                route: '/quality/app2',
              ),
              _GridTile(
                number: '3',
                title: 'Yarn Quality',
                subtitle: 'Full prediction from AFIS/HVI',
                icon: Icons.science_outlined,
                color: Color(0xFF9061F9),
                route: '/quality/app3',
              ),
            ]),

            const SizedBox(height: 18),

            // ── Reference Tables — 2-column grid ─────────────────────────
            const _SectionHeader('Reference Tables'),
            const SizedBox(height: 8),
            _AppGrid(tiles: const [
              _GridTile(
                number: '4',
                title: 'Cotton Standards',
                subtitle: 'Length · mic · strength',
                icon: Icons.table_chart_outlined,
                color: Color(0xFFE3A008),
                route: '/quality/app4',
              ),
              _GridTile(
                number: '5',
                title: 'Variety Lookup',
                subtitle: 'Indian & foreign cottons',
                icon: Icons.grass_outlined,
                color: Color(0xFF0E9F6E),
                route: '/quality/app5',
              ),
              _GridTile(
                number: '6',
                title: 'Yarn Benchmarks',
                subtitle: 'Best / Good / Average COPS',
                icon: Icons.bar_chart,
                color: Color(0xFFFF5A1F),
                route: '/quality/app6',
              ),
            ]),

            const SizedBox(height: 18),

            // ── Full-width tiles ──────────────────────────────────────────
            const _SectionHeader('Blend Optimiser'),
            const SizedBox(height: 8),
            _FullWidthTile(
              title: 'Mix Selection',
              subtitle:
                  'LP simplex optimiser — minimum cost blend that meets strength target',
              icon: Icons.tune,
              color: const Color(0xFF6D28D9),
              route: '/quality/mix',
            ),
            const SizedBox(height: 8),
            const _SectionHeader('Tracking'),
            const SizedBox(height: 8),
            _FullWidthTile(
              title: 'Mixing Quality Tracker',
              subtitle: 'Daily log · weighted-average index · trend chart',
              icon: Icons.timeline,
              color: AppTheme.primary,
              route: '/quality/tracker',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Hero chip (quick access inside header) ────────────────────────────────────

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroChip(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── 2-column grid of app tiles ────────────────────────────────────────────────

class _AppGrid extends StatelessWidget {
  final List<_GridTile> tiles;
  const _AppGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    // Build rows of 2
    final rows = <Widget>[];
    for (int i = 0; i < tiles.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: tiles[i]),
          const SizedBox(width: 10),
          Expanded(
              child: i + 1 < tiles.length
                  ? tiles[i + 1]
                  : const SizedBox.shrink()),
        ],
      ));
      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

// ── Grid tile ─────────────────────────────────────────────────────────────────

class _GridTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _GridTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      number,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: color.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full-width tile ───────────────────────────────────────────────────────────

class _FullWidthTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _FullWidthTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: color.withValues(alpha: 0.6), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
