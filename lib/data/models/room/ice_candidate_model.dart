class IceCandidateModel {
  String? candidate;
  String? sdpMid;
  int? sdpMLineIndex;
  String? userId;
  String? dateCreated;

  IceCandidateModel({
    this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
    this.userId,
    this.dateCreated,
  });

  factory IceCandidateModel.fromJson(Map<String, dynamic> json) => IceCandidateModel(
    candidate: json["candidate"],
    sdpMid: json["sdp_mid"],
    sdpMLineIndex: json["sdp_m_line_index"],
    userId: json["user_id"],
    dateCreated: json["date_created"],
  );

  Map<String, dynamic> toJson() => {
    "candidate": candidate,
    "sdp_mid": sdpMid,
    "sdp_m_line_index": sdpMLineIndex,
    "user_id": userId,
    "date_created": dateCreated,
  };
}
