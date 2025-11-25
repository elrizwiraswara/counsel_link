import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/common/result.dart';
import '../models/schedule/schedule_model.dart';

abstract class ScheduleRepository {
  Future<Result<void>> createOrUpdateSchedule(ScheduleModel schedule);
  Future<Result<List<ScheduleModel>>> getAllSchedule();
  Future<Result<ScheduleModel>> getSchedule(String scheduleId);
  Future<Result<ScheduleModel?>> getUserCurrentSchedule(String userId);
  Future<Result<List<ScheduleModel>>> getClientScheduleHistory(String userId);
  Future<Result<List<ScheduleModel>>> getCounselorUpcomingSchedules(String userId);
  Future<Result<List<ScheduleModel>>> getCounselorScheduleHistory(String userId);
  Stream<QuerySnapshot<Map<String, dynamic>>> scheduleListener();
}

class ScheduleRepositoryImpl extends ScheduleRepository {
  final FirebaseFirestore _firebaseFirestore;

  ScheduleRepositoryImpl(this._firebaseFirestore);

  @override
  Future<Result<void>> createOrUpdateSchedule(ScheduleModel schedule) async {
    try {
      await _firebaseFirestore.collection('schedules').doc(schedule.id).set(schedule.toJson(), SetOptions(merge: true));
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ScheduleModel>>> getAllSchedule() async {
    try {
      final res = await _firebaseFirestore.collection('schedules').get();
      if (res.docs.isEmpty) return Result.success(data: []);
      final schedules = res.docs.map((doc) => ScheduleModel.fromJson(doc.data())).toList();
      return Result.success(data: schedules);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ScheduleModel>> getSchedule(String scheduleId) async {
    try {
      final res = await _firebaseFirestore.collection('schedules').doc(scheduleId).get();
      if (res.data() == null) return Result.failure(error: 'Schedule not found');
      return Result.success(data: ScheduleModel.fromJson(res.data()!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ScheduleModel?>> getUserCurrentSchedule(String userId) async {
    try {
      final res = await _firebaseFirestore
          .collection('schedules')
          .where('client.id', isEqualTo: userId)
          .where(
            Filter.or(
              Filter('status', isEqualTo: ScheduleStatus.created.value),
              Filter('status', isEqualTo: ScheduleStatus.confirmed.value),
              Filter('status', isEqualTo: ScheduleStatus.unconfirmed.value),
            ),
          )
          .get();

      if (res.docs.isEmpty) return Result.success(data: null);

      final data = ScheduleModel.fromJson(res.docs.first.data());

      return Result.success(data: data);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ScheduleModel>>> getClientScheduleHistory(String userId) async {
    try {
      final res = await _firebaseFirestore
          .collection('schedules')
          .where('client.id', isEqualTo: userId)
          .where('status', isNotEqualTo: ScheduleStatus.created.value)
          .get();

      if (res.docs.isEmpty) return Result.success(data: []);
      final schedules = res.docs.map((doc) => ScheduleModel.fromJson(doc.data())).toList();
      return Result.success(data: schedules);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ScheduleModel>>> getCounselorUpcomingSchedules(String userId) async {
    try {
      final res = await _firebaseFirestore
          .collection('schedules')
          .where('counselor.id', isEqualTo: userId)
          .where('status', isEqualTo: ScheduleStatus.confirmed.value)
          .get();

      if (res.docs.isEmpty) return Result.success(data: []);
      final schedules = res.docs.map((doc) => ScheduleModel.fromJson(doc.data())).toList();
      return Result.success(data: schedules);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ScheduleModel>>> getCounselorScheduleHistory(String userId) async {
    try {
      final res = await _firebaseFirestore
          .collection('schedules')
          .where('counselor.id', isEqualTo: userId)
          .where('status', isNotEqualTo: ScheduleStatus.created.value)
          .get();

      if (res.docs.isEmpty) return Result.success(data: []);
      final schedules = res.docs.map((doc) => ScheduleModel.fromJson(doc.data())).toList();
      return Result.success(data: schedules);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> scheduleListener() {
    return _firebaseFirestore.collection('schedules').snapshots();
  }
}
