import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../data/models/schedule/schedule_model.dart';
import '../../../data/models/user/gender_model.dart';
import '../../../data/models/user/user_model.dart';
import '../../view_model/home_admin_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_filled_button.dart';
import '../../widgets/app_fluent_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_outlined_button.dart';
import '../../widgets/app_text_field.dart';
import 'widgets/counseling_history_table.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_photo.dart';

class HomeViewAdmin extends StatefulWidget with WatchItStatefulWidgetMixin {
  const HomeViewAdmin({super.key});

  @override
  State<HomeViewAdmin> createState() => _HomeViewAdminState();
}

class _HomeViewAdminState extends State<HomeViewAdmin> {
  final model = di<HomeAdminViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      model.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allSchedule = watchPropertyValue((HomeAdminViewModel m) => m.allSchedule);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            const AppLogo(),
            const SizedBox(height: AppSizes.padding),
            AppSizes.screenWidth(context) > 1080 ? _DesktopView() : _MobileView(),
            const SizedBox(height: AppSizes.padding * 1.5),
            CounselingHistoryTable(data: allSchedule ?? []),
          ],
        ),
      ),
    );
  }
}

class _DesktopView extends StatelessWidget {
  const _DesktopView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: AppSizes.screenWidth(context),
          height: AppSizes.screenHeight(context) / 3,
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ProfileCard()),
              SizedBox(width: AppSizes.padding),
              _CounselingTotalCard(),
              SizedBox(width: AppSizes.padding),
              _CounselingDoneCard(),
              SizedBox(width: AppSizes.padding),
              _CounselingCancelledCard(),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        SizedBox(
          width: AppSizes.screenWidth(context),
          height: AppSizes.screenHeight(context) / 2,
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WaitingToConfirmCard(),
              SizedBox(width: AppSizes.padding),
              _CounselorList(),
              SizedBox(width: AppSizes.padding),
              _ServiceList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileView extends StatelessWidget {
  const _MobileView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: AppSizes.screenWidth(context),
          height: 1024,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(expand: true),
              SizedBox(height: AppSizes.padding),
              _CounselingTotalCard(),
              SizedBox(height: AppSizes.padding),
              _CounselingDoneCard(),
              SizedBox(height: AppSizes.padding),
              _CounselingCancelledCard(),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        SizedBox(
          width: AppSizes.screenWidth(context),
          height: 1200,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WaitingToConfirmCard(),
              SizedBox(height: AppSizes.padding),
              _CounselorList(),
              SizedBox(height: AppSizes.padding),
              _ServiceList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounselingTotalCard extends StatelessWidget with WatchItMixin {
  const _CounselingTotalCard();

  @override
  Widget build(BuildContext context) {
    final allSchedule = watchPropertyValue((HomeAdminViewModel m) => m.allSchedule);

    return Expanded(
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${allSchedule?.length}',
                style: AppTextStyle.bold(size: 52),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                'TOTAL COUNSELING',
                style: AppTextStyle.bold(size: 16),
              ),
              const SizedBox(height: AppSizes.padding),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounselingDoneCard extends StatelessWidget with WatchItMixin {
  const _CounselingDoneCard();

  @override
  Widget build(BuildContext context) {
    final allSchedule = watchPropertyValue((HomeAdminViewModel m) => m.allSchedule);

    return Expanded(
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        buttonColor: AppColors.greenLv6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${allSchedule?.where((e) => e.status == ScheduleStatus.done).length ?? 0}',
                style: AppTextStyle.bold(size: 52),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                'COUNSELING DONE',
                style: AppTextStyle.bold(size: 16),
              ),
              const SizedBox(height: AppSizes.padding),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounselingCancelledCard extends StatelessWidget with WatchItMixin {
  const _CounselingCancelledCard();

  @override
  Widget build(BuildContext context) {
    final allSchedule = watchPropertyValue((HomeAdminViewModel m) => m.allSchedule);

    return Expanded(
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        buttonColor: AppColors.redLv6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${allSchedule?.where((e) => e.status == ScheduleStatus.cancelled).length ?? 0}',
                style: AppTextStyle.bold(size: 52),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                'COUNSELING CANCELLED',
                style: AppTextStyle.bold(size: 16),
              ),
              const SizedBox(height: AppSizes.padding),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingToConfirmCard extends StatelessWidget with WatchItMixin {
  const _WaitingToConfirmCard();

  @override
  Widget build(BuildContext context) {
    final waitingConfirmSchedules = watchPropertyValue((HomeAdminViewModel m) => m.waitingConfirmSchedules);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting for Confirmation (${waitingConfirmSchedules?.length})',
            style: AppTextStyle.bold(size: 16),
          ),
          const SizedBox(height: AppSizes.padding),
          Expanded(
            child: AppOutlinedButton(
              height: null,
              padding: const EdgeInsets.all(AppSizes.padding),
              alignment: Alignment.topLeft,
              child: waitingConfirmSchedules!.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(
                            waitingConfirmSchedules.length,
                            (i) => _WaitingListTile(schedule: waitingConfirmSchedules[i]),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        '(Empty)',
                        style: AppTextStyle.bold(
                          size: 12,
                          color: AppColors.blackLv2,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounselorList extends StatelessWidget with WatchItMixin {
  const _CounselorList();

  @override
  Widget build(BuildContext context) {
    final allCounselor = watchPropertyValue((HomeAdminViewModel m) => m.allCounselor);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'List of Counselors (${allCounselor?.length})',
                style: AppTextStyle.bold(size: 16),
              ),
              AppFluentButton(
                text: '+ Add Counselor',
                onTap: () async {
                  await AppDialog.show(
                    title: 'Add Counselor Account',
                    showButtons: false,
                    child: const _CreateCounselorDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Expanded(
            child: AppOutlinedButton(
              height: null,
              padding: const EdgeInsets.all(AppSizes.padding),
              alignment: Alignment.topLeft,
              child: allCounselor!.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(
                            allCounselor.length,
                            (i) => _CounselorListTile(user: allCounselor[i]),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        '(Empty)',
                        style: AppTextStyle.bold(
                          size: 12,
                          color: AppColors.blackLv2,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceList extends StatelessWidget with WatchItMixin {
  const _ServiceList();

  @override
  Widget build(BuildContext context) {
    final allServiceType = watchPropertyValue((HomeAdminViewModel m) => m.allServiceType);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'List of Service Types (${allServiceType?.length})',
                style: AppTextStyle.bold(size: 16),
              ),
              AppFluentButton(
                text: '+ Add Service Type',
                onTap: () async {
                  await AppDialog.show(
                    title: 'Add Service Type',
                    showButtons: false,
                    child: const _CreateServiceTypeDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Expanded(
            child: AppOutlinedButton(
              height: null,
              padding: const EdgeInsets.all(AppSizes.padding),
              alignment: Alignment.topLeft,
              child: allServiceType!.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(
                            allServiceType.length,
                            (i) => _ServiceListTile(serviceType: allServiceType[i]),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        '(Empty)',
                        style: AppTextStyle.bold(
                          size: 12,
                          color: AppColors.blackLv2,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingListTile extends StatelessWidget {
  const _WaitingListTile({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeAdminViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
      child: AppOutlinedButton(
        onTap: () {
          model.selectedSchedule = schedule;
          AppDialog.show(
            showButtons: false,
            child: _ConfirmScheduleDialog(),
          );
        },
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        buttonColor: AppColors.tangerineLv6,
        borderColor: AppColors.tangerineLv1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ProfilePhoto(
                    size: 46,
                    imgUrl: schedule.client?.imageUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateTimeFormatter.normalWithClock(DateTime.now().toIso8601String()),
                          style: AppTextStyle.bold(size: 14),
                        ),
                        Text(
                          '${schedule.client?.name ?? ''} • ${schedule.medium?.name ?? ''} • ${schedule.serviceType?.name ?? ''}',
                          style: AppTextStyle.semibold(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.tangerineLv1,
            ),
          ],
        ),
      ),
    );
  }
}

class _CounselorListTile extends StatelessWidget {
  const _CounselorListTile({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeAdminViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        buttonColor: AppColors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ProfilePhoto(
                    size: 46,
                    imgUrl: user.imageUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user.name ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bold(size: 14),
                        ),
                        Text(
                          user.phone ?? '',
                          style: AppTextStyle.semibold(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  AppDialog.show(
                    title: 'Confirmation',
                    text: 'Are you sure you want to delete this counselor account?',
                    leftButtonText: 'Cancel',
                    rightButtonText: 'Delete',
                    onTapRightButton: (context) async {
                      context.pop();

                      final res = await AppDialog.showProgress(() async {
                        return await model.deleteCounselor(user);
                      });

                      if (res.isFailure) {
                        AppDialog.showError(error: res.error?.toString());
                      }
                    },
                  );
                },
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.blackLv1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  const _ServiceListTile({required this.serviceType});

  final MenuItemModel serviceType;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeAdminViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        buttonColor: AppColors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (serviceType.name ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bold(size: 14),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.blackLv1,
                    ),
                    onTap: () async {
                      await AppDialog.show(
                        title: 'Edit Service Type',
                        child: _CreateServiceTypeDialog(serviceType: serviceType),
                        rightButtonText: 'Cancel',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.blackLv1,
                    ),
                    onTap: () {
                      AppDialog.show(
                        title: 'Confirmation',
                        text: 'Are you sure you want to delete this service type?',
                        leftButtonText: 'Cancel',
                        rightButtonText: 'Delete',
                        onTapRightButton: (context) async {
                          context.pop();

                          final res = await AppDialog.showProgress(() async {
                            return await model.deleteServiceType(serviceType);
                          });

                          if (res.isFailure) {
                            AppDialog.showError(error: res.error?.toString());
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCounselorDialog extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _CreateCounselorDialog();

  @override
  State<_CreateCounselorDialog> createState() => _CreateCounselorDialogState();
}

class _CreateCounselorDialogState extends State<_CreateCounselorDialog> {
  final model = di<HomeAdminViewModel>();

  final phoneController = TextEditingController();
  final counselorNameController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    counselorNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneNotEmpty = watch(phoneController).text.isNotEmpty;
    final isNameNotEmpty = watch(counselorNameController).text.isNotEmpty;

    return Column(
      children: [
        AppTextField(
          controller: phoneController,
          labelText: 'Counselor Phone Number',
          hintText: 'Enter phone number (e.g. +62xxx)',
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$'))],
          keyboardType: TextInputType.phone,
          maxLength: 15,
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: counselorNameController,
          labelText: 'Counselor Full Name',
          hintText: 'Enter full name',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppFilledButton(
                text: 'Cancel',
                buttonColor: AppColors.blackLv5,
                textColor: AppColors.blackLv2,
                onTap: () => context.pop(),
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(
              child: AppFilledButton(
                enable: isNameNotEmpty && isPhoneNotEmpty,
                text: 'Add',
                onTap: () async {
                  context.pop();

                  final res = await AppDialog.showProgress(() async {
                    return await model.createCounselor(
                      phone: phoneController.text,
                      name: counselorNameController.text,
                    );
                  });

                  if (res.isFailure) {
                    AppDialog.showError(error: res.error?.toString());
                  }

                  model.getAllCounselor();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CreateServiceTypeDialog extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _CreateServiceTypeDialog({this.serviceType});

  final MenuItemModel? serviceType;

  @override
  State<_CreateServiceTypeDialog> createState() => _CreateServiceTypeDialogState();
}

class _CreateServiceTypeDialogState extends State<_CreateServiceTypeDialog> {
  final model = di<HomeAdminViewModel>();

  final serviceTypeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.serviceType != null) {
      serviceTypeNameController.text = widget.serviceType!.name ?? '';
    }
  }

  @override
  void dispose() {
    serviceTypeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNameNotEmpty = watch(serviceTypeNameController).text.isNotEmpty;

    return Column(
      children: [
        AppTextField(
          controller: serviceTypeNameController,
          labelText: 'Service Type Name',
          hintText: 'Enter service type name',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppFilledButton(
                text: 'Cancel',
                buttonColor: AppColors.blackLv5,
                textColor: AppColors.blackLv2,
                onTap: () => context.pop(),
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(
              child: AppFilledButton(
                enable: isNameNotEmpty,
                text: widget.serviceType != null ? 'Save' : 'Add',
                onTap: () async {
                  context.pop();

                  final res = await AppDialog.showProgress(() async {
                    return await model.createOrUpdateServiceType(
                      id: widget.serviceType?.id,
                      name: serviceTypeNameController.text,
                    );
                  });

                  if (res.isFailure) {
                    AppDialog.showError(error: res.error.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmScheduleDialog extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _ConfirmScheduleDialog();

  @override
  State<_ConfirmScheduleDialog> createState() => _ConfirmScheduleDialogState();
}

class _ConfirmScheduleDialogState extends State<_ConfirmScheduleDialog> {
  final model = di<HomeAdminViewModel>();

  final adminMessageController = TextEditingController();

  @override
  void dispose() {
    adminMessageController.dispose();
    super.dispose();
  }

  bool isConfirmScheduleEnabled(UserModel? selectedCounselor, ScheduleModel? selectedSchedule) {
    if (selectedSchedule == null) {
      return false;
    }

    if (selectedSchedule.status == ScheduleStatus.confirmed) {
      if (selectedCounselor != null) {
        return true;
      } else {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCounselor = watchPropertyValue((HomeAdminViewModel m) => m.selectedCounselor);
    final selectedSchedule = watchPropertyValue((HomeAdminViewModel m) => m.selectedSchedule);
    final selectedScheduleStatus = watchPropertyValue((HomeAdminViewModel m) => m.selectedSchedule?.status);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePhoto(
                size: 44,
                imgUrl: selectedSchedule?.client?.imageUrl,
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedSchedule?.client?.name ?? '',
                    style: AppTextStyle.bold(size: 16),
                  ),
                  Text(
                    selectedSchedule?.client?.phone ?? '',
                    style: AppTextStyle.medium(size: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                DateTimeFormatter.normal(selectedSchedule?.dateTime ?? ''),
                style: AppTextStyle.bold(size: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.av_timer_rounded,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                DateTimeFormatter.onlyClockWithDivider(selectedSchedule?.dateTime ?? ''),
                style: AppTextStyle.bold(size: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.wifi,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                selectedSchedule?.medium?.name ?? '-',
                style: AppTextStyle.bold(size: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.topic,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                selectedSchedule?.serviceType?.name ?? '',
                style: AppTextStyle.bold(size: 11),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Schedule Status',
            style: AppTextStyle.bold(size: 14),
          ),
          const SizedBox(height: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                model.onChangedScheduleConfirmation(ScheduleStatus.confirmed);
              },
              child: Row(
                children: [
                  RadioGroup<ScheduleStatus>(
                    groupValue: selectedScheduleStatus,
                    onChanged: model.onChangedScheduleConfirmation,
                    child: Radio(
                      value: ScheduleStatus.confirmed,
                      activeColor: AppColors.tangerineLv1,
                    ),
                  ),
                  Text(
                    'Confirmed',
                    style: AppTextStyle.semibold(size: 14),
                  ),
                ],
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                model.onChangedScheduleConfirmation(ScheduleStatus.unconfirmed);
              },
              child: Row(
                children: [
                  RadioGroup<ScheduleStatus>(
                    groupValue: selectedScheduleStatus,
                    onChanged: model.onChangedScheduleConfirmation,
                    child: Radio(
                      value: ScheduleStatus.unconfirmed,
                      activeColor: AppColors.tangerineLv1,
                    ),
                  ),
                  Text(
                    'Can not be confirmed',
                    style: AppTextStyle.semibold(size: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          selectedSchedule?.status == ScheduleStatus.confirmed
              ? AppDropDown<String>(
                  labelText: 'Choose Counselor',
                  selectedValue: selectedCounselor?.id,
                  dropdownItems: List.generate(
                    model.allCounselor?.length ?? 0,
                    (i) => DropdownMenuItem<String>(
                      value: model.allCounselor?[i].id,
                      child: Text(model.allCounselor?[i].name ?? ''),
                    ),
                  ),
                  onChanged: model.onChangedScheduleCounselor,
                )
              : selectedSchedule?.status == ScheduleStatus.unconfirmed
              ? AppTextField(
                  controller: adminMessageController,
                  minLines: 3,
                  maxLines: 3,
                  labelText: 'Message client',
                  hintText: 'Message client',
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 18),
          AppFilledButton(
            enable: isConfirmScheduleEnabled(selectedCounselor, selectedSchedule),
            text: 'Submit',
            onTap: () async {
              context.pop();

              final res = await AppDialog.showProgress(() async {
                return await model.updateSchedule();
              });

              if (res.isFailure) {
                AppDialog.showError(error: res.error?.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
