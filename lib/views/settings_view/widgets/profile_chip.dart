import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller/settings_controller.dart';
import '../../../core/theme/theme_constants.dart';

/// Identity card at the top of Settings. Pulls live user from
/// [SettingsController.user] (which proxies to `AuthService`).
class ProfileChip extends StatelessWidget {
  const ProfileChip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _Avatar(url: user?.pictureUrl, fallback: user?.name ?? user?.email),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user!.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 12,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String? fallback;

  const _Avatar({this.url, this.fallback});

  @override
  Widget build(BuildContext context) {
    final initials = (fallback ?? '?').characters.take(2).join().toUpperCase();
    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: url == null
            ? Container(
                color: AppColors.surface2,
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink2,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
