import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/themes/app_text_style.dart';
import '../../../../data/models/user/user_model.dart';
import '../../../view_model/auth_view_model.dart';
import '../../../view_model/profile_view_model.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_outlined_button.dart';
import 'profile_photo.dart';

class ProfileCard extends StatelessWidget with WatchItMixin {
  final bool expand;

  const ProfileCard({super.key, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final user = watchPropertyValue((AuthViewModel m) => m.user);

    return Container(
      constraints: expand ? null : const BoxConstraints(maxWidth: 300),
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfilePhoto(
                  size: 52,
                  imgUrl: user?.imageUrl,
                  onChangeImage: () => onChangeImage(context, user),
                ),
                const SizedBox(width: AppSizes.padding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello!',
                      style: AppTextStyle.medium(size: 12),
                    ),
                    Text(
                      user?.name ?? '(No Name)',
                      style: AppTextStyle.bold(size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.padding),
            user?.role == UserRole.admin ? const SizedBox.shrink() : _EditProfileButton(),
            _SignOutButton(),
          ],
        ),
      ),
    );
  }

  void onChangeImage(BuildContext context, UserModel? user) async {
    final profileViewModel = di<ProfileViewModel>();
    final imagePicker = di<ImagePicker>();

    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) return;

    final res = await AppDialog.showProgress(() async {
      return await profileViewModel.uploadImage(pickedFile);
    });

    if (res.isFailure) {
      AppDialog.showError(error: res.error.toString());
    }
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final confirm = await AppDialog.show<bool>(
            title: 'Sign Out',
            text: 'Are you sure you want to sign out?',
            leftButtonText: 'Cancel',
            rightButtonText: 'Sign Out',
            onTapRightButton: (context) => context.pop(true),
          );

          if (confirm != true) return;

          final res = await AppDialog.showProgress(() async {
            return await di<AuthViewModel>().signOut();
          });

          if (res.isFailure) {
            return AppDialog.showError(error: res.error.toString());
          }

          AppRoutes.router.refresh();
        },
        child: Row(
          children: [
            const Icon(
              Icons.exit_to_app,
              color: AppColors.tangerineLv1,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: AppTextStyle.bold(
                size: 12,
                color: AppColors.tangerineLv1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/edit-profile', extra: false);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
          child: Row(
            children: [
              const Icon(
                Icons.person,
                color: AppColors.tangerineLv1,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: AppTextStyle.bold(
                  size: 12,
                  color: AppColors.tangerineLv1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
