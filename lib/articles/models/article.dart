import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Article {
  Article({
    required this.title,
    this.description,
    this.id,
    this.tags= const [],
    this.isRead = false,
    this.writer,
  });

  String title;
  String? description;
  List <int> tags;
  String? id;
  bool isRead;
  String? writer;
}

