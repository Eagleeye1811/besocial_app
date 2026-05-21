import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/instagram_controller/instagram_controller.dart';
import '../../../controllers/settings_controller/settings_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/profile_chip.dart';

/// Mobile-specific (the website has no Settings page). Carries the things
/// that don't fit anywhere else: identity, Instagram connection, app info,
/// destructive logout.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back<void>,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const ProfileChip(),
            const SizedBox(height: 22),
            const _SectionHeader('Account'),
            const _InstagramRow(),
            const SizedBox(height: 22),
            const _SectionHeader('About'),
            const _StaticRow(
              icon: Icons.info_outline,
              title: 'Version',
              trailing: SettingsController.appVersion,
            ),
            const _StaticRow(
              icon: Icons.policy_outlined,
              title: 'Privacy & terms',
              trailing: '—',
            ),
            const SizedBox(height: 30),
            _LogoutButton(onPressed: () => _confirmLogout(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You can sign back in any time with Google.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.logout();
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.mono,
          fontFamilyFallback: AppFonts.monoFallback,
          fontSize: 11,
          letterSpacing: 0.44,
          color: AppColors.ink4,
        ),
      ),
    );
  }
}

class _InstagramRow extends StatelessWidget {
  const _InstagramRow();

  @override
  Widget build(BuildContext context) {
    final ig = Get.find<InstagramController>();
    return Obx(() {
      final connected = ig.isConnected;
      final username = ig.connectedUsername;
      final connecting = ig.isConnecting.value;
      return _RowContainer(
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: connected ? AppColors.good : AppColors.ink4,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instagram',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    connected
                        ? (username != null
                            ? '@$username'
                            : 'Connected')
                        : 'Not connected',
                    style: TextStyle(fontSize: 12, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: connecting ? null : ig.startConnect,
              child: Text(
                connecting
                    ? '…'
                    : (connected ? 'Reconnect' : 'Connect'),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StaticRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  const _StaticRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return _RowContainer(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.ink3),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 12,
              color: AppColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowContainer extends StatelessWidget {
  final Widget child;
  const _RowContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, size: 16),
        label: const Text('Log out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
