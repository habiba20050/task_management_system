import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../cubit/teams_cubit.dart';
import '../../../../core/localization/translate_extension.dart';
import '../../cubit/teams_state.dart';
import '../widgets/create_team_dialog_widget.dart';
import '../widgets/team_card_widget.dart';
import 'team_details_screen.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../responsive/responsive_layout.dart';
import '../../model/team_model.dart';
import '../../../../core/network/mock_database.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../core/styles/app_shadow.dart';
import '../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../core/widgets/cards/app_cards.dart';

class TeamsDashboardScreen extends StatefulWidget {
  const TeamsDashboardScreen({super.key});

  @override
  State<TeamsDashboardScreen> createState() => _TeamsDashboardScreenState();
}
class _TeamsDashboardScreenState extends State<TeamsDashboardScreen> {
  String _searchQuery = '';
  String _selectedDept = 'All';
  bool _showTeamsView = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showTeamsView ? 'Team Management Portal'.tr(context) : 'Department Configuration'.tr(context),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _showTeamsView
                            ? 'Track and filter university team operations & department progress'.tr(context)
                            : 'Manage academic departments and configurations'.tr(context),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_showTeamsView) {
                        CreateTeamDialogWidget.show(
                          context,
                          context.read<TeamsCubit>(),
                        );
                      } else {
                        _showAddDeptDialog(context, currentUserId);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: Text(
                      _showTeamsView ? 'Add New Team'.tr(context) : 'Add Department'.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Segmented Toggle Button
              Row(
                children: [
                  _buildSegmentButton(
                    label: 'Teams'.tr(context),
                    isSelected: _showTeamsView,
                    onTap: () => setState(() => _showTeamsView = true),
                  ),
                  SizedBox(width: 12.w),
                  _buildSegmentButton(
                    label: 'Departments'.tr(context),
                    isSelected: !_showTeamsView,
                    onTap: () => setState(() => _showTeamsView = false),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. Search & Reactive Filters Row
              if (_showTeamsView) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search teams by name or leader...'.tr(context),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13.sp,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDept,
                          items: [
                            'All',
                            'IT Services',
                            'CS Dept',
                            'Business',
                            'Math Dept',
                          ].map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(
                                dept,
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ),
                          ).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDept = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search departments by name or code...'.tr(context),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13.sp,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],

              // 3. Stat Cards Section
              if (_showTeamsView)
                BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, state) {
                    if (state is TeamsLoaded) {
                      final totalTeams = state.teams.length;
                      final totalMembers = state.teams.fold<int>(
                        0,
                        (sum, team) => sum + team.membersCount,
                      );
                      final avgProgress = totalTeams == 0
                          ? 0.0
                          : state.teams.fold<double>(
                                  0,
                                  (sum, team) => sum + team.completionPercentage,
                                ) /
                                totalTeams;

                      return _buildStatsRow(
                        context,
                        [
                          _buildStatWidget(
                            'Active Teams',
                            totalTeams.toString(),
                            Icons.groups_outlined,
                            Colors.blue,
                          ),
                          _buildStatWidget(
                            'Assigned Members',
                            totalMembers.toString(),
                            Icons.person_outline,
                            Colors.green,
                          ),
                          _buildStatWidget(
                            'Avg Completion',
                            '${avgProgress.toInt()}%',
                            Icons.trending_up,
                            Colors.purple,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              else
                _buildStatsRow(
                  context,
                  [
                    _buildStatWidget(
                      'Total Departments',
                      db.departments.length.toString(),
                      Icons.business,
                      Colors.blue,
                    ),
                    _buildStatWidget(
                      'Total Teams',
                      db.teams.length.toString(),
                      Icons.groups_outlined,
                      Colors.green,
                    ),
                    _buildStatWidget(
                      'Total Managers',
                      db.users.where((u) => u.role == 'Manager').length.toString(),
                      Icons.person_outline,
                      Colors.purple,
                    ),
                  ],
                ),
              SizedBox(height: 24.h),

              // 4. Clean Data Table for Teams or Departments
              Expanded(
                child: _showTeamsView
                    ? BlocBuilder<TeamsCubit, TeamsState>(
                        builder: (context, state) {
                          if (state is TeamsLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is TeamsLoaded) {
                            final filtered = state.teams.where((t) {
                              final matchesSearch =
                                  t.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  t.leaderName.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  );
                              final matchesDept =
                                  _selectedDept == 'All' ||
                                  t.department == _selectedDept;
                              return matchesSearch && matchesDept;
                            }).toList();

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No teams found matching search criteria.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return isDesktop
                                ? _buildDesktopTable(context, filtered, context.read<TeamsCubit>())
                                : _buildMobileCards(context, filtered, context.read<TeamsCubit>());
                          }
                          return const SizedBox.shrink();
                        },
                      )
                    : _buildDepartmentsTable(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatWidget(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      height: 76.h,
      child: StatCard(
        title: label.tr(context),
        value: value,
        icon: icon,
        accentColor: color,
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<Widget> cards) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    if (isDesktop || isTablet) {
      return Row(
        children: [
          Expanded(child: cards.isNotEmpty ? cards[0] : const SizedBox.shrink()),
          SizedBox(width: 16.w),
          Expanded(child: cards.length > 1 ? cards[1] : const SizedBox.shrink()),
          SizedBox(width: 16.w),
          Expanded(child: cards.length > 2 ? cards[2] : const SizedBox.shrink()),
        ],
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SizedBox(width: double.infinity, child: c),
        )).toList(),
      );
    }
  }

  Widget _buildDesktopTable(BuildContext context, List<TeamModel> filtered, TeamsCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(context),
          ...filtered.map((t) => _buildTableRow(context, t, cubit)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Team Name'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Department'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Team Leader'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 1, child: Text('Members'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Completion Rate'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, TeamModel t, TeamsCubit cubit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.group_work_outlined, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    t.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  t.department.tr(context),
                  style: TextStyle(color: const Color(0xFF0A448C), fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.aituRed.withOpacity(0.1),
                  child: Text(t.leaderInitials, style: TextStyle(fontSize: 9.sp, color: AppColors.aituRed, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(t.leaderName, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${t.membersCount}'),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: t.progress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('${t.completionPercentage.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => TeamDetailsScreen(team: t),
                    );
                  },
                  tooltip: 'More Details'.tr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  onPressed: () => _showEditTeamDialog(context, t, cubit),
                  tooltip: 'Edit Team'.tr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                  onPressed: () => _showDeleteTeamConfirm(context, t.id, cubit),
                  tooltip: 'Delete Team'.tr(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCards(
    BuildContext context,
    List<TeamModel> filtered,
    TeamsCubit cubit,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 135.h,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, idx) {
            return TeamCardWidget(team: filtered[idx]);
          },
        );
      },
    );
  }

  void _showEditTeamDialog(BuildContext context, TeamModel team, TeamsCubit cubit) {
    CreateTeamDialogWidget.show(context, cubit, teamToEdit: team);
  }

  void _showDeleteTeamConfirm(BuildContext context, String teamId, TeamsCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team'.tr(context)),
        content: Text('Are you sure you want to delete this team?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              cubit.deleteTeam(teamId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Team deleted successfully'.tr(context))),
              );
            },
            child: Text('Delete'.tr(context), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
          boxShadow: isSelected ? AppShadow.soft : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentsTable(BuildContext context) {
    final db = MockDatabase.instance;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    final filtered = db.departments.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No departments found matching search criteria.'.tr(context),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDeptTableHeader(context),
              ...filtered.map((d) => _buildDeptTableRow(context, d)),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, idx) {
          final dept = filtered[idx];
          final mgr = db.users.firstWhere((u) => u.id == dept.managerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            child: ListTile(
              title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${dept.code} | Manager: ${mgr.fullName}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditDeptDialog(context, dept, '1'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _showDeleteDeptConfirm(context, dept.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDeptTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Department Name'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Code'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 3, child: Text('Manager'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 4, child: Text('Description'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildDeptTableRow(BuildContext context, MockDepartment d) {
    final db = MockDatabase.instance;
    final mgr = db.users.firstWhere((u) => u.id == d.managerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.business, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    d.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(d.code),
          ),
          Expanded(
            flex: 3,
            child: Text(mgr.fullName, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 4,
            child: Text(d.description, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  onPressed: () => _showEditDeptDialog(context, d, '1'),
                  tooltip: 'Edit Department'.tr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                  onPressed: () => _showDeleteDeptConfirm(context, d.id),
                  tooltip: 'Delete Department'.tr(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }

  void _showAddDeptDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final codeCon = TextEditingController();
    final descCon = TextEditingController();
    String? managerId = db.users.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 500.w,
            padding: EdgeInsets.all(32.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Department'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Create a new academic department configuration.'.tr(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Department Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildInputDecoration(context, 'e.g. Computer Science'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Code'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: codeCon,
                    decoration: _buildInputDecoration(context, 'e.g. CS'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Description'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: descCon,
                    decoration: _buildInputDecoration(context, 'Enter department description...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Manager'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: managerId,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(context, ''),
                    items: db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                    onChanged: (v) => setDialogState(() => managerId = v),
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr(context),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameCon.text.isNotEmpty && codeCon.text.isNotEmpty) {
                              setState(() {
                                db.addDepartment(
                                  MockDepartment(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: nameCon.text,
                                    code: codeCon.text,
                                    description: descCon.text,
                                    managerId: managerId ?? '',
                                    createdDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                  ),
                                  adminId,
                                );
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
      ),
    );
  }

  void _showEditDeptDialog(BuildContext context, MockDepartment dept, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController(text: dept.name);
    final codeCon = TextEditingController(text: dept.code);
    final descCon = TextEditingController(text: dept.description);
    String managerId = dept.managerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 500.w,
            padding: EdgeInsets.all(32.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Department'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Update the configuration attributes of the department.'.tr(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Department Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildInputDecoration(context, 'e.g. Computer Science'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Code'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: codeCon,
                    decoration: _buildInputDecoration(context, 'e.g. CS'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Description'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: descCon,
                    decoration: _buildInputDecoration(context, 'Enter department description...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Manager'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: managerId,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(context, ''),
                    items: db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                    onChanged: (v) => setDialogState(() => managerId = v!),
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr(context),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              db.editDepartment(
                                MockDepartment(
                                  id: dept.id,
                                  name: nameCon.text,
                                  code: codeCon.text,
                                  description: descCon.text,
                                  managerId: managerId,
                                  createdDate: dept.createdDate,
                                ),
                                adminId,
                              );
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
      ),
    );
  }

  void _showDeleteDeptConfirm(BuildContext context, String deptId) {
    final db = MockDatabase.instance;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delete Department'.tr(context),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              const Divider(color: Color(0xFFF1F5F9), thickness: 1),
              SizedBox(height: 20.h),
              Text(
                'Are you sure you want to delete this department?'.tr(context),
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr(context),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          db.deleteDepartment(deptId, '1');
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Department deleted successfully'.tr(context))),
                        );
                      },
                      child: Text('Delete'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
