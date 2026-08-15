import '../model/login_request.dart';
import '../model/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
