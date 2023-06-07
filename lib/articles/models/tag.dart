import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';
@JsonSerializable()
class Tag {
  Tag({
    required this.title,
    required this.id,
    required this.color
  });

  String title;
  int id;
  String color;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
