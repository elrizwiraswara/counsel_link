import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../core/assets/assets.dart';
import '../../core/themes/app_sizes.dart';
import '../../core/themes/app_text_style.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppImage(
          image: Assets.logo,
          imgProvider: ImgProvider.assetImage,
          height: 45,
        ),
        const SizedBox(width: AppSizes.padding / 1.5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Counsel Link', style: AppTextStyle.bold(size: 18)),
              Text(
                'An online counseling service app',
                style: AppTextStyle.medium(size: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
