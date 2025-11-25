import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../core/common/result.dart';

abstract class StorageRepository {
  Future<Result<String>> uploadUserPhoto(String phone, Uint8List data);
  Future<Result<String>> uploadProductImage(String productId, int imageIndex, String userId, String imagePath);
  Future<Result<String>> uploadTransferProofImage(String transactionId, String userId, String imagePath);
}

class StorageRepositoryImpl extends StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepositoryImpl(this._firebaseStorage);

  @override
  Future<Result<String>> uploadUserPhoto(String phone, Uint8List data) async {
    try {
      final ref = _firebaseStorage.ref().child('user_photos').child('$phone.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg', customMetadata: {'picked-file-path': phone});

      final taskSnapshot = await ref.putData(data, metadata);
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return Result.success(data: downloadUrl);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> uploadProductImage(String productId, int imageIndex, String userId, String imagePath) async {
    try {
      final ref = _firebaseStorage.ref().child('products').child(productId).child('ProductImage_$imageIndex.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': imagePath, 'user-id': userId},
      );

      final taskSnapshot = await ref.putFile(File(imagePath), metadata);
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return Result.success(data: downloadUrl);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> uploadTransferProofImage(String transactionId, String userId, String imagePath) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _firebaseStorage
          .ref()
          .child('transactions')
          .child(transactionId)
          .child('TransferProofImage_$timestamp.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': imagePath, 'user-id': userId},
      );

      final taskSnapshot = await ref.putFile(File(imagePath), metadata);
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return Result.success(data: downloadUrl);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
