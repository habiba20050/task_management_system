import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/change_password_request.dart';
import '../model/profile_response.dart';
import '../service/profile_api.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileApi;
  final FlutterSecureStorage _secureStorage;

  ProfileRepositoryImpl(this._profileApi, this._secureStorage);

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  @override
  Future<ProfileResponse> getProfile() async {
    return _profileApi.getProfile(await _getToken());
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await _profileApi.changePassword(await _getToken(), request);
  }

  @override
  Future<ProfileResponse> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobTitle,
  }) async {
    return _profileApi.updateProfile(
      token: await _getToken(),
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      jobTitle: jobTitle,
    );
  }
}
