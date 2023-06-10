import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/articles/blocs/tags_state.dart';

import '../models/tag.dart';

class TagsBloc extends Cubit<TagState> {
  TagsBloc() : super(TagState());

  initialize() async {
    await getTags();
  }

  Future<void> getTags() async {
    final List<Tag> tags = [];
    final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.deepPurple, Colors.yellow, Colors.pinkAccent, Colors.brown];
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('Tags').get();
      if (snapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> allData = snapshot.docs.toList();
        for (int i = 0; i < allData.length; i++) {
          Tag test = Tag(title: allData[i]['name'], color: colors[i], id: allData[i]['id']);
          tags.add(test);
        }
        emit(state.copyWith(tags: tags));
      } else {
        emit(state.copyWith(tags: [])); // No tags found
      }
    } catch (error) {
      print('Error fetching tags: $error');
      emit(state.copyWith(tags: [])); // Error occurred while fetching tags
    }
  }
}
