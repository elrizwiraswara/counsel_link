import 'package:flutter/material.dart';

import '../../core/common/result.dart';
import '../../core/utilities/uid_generator.dart';
import '../../data/models/schedule/schedule_model.dart';
import '../../data/models/user/gender_model.dart';
import '../../data/models/user/user_model.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/service_type_repository.dart';
import '../../data/repositories/user_repository.dart';

class HomeAdminViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final ServiceTypeRepository serviceTypeRepository;
  final ScheduleRepository scheduleRepository;

  HomeAdminViewModel({
    required this.userRepository,
    required this.serviceTypeRepository,
    required this.scheduleRepository,
  });

  List<ScheduleModel>? allSchedule = [];
  List<ScheduleModel>? waitingConfirmSchedules = [];

  List<UserModel>? allCounselor = [];

  List<MenuItemModel>? allServiceType = [];

  ScheduleModel? selectedSchedule;
  UserModel? selectedCounselor;

  void init() {
    _scheduleListener();
    _getAllServiceType();
    getAllCounselor();
  }

  void _scheduleListener() {
    scheduleRepository.scheduleListener().listen((data) {
      _getAllSchedule();
    });
  }

  void _getAllServiceType() async {
    final res = await serviceTypeRepository.getAllServiceType();

    if (res.data == null || res.data!.isEmpty) {
      allServiceType = [];
      notifyListeners();
      return;
    }

    allServiceType = res.data;
    notifyListeners();
  }

  void _getAllSchedule() async {
    final res = await scheduleRepository.getAllSchedule();

    allSchedule = res.data;
    allSchedule?.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    // Waiting schedule
    waitingConfirmSchedules = allSchedule?.where((e) => e.status == ScheduleStatus.created).toList();

    waitingConfirmSchedules?.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    notifyListeners();
  }

  void getAllCounselor() async {
    final res = await userRepository.getAllCounselor();

    allCounselor = res.data;
    notifyListeners();
  }

  Future<Result<void>> createCounselor({required String phone, required String name}) async {
    if (!phone.startsWith('+')) {
      return Result.failure(
        title: 'Phone Number Not Valid',
        message: 'Please enter a valid phone number with country code. e.g. +62xxx',
        error: 'phone number format is not valid',
      );
    }

    // Check is user has been added into firestore
    final res = await userRepository.getUserByPhone(phone);
    if (res.isFailure) return Result.failure(error: res.error!);

    if (res.data != null) {
      return Result.failure(
        title: 'Phone Number Already Registered',
        message: 'Phone number you entered already registered!',
        error: 'user exist',
      );
    }

    var user = UserModel(
      id: UidGenerator.createUid(phone),
      phone: phone,
      name: name,
      role: UserRole.counselor,
      dateCreated: DateTime.now().toIso8601String(),
    );

    final createRes = await userRepository.createOrUpdateUser(user);
    if (createRes.isFailure) return Result.failure(error: createRes.error!);

    getAllCounselor();

    return Result.success(data: null);
  }

  Future<Result<void>> deleteCounselor(UserModel user) async {
    final res = await userRepository.deleteUser(user);
    if (res.isFailure) return Result.failure(error: res.error!);

    getAllCounselor();

    return Result.success(data: null);
  }

  Future<Result<void>> createOrUpdateServiceType({String? id, required String name}) async {
    var serviceType = MenuItemModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    final res = await serviceTypeRepository.createOrUpdateServiceType(serviceType);
    if (res.isFailure) return Result.failure(error: res.error!);

    _getAllServiceType();

    return Result.success(data: null);
  }

  Future<Result<void>> deleteServiceType(MenuItemModel serviceType) async {
    final res = await serviceTypeRepository.deleteServiceType(serviceType);
    if (res.isFailure) return Result.failure(error: res.error!);

    _getAllServiceType();

    return Result.success(data: null);
  }

  void onChangedAdminMessage(String val) {
    selectedSchedule?.adminMessage = val;
    notifyListeners();
  }


  void onChangedScheduleStatus(ScheduleStatus? val) {
    if (val != null) selectedSchedule?.status = val;
  }

  void onChangedScheduleConfirmation(ScheduleStatus? val) {
    selectedSchedule?.status = val;
    selectedCounselor = allCounselor?.firstOrNull;
    selectedSchedule?.counselor = selectedCounselor;
    notifyListeners();
  }

  void onChangedScheduleCounselor(String? val) {
    selectedCounselor = allCounselor?.firstWhere((e) => e.id == val);
    selectedSchedule?.counselor = selectedCounselor;
    notifyListeners();
  }

  void onChangedScheduleMessage(String val) {
    selectedSchedule?.adminMessage = val;
    notifyListeners();
  }

  Future<Result<void>> updateSchedule() async {
    if (selectedSchedule == null) return Result.failure(error: 'schedule null');

    final res = await scheduleRepository.createOrUpdateSchedule(selectedSchedule!);
    if (res.isFailure) return Result.failure(error: res.error!);

    _getAllSchedule();

    return Result.success(data: null);
  }
}
