import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Message {
  Message({
    required this.text,
    required this.mine,
    required this.time
  });

  String text;
  bool mine;
  String time;
}
