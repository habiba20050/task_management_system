import '../model/user_role_model.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}
class UsersLoading extends UsersState {}
class UsersLoaded extends UsersState {
  final List<UserRoleModel> allUsers;
  final List<UserRoleModel> filteredUsers;
  UsersLoaded({required this.allUsers, required this.filteredUsers});
}
class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}