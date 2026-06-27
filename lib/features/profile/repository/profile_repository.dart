import '../model/profile_response.dart';

abstract class ProfileRepository {
  Future<ProfileResponse> getProfile();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<ProfileResponse> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobTitle,
  });
}
