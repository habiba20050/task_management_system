import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/features/teams/cubit/teams_cubit.dart';
import '../../../../../../core/network/mock_database.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/colors/app_colors.dart';

class AssignMemberToTeamDialogWidget extends StatefulWidget {
  final String? initialEmployeeId;
  final String? initialTeamId;

  const AssignMemberToTeamDialogWidget({
    super.key,
    this.initialEmployeeId,
    this.initialTeamId,
  });

  static void show(
    BuildContext context,
    TeamsCubit cubit, {
    String? initialEmployeeId,
    String? initialTeamId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: AssignMemberToTeamDialogWidget(
          initialEmployeeId: initialEmployeeId,
          initialTeamId: initialTeamId,
        ),
      ),
    );
  }

  @override
  State<AssignMemberToTeamDialogWidget> createState() => _AssignMemberToTeamDialogWidgetState();
}

class _AssignMemberToTeamDialogWidgetState extends State<AssignMemberToTeamDialogWidget> {
  String? _selectedEmployeeId;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.initialEmployeeId;
    _selectedTeamId = widget.initialTeamId;
  }

  List<MockUser> get _employees {
    final db = MockDatabase.instance;
    final authState = context.read<AuthCubit>().state;
    final managerId = authState is AuthSuccess ? authState.user.id : '1';
    final allSubIds = db.teams
        .where((t) => t.managerId == managerId)
        .expand((t) => [...t.memberIds, t.leaderId])
        .toSet();
    return db.users
        .where((u) => allSubIds.contains(u.id))
        .where((u) => u.role == 'Team Leader' || u.role == 'Team Member')
        .toList();
  }

  List<MockTeam> get _teams {
    final db = MockDatabase.instance;
    final authState = context.read<AuthCubit>().state;
    final managerId = authState is AuthSuccess ? authState.user.id : '1';
    return db.teams.where((t) => t.managerId == managerId).toList();
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  String _teamNameFor(String userId) {
    final db = MockDatabase.instance;
    final team = db.teams.firstWhere(
      (t) => t.memberIds.contains(userId) || t.leaderId == userId,
      orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
    );
    return team.id.isEmpty ? 'Not in a team'.tr(context) : team.name;
  }

  void _handleSubmit() {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an employee.'.tr(context))),
      );
      return;
    }
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a team.'.tr(context))),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final managerId = authState is AuthSuccess ? authState.user.id : '1';

    context.read<TeamsCubit>().assignMemberToTeam(
          memberId: _selectedEmployeeId!,
          teamId: _selectedTeamId!,
          managerId: managerId,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee assigned to team successfully.'.tr(context)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = _employees;
    final teams = _teams;
    final selectedEmployee = employees.firstWhere(
      (u) => u.id == _selectedEmployeeId,
      orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''),
    );
    final selectedTeam = teams.firstWhere(
      (t) => t.id == _selectedTeamId,
      orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                // Employee
                _buildFieldLabel(Icons.person_outline, 'Employee'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedEmployeeId,
                  isExpanded: true,
                  hint: Text(
                    'Select an employee...'.tr(context),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  decoration: _buildInputDecoration(''),
                  items: employees
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Row(
                              children: [
                                _buildAvatar(e.fullName, 30, AppColors.primary),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    e.fullName,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedEmployeeId = val),
                ),
                const SizedBox(height: 22),

                // Team
                _buildFieldLabel(Icons.groups_outlined, 'Team'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTeamId,
                  isExpanded: true,
                  hint: Text(
                    'Select a team...'.tr(context),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  decoration: _buildInputDecoration(''),
                  items: teams
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Row(
                              children: [
                                _buildAvatar(t.name, 30, AppColors.aituRed),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    t.name,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTeamId = val),
                ),
                const SizedBox(height: 22),

                // Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(
                        selectedEmployee.id.isEmpty ? '?' : selectedEmployee.fullName,
                        40,
                        AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedEmployee.id.isEmpty
                                  ? 'No employee selected'.tr(context)
                                  : selectedEmployee.fullName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedEmployee.id.isEmpty
                                  ? 'No employee selected'.tr(context)
                                  : '${'Current team'.tr(context)}: ${_teamNameFor(selectedEmployee.id)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedTeam.id.isEmpty
                                  ? 'No team selected'.tr(context)
                                  : '${'Will be added to'.tr(context)} ${selectedTeam.name} (${selectedTeam.memberIds.length} members)',
                              style: TextStyle(
                                fontSize: 11,
                                color: selectedTeam.id.isEmpty ? AppColors.textSecondary : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Cancel and Submit buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Cancel'.tr(context),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSubmitButton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign to Team'.tr(context),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add an employee to one of your teams.'.tr(context),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label.tr(context),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String name, double size, Color color) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: color,
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _handleSubmit,
          child: Center(
            child: Text(
              'Assign'.tr(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
