import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/common/result.dart';
import '../models/room/ice_candidate_model.dart';
import '../models/room/room_model.dart';
import '../models/room/session_model.dart';

abstract class RoomRepository {
  Future<Result<RoomModel?>> getRoom(String roomId);
  Future<Result<void>> setRoomSessionOffer(String roomId, SessionModel session);
  Future<Result<void>> setRoomSessionAnswer(String roomId, SessionModel session);
  Future<Result<void>> setRoomIceCandidate(String roomId, IceCandidateModel candidate);
  Future<Result<void>> resetRoomSession(String roomId);
  Future<Result<void>> resetRoomIceCandidates(String roomId);
  Future<Result<void>> deleteRoom(String roomId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> roomListener(String roomId);
  Stream<QuerySnapshot<Map<String, dynamic>>> iceCandidatesListener(String roomId);
  Stream<QuerySnapshot<Map<String, dynamic>>> chatsListener(String roomId);
  Future<Result<void>> submitChatMessage(String roomId, String userId, String message);
  Future<Result<void>> setUserVideoAudioEnabled({
    required String roomId,
    required String userId,
    required bool localVideoEnabled,
    required bool localAudioEnabled,
  });
}

class RoomRepositoryImpl extends RoomRepository {
  final FirebaseFirestore _firebaseFirestore;

  RoomRepositoryImpl(this._firebaseFirestore);

  @override
  Future<Result<RoomModel?>> getRoom(String roomId) async {
    try {
      final data = await _firebaseFirestore.collection('rooms').doc(roomId).get();
      if (data.data() == null) return Result.success(data: null);
      return Result.success(data: RoomModel.fromJson(data.data()!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> setRoomSessionOffer(String roomId, SessionModel session) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).set(
        {'offer': session.toJson()},
        SetOptions(merge: true),
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> setRoomSessionAnswer(String roomId, SessionModel session) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).set(
        {'answer': session.toJson()},
        SetOptions(merge: true),
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> setRoomIceCandidate(String roomId, IceCandidateModel candidate) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).collection('candidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'user_id': candidate.userId,
        'date_created': DateTime.now().toIso8601String(),
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> resetRoomSession(String roomId) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).set(
        {'offer': null, 'answer': null},
        SetOptions(merge: true),
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> resetRoomIceCandidates(String roomId) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).collection('candidates').doc().delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteRoom(String roomId) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> roomListener(String roomId) {
    return _firebaseFirestore.collection('rooms').doc(roomId).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> iceCandidatesListener(String roomId) {
    return _firebaseFirestore.collection('rooms').doc(roomId).collection('candidates').snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> chatsListener(String roomId) {
    return _firebaseFirestore.collection('rooms').doc(roomId).collection('chats').snapshots();
  }

  @override
  Future<Result<void>> submitChatMessage(String roomId, String userId, String message) async {
    try {
      await _firebaseFirestore.collection('rooms').doc(roomId).collection('chats').add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'user_id': userId,
        'message': message,
        'date_created': DateTime.now().toIso8601String(),
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> setUserVideoAudioEnabled({
    required String roomId,
    required String userId,
    required bool localVideoEnabled,
    required bool localAudioEnabled,
  }) async {
    try {
      final room = _firebaseFirestore.collection('rooms').doc(roomId);
      final data = (await room.get()).data();

      if (data == null) return Result.failure(error: 'Room not found');

      if (data.containsKey('offer') && data['offer']['user_id'] == userId) {
        await room.set(
          {
            'offer': {
              'video_enabled': localVideoEnabled,
              'audio_enabled': localAudioEnabled,
            },
          },
          SetOptions(merge: true),
        );
      }

      if (data.containsKey('answer') && data['answer']['user_id'] == userId) {
        await room.set(
          {
            'answer': {
              'video_enabled': localVideoEnabled,
              'audio_enabled': localAudioEnabled,
            },
          },
          SetOptions(merge: true),
        );
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
