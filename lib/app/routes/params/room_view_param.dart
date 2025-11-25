import '../../../data/models/user/user_model.dart';

class RoomViewParam {
  final String scheduleId;
  final String roomId;
  final UserModel client;
  final UserModel counselor;

  RoomViewParam({required this.scheduleId, required this.roomId, required this.client, required this.counselor});
}
