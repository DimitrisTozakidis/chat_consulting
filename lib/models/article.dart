import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';
@JsonSerializable()
class Article {
  Article({
    required this.title,
    this.description,
    this.id,
    this.tags= const [],
    this.isRead = false,
    required this.image
  });

  String title;
  String? description;
  List <int> tags;
  int? id;
  bool isRead;
  final String image;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}

