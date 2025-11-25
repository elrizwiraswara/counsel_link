import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_style.dart';

class AppFluentButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double fontSize;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final bool enable;
  final bool center;
  final Color color;
  final String? text;
  final Widget? icon;
  final Widget? child;
  final Function()? onTap;

  const AppFluentButton({
    super.key,
    this.width,
    this.height,
    this.fontSize = 10,
    this.borderWidth = 0.2,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.enable = true,
    this.center = true,
    this.color = AppColors.tangerineLv1,
    this.text,
    this.icon,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: enable ? onTap : null,
        splashColor: Colors.black.withValues(alpha: 0.06),
        splashFactory: InkRipple.splashFactory,
        highlightColor: enable ? Colors.white38 : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: enable ? color.withValues(alpha: 0.08) : AppColors.blackLv6,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: center ? Center(child: childWidget()) : childWidget(),
        ),
      ),
    );
  }

  Widget childWidget() {
    return child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: icon,
              ),
            Text(
              text ?? '',
              textAlign: TextAlign.center,
              style: AppTextStyle.bold(
                size: fontSize,
                color: enable ? color : AppColors.blackLv2,
              ),
            ),
          ],
        );
  }
}
