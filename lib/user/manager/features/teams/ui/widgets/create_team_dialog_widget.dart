import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/features/teams/cubit/teams_cubit.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import '../../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/colors/app_colors.dart';

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
  final _memberSearchController = TextEditingController();
  String? _selectedLeaderId;
  List<String> _selectedMemberIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.teamToEdit != null) {
      _teamNameController.text = widget.teamToEdit!.name;

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
    _memberSearchController.dispose();
    super.dispose();
  }

  List<MockUser> get _filteredMembers {
    final db = MockDatabase.instance;
    final members = db.users.where((u) => u.role == 'Team Member').toList();
    final q = _memberSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return members;
    return members
        .where((m) => m.fullName.toLowerCase().contains(q) || m.email.toLowerCase().contains(q))
        .toList();
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one team member.'.tr(context))),
      );
      return;
    }

    final db = MockDatabase.instance;
    final name = _teamNameController.text;

    final authState = context.read<AuthCubit>().state;
    final managerId = authState is AuthSuccess ? authState.user.id : '2';
    final managerUser = db.users.firstWhere(
      (u) => u.id == managerId,
      orElse: () => MockUser(
        id: managerId,
        email: 'manager@aitu.edu',
        fullName: 'Manager',
        role: 'Manager',
        department: 'Computer Science',
      ),
    );
    final dept = managerUser.department.isEmpty ? 'Computer Science' : managerUser.department;

    final leaderUser = db.users.firstWhere((u) => u.id == _selectedLeaderId);

    final newTeam = TeamModel(
      id: widget.teamToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      department: dept,
      leaderName: leaderUser.fullName,
      leaderInitials: _initials(leaderUser.fullName),
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

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final leaders = db.users.where((u) => u.role == 'Team Leader').toList();
    final members = _filteredMembers;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Team Name
                  _buildFieldLabel(Icons.groups_outlined, 'Team Name'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _teamNameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    decoration: _buildInputDecoration('e.g., Software Engineering Team'),
                    validator: (val) => val == null || val.isEmpty ? 'Team name is required'.tr(context) : null,
                  ),
                  const SizedBox(height: 22),

                  // Team Leader Dropdown
                  _buildFieldLabel(Icons.person_outline, 'Team Leader'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedLeaderId,
                    isExpanded: true,
                    hint: Text(
                      'Select a team leader...'.tr(context),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    decoration: _buildInputDecoration(''),
                    items: leaders
                        .map((l) => DropdownMenuItem(
                              value: l.id,
                              child: Row(
                                children: [
                                  _buildAvatar(l.fullName, 30, AppColors.primary),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      l.fullName,
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedLeaderId = val),
                    validator: (val) => val == null ? 'Team leader is required'.tr(context) : null,
                  ),
                  const SizedBox(height: 22),

                  // Members Multi-Select
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel(Icons.group_add_outlined, 'Team Members'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedMemberIds.length} selected'.tr(context),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _memberSearchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _buildInputDecoration('Search members...'.tr(context), icon: Icons.search),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: members.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No members found', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            children: members.map((m) {
                              final isChecked = _selectedMemberIds.contains(m.id);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: CheckboxListTile(
                                  value: isChecked,
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Row(
                                    children: [
                                      _buildAvatar(m.fullName, 34, AppColors.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.fullName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              m.email,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
          child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.teamToEdit != null ? 'Edit Team'.tr(context) : 'Create New Team'.tr(context),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.teamToEdit != null
                    ? 'Update team details, leader and members.'.tr(context)
                    : 'Set up a new team, assign a leader and select members.'.tr(context),
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
          fontSize: size * 0.38,
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
              (widget.teamToEdit != null ? 'Save Changes' : 'Create Team').tr(context),
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

  InputDecoration _buildInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.textSecondary, size: 20)
          : null,
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
