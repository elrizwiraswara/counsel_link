import '../user/gender_model.dart';
import '../user/user_model.dart';

class ScheduleModel {
  String? id;
  MenuItemModel? medium;
  MenuItemModel? serviceType;
  UserModel? client;
  UserModel? counselor;
  ScheduleStatus? status;
  String? dateTime;
  String? dateCreated;
  String? roomId;
  String? adminMessage;

  ScheduleModel({
    this.id,
    this.medium,
    this.serviceType,
    this.client,
    this.counselor,
    this.status,
    this.dateTime,
    this.dateCreated,
    this.roomId,
    this.adminMessage,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json["id"],
    medium: json["medium"] != null ? MenuItemModel?.fromJson(json["medium"]) : null,
    serviceType: json["service_type"] != null ? MenuItemModel?.fromJson(json["service_type"]) : null,
    client: json["client"] != null ? UserModel?.fromJson(json["client"]) : null,
    counselor: json["counselor"] != null ? UserModel?.fromJson(json["counselor"]) : null,
    status: json["status"] != null ? ScheduleStatus.fromValue(json["status"]) : null,
    dateTime: json["date_time"],
    dateCreated: json["date_created"],
    roomId: json["room_id"],
    adminMessage: json["admin_message"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "medium": medium?.toJson(),
    "service_type": serviceType?.toJson(),
    "client": client?.toJson(),
    "counselor": counselor?.toJson(),
    "status": status?.value,
    "date_time": dateTime,
    "date_created": dateCreated,
    "room_id": roomId,
    "admin_message": adminMessage,
  };
}

enum ScheduleStatus {
  created('created'),
  confirmed('confirmed'),
  unconfirmed('unconfirmed'),
  done('done'),
  cancelled('cancelled')
  ;

  final String value;
  const ScheduleStatus(this.value);

  static ScheduleStatus? fromValue(String? value) {
    return ScheduleStatus.values.where((e) => e.value == value).firstOrNull;
  }
}
