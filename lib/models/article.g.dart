// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      title: json['title'] as String,
      description: json['description'] as String?,
      id: json['id'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      isRead: json['isRead'] as bool? ?? false,
      image: json['image'] as String,
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'tags': instance.tags,
      'id': instance.id,
      'isRead': instance.isRead,
      'image': instance.image,
    };
