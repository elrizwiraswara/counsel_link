import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/common/result.dart';
import '../models/user/gender_model.dart';

abstract class ServiceTypeRepository {
  Future<Result<List<MenuItemModel>>> getAllServiceType();
  Future<Result<void>> createOrUpdateServiceType(MenuItemModel service);
  Future<Result<void>> deleteServiceType(MenuItemModel service);
}

class ServiceTypeRepositoryImpl extends ServiceTypeRepository {
  final FirebaseFirestore _firebaseFirestore;

  ServiceTypeRepositoryImpl(this._firebaseFirestore);

  @override
  Future<Result<List<MenuItemModel>>> getAllServiceType() async {
    try {
      final res = await _firebaseFirestore.collection('service_types').get();
      if (res.docs.isEmpty) return Result.success(data: []);
      final services = res.docs.map((doc) => MenuItemModel.fromJson(doc.data())).toList();
      return Result.success(data: services);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> createOrUpdateServiceType(MenuItemModel service) async {
    try {
      await _firebaseFirestore
          .collection('service_types')
          .doc(service.id)
          .set(service.toJson(), SetOptions(merge: true));
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteServiceType(MenuItemModel service) async {
    try {
      await _firebaseFirestore.collection('service_types').doc(service.id).delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
