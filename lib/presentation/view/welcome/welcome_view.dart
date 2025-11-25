import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/assets.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../widgets/app_filled_button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: AppSizes.size(context).height,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: AppImage(
                image: Assets.welcomeBg,
                imgProvider: ImgProvider.assetImage,
                width: AppSizes.screenWidth(context) > 800
                    ? AppSizes.screenWidth(context) / 2
                    : AppSizes.screenWidth(context) / 1.5,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.screenWidth(context) / 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppImage(
                    image: Assets.logo,
                    imgProvider: ImgProvider.assetImage,
                    width: 120,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to Counsel Link',
                    style: AppTextStyle.bold(
                      size: AppSizes.padding * 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: AppSizes.screenWidth(context) > 800
                        ? AppSizes.screenWidth(context) / 2
                        : AppSizes.screenWidth(context),
                    child: Text(
                      'An online counseling service application facilitates connections between families and counselors through a scheduled counseling system, realtime chat and video call communication, utilizing Flutter WebRTC.',
                      style: AppTextStyle.medium(
                        size: AppSizes.padding / 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.padding * 1.5),
                  AppFilledButton(
                    width: 165,
                    text: 'Sign In',
                    onTap: () {
                      context.go('/auth/sign-in');
                    },
                  ),
                  const SizedBox(height: AppSizes.padding * 1.5),
                  Row(
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTextStyle.regular(size: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/auth/sign-up');
                        },
                        child: Text(
                          'Sign up',
                          style: AppTextStyle.semibold(
                            size: 14,
                            color: AppColors.tangerineLv1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
