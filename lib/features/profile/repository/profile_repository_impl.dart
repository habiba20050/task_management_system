import '../../../core/network/mock_database.dart';
import '../../../core/storage/local_storage.dart';
import '../model/profile_response.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final MockDatabase _db = MockDatabase.instance;

  ProfileRepositoryImpl();

  Future<String> _getCurrentUserId() async {
    final userId = LocalStorage.getString('current_user_id');
    if (userId == null || userId.isEmpty) {
      return '1'; // Default to admin user
    }
    return userId;
  }

  @override
  Future<ProfileResponse> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    final userId = await _getCurrentUserId();
    final user = _db.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => _db.users.first,
    );

    return ProfileResponse(
      id: user.id,
      username: user.fullName.toLowerCase().replaceAll(' ', '.'),
      email: user.email,
      fullName: user.fullName,
      jobTitle: user.role,
      department: user.department,
      phoneNumber: user.phone,
      role: user.role,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // Mock password change - just return success
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Password fields cannot be empty');
    }
  }

  @override
  Future<ProfileResponse> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobTitle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    final userId = await _getCurrentUserId();
    final idx = _db.users.indexWhere((u) => u.id == userId);
    
    if (idx != -1) {
      final user = _db.users[idx];
      _db.users[idx] = MockUser(
        id: user.id,
        email: email.isNotEmpty ? email : user.email,
        fullName: fullName.isNotEmpty ? fullName : user.fullName,
        role: user.role,
        department: user.department,
        phone: phoneNumber.isNotEmpty ? phoneNumber : user.phone,
        status: user.status,
        teamId: user.teamId,
        isActive: user.isActive,
        lastActive: user.lastActive,
        points: user.points,
        productivityScore: user.productivityScore,
        deadlineCommitment: user.deadlineCommitment,
        approvalRate: user.approvalRate,
        rejectionRate: user.rejectionRate,
        leaderEvaluation: user.leaderEvaluation,
        finalScore: user.finalScore,
      );
      await _db.save();
    }

    return getProfile();
  }
}
