import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/params/room_view_param.dart';
import '../../core/common/result.dart';
import '../../core/utilities/console_logger.dart';
import '../../data/models/chat/chat_model.dart';
import '../../data/models/room/ice_candidate_model.dart';
import '../../data/models/room/room_model.dart';
import '../../data/models/room/session_model.dart';
import '../../data/models/schedule/schedule_model.dart';
import '../../data/models/user/user_model.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../widgets/app_dialog.dart';
import 'auth_view_model.dart';

class RoomViewModel extends ChangeNotifier {
  final ScheduleRepository scheduleRepository;
  final RoomRepository roomRepository;
  final AuthViewModel authViewModel;

  RoomViewModel({
    required this.scheduleRepository,
    required this.roomRepository,
    required this.authViewModel,
  });

  RTCPeerConnection? _peerConnections;

  RTCVideoRenderer localStream = RTCVideoRenderer();
  RTCVideoRenderer remoteStream = RTCVideoRenderer();

  String? _roomId;
  String? _scheduleId;
  UserModel? user;
  UserModel? opponentUser;

  List<ChatModel> chats = [];

  bool localVideoEnabled = true;
  bool localAudioEnabled = true;

  bool remoteVideoEnabled = true;
  bool remoteAudioEnabled = true;

  var localObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  var remoteObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;

  StreamSubscription? _roomListener;
  StreamSubscription? _iceCandidatesListener;
  StreamSubscription? _chatsListener;

  Future<void> init(RoomViewParam param) async {
    final currentUser = authViewModel.user;
    if (currentUser == null) throw Exception('Unauthenticated');

    _scheduleId = param.scheduleId;
    _roomId = param.roomId;

    if (currentUser.id == param.client.id) {
      user = param.client;
      opponentUser = param.counselor;
    } else {
      user = param.counselor;
      opponentUser = param.client;
    }

    await _initCall();
  }

  Future<void> resetStates() async {
    if (remoteStream.srcObject != null) {
      _peerConnections?.removeStream(remoteStream.srcObject!);
      remoteStream.srcObject = null;
    }

    if (localStream.srcObject != null) {
      _peerConnections?.removeStream(localStream.srcObject!);
      localStream.srcObject = null;
    }

    await _peerConnections?.restartIce();
    await _peerConnections?.close();
    await _roomListener?.cancel();
    await _iceCandidatesListener?.cancel();
    await _chatsListener?.cancel();

    _peerConnections = null;
    _roomListener = null;
    _iceCandidatesListener = null;
    _chatsListener = null;
    chats.clear();
    remoteVideoEnabled = true;
    remoteAudioEnabled = true;
    cl('[closeCall].closed');
  }

  Future<void> _initCall() async {
    // Ensure states are reset
    await resetStates();

    final resRoom = await _initRoom();

    if (resRoom.isFailure) {
      return AppDialog.showError(
        title: resRoom.title,
        message: resRoom.message,
        error: resRoom.error?.toString(),
        buttonText: 'Back',
        onTap: (context) => context.go('/home'),
      );
    }

    final resRtc = await _initRTC();

    if (resRtc.isFailure) {
      return AppDialog.showError(
        title: resRtc.title,
        message: resRtc.message,
        error: resRtc.error?.toString(),
        buttonText: 'Back',
        onTap: (context) => context.go('/home'),
      );
    }

    final resOffer = await _createOrAnswerCall();

    if (resOffer.isFailure) {
      return AppDialog.showError(
        title: resOffer.title,
        message: resOffer.message,
        error: resOffer.error?.toString(),
        buttonText: 'Back',
        onTap: (context) => context.go('/home'),
      );
    }

    _listenRoom();
    _listenIceCandidates();
    _listenChats();
  }

  Future<Result<void>> _initRoom() async {
    if (_roomId == null || _scheduleId == null) {
      throw Exception('Required param null');
    }

    final scheduleRes = await scheduleRepository.getSchedule(_scheduleId!);
    if (scheduleRes.isFailure) return Result.failure(error: scheduleRes.error!);

    final status = scheduleRes.data?.status;
    final isClosed =
        status == ScheduleStatus.unconfirmed || status == ScheduleStatus.done || status == ScheduleStatus.cancelled;

    if (isClosed) {
      return Result.failure(
        title: 'Session Has Been Closed',
        message: 'Thank you for using our services',
        error: 'closed',
      );
    }

    return Result.success(data: null);
  }

  Future<Result<void>> _initRTC() async {
    try {
      // Init Peer
      await _createRTCPeerConnection();

      // Init local stream
      await localStream.initialize();
      await _loadLocalMediaStream();

      // Init remote stream
      await remoteStream.initialize();

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<void> _createRTCPeerConnection() async {
    final config = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
        {'url': 'stun:stun1.l.google.com:19302'},
        {'url': 'stun:stun2.l.google.com:19302'},
        {'url': 'stun:stun3.l.google.com:19302'},
        {'url': 'stun:stun4.l.google.com:19302'},
      ],
    };

    final constraints = <String, dynamic>{
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      'optional': [],
    };

    _peerConnections = await createPeerConnection(config, constraints);

    _peerConnections?.onIceCandidate = (candidate) async {
      await _sendIceCandidate(candidate);
    };

    _peerConnections?.onAddStream = (stream) {
      cl('[pc.onAddStream].stream = ${stream.id}');
    };

    _peerConnections?.onConnectionState = (state) async {
      cl('[pc.onConnectionState].state: $state');

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        await resetStates();
        await _resetSession();
        await _resetIceCandidates();
        await _initCall();
      }
    };

    _peerConnections?.onSignalingState = (state) {
      cl('[pc.onSignalingState].state: $state');
    };

    _peerConnections?.onIceConnectionState = (state) async {
      cl('[pc.onIceConnectionState].state: $state');
    };
  }

  Future<void> _loadLocalMediaStream() async {
    final constraints = <String, dynamic>{'audio': true, 'video': true};

    final stream = await navigator.mediaDevices.getUserMedia(constraints);

    localStream.srcObject = stream;
    _peerConnections?.addStream(stream);
    notifyListeners();

    cl('[_loadLocalMediaStream] added local stream. ownerTag: ${stream.ownerTag}');
  }

  Future<Result<void>> _sendIceCandidate(RTCIceCandidate candidate) async {
    return await roomRepository.setRoomIceCandidate(
      _roomId!,
      IceCandidateModel(
        candidate: candidate.candidate,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
        userId: user?.id,
        dateCreated: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<Result<void>> _createOrAnswerCall() async {
    final roomRes = await roomRepository.getRoom(_roomId!);
    if (roomRes.isFailure) return Result.failure(error: roomRes.error!);

    final offer = roomRes.data?.offer;

    if (offer == null || offer.userId == user?.id) {
      return await _createCall();
    } else {
      return await _answerCall(roomRes.data!.offer!);
    }
  }

  Future<Result<void>> _createCall() async {
    final sessionDesc = await _peerConnections?.createOffer();

    if (sessionDesc == null || sessionDesc.sdp == null) {
      return Result.failure(error: 'sessionDesc null');
    }

    cl('[_createCall].createOffer.sessionDesc: $sessionDesc');
    await _peerConnections?.setLocalDescription(sessionDesc);

    // Remove remote stream if exist
    if (remoteStream.srcObject != null) {
      _peerConnections?.removeStream(remoteStream.srcObject!);
      remoteStream.srcObject = null;
      notifyListeners();
    }

    await _resetSession();
    await _resetIceCandidates();

    final res = await roomRepository.setRoomSessionOffer(
      _roomId!,
      SessionModel(
        sdp: sessionDesc.sdp,
        type: sessionDesc.type,
        userId: user!.id,
        userName: user!.name,
        userImageUrl: user!.imageUrl,
        videoEnabled: localVideoEnabled,
        audioEnabled: localAudioEnabled,
        dateCreated: DateTime.now().toIso8601String(),
      ),
    );

    if (res.isFailure) return Result.failure(error: res.error!);

    return Result.success(data: null);
  }

  Future<Result<void>> _answerCall(SessionModel offer) async {
    try {
      await _receiveRemoteSdp(offer);

      final sessionDesc = await _peerConnections?.createAnswer();

      if (sessionDesc == null || sessionDesc.sdp == null) {
        ce('[_answerCall].createAnswer.sessionDesc null');
        return Result.failure(error: 'Failed to create answer');
      }

      cl('[_answerCall].createAnswer.sessionDesc: $sessionDesc');
      await _peerConnections?.setLocalDescription(sessionDesc);

      final res = await roomRepository.setRoomSessionAnswer(
        _roomId!,
        SessionModel(
          sdp: sessionDesc.sdp,
          type: sessionDesc.type,
          userId: user!.id,
          userName: user!.name,
          userImageUrl: user!.imageUrl,
          videoEnabled: localVideoEnabled,
          audioEnabled: localAudioEnabled,
          dateCreated: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<void> _receiveRemoteSdp(SessionModel session) async {
    if (_peerConnections?.signalingState == RTCSignalingState.RTCSignalingStateStable ||
        _peerConnections?.connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      cw('[_receiveRemoteSdp] already connected, skipped');
      return;
    }

    cl('[_receiveRemoteSdp].session: ${session.toJson()}');

    // Set remote sdp
    await _peerConnections?.setRemoteDescription(
      RTCSessionDescription(session.sdp, session.type),
    );

    // Set remote stream
    final streams = _peerConnections?.getRemoteStreams();
    if (streams?.isNotEmpty ?? false) {
      if (streams?.firstOrNull == null) return;
      cl('[_receiveRemoteSdp].added remote stream: ${streams?.firstOrNull?.toString()}');
      remoteStream.srcObject = streams!.first!;
      _peerConnections?.addStream(streams.first!);
      notifyListeners();
    }
  }

  Future<Result<void>> _resetSession() async {
    return await roomRepository.resetRoomSession(_roomId!);
  }

  Future<Result<void>> _resetIceCandidates() async {
    return await roomRepository.resetRoomIceCandidates(_roomId!);
  }

  Future<void> _listenRoom() async {
    _roomListener = roomRepository.roomListener(_roomId!).listen((event) async {
      if (event.data() == null) return;

      final data = RoomModel.fromJson(event.data()!);

      if (data.offer != null && data.offer!.userId != user?.id) {
        remoteAudioVideoController(data.offer!);
      } else if (data.answer != null && data.answer!.userId != user?.id) {
        remoteAudioVideoController(data.answer!);
        _receiveRemoteSdp(data.answer!);
      }
    });
  }

  Future<void> _listenIceCandidates() async {
    _iceCandidatesListener = roomRepository.iceCandidatesListener(_roomId!).listen((event) async {
      for (var e in event.docChanges) {
        if (e.type == DocumentChangeType.added) {
          final data = e.doc.data();

          if (data != null) {
            await _addCandidate(data);
          }
        }
      }
    });
  }

  Future<void> _listenChats() async {
    _chatsListener = roomRepository.chatsListener(_roomId!).listen((event) async {
      for (var e in event.docChanges) {
        if (e.type == DocumentChangeType.added) {
          final data = e.doc.data();

          if (data != null) {
            var chat = ChatModel.fromJson(data);
            if (chats.any((e) => e.id == chat.id)) return;
            chats.add(chat);
            chats.sort((a, b) {
              final dateA = DateTime.parse(a.dateCreated!);
              final dateB = DateTime.parse(b.dateCreated!);
              return dateA.compareTo(dateB);
            });
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> _addCandidate(Map<String, dynamic> data) async {
    if (_peerConnections?.connectionState == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
        _peerConnections?.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
      cw('[_addCandidate] signalingState closed, skipped');
      return;
    }

    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );

    final remoteDesc = await _peerConnections?.getRemoteDescription();
    if (remoteDesc == null) return;

    await _peerConnections!.addCandidate(candidate);
  }

  void localAudioVideoController(String kind, bool value) async {
    localStream.srcObject?.getTracks().forEach((e) {
      if (e.kind == kind) {
        e.enabled = value;
        if (kind == 'video') localVideoEnabled = value;
        if (kind == 'audio') localAudioEnabled = value;
      }
    });

    await roomRepository.setUserVideoAudioEnabled(
      roomId: _roomId!,
      userId: user!.id!,
      localVideoEnabled: localVideoEnabled,
      localAudioEnabled: localAudioEnabled,
    );

    notifyListeners();
  }

  void remoteAudioVideoController(SessionModel data) async {
    cl('[remoteAudioVideoController].remoteVideoEnabled: $remoteVideoEnabled, remoteAudioEnabled: $remoteAudioEnabled');
    remoteVideoEnabled = data.videoEnabled ?? false;
    remoteAudioEnabled = data.audioEnabled ?? false;
    notifyListeners();
  }

  void onTapLocalVideoFit() {
    if (localObjectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain) {
      localObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
    } else {
      localObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
    }
    notifyListeners();
  }

  void onTapRemoteVideoFit() {
    if (remoteObjectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain) {
      remoteObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
    } else {
      remoteObjectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
    }
    notifyListeners();
  }

  Future<Result<void>> onSubmitChat(String message) async {
    return await roomRepository.submitChatMessage(_roomId!, user!.id!, message);
  }
}
