import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatar;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.avatar,
    required this.role,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatar,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'avatar': avatar,
      'role': role,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  @override
  List<Object?> get props => [id, email, username, fullName, avatar, role];
}
