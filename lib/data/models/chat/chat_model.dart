class ChatModel {
  int? id;
  String? userId;
  String? message;
  String? dateCreated;

  ChatModel({
    this.id,
    this.userId,
    this.message,
    this.dateCreated,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json["id"],
    userId: json["user_id"],
    message: json["message"],
    dateCreated: json["date_created"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "message": message,
    "date_created": dateCreated,
  };
}
