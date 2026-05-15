import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Shows install-to-home-screen guidance on web only.
// Native builds: renders nothing.
class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _dismissed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.download_rounded, color: AppTheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _showInstallSheet(context),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Install as App',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap here to install for offline use',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showInstallSheet(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('How?', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: const Icon(Icons.close,
                size: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showInstallSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.install_mobile, size: 44, color: AppTheme.primary),
            const SizedBox(height: 12),
            const Text(
              'Install Mill Costing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // iPhone instructions
            _PlatformSection(
              icon: Icons.phone_iphone,
              title: 'On iPhone (Safari)',
              steps: const [
                'Open this page in Safari (not Chrome)',
                'Tap the Share button  at the bottom',
                'Scroll down and tap "Add to Home Screen"',
                'Tap "Add" — done!',
              ],
            ),

            const Divider(height: 28),

            // Android instructions
            _PlatformSection(
              icon: Icons.phone_android,
              title: 'On Android (Chrome)',
              steps: const [
                'Tap the ⋮ menu at the top right',
                'Tap "Add to Home Screen" or "Install App"',
                'Tap "Add" — done!',
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.offline_bolt,
                      size: 16, color: AppTheme.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Works completely offline after install. '
                      'Your mill profiles are saved on your device.',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.success),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> steps;

  const _PlatformSection({
    required this.icon,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        ...steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(e.value,
                        style: const TextStyle(fontSize: 13)),
                  )),
                ],
              ),
            )),
      ],
    );
  }
}
