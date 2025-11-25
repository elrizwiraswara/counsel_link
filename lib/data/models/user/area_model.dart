class AreaModel {
  String? id;
  String? name;

  AreaModel({
    this.id,
    this.name,
  });

  factory AreaModel.fromJson(Map<String, dynamic>? json) => AreaModel(
    id: json?["id"],
    name: json?["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
