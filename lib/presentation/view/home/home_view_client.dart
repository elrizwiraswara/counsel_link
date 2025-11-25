import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/routes/params/room_view_param.dart';
import '../../../core/const/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../data/models/schedule/schedule_model.dart';
import '../../view_model/home_client_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_filled_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_outlined_button.dart';
import '../../widgets/app_text_field.dart';
import 'widgets/counseling_history_table.dart';
import 'widgets/profile_card.dart';

class HomeViewClient extends StatefulWidget with WatchItStatefulWidgetMixin {
  const HomeViewClient({super.key});

  @override
  State<HomeViewClient> createState() => _HomeViewClientState();
}

class _HomeViewClientState extends State<HomeViewClient> {
  final model = di<HomeClientViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      model.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleHistory = watchPropertyValue((HomeClientViewModel m) => m.scheduleHistory);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            const AppLogo(),
            const SizedBox(height: AppSizes.padding),
            AppSizes.screenWidth(context) > 800 ? _DesktopView() : _MobileView(),
            const SizedBox(height: AppSizes.padding * 1.5),
            CounselingHistoryTable(data: scheduleHistory ?? []),
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
    return Container(
      width: AppSizes.screenWidth(context),
      constraints: const BoxConstraints(maxHeight: 360),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileCard(),
          const SizedBox(width: AppSizes.padding),
          _ScheduleCard(),
        ],
      ),
    );
  }
}

class _MobileView extends StatelessWidget {
  const _MobileView();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.screenWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileCard(expand: true),
          const SizedBox(height: AppSizes.padding),
          _ScheduleCard(),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget with WatchItMixin {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final currentSchedule = watchPropertyValue((HomeClientViewModel m) => m.currentSchedule);

    return currentSchedule == null
        ? const _CreateScheduleCard()
        : currentSchedule.status! == ScheduleStatus.created || currentSchedule.status == ScheduleStatus.confirmed
        ? _WaitingOrConfirmedCard(schedule: currentSchedule)
        : _ScheduleNotAvailableCard(schedule: currentSchedule);
  }
}

class _CreateScheduleCard extends StatelessWidget {
  const _CreateScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: AppSizes.screenWidth(context) > 800 ? const BoxConstraints(maxWidth: 300) : null,
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Counseling',
                  style: AppTextStyle.bold(size: 16),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  'Here are the steps for creating a counseling schedule:',
                  style: AppTextStyle.bold(size: 12),
                ),
                const SizedBox(height: AppSizes.padding / 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "1. ",
                      style: AppTextStyle.medium(size: 12),
                    ),
                    Expanded(
                      child: Text(
                        "Click the create schedule button below",
                        style: AppTextStyle.medium(size: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "2. ",
                      style: AppTextStyle.medium(size: 12),
                    ),
                    Expanded(
                      child: Text(
                        "Choose counseling type time",
                        style: AppTextStyle.medium(size: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "3. ",
                      style: AppTextStyle.medium(size: 12),
                    ),
                    Expanded(
                      child: Text(
                        "Wait for Admin confirmation",
                        style: AppTextStyle.medium(size: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "4. ",
                      style: AppTextStyle.medium(size: 12),
                    ),
                    Expanded(
                      child: Text(
                        "Enter the counseling room/page",
                        style: AppTextStyle.medium(size: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.padding),
            const _CreateScheduleButton(),
          ],
        ),
      ),
    );
  }
}

class _CreateScheduleButton extends StatelessWidget {
  const _CreateScheduleButton({this.currentSchedule});

  final ScheduleModel? currentSchedule;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeClientViewModel>();

    return AppFilledButton(
      text: 'Create Schedule',
      width: double.infinity,
      onTap: () async {
        if (currentSchedule != null) {
          final res = await AppDialog.showProgress(() async {
            return await model.cancelSchedule();
          });

          if (res.isFailure) {
            return AppDialog.showError(error: res.error.toString());
          }
        }

        AppDialog.show(
          title: 'Create Schedule',
          showButtons: false,
          child: const _CreateScheduleDialog(),
        );
      },
    );
  }
}

class _WaitingOrConfirmedCard extends StatelessWidget {
  const _WaitingOrConfirmedCard({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeClientViewModel>();

    return Container(
      constraints: AppSizes.screenWidth(context) > 800 ? const BoxConstraints(maxWidth: 300) : null,
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        buttonColor: AppColors.tangerineLv6,
        borderColor: AppColors.tangerineLv1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.status == ScheduleStatus.created ? 'Waiting Confirmation' : 'Schedule Confirmed',
                  style: AppTextStyle.bold(size: 16),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  schedule.status == ScheduleStatus.created
                      ? 'The counseling schedule has been created, please wait for confirmation from the Admin.'
                      : schedule.medium?.id == 'online'
                      ? 'The counseling schedule has been confirmed, please reopen this web page at the schedule that has been created.'
                      : 'The counseling schedule has been confirmed, please come to the $counselorAddress at the specified schedule.',
                  style: AppTextStyle.semibold(size: 12),
                ),
                const SizedBox(height: AppSizes.padding),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateTimeFormatter.normal(schedule.dateTime!),
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
                      DateTimeFormatter.onlyClockWithDivider(schedule.dateTime!),
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
                      schedule.medium?.name ?? '-',
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
                      schedule.serviceType?.name ?? '',
                      style: AppTextStyle.bold(size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (schedule.counselor != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.counselor?.name ?? '-',
                        style: AppTextStyle.bold(size: 11),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSizes.padding),
                if (schedule.status == ScheduleStatus.created)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.semibold(
                          size: 12,
                          color: AppColors.tangerineLv1,
                        ),
                      ),
                      onTap: () {
                        AppDialog.show(
                          title: 'Confirm',
                          text: 'Are you sure want to cancel this schedule?',
                          rightButtonText: 'Yes',
                          leftButtonText: 'No',
                          onTapRightButton: (context) async {
                            context.pop();

                            final res = await AppDialog.showProgress(() async {
                              return await model.cancelSchedule();
                            });

                            if (res.isFailure) {
                              AppDialog.showError(error: res.error.toString());
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (schedule.status == ScheduleStatus.confirmed && schedule.dateTime != null)
              CountdownTimer(
                endTime: DateTime.parse(schedule.dateTime!).millisecondsSinceEpoch,
                widgetBuilder: (_, time) {
                  if (time == null) {
                    return _EnterCounselingButton(schedule: schedule);
                  }

                  return _TimerButton(time: time);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EnterCounselingButton extends StatelessWidget {
  const _EnterCounselingButton({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    if (schedule.medium?.id == 'offline') {
      return const SizedBox.shrink();
    }

    return AppFilledButton(
      text: 'Enter Counseling Room',
      width: double.infinity,
      onTap: () async {
        context.go(
          '/room',
          extra: RoomViewParam(
            scheduleId: schedule.id!,
            roomId: schedule.roomId!,
            client: schedule.client!,
            counselor: schedule.counselor!,
          ),
        );
      },
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.time});

  final CurrentRemainingTime? time;

  @override
  Widget build(BuildContext context) {
    return AppFilledButton(
      width: double.infinity,
      enable: false,
      onTap: () {},
      text: '🕑 ${time?.days ?? '0'}:${time?.hours ?? '0'}:${time?.min ?? '0'}:${time?.sec ?? '0'}',
    );
  }
}

class _ScheduleNotAvailableCard extends StatelessWidget {
  const _ScheduleNotAvailableCard({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: AppSizes.screenWidth(context) > 800 ? const BoxConstraints(maxWidth: 300) : null,
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        buttonColor: AppColors.redLv6,
        borderColor: AppColors.redLv1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Not Available',
                  style: AppTextStyle.bold(size: 16),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  'The counseling schedule you made for the date ${DateTimeFormatter.stripDateWithClock(schedule.dateTime!)} not available, please create a new schedule by pressing the Create Schedule button.',
                  style: AppTextStyle.semibold(size: 12),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  schedule.adminMessage ?? '',
                  style: AppTextStyle.bold(size: 12),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.padding),
            _CreateScheduleButton(currentSchedule: schedule),
          ],
        ),
      ),
    );
  }
}

class _CreateScheduleDialog extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _CreateScheduleDialog();

  @override
  State<_CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<_CreateScheduleDialog> {
  final model = di<HomeClientViewModel>();

  final counselingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    model.resetCreateSceduleState();
  }

  @override
  void dispose() {
    counselingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCounselingMedium = watchPropertyValue((HomeClientViewModel m) => m.selectedCounselingMedium);
    final selectedServiceType = watchPropertyValue((HomeClientViewModel m) => m.selectedServiceType);
    final selectedDateTime = watchPropertyValue((HomeClientViewModel m) => m.selectedDateTime);
    final allServiceType = watchPropertyValue((HomeClientViewModel m) => m.allServiceType);

    return Column(
      children: [
        AppDropDown(
          labelText: 'Counseling Medium',
          selectedValue: selectedCounselingMedium.id,
          dropdownItems: List.generate(
            conselingMedium.length,
            (i) => DropdownMenuItem<String>(
              value: conselingMedium[i].id,
              child: Text(
                conselingMedium[i].name ?? '',
              ),
            ),
          ),
          onChanged: model.onChangedMedium,
        ),
        const SizedBox(height: AppSizes.padding),
        AppDropDown(
          labelText: 'Service Type (Topic)',
          hintText: 'Select service type',
          selectedValue: selectedServiceType?.id,
          dropdownItems: List.generate(
            allServiceType.length,
            (i) => DropdownMenuItem<String>(
              value: allServiceType[i].id,
              child: Text(allServiceType[i].name ?? ''),
            ),
          ),
          onChanged: model.onChangedServiceType,
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: counselingDateController,
          labelText: 'Date & Time',
          hintText: 'Choose date & time',
          enabled: false,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.blackLv2,
            size: 18,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
            );

            if (date != null) {
              final time = await showTimePicker(
                // ignore: use_build_context_synchronously
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (time != null) {
                final dt = date.copyWith(hour: time.hour, minute: time.minute);
                model.onChangedDate(dt);
                counselingDateController.text = DateTimeFormatter.stripDateWithClock(dt.toIso8601String());
              }
            }
          },
        ),
        const SizedBox(height: AppSizes.padding * 1.2),
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
                enable: selectedServiceType != null && selectedDateTime != null,
                text: 'Create Schedule',
                onTap: () async {
                  context.pop();

                  final res = await AppDialog.showProgress(() async {
                    return await model.createSchedule();
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
