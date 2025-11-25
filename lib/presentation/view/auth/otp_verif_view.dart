import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class OtpVerifView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const OtpVerifView({super.key});

  @override
  State<OtpVerifView> createState() => _OtpVerifViewState();
}

class _OtpVerifViewState extends State<OtpVerifView> {
  final model = di<AuthViewModel>();

  final otpController = TextEditingController();

  @override
  void initState() {
    model.startOtpTimer();
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    model.resetOtpTimer();
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
              child: verifForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget verifForm() {
    final resendOtpTime = watchPropertyValue((AuthViewModel m) => m.resendOtpTime);
    final otp = watch(otpController).text;

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
            'Verification Code',
            style: AppTextStyle.bold(size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter the OTP code sent to your phone number',
            style: AppTextStyle.medium(size: 12),
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          AppTextField(
            controller: otpController,
            labelText: 'OTP Code',
            hintText: 'Enter the OTP code',
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.phone,
            maxLength: 6,
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          AppFilledButton(
            enable: model.enableButton(otp, 6),
            text: 'Verify',
            onTap: () async {
              FocusScope.of(context).unfocus();

              final res = await AppDialog.showProgress(() async {
                return await model.submitOtp(otp);
              });

              if (res.isFailure) {
                return AppDialog.showError(error: res.error.toString());
              }

              final isNewUser = res.data?.name == null;

              if (isNewUser) {
                AppRoutes.router.go('/edit-profile', extra: true);
              } else {
                AppRoutes.router.go('/home');
              }
            },
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: AppTextStyle.regular(size: 12),
              ),
              GestureDetector(
                child: Text(
                  "Resend ${resendOtpTime > 0 ? '($resendOtpTime)' : ''}",
                  style: AppTextStyle.semibold(
                    size: 12,
                    color: resendOtpTime > 0 ? AppColors.blackLv2 : AppColors.tangerineLv1,
                  ),
                ),
                onTap: () {
                  if (resendOtpTime == 0) model.resendOtp();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
