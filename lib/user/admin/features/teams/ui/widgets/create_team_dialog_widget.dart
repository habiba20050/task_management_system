import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/features/teams/cubit/teams_cubit.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';

class CreateTeamDialogWidget extends StatefulWidget {
  final TeamModel? teamToEdit;
  const CreateTeamDialogWidget({super.key, this.teamToEdit});

  static void show(
    BuildContext context,
    TeamsCubit cubit, {
    TeamModel? teamToEdit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: CreateTeamDialogWidget(teamToEdit: teamToEdit),
      ),
    );
  }

  @override
  State<CreateTeamDialogWidget> createState() => _CreateTeamDialogWidgetState();
}

class _CreateTeamDialogWidgetState extends State<CreateTeamDialogWidget> {
  final _formKey = GlobalKey<FormState>();

  final _teamNameController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedLeaderId;
  List<String> _selectedMemberIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.teamToEdit != null) {
      _teamNameController.text = widget.teamToEdit!.name;
      _selectedDepartment = widget.teamToEdit!.department;
      
      final db = MockDatabase.instance;
      final mockTeam = db.teams.firstWhere(
        (t) => t.id == widget.teamToEdit!.id,
        orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
      );
      if (mockTeam.id.isNotEmpty) {
        _selectedLeaderId = mockTeam.leaderId;
        _selectedMemberIds = List.from(mockTeam.memberIds);
      }
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final leaders = db.users.where((u) => u.role == 'Team Leader').toList();
    final members = db.users.where((u) => u.role == 'Team Member').toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Title and X close)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.teamToEdit != null ? 'Edit Team'.tr(context) : 'Create New Team'.tr(context),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.teamToEdit != null
                              ? 'Update team details, leader and members.'.tr(context)
                              : 'Set up a new team, assign a leader and select members.'.tr(context),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                const SizedBox(height: 20),

                // Team Name
                _buildFieldLabel('Team Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _teamNameController,
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                  decoration: _buildInputDecoration('e.g., Software Engineering Team'),
                  validator: (val) => val == null || val.isEmpty ? 'Team name is required'.tr(context) : null,
                ),
                const SizedBox(height: 20),

                // Department Dropdown
                _buildFieldLabel('Department'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  hint: Text(
                    'Select Department'.tr(context),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                  ),
                  decoration: _buildInputDecoration(''),
                  items: ['Computer Science', 'IT Services', 'CS Dept', 'Business', 'Math Dept', 'Engineering']
                      .map((label) => DropdownMenuItem(value: label, child: Text(label.tr(context))))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDepartment = val),
                  validator: (val) => val == null ? 'Department is required'.tr(context) : null,
                ),
                const SizedBox(height: 20),

                // Team Leader Dropdown
                _buildFieldLabel('Team Leader'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLeaderId,
                  hint: Text(
                    'Select a team leader...'.tr(context),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                  ),
                  decoration: _buildInputDecoration(''),
                  items: leaders
                      .map((l) => DropdownMenuItem(value: l.id, child: Text(l.fullName)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLeaderId = val),
                  validator: (val) => val == null ? 'Team leader is required'.tr(context) : null,
                ),
                const SizedBox(height: 20),

                // Members Multi-Select Checkboxes
                _buildFieldLabel('Team Members'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: members.map((m) {
                        final isChecked = _selectedMemberIds.contains(m.id);
                        return CheckboxListTile(
                          title: Text(m.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(m.email, style: const TextStyle(fontSize: 12)),
                          value: isChecked,
                          activeColor: const Color(0xFF0F4C81),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedMemberIds.add(m.id);
                              } else {
                                _selectedMemberIds.remove(m.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Cancel and Submit buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel'.tr(context),
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedMemberIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select at least one team member.'.tr(context))),
                              );
                              return;
                            }

                            final name = _teamNameController.text;
                            final dept = _selectedDepartment ?? 'Computer Science';
                            final leaderUser = db.users.firstWhere((u) => u.id == _selectedLeaderId);

                            // Get current manager ID
                            final authState = context.read<AuthCubit>().state;
                            final managerId = authState is AuthSuccess ? authState.user.id : '2';

                            final newTeam = TeamModel(
                              id: widget.teamToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              name: name,
                              department: dept,
                              leaderName: leaderUser.fullName,
                              leaderInitials: leaderUser.fullName
                                  .split(' ')
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              membersCount: _selectedMemberIds.length,
                              totalTasks: widget.teamToEdit?.totalTasks ?? 0,
                              completedTasks: widget.teamToEdit?.completedTasks ?? 0,
                            );

                            if (widget.teamToEdit != null) {
                              context.read<TeamsCubit>().updateTeam(
                                    newTeam,
                                    _selectedMemberIds,
                                    managerId,
                                    _selectedLeaderId!,
                                  );
                            } else {
                              context.read<TeamsCubit>().addTeam(
                                    newTeam,
                                    _selectedMemberIds,
                                    managerId,
                                    _selectedLeaderId!,
                                  );
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C81),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          (widget.teamToEdit != null ? 'Save Changes' : 'Create Team').tr(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }
}
