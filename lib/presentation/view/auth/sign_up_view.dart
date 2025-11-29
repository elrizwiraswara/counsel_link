import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/assets/assets.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../view_model/auth_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_filled_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';

class SignUpView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final model = di<AuthViewModel>();

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: AppSizes.screenHeight(context),
        child: Stack(
          alignment: Alignment.center,
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
            SingleChildScrollView(
              child: form(),
            ),
          ],
        ),
      ),
    );
  }

  Widget form() {
    final phone = watch(_phoneController).text;

    return Container(
      width: 500,
      padding: const EdgeInsets.all(AppSizes.padding * 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          const SizedBox(height: AppSizes.padding * 1.5),
          Text(
            'Sign Up',
            style: AppTextStyle.bold(size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Please sign up using your phone number",
            style: AppTextStyle.medium(size: 12),
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          AppTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$'))],
            keyboardType: TextInputType.phone,
            maxLength: 15,
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          AppFilledButton(
            enable: model.enableButton(phone, 6),
            text: 'Sign Up',
            onTap: () async {
              FocusScope.of(context).unfocus();

              final res = await AppDialog.showProgress(() async {
                return await model.onTapSignUpButton(phone);
              });

              if (res.isSuccess) {
                if (res.isFailure) {
                  return AppDialog.show(
                    title: res.title,
                    text: res.message,
                  );
                }

                AppRoutes.instance.router.go('/auth/otp-verify');
              } else {
                AppDialog.show(
                  title: res.title,
                  text: res.message,
                );
              }
            },
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: AppTextStyle.regular(size: 12),
              ),
              GestureDetector(
                onTap: () {
                  context.go('/auth/sign-in');
                },
                child: Text(
                  'Sign In',
                  style: AppTextStyle.semibold(
                    size: 12,
                    color: AppColors.tangerineLv1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
