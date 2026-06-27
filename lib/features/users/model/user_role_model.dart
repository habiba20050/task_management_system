class UserRoleModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String role; // Admin, Manager, Member
  final String department;
  final bool isActive;
  final String lastActive;

  UserRoleModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.department,
    required this.isActive,
    required this.lastActive,
  });

  String get initials {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}