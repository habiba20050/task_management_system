import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_state.dart';
import '../model/user_role_model.dart';


class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  List<UserRoleModel> _allUsers = [];
  String _currentSearchQuery = "";
  String _currentRoleFilter = "All";

  void fetchUsers() {
    emit(UsersLoading());
    // بيانات تجريبية تحاكي الموجود في الصورة تماماً لتشغيل الشاشة فوراً
    _allUsers = [
      UserRoleModel(id: '1', name: 'Dr. Ahmed Hassan', email: 'ahmed.hassan@aitu.edu.eg', username: '@ahmed.hassan', role: 'Admin', department: 'Computer Science', isActive: true, lastActive: 'Just now'),
      UserRoleModel(id: '2', name: 'Prof. Khalid Mansour', email: 'k.mansour@aitu.edu.eg', username: '@k.mansour', role: 'Manager', department: 'Engineering', isActive: true, lastActive: '2 hours ago'),
      UserRoleModel(id: '3', name: 'Sarah Ahmed', email: 'sarah.ahmed@aitu.edu.eg', username: '@sarah.ahmed', role: 'Member', department: 'Computer Science', isActive: true, lastActive: '5 min ago'),
      UserRoleModel(id: '4', name: 'Prof. Khalid Mansour', email: 'k.mansour@aitu.edu.eg', username: '@k.mansour', role: 'Manager', department: 'Engineering', isActive: false, lastActive: '2 hours ago'),
      UserRoleModel(id: '5', name: 'Sarah Ahmed', email: 'sarah.ahmed@aitu.edu.eg', username: '@sarah.ahmed', role: 'Member', department: 'Computer Science', isActive: true, lastActive: '5 min ago'),
    ];
    emit(UsersLoaded(allUsers: _allUsers, filteredUsers: _allUsers));
  }

  void searchUsers(String query) {
    _currentSearchQuery = query;
    _applyFilter();
  }

  void filterByRole(String role) {
    _currentRoleFilter = role;
    _applyFilter();
  }

  void _applyFilter() {
    if (state is UsersLoaded) {
      List<UserRoleModel> results = _allUsers;

      // 1. تطبيق فلتر الأدوار (Tabs)
      if (_currentRoleFilter != 'All') {
        results = results.where((u) => u.role == _currentRoleFilter).toList();
      }

      // 2. تطبيق فلتر السيرش
      if (_currentSearchQuery.isNotEmpty) {
        results = results.where((u) => 
          u.name.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_currentSearchQuery.toLowerCase())
        ).toList();
      }

      emit(UsersLoaded(allUsers: _allUsers, filteredUsers: results));
    }
  }
}