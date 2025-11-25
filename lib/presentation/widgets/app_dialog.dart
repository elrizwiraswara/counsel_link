import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../../app/routes/app_routes.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_sizes.dart';
import '../../core/themes/app_text_style.dart';
import 'app_filled_button.dart';
import 'app_progress_indicator.dart';

//App Dialog
class AppDialog {
  static Future<T?> show<T>({
    String? title,
    Widget? child,
    String? text,
    EdgeInsetsGeometry? padding,
    String? leftButtonText,
    String? rightButtonText = 'Tutup',
    Color? backgroundColor,
    Function(BuildContext)? onTapLeftButton,
    Function(BuildContext)? onTapRightButton,
    bool dismissible = true,
    bool showButtons = true,
    bool enableRightButton = true,
    bool enableLeftButton = true,
    Color leftButtonTextColor = AppColors.blackLv2,
    Color rightButtonTextColor = AppColors.orangeLv1,
    double? elevation,
  }) async {
    final context = AppRoutes.router.configuration.navigatorKey.currentContext;
    if (context == null) throw Exception('No context available for dialog');

    return await showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return AppDialogWidget(
          title: title,
          text: text,
          padding: padding,
          leftButtonText: leftButtonText,
          rightButtonText: rightButtonText,
          backgroundColor: backgroundColor,
          onTapLeftButton: onTapLeftButton,
          onTapRightButton: onTapRightButton,
          dismissible: dismissible,
          showButtons: showButtons,
          enableRightButton: enableRightButton,
          enableLeftButton: enableLeftButton,
          leftButtonTextColor: leftButtonTextColor,
          rightButtonTextColor: rightButtonTextColor,
          elevation: elevation,
          child: child,
        );
      },
    );
  }

  static Future<T> showProgress<T>(Future<T> Function() process, {bool dismissible = false}) async {
    final context = AppRoutes.router.configuration.navigatorKey.currentContext;
    if (context == null) throw Exception('No context available for dialog');

    showDialog(
      context: context,
      builder: (context) {
        return AppDialogWidget(
          dismissible: kDebugMode ? true : dismissible,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showButtons: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.padding,
              AppSizes.padding * 1.2,
              AppSizes.padding,
              AppSizes.padding,
            ),
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: const AppProgressIndicator(
              color: AppColors.blackLv1,
              textColor: AppColors.blackLv1,
            ),
          ),
        );
      },
    );

    try {
      // Execute the process
      final result = await process();

      // Close the dialog
      _closeDialog();

      return result;
    } catch (e) {
      // Close the dialog on error
      _closeDialog();

      // Rethrow the error so caller can handle it
      rethrow;
    }
  }

  static void _closeDialog() {
    if (AppRoutes.router.configuration.navigatorKey.currentState?.canPop() ?? false) {
      AppRoutes.router.configuration.navigatorKey.currentState?.pop();
    }
  }

  static Future<T?> showError<T>({
    bool dismissible = false,
    String? title,
    String? message,
    String? error,
    String? buttonText,
    Function(BuildContext)? onTap,
  }) async {
    final context = AppRoutes.router.configuration.navigatorKey.currentContext;
    if (context == null) throw Exception('No context available for dialog');

    return await showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return AppDialogWidget(
          dismissible: kDebugMode ? true : dismissible,
          title: title ?? 'Oops!',
          rightButtonText: buttonText ?? 'Restart',
          onTapRightButton: (context) {
            if (onTap != null) {
              onTap(context);
            } else {
              Restart.restartApp();
            }
          },
          child: Column(
            children: [
              Text(
                message ?? 'Something went wrong, please try again or restart the app',
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(size: 12),
              ),
              error != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        error.toString().length > 200 ? error.toString().substring(0, 200) : error.toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.semibold(size: 8, color: AppColors.blackLv2),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}

// Custom Dialog
class AppDialogWidget extends StatelessWidget {
  final String? title;
  final Widget? child;
  final String? text;
  final EdgeInsetsGeometry? padding;
  final String? leftButtonText;
  final String? rightButtonText;
  final Color? backgroundColor;
  final Function(BuildContext)? onTapLeftButton;
  final Function(BuildContext)? onTapRightButton;
  final bool dismissible;
  final bool showButtons;
  final bool enableRightButton;
  final bool enableLeftButton;
  final Color leftButtonTextColor;
  final Color rightButtonTextColor;
  final double? elevation;

  const AppDialogWidget({
    super.key,
    this.title,
    this.child,
    this.text,
    this.padding,
    this.rightButtonText = 'Tutup',
    this.leftButtonText,
    this.backgroundColor,
    this.onTapLeftButton,
    this.onTapRightButton,
    this.dismissible = true,
    this.showButtons = true,
    this.enableRightButton = true,
    this.enableLeftButton = true,
    this.leftButtonTextColor = AppColors.blackLv2,
    this.rightButtonTextColor = AppColors.orangeLv1,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        elevation: elevation,
        backgroundColor: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                dialogTitle(),
                dialogBody(),
                dialogButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dialogTitle() {
    return title != null
        ? Container(
            padding: const EdgeInsets.all(AppSizes.padding),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: AppColors.blackLv3)),
            ),
            child: Text(title!, textAlign: TextAlign.center, style: AppTextStyle.bold(size: 14)),
          )
        : const SizedBox.shrink();
  }

  Widget dialogBody() {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.padding),
      child: text != null
          ? Text(text!, textAlign: TextAlign.center, style: AppTextStyle.medium(size: 12))
          : child ?? const SizedBox.shrink(),
    );
  }

  Widget dialogButtons(BuildContext context) {
    return !showButtons
        ? const SizedBox.shrink()
        : Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  color: AppColors.blackLv3,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                leftButtonText != null
                    ? Expanded(
                        child: AppFilledButton(
                          height: 48,
                          buttonColor: Colors.white,
                          text: leftButtonText!,
                          fontSize: 12,
                          textColor: enableRightButton ? leftButtonTextColor : AppColors.blackLv3,
                          onTap: () async {
                            if (enableLeftButton) {
                              if (onTapLeftButton != null) {
                                onTapLeftButton!(context);
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                leftButtonText != null && rightButtonText != null
                    ? Container(height: 18, width: 1, color: AppColors.blackLv3)
                    : const SizedBox.shrink(),
                rightButtonText != null
                    ? Expanded(
                        child: AppFilledButton(
                          height: 48,
                          buttonColor: Colors.white,
                          text: rightButtonText!,
                          fontSize: 12,
                          textColor: enableRightButton ? rightButtonTextColor : AppColors.blackLv2,
                          onTap: () async {
                            if (enableRightButton) {
                              if (onTapRightButton != null) {
                                onTapRightButton!(context);
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
  }
}
