import 'package:flutter/material.dart';

import '../../core/common/result.dart';
import '../../core/const/constants.dart';
import '../../data/models/schedule/schedule_model.dart';
import '../../data/models/user/gender_model.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/service_type_repository.dart';
import 'auth_view_model.dart';

class HomeClientViewModel extends ChangeNotifier {
  final ServiceTypeRepository serviceTypeRepository;
  final ScheduleRepository scheduleRepository;
  final AuthViewModel authViewModel;

  HomeClientViewModel({
    required this.serviceTypeRepository,
    required this.scheduleRepository,
    required this.authViewModel,
  });

  ScheduleModel? currentSchedule;
  List<ScheduleModel>? scheduleHistory = [];

  List<MenuItemModel> allServiceType = [];

  MenuItemModel selectedCounselingMedium = conselingMedium.first;
  MenuItemModel? selectedServiceType;
  String? selectedDateTime;

  void resetCreateSceduleState() {
    selectedCounselingMedium = conselingMedium.first;
    selectedServiceType = null;
    selectedDateTime = null;
  }

  void init() {
    _getServiceTypes();
    _scheduleListener();
  }

  void _scheduleListener() {
    scheduleRepository.scheduleListener().listen((data) {
      getCurrentSchedule();
      getScheduleHistory();
    });
  }

  void _getServiceTypes() async {
    final res = await serviceTypeRepository.getAllServiceType();

    if (res.data == null || res.data!.isEmpty) {
      allServiceType = [MenuItemModel(name: '(Any)')];
      selectedServiceType = allServiceType.first;
      notifyListeners();
      return;
    }

    allServiceType = res.data ?? [];
    selectedServiceType = allServiceType.first;
    notifyListeners();
  }

  void getCurrentSchedule() async {
    if (authViewModel.user?.id == null) throw Exception('Unauthenticated!');

    final res = await scheduleRepository.getUserCurrentSchedule(authViewModel.user!.id!);

    currentSchedule = res.data;
    notifyListeners();
  }

  Future<void> getScheduleHistory() async {
    if (authViewModel.user?.id == null) throw Exception('Unauthenticated!');

    final res = await scheduleRepository.getClientScheduleHistory(authViewModel.user!.id!);

    if (res.data == null || res.data!.isEmpty) {
      scheduleHistory = [];
      notifyListeners();
      return;
    }

    scheduleHistory = res.data;
    scheduleHistory?.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    notifyListeners();
  }

  Future<Result<void>> createSchedule() async {
    if (authViewModel.user?.id == null) throw Exception('Unauthenticated!');

    var schedule = ScheduleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medium: selectedCounselingMedium,
      serviceType: selectedServiceType,
      client: authViewModel.user!,
      counselor: null,
      status: ScheduleStatus.created,
      dateTime: selectedDateTime,
      dateCreated: DateTime.now().toIso8601String(),
      roomId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    final res = await scheduleRepository.createOrUpdateSchedule(schedule);
    if (res.isFailure) return Result.failure(error: res.error!);

    currentSchedule = schedule;
    notifyListeners();

    return Result.success(data: null);
  }

  Future<Result<void>> cancelSchedule() async {
    if (currentSchedule == null) throw Exception('currentSchedule null');

    currentSchedule!.status = ScheduleStatus.cancelled;

    final res = await scheduleRepository.createOrUpdateSchedule(currentSchedule!);
    if (res.isFailure) return Result.failure(error: res.error!);

    currentSchedule = null;
    notifyListeners();

    return Result.success(data: null);
  }

  void onChangedMedium(dynamic value) {
    selectedCounselingMedium = conselingMedium.firstWhere((e) => e.id == value);
    notifyListeners();
  }

  void onChangedServiceType(dynamic value) {
    selectedServiceType = allServiceType.firstWhere((e) => e.id == value);
    notifyListeners();
  }

  void onChangedDate(DateTime value) {
    selectedDateTime = value.toIso8601String();
    notifyListeners();
  }
}
