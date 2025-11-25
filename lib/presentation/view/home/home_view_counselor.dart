import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/routes/params/room_view_param.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../data/models/schedule/schedule_model.dart';
import '../../view_model/home_counselor_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_filled_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_outlined_button.dart';
import 'widgets/counseling_history_table.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_photo.dart';

class HomeViewCounselor extends StatefulWidget with WatchItStatefulWidgetMixin {
  const HomeViewCounselor({super.key});

  @override
  State<HomeViewCounselor> createState() => _HomeViewCounselorState();
}

class _HomeViewCounselorState extends State<HomeViewCounselor> {
  final model = di<HomeCounselorViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      model.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleHistory = watchPropertyValue((HomeCounselorViewModel m) => m.scheduleHistory);

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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth(context),
      constraints: const BoxConstraints(maxHeight: 360),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(),
          SizedBox(width: AppSizes.padding),
          _WaitingCard(),
          Expanded(child: _WaitingListCard()),
        ],
      ),
    );
  }
}

class _MobileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.screenWidth(context),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(expand: true),
          SizedBox(height: AppSizes.padding),
          _WaitingCard(),
          SizedBox(height: 300, child: _WaitingListCard()),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget with WatchItMixin {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    final model = di<HomeCounselorViewModel>();

    final nearestSchedule = watchPropertyValue((HomeCounselorViewModel m) => m.nearestSchedule);

    if (nearestSchedule == null) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: AppSizes.screenWidth(context) > 800 ? const BoxConstraints(maxWidth: 300) : null,
      margin: AppSizes.screenWidth(context) > 800
          ? EdgeInsets.only(right: AppSizes.padding)
          : EdgeInsets.only(bottom: AppSizes.padding),
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        alignment: Alignment.topLeft,
        buttonColor: AppColors.tangerineLv6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTime.now().compareTo(DateTime.parse(nearestSchedule.dateTime!)) >= 0
                      ? 'Ongoing'
                      : 'Starting Soon',
                  style: AppTextStyle.bold(size: 16),
                ),
                const SizedBox(height: AppSizes.padding),
                Row(
                  children: [
                    ProfilePhoto(
                      size: 44,
                      imgUrl: nearestSchedule.client?.imageUrl,
                    ),
                    const SizedBox(width: AppSizes.padding / 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nearestSchedule.client?.name ?? '',
                          style: AppTextStyle.bold(size: 16),
                        ),
                        Text(
                          nearestSchedule.client?.phone ?? '',
                          style: AppTextStyle.medium(size: 12),
                        ),
                      ],
                    ),
                  ],
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
                      DateTimeFormatter.normal(nearestSchedule.dateTime!),
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
                      DateTimeFormatter.onlyClockWithDivider(nearestSchedule.dateTime!),
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
                      nearestSchedule.medium?.name ?? '-',
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
                      nearestSchedule.serviceType?.name ?? '',
                      style: AppTextStyle.bold(size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.padding / 1.2),
                if (!DateTime.parse(nearestSchedule.dateTime!).isBefore(DateTime.now()))
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
                              return await model.closeConselingSession();
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
            const SizedBox(height: AppSizes.padding / 2),
            CountdownTimer(
              endTime: DateTime.parse(nearestSchedule.dateTime!).millisecondsSinceEpoch,
              widgetBuilder: (_, time) {
                if (time == null) {
                  return Column(
                    children: [
                      _EnterCounselingButton(schedule: nearestSchedule),
                      const SizedBox(height: AppSizes.padding / 1.2),
                      const _CloseRoomButton(),
                    ],
                  );
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

class _CloseRoomButton extends StatelessWidget {
  const _CloseRoomButton();

  @override
  Widget build(BuildContext context) {
    final homeCounselorViewModel = di<HomeCounselorViewModel>();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Text(
          'Close Counseling Session',
          style: AppTextStyle.semibold(
            size: 12,
            color: AppColors.orangeLv1,
          ),
        ),
        onTap: () {
          AppDialog.show(
            title: 'Confirm',
            text: 'Are you sure you want to close and finish this counseling session?',
            rightButtonText: 'Yes',
            leftButtonText: 'Cancel',
            onTapRightButton: (context) async {
              context.pop();

              final res = await AppDialog.showProgress(() async {
                return await homeCounselorViewModel.closeConselingSession();
              });

              if (res.isFailure) {
                AppDialog.showError(error: res.error.toString());
              }
            },
          );
        },
      ),
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

class _WaitingListCard extends StatelessWidget with WatchItMixin {
  const _WaitingListCard();

  @override
  Widget build(BuildContext context) {
    final upcomingSchedules = watchPropertyValue((HomeCounselorViewModel m) => m.upcomingSchedules);

    if (upcomingSchedules == null) {
      return const SizedBox.shrink();
    }

    return AppOutlinedButton(
      height: null,
      padding: const EdgeInsets.all(AppSizes.padding),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming (${upcomingSchedules.length})',
            style: AppTextStyle.bold(size: 16),
          ),
          const SizedBox(height: AppSizes.padding),
          Expanded(
            child: upcomingSchedules.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          upcomingSchedules.length,
                          (i) => _WaitingListTile(schedule: upcomingSchedules[i]),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      '(Empty)',
                      style: AppTextStyle.bold(size: 12, color: AppColors.blackLv2),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
      child: AppOutlinedButton(
        height: null,
        padding: const EdgeInsets.all(AppSizes.padding),
        buttonColor: AppColors.white,
        child: Row(
          children: [
            ProfilePhoto(
              size: 46,
              imgUrl: schedule.client!.imageUrl,
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
    );
  }
}
