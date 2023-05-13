import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserCustom {
  UserCustom({
    required this.name,
    required this.email,
    required this.password,
    this.id,
  });

  String name;
  String email;
  String password;
  int? id;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'id': id,
      };

  static UserCustom fromJson(Map<String, dynamic> json) => UserCustom(
        id: json['id'],
        name: json['name'],
        password: json['password'],
        email: json['email'],
      );
}
