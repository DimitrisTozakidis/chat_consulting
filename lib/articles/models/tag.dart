import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Tag {
  Tag({
    required this.title,
    required this.id,
    required this.color
  });

  String title;
  int id;
  Color color;

}
