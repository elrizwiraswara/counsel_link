import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/assets/assets.dart';
import '../../../core/const/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../view_model/profile_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_filled_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_outlined_button.dart';
import '../../widgets/app_text_field.dart';

class EditProfileView extends StatefulWidget with WatchItStatefulWidgetMixin {
  final bool isNewUser;

  const EditProfileView({super.key, required this.isNewUser});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final profileViewModel = di<ProfileViewModel>();

  final nameController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      profileViewModel.initProfileView();

      nameController.text = profileViewModel.user!.name ?? '';
      birthPlaceController.text = profileViewModel.user!.birthPlace ?? '';
      birthDateController.text = profileViewModel.user!.birthDate ?? '';
      addressController.text = profileViewModel.user!.address ?? '';
    });
    super.initState();
  }

  bool signUpEnabled() {
    final validator = [
      nameController.text.isNotEmpty,
      birthPlaceController.text.isNotEmpty,
      birthDateController.text.isNotEmpty,
      addressController.text.isNotEmpty,
    ];

    return !validator.contains(false);
  }

  @override
  void dispose() {
    nameController.dispose();
    birthPlaceController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: AppSizes.size(context).height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: AppSizes.size(context).width > 800
                    ? AppSizes.size(context).width / 2
                    : AppSizes.size(context).width / 1.5,
                child: const AppImage(
                  image: Assets.welcomeBg,
                  imgProvider: ImgProvider.assetImage,
                ),
              ),
            ),
            widget.isNewUser
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(82),
                    child: signUpForm(),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const AppLogo(),
                        const SizedBox(height: 40),
                        editProfileForm(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget signUpForm() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(37),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 32),
          Text('Sign Up', style: AppTextStyle.bold(size: 18)),
          const SizedBox(height: 14),
          termsAndConditions(),
          const SizedBox(height: 32),
          name(),
          const SizedBox(height: 18),
          gender(),
          const SizedBox(height: 18),
          birthPlace(),
          const SizedBox(height: 18),
          birthDate(),
          const SizedBox(height: 18),
          religion(),
          const SizedBox(height: 18),
          address(),
          const SizedBox(height: 18),
          city(),
          const SizedBox(height: 18),
          district(),
          const SizedBox(height: 18),
          village(),
          const SizedBox(height: 32),
          registerButton(),
          const SizedBox(height: 32),
          signInText(),
        ],
      ),
    );
  }

  Widget editProfileForm() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(37),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              BackButton(
                onPressed: () => context.go('/home'),
              ),
              Text(
                'Edit Profile',
                style: AppTextStyle.bold(size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          name(),
          const SizedBox(height: 18),
          gender(),
          const SizedBox(height: 18),
          birthPlace(),
          const SizedBox(height: 18),
          birthDate(),
          const SizedBox(height: 18),
          religion(),
          const SizedBox(height: 18),
          address(),
          const SizedBox(height: 18),
          district(),
          const SizedBox(height: 18),
          village(),
          const SizedBox(height: 32),
          saveButton(),
        ],
      ),
    );
  }

  Widget termsAndConditions() {
    return AppOutlinedButton(
      height: null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms and Conditions',
            style: AppTextStyle.bold(
              size: 10,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            """"By filling out this registration form, I declare that I am willing to participate in the online counseling process to share my problems and personal life voluntarily without any coercion and/or to carry out a series of online psychological counseling processes.
             \nIn this activity, the Clinical Psychologist is obliged to explain :\n""",
            style: AppTextStyle.medium(
              size: 10,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1.  ',
                style: AppTextStyle.medium(
                  size: 10,
                ),
              ),
              Expanded(
                child: Text(
                  'A detailed process of the activities that will take place as part of the implementation of online counseling',
                  style: AppTextStyle.medium(
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2. ',
                style: AppTextStyle.medium(
                  size: 10,
                ),
              ),
              Expanded(
                child: Text(
                  'The purpose of this online counseling is to understand the client more deeply along with all issues related to them that are considered important to bring into the therapeutic process',
                  style: AppTextStyle.medium(
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "3. ",
                style: AppTextStyle.medium(
                  size: 10,
                ),
              ),
              Expanded(
                child: Text(
                  'Personal identity will be kept confidential from any party in accordance with the Psychological Code of Ethics."',
                  style: AppTextStyle.medium(
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget name() {
    return AppTextField(
      controller: nameController,
      onChanged: profileViewModel.onChangedName,
      labelText: 'Full Name',
      hintText: 'Enter your full name',
    );
  }

  Widget gender() {
    return AppDropDown<String>(
      labelText: 'Gender',
      selectedValue: profileViewModel.selectedGender.id,
      dropdownItems: List.generate(
        genderMenuItems.length,
        (i) => DropdownMenuItem<String>(
          value: genderMenuItems[i].id,
          child: Text(genderMenuItems[i].name ?? ''),
        ),
      ),
      onChanged: profileViewModel.onChangedGender,
    );
  }

  Widget birthPlace() {
    return AppTextField(
      controller: birthPlaceController,
      onChanged: profileViewModel.onChangedBirthPlace,
      labelText: 'Place of Birth',
      hintText: 'Enter your place of birth',
    );
  }

  Widget birthDate() {
    return AppTextField(
      controller: birthDateController,
      labelText: 'Birth Date',
      hintText: 'Enter your birth date',
      enabled: false,
      suffixIcon: const Icon(
        Icons.calendar_month_outlined,
        color: AppColors.blackLv2,
        size: 18,
      ),
      onTap: () async {
        var date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );

        if (date == null) return;

        birthDateController.text = DateTimeFormatter.stripDate(date.toIso8601String());
        profileViewModel.onChangedBirthdate(birthDateController.text);
      },
    );
  }

  Widget religion() {
    final selectedReligion = watchPropertyValue((ProfileViewModel m) => m.selectedReligion);

    return AppDropDown<String>(
      labelText: 'Religion',
      selectedValue: selectedReligion.id,
      dropdownItems: List.generate(
        religionMenuItems.length,
        (i) => DropdownMenuItem<String>(
          value: religionMenuItems[i].id,
          child: Text(religionMenuItems[i].name ?? ''),
        ),
      ),
      onChanged: profileViewModel.onChangedReligion,
    );
  }

  Widget address() {
    return AppTextField(
      controller: addressController,
      onChanged: profileViewModel.onChangedAddress,
      labelText: 'Address',
      hintText: 'Enter your address',
    );
  }

  Widget city() {
    return AppDropDown<Map<String, dynamic>>(
      labelText: 'City',
      selectedValue: locationData.first,
      dropdownItems: List.generate(
        locationData.length,
        (i) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: locationData[i],
            child: Text(
              locationData[i]['name'],
            ),
          );
        },
      ),
      onChanged: (value) => profileViewModel.onChangedCity(value),
    );
  }

  Widget district() {
    final city = watchPropertyValue((ProfileViewModel m) => m.city);
    final district = watchPropertyValue((ProfileViewModel m) => m.district);

    return AppDropDown<Map<String, dynamic>>(
      labelText: 'District',
      selectedValue: locationData
          .firstWhere((e) => e['id'] == city['id'])['district']
          .firstWhere((e) => e['id'] == district['id']),
      dropdownItems: List.generate(
        locationData.firstWhere((e) => e['id'] == city['id'])['district'].length,
        (i) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: locationData.firstWhere((e) => e['id'] == city['id'])['district'][i],
            child: Text(
              locationData.firstWhere((e) => e['id'] == city['id'])['district'][i]['name'],
            ),
          );
        },
      ),
      onChanged: (value) => profileViewModel.onChangedDistrict(value),
    );
  }

  Widget village() {
    final city = watchPropertyValue((ProfileViewModel m) => m.city);
    final district = watchPropertyValue((ProfileViewModel m) => m.district);
    final village = watchPropertyValue((ProfileViewModel m) => m.village);

    return AppDropDown<Map<String, dynamic>>(
      labelText: 'Village',
      selectedValue: locationData
          .firstWhere((e) => e['id'] == city['id'])['district']
          .firstWhere((e) => e['id'] == district['id'])['village']
          .firstWhere((e) => e['id'] == village['id']),
      dropdownItems: List.generate(
        locationData
            .firstWhere((e) => e['id'] == city['id'])['district']
            .firstWhere((e) => e['id'] == district['id'])['village']
            .length,
        (i) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: locationData
                .firstWhere((e) => e['id'] == city['id'])['district']
                .firstWhere((e) => e['id'] == district['id'])['village'][i],
            child: Text(
              locationData
                  .firstWhere((e) => e['id'] == city['id'])['district']
                  .firstWhere((e) => e['id'] == district['id'])['village'][i]['name'],
            ),
          );
        },
      ),
      onChanged: (value) => profileViewModel.onChangedVillage(value),
    );
  }

  Widget registerButton() {
    return AppFilledButton(
      text: 'Sign Up',
      enable: signUpEnabled(),
      onTap: () async {
        FocusScope.of(context).unfocus();

        final res = await AppDialog.showProgress(() async {
          return await profileViewModel.createOrUpdateUser(isCreateNewUser: true);
        });

        if (res.isFailure) {
          return AppDialog.showError(error: res.error.toString());
        } else {
          AppRoutes.router.go('/home');
        }
      },
    );
  }

  Widget saveButton() {
    return AppFilledButton(
      text: 'Save',
      onTap: () async {
        FocusScope.of(context).unfocus();

        final res = await AppDialog.showProgress(() async {
          return await profileViewModel.createOrUpdateUser(isCreateNewUser: true);
        });

        if (res.isFailure) {
          return AppDialog.showError(error: res.error.toString());
        }

        AppDialog.show(
          title: 'Success',
          text: 'Profile updated successfully',
          rightButtonText: 'OK',
        );
      },
    );
  }

  Widget signInText() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyle.regular(
            size: 12,
          ),
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
    );
  }
}
