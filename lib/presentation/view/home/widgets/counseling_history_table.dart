import 'package:excel_dart/excel_dart.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../core/const/constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/themes/app_text_style.dart';
import '../../../../core/utilities/date_time_formatter.dart';
import '../../../../data/models/schedule/schedule_model.dart';
import '../../../../data/models/user/user_model.dart';
import '../../../view_model/auth_view_model.dart';
import '../../../view_model/home_admin_view_model.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_filled_button.dart';
import '../../../widgets/app_fluent_button.dart';

class CounselingHistoryTable extends StatefulWidget with WatchItStatefulWidgetMixin {
  final List<ScheduleModel> data;

  const CounselingHistoryTable({super.key, required this.data});

  @override
  State<CounselingHistoryTable> createState() => _CounselingHistoryTableState();
}

class _CounselingHistoryTableState extends State<CounselingHistoryTable> {
  void _downloadData() async {
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['COUNSELING DATA'];

    excel.setDefaultSheet('COUNSELING DATA');

    for (int i = 0; i < 7; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = _excelCellHeader(i);
      cell.cellStyle = CellStyle(backgroundColorHex: "#B0B0B0");
    }

    for (int i = 0; i < widget.data.length; i++) {
      for (int j = 0; j < 7; j++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));

        cell.value = _excelCellValue(i, j, widget.data[i]);
      }
    }

    String now = DateTime.now().toIso8601String();
    String fileName = 'COUNSELING$now';

    excel.save(fileName: "$fileName.xlsx");
  }

  String _excelCellHeader(int i) {
    return i == 0
        ? 'NO'
        : i == 1
        ? 'COUNSELING TIME'
        : i == 2
        ? 'CLIENT'
        : i == 3
        ? 'COUNSELOR'
        : i == 4
        ? 'SERVICE TYPE'
        : i == 5
        ? 'SERVICE MEDIUM'
        : i == 6
        ? 'STATUS'
        : '';
  }

  dynamic _excelCellValue(int no, int j, ScheduleModel data) {
    return j == 0
        ? no + 1
        : j == 1
        ? data.dateTime
        : j == 2
        ? data.client?.name ?? ''
        : j == 3
        ? data.counselor?.name ?? ''
        : j == 4
        ? data.serviceType?.name ?? ''
        : j == 5
        ? data.medium?.name ?? ''
        : j == 6
        ? scheduleStatusName(data.status)
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.margin * 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Counseling History',
                style: AppTextStyle.bold(size: 16),
              ),
              AppFluentButton(
                text: 'Download Excel',
                onTap: () => _downloadData(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: AppSizes.screenWidth(context) > 1024 ? AppSizes.screenWidth(context) : 1024,
                child: Column(
                  children: [
                    const _TableHeader(),
                    widget.data.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.data.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, i) {
                              return _TableRow(
                                index: i,
                                schedule: widget.data[i],
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.padding * 2),
                            decoration: const BoxDecoration(color: AppColors.blackLv6),
                            child: const Center(
                              child: Text(
                                '(Empty)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: const BoxDecoration(color: AppColors.blackLv4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'NO',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'COUNSELING TIME',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'CLIENT',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'COUNSELOR',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'SERVICE TYPE',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'SERVICE MEDIUM',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'STATUS',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget with WatchItMixin {
  const _TableRow({
    required this.index,
    required this.schedule,
  });

  final int index;
  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final user = watchPropertyValue((AuthViewModel m) => m.user);

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(color: index.isEven ? AppColors.white : AppColors.blackLv6),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (index + 1).toString(),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateTimeFormatter.normalWithClock(schedule.dateTime!),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schedule.client?.name ?? '',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schedule.counselor?.name ?? '-',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schedule.serviceType?.name ?? '',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schedule.medium?.name ?? '',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold(size: 12),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scheduleStatusName(schedule.status),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bold(size: 12, color: scheduleStatusColor(schedule.status)),
                  ),
                  user?.role == UserRole.admin
                      ? Padding(
                          padding: const EdgeInsets.only(left: AppSizes.padding / 2),
                          child: AppFluentButton(
                            text: 'Change',
                            onTap: () {
                              AppDialog.show(
                                title: 'Change Status',
                                child: _StatusActionDialog(schedule: schedule),
                                showButtons: false,
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusActionDialog extends StatelessWidget {
  const _StatusActionDialog({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final model = di<HomeAdminViewModel>();

    model.selectedSchedule = schedule;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropDown<ScheduleStatus>(
            labelText: 'Change Status',
            selectedValue: model.selectedSchedule?.status,
            dropdownItems: List.generate(
              ScheduleStatus.values.length,
              (i) => DropdownMenuItem<ScheduleStatus>(
                value: ScheduleStatus.values[i],
                child: Text(scheduleStatusName(ScheduleStatus.values[i])),
              ),
            ),
            onChanged: model.onChangedScheduleStatus,
          ),
          const SizedBox(height: 18),
          AppFilledButton(
            text: 'Submit',
            onTap: () {
              Navigator.pop(context);
              model.updateSchedule();
            },
          ),
        ],
      ),
    );
  }
}
