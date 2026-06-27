import '../models/user_model.dart';

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel? user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
    };
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ??
          json['token'] as String? ??
          '',
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
