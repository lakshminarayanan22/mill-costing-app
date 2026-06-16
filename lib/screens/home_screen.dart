import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mill_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/install_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMill = ref.watch(activeMillProvider);
    final allMills = ref.watch(millProfilesProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ecolink Mill Costing',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Yarn cost calculator',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => context.push('/profiles'),
                    icon: const Icon(Icons.factory_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Install banner (web only)
              const InstallBanner(),

              // Active mill card
              _ActiveMillCard(mill: activeMill, allMills: allMills, ref: ref),

              const SizedBox(height: 24),

              // Main action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/calculator'),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('New Calculation'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/quality'),
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Quality Diagnosis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF057A55),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profiles'),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Manage Mill Profiles'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppTheme.divider),
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Info footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reference: RST 2 mill, 94s combed compact 2-ply TFO. '
                        'Edit mill profiles to match your mill.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveMillCard extends StatelessWidget {
  final dynamic mill;
  final List<dynamic> allMills;
  final WidgetRef ref;

  const _ActiveMillCard(
      {required this.mill, required this.allMills, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.factory, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Active Mill',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (allMills.length > 1)
                  TextButton(
                    onPressed: () => _showMillPicker(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Switch',
                        style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mill.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                millStatChip(
                    icon: Icons.grain,
                    label: '${mill.totalSpindles} spindles'),
                millStatChip(
                    icon: Icons.view_module_outlined,
                    label: '${mill.ringFrameCount} frames'),
                millStatChip(
                    icon: Icons.filter_list,
                    label: '${mill.cards} cards'),
                if (mill.tfoSpindles > 0)
                  millStatChip(
                      icon: Icons.double_arrow,
                      label: '${mill.tfoSpindles} TFO'),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget millStatChip({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    ),
  );
}

  void _showMillPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Mill',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            ...allMills.map(
              (m) => ListTile(
                title: Text(m.name),
                subtitle: Text('${m.totalSpindles} spindles'),
                trailing: m.id == mill.id
                    ? const Icon(Icons.check, color: AppTheme.primary)
                    : null,
                onTap: () {
                  ref.read(activeMillProvider.notifier).select(m);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
