import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/blocs/tags_state.dart';

import '../models/tag.dart';

class TagsBloc extends Cubit<TagState> {
  TagsBloc() : super(TagState());

  initialize() async {
    await getTags();
  }

  getTags() async {
    final List<Tag> tags = [];
    try {
      final dio = Dio();
      final response =  await dio.get('http://192.168.2.3:3000/tags');
      final List<dynamic> list = response.data;

      for (var element in list) {
        tags.add(Tag.fromJson(element));
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    emit(state.copyWith(tags: tags));
  }
}
