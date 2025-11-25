import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/assets/assets.dart';
import '../../../../core/themes/app_colors.dart';

class ProfilePhoto extends StatelessWidget {
  final double size;
  final String? imgUrl;
  final Function()? onChangeImage;

  const ProfilePhoto({
    super.key,
    required this.size,
    required this.imgUrl,
    this.onChangeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.blackLv5,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          AppImage(
            image: imgUrl ?? Assets.user,
            borderRadius: BorderRadius.circular(100),
            width: size,
            height: size,
          ),
          onChangeImage != null
              ? Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onChangeImage,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.tangerineLv1,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(3, 3),
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 12,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
