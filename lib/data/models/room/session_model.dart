class SessionModel {
  String? sdp;
  String? type;
  String? userId;
  String? userName;
  String? userImageUrl;
  bool? videoEnabled;
  bool? audioEnabled;
  String? dateCreated;

  SessionModel({
    this.sdp,
    this.type,
    this.userId,
    this.userName,
    this.userImageUrl,
    this.videoEnabled,
    this.audioEnabled,
    this.dateCreated,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    sdp: json["sdp"],
    type: json["type"],
    userId: json["user_id"],
    userName: json["user_name"],
    userImageUrl: json["user_image_url"],
    videoEnabled: json["video_enabled"],
    audioEnabled: json["audio_enabled"],
    dateCreated: json["date_created"],
  );

  Map<String, dynamic> toJson() => {
    "sdp": sdp,
    "type": type,
    "user_id": userId,
    "user_name": userName,
    "user_image_url": userImageUrl,
    "video_enabled": videoEnabled,
    "audio_enabled": audioEnabled,
    "date_created": dateCreated,
  };
}
