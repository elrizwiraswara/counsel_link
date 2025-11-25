import 'package:flutter/material.dart';

import '../../core/common/result.dart';
import '../../data/models/schedule/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/service_type_repository.dart';
import 'auth_view_model.dart';

class HomeCounselorViewModel extends ChangeNotifier {
  final ServiceTypeRepository serviceTypeRepository;
  final ScheduleRepository scheduleRepository;
  final AuthViewModel authViewModel;

  HomeCounselorViewModel({
    required this.serviceTypeRepository,
    required this.scheduleRepository,
    required this.authViewModel,
  });

  ScheduleModel? nearestSchedule;
  List<ScheduleModel>? upcomingSchedules = [];
  List<ScheduleModel>? scheduleHistory = [];

  void init() async {
    _scheduleListener();
  }

  void _scheduleListener() {
    scheduleRepository.scheduleListener().listen((data) {
      _getUpcomingSchedules();
      _getScheduleHistory();
    });
  }

  void _getUpcomingSchedules() async {
    if (authViewModel.user?.id == null) throw Exception('Unauthenticated!');

    final res = await scheduleRepository.getCounselorUpcomingSchedules(authViewModel.user!.id!);

    if (res.data == null || res.data!.isEmpty) {
      upcomingSchedules = [];
      nearestSchedule = null;
      notifyListeners();
      return;
    }

    upcomingSchedules = res.data;
    upcomingSchedules?.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    nearestSchedule = upcomingSchedules?.first;
    upcomingSchedules?.removeAt(0);
    notifyListeners();
  }

  void _getScheduleHistory() async {
    if (authViewModel.user?.id == null) throw Exception('Unauthenticated!');

    final res = await scheduleRepository.getCounselorScheduleHistory(authViewModel.user!.id!);

    if (res.data == null || res.data!.isEmpty) {
      scheduleHistory = [];
      notifyListeners();
      return;
    }

    scheduleHistory = res.data;
    scheduleHistory?.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    notifyListeners();
  }

  Future<Result<void>> closeConselingSession() async {
    if (nearestSchedule == null) throw Exception('nearestSchedule null');

    nearestSchedule!.status = ScheduleStatus.done;

    final res = await scheduleRepository.createOrUpdateSchedule(nearestSchedule!);
    if (res.isFailure) return Result.failure(error: res.error!);

    nearestSchedule = null;
    _getUpcomingSchedules();
    _getScheduleHistory();
    notifyListeners();

    return Result.success(data: null);
  }
}
