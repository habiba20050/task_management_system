import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_state.dart';
import '../model/user_role_model.dart';
import '../../../../core/network/mock_database.dart';


class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  List<UserRoleModel> _allUsers = [];
  String _currentSearchQuery = "";
  String _currentRoleFilter = "All";

  void fetchUsers() {
    emit(UsersLoading());
    final dbUsers = MockDatabase.instance.users;
    _allUsers = dbUsers.map((u) => UserRoleModel(
      id: u.id,
      name: u.fullName,
      email: u.email,
      username: '@${u.email.split('@').first}',
      role: u.role,
      department: u.department,
      isActive: u.isActive,
      lastActive: u.lastActive,
    )).toList();
    _applyFilter();
  }

  void searchUsers(String query) {
    _currentSearchQuery = query;
    _applyFilter();
  }

  void filterByRole(String role) {
    _currentRoleFilter = role;
    _applyFilter();
  }

  void updateUser(UserRoleModel user) {
    final db = MockDatabase.instance;
    final idx = db.users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      final updatedUser = MockUser(
        id: user.id,
        email: user.email,
        fullName: user.name,
        role: user.role,
        department: user.department,
        isActive: user.isActive,
        lastActive: user.lastActive,
        points: db.users[idx].points,
        productivityScore: db.users[idx].productivityScore,
        deadlineCommitment: db.users[idx].deadlineCommitment,
        approvalRate: db.users[idx].approvalRate,
        rejectionRate: db.users[idx].rejectionRate,
        leaderEvaluation: db.users[idx].leaderEvaluation,
        finalScore: db.users[idx].finalScore,
      );
      db.editUser(updatedUser);
      fetchUsers();
    }
  }

  void deleteUser(String id) {
    MockDatabase.instance.deleteUser(id);
    fetchUsers();
  }

  void _applyFilter() {
    // If the state is not loaded, we start with the full list
    List<UserRoleModel> results = _allUsers;

    // 1. apply role filter
    if (_currentRoleFilter != 'All') {
      final dbRole = _currentRoleFilter == 'Member' ? 'Team Member' : _currentRoleFilter;
      results = results.where((u) => u.role == dbRole).toList();
    }

    // 2. apply search filter
    if (_currentSearchQuery.isNotEmpty) {
      results = results.where((u) => 
        u.name.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
        u.email.toLowerCase().contains(_currentSearchQuery.toLowerCase())
      ).toList();
    }

    emit(UsersLoaded(allUsers: _allUsers, filteredUsers: results));
  }
}