import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/common/result.dart';
import '../models/user/user_model.dart';

abstract class UserRepository {
  Future<Result<UserModel?>> getUser(String id);
  Future<Result<UserModel?>> getUserByPhone(String phone);
  Future<Result<List<UserModel>>> getAllCounselor();
  Future<Result<void>> createOrUpdateUser(UserModel user);
  Future<Result<void>> deleteUser(UserModel user);
}

class UserRepositoryImpl extends UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepositoryImpl(this._firebaseFirestore);

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      final res = await _firebaseFirestore.collection('users').doc(id).get();
      if (res.data() == null) return Result.success(data: null);
      return Result.success(data: UserModel.fromJson(res.data()!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUserByPhone(String phone) async {
    try {
      final res = await _firebaseFirestore.collection('users').where('phone', isEqualTo: phone).get();
      if (res.docs.isEmpty) return Result.success(data: null);
      return Result.success(data: UserModel.fromJson(res.docs.first.data()));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<UserModel>>> getAllCounselor() async {
    try {
      final res = await _firebaseFirestore.collection('users').where('role', isEqualTo: 'counselor').get();
      if (res.docs.isEmpty) return Result.success(data: []);
      final users = res.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      return Result.success(data: users);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> createOrUpdateUser(UserModel user) async {
    try {
      await _firebaseFirestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(UserModel user) async {
    try {
      await _firebaseFirestore.collection('users').doc(user.id).delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
