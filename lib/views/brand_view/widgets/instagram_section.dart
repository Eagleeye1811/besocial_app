import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/instagram_controller/instagram_controller.dart';
import '../../../core/theme/theme_constants.dart';
import 'section_card.dart';

/// Connect / reconnect Instagram. Surfaces the live status from
/// [InstagramController]. Used in Brand today; Phase 13 (Settings) reuses
/// the same widget.
class InstagramSection extends StatelessWidget {
  const InstagramSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstagramController>();

    return BrandSectionCard(
      eyebrow: 'Instagram',
      title: 'Connect your account',
      child: Obx(() {
        final status = controller.status.value;
        final loading = controller.isLoading.value;
        final connecting = controller.isConnecting.value;

        if (loading && status == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
          );
        }

        final connected = status?.connected ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusRow(status: status),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: connecting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Icon(
                            connected
                                ? Icons.refresh
                                : Icons.link,
                            size: 16,
                          ),
                    label: Text(
                      connecting
                          ? (connected ? 'Reconnecting…' : 'Connecting…')
                          : (connected
                              ? 'Reconnect'
                              : 'Connect Instagram'),
                    ),
                    onPressed: connecting ? null : controller.startConnect,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final err = controller.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Text(
                err,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12.5,
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final dynamic status;
  const _StatusRow({required this.status});

  @override
  Widget build(BuildContext context) {
    final connected = status?.connected ?? false;
    final username = status?.igUsername as String?;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: connected ? AppColors.good : AppColors.ink4,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            connected
                ? (username != null
                    ? 'Connected as @$username'
                    : 'Connected')
                : 'Not connected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
