import 'session_model.dart';

class RoomModel {
  SessionModel? offer;
  SessionModel? answer;

  RoomModel({
    this.offer,
    this.answer,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    offer: json["offer"] != null ? SessionModel.fromJson(json['offer']) : null,
    answer: json["answer"] != null ? SessionModel.fromJson(json['answer']) : null,
  );

  Map<String, dynamic> toJson() => {
    "offer": offer?.toJson(),
    "answer": answer?.toJson(),
  };
}
