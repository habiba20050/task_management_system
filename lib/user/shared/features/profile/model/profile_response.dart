import 'package:equatable/equatable.dart';

class ProfileResponse extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? jobTitle;
  final String? department;
  final String? phoneNumber;
  final String role;

  const ProfileResponse({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.jobTitle,
    this.department,
    this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'department': department,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: (json['id'] ?? json['nameid'] ?? '').toString(),
      username: (json['username'] ?? json['unique_name'] ?? '') as String,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['FullName'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  @override
  List<Object?> get props =>
      [id, username, email, fullName, jobTitle, department, phoneNumber, role];
}
