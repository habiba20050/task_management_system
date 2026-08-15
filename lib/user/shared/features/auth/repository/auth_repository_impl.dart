import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../core/network/mock_database.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/user_model.dart';
import '../service/auth_api.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._authApi, this._secureStorage);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    // Intercept with MockDatabase for demo accounts or offline usability
    try {
      final mockUser = MockDatabase.instance.login(request.identifier, request.password);
      if (mockUser != null) {
        final user = UserModel(
          id: mockUser.id,
          email: mockUser.email,
          username: mockUser.email.split('@')[0],
          fullName: mockUser.fullName,
          role: mockUser.role,
        );
        final response = LoginResponse(
          accessToken: 'mock_token_${mockUser.role}',
          user: user,
        );

        await _secureStorage.write(
          key: 'access_token',
          value: response.accessToken,
        );
        
        await _secureStorage.write(
          key: 'user_role',
          value: mockUser.role,
        );

        await _secureStorage.write(
          key: 'user_email',
          value: mockUser.email,
        );

        return response;
      }
    } catch (e) {
      // Fallback to real API if not in the mock database
      try {
        final response = await _authApi.login(request);
        await _secureStorage.write(
          key: 'access_token',
          value: response.accessToken,
        );
        if (response.user != null) {
          await _secureStorage.write(
            key: 'user_role',
            value: response.user!.role,
          );
          await _secureStorage.write(
            key: 'user_email',
            value: response.user!.email,
          );
        }
        return response;
      } catch (_) {
        rethrow;
      }
    }
    throw Exception('Login failed.');
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_role');
    await _secureStorage.delete(key: 'user_email');
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Intercept/mock forgot password
    final exists = MockDatabase.instance.users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (!exists) {
      throw Exception('No account found with this email.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    // Reset password locally
    final idx = MockDatabase.instance.users.indexWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (idx == -1) {
      throw Exception('User not found.');
    }
  }
}
