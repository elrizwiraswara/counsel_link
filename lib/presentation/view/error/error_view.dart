import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../app/routes/params/error_view_param.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_filled_button.dart';

class ErrorView extends StatelessWidget {
  final ErrorViewParam param;

  const ErrorView({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(
              error: param.error ?? param.flutterError,
              message: param.message,
              textOnly: false,
            ),
            const SizedBox(height: AppSizes.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppFilledButton(
                  buttonColor: Theme.of(context).colorScheme.surface,
                  textColor: Theme.of(context).colorScheme.primary,
                  text: 'Back to home',
                  onTap: () {
                    AppRoutes.router.go('/home');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
