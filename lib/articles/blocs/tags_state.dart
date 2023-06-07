import '../models/tag.dart';

class TagState {
  TagState({this.tags = const []});

  List<Tag> tags;

  TagState copyWith({List<Tag>? tags}) {
    return TagState(tags: tags ?? this.tags);
  }
}
