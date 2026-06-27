import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../service/auth_api.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._authApi, this._secureStorage);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _authApi.login(request);

    await _secureStorage.write(
      key: 'access_token',
      value: response.accessToken,
    );

    if (response.refreshToken != null) {
      await _secureStorage.write(
        key: 'refresh_token',
        value: response.refreshToken,
      );
    }

    return response;
  }

  @override
  Future<void> logout() async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      try {
        await _authApi.logout(token);
      } catch (_) {}
    }
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _authApi.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _authApi.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
