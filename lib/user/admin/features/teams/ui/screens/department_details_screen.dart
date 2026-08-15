import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../responsive/responsive_layout.dart';
import 'team_details_screen.dart';

class DepartmentDetailsScreen extends StatelessWidget {
  final MockDepartment department;

  const DepartmentDetailsScreen({super.key, required this.department});

  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  Widget _gradientChip(IconData icon, Color color, {double size = 40}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, _darker(color)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size * 0.32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.48),
      );

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    final manager = db.users.firstWhere(
      (u) => u.id == department.managerId,
      orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: department.name),
    );

    final employees = db.users.where((u) => u.department == department.name).toList();
    final teams = db.teams.where((t) => t.department == department.name).toList();

    final teamModels = teams.map((t) => _toTeamModel(db, t)).toList();

    final teamMembersCount = teamModels.fold<int>(0, (s, t) => s + t.membersCount);
    final teamTasksCount = teamModels.fold<int>(0, (s, t) => s + t.totalTasks);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              department.name,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Department Details'.tr(context),
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Department Information ────────────────────────
              _sectionCard(
                title: 'Department Information'.tr(context),
                icon: Icons.badge_outlined,
                iconColor: AppColors.primary,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _gradientChip(Icons.business_outlined, AppColors.primary, size: 48),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                department.name,
                                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              _deptBadge(context, department.code),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${employees.length} ${'Employees'.tr(context)}',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            SizedBox(height: 2.h),
                            Text('${teams.length} ${'Teams'.tr(context)}',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    const Divider(color: Color(0xFFF1F5F9)),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.tag_outlined,
                            color: AppColors.primary,
                            label: 'Code'.tr(context),
                            value: department.code,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.calendar_today_outlined,
                            color: Colors.teal,
                            label: 'Created'.tr(context),
                            value: department.createdDate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.manage_accounts_outlined,
                            color: Colors.blue,
                            label: 'Manager'.tr(context),
                            value: manager.fullName,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.description_outlined,
                            color: Colors.orange,
                            label: 'Description'.tr(context),
                            value: department.description.isEmpty ? '—' : department.description,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── 2. Overview Stats ────────────────────────────────
              _sectionCard(
                title: 'Overview'.tr(context),
                icon: Icons.insights_outlined,
                iconColor: AppColors.primary,
                child: _statsRow(
                  context,
                  _statBox('Employees'.tr(context), '${employees.length}', Icons.people_outline, AppColors.primary),
                  _statBox('Teams'.tr(context), '${teams.length}', Icons.groups_outlined, Colors.green),
                  _statBox('Team Members'.tr(context), '$teamMembersCount', Icons.group_outlined, Colors.indigo),
                  _statBox('Assigned Tasks'.tr(context), '$teamTasksCount', Icons.assignment_outlined, Colors.orange),
                ),
              ),
              SizedBox(height: 16.h),

              // ── 3. Department Manager ────────────────────────────
              _sectionCard(
                title: 'Department Manager'.tr(context),
                icon: Icons.manage_accounts_outlined,
                iconColor: Colors.blue,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      _avatar(manager.fullName, 48, Colors.blue),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(manager.fullName,
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 3.h),
                            Text(manager.email,
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      _tag('Manager'.tr(context), Colors.blue, Colors.blue.withValues(alpha: 0.1)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // ── 4. Employees ─────────────────────────────────────
              _sectionCard(
                title: 'Employees'.tr(context),
                icon: Icons.people_outline,
                iconColor: Colors.indigo,
                trailing: Text('(${employees.length})',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                child: employees.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text('No employees in this department.'.tr(context),
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                      )
                    : Column(
                        children: employees.map((u) {
                          final scoreColor = u.finalScore >= 80
                              ? AppColors.success
                              : (u.finalScore >= 60 ? Colors.orange : AppColors.danger);
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              children: [
                                _avatar(u.fullName, 38, _roleColor(u.role)),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(u.fullName,
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 2.h),
                                      Text(u.email,
                                          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 4.h),
                                      Wrap(
                                        spacing: 6.w,
                                        runSpacing: 4.h,
                                        children: [
                                          _tag(u.role.tr(context), _roleColor(u.role), _roleColor(u.role).withValues(alpha: 0.1)),
                                          _statusTag(context, u.isActive),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${u.finalScore.toInt()}%',
                                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: scoreColor)),
                                    SizedBox(height: 2.h),
                                    Text('Score'.tr(context), style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(height: 16.h),

              // ── 5. Teams ─────────────────────────────────────────
              _sectionCard(
                title: 'Teams'.tr(context),
                icon: Icons.groups_outlined,
                iconColor: Colors.green,
                trailing: Text('(${teams.length})',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                child: teams.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text('No teams in this department.'.tr(context),
                              style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                        ),
                      )
                    : Column(
                        children: teamModels.map((t) {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TeamDetailsScreen(team: t)),
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _gradientChip(Icons.group_work_outlined, AppColors.primary, size: 34),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t.name,
                                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '${'Leader'.tr(context)}: ${t.leaderName}',
                                              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Icon(Icons.people_outline, size: 13.sp, color: AppColors.textSecondary),
                                      SizedBox(width: 3.w),
                                      Text('${t.membersCount} ${'members'.tr(context)}',
                                          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4.r),
                                          child: LinearProgressIndicator(
                                            value: t.progress,
                                            minHeight: 6.h,
                                            backgroundColor: Colors.grey.shade200,
                                            color: t.progress >= 0.75
                                                ? AppColors.success
                                                : (t.progress >= 0.4 ? Colors.orange : AppColors.danger),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text('${t.completionPercentage.toInt()}%',
                                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TeamModel _toTeamModel(MockDatabase db, MockTeam t) {
    final leader = db.users.firstWhere(
      (u) => u.id == t.leaderId,
      orElse: () => MockUser(id: '', email: '', fullName: t.leaderId, role: '', department: ''),
    );
    final teamTasks = db.tasks.where((tsk) => t.memberIds.contains(tsk.assignedMemberId)).toList();
    final completed = teamTasks
        .where((tsk) => tsk.status == 'Completed' || tsk.status == 'Approved' || tsk.status == 'Approved With Suggestions')
        .length;

    return TeamModel(
      id: t.id,
      name: t.name,
      department: t.department,
      leaderName: leader.fullName,
      leaderInitials: _initials(leader.fullName),
      membersCount: t.memberIds.length,
      totalTasks: teamTasks.length,
      completedTasks: completed,
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Team Leader':
        return Colors.indigo;
      case 'Team Member':
        return Colors.teal;
      case 'Manager':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required Color color, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                SizedBox(height: 2.h),
                Text(value,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deptBadge(BuildContext context, String dept) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(dept.tr(context),
          style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statsRow(BuildContext context, Widget a, Widget b, Widget c, Widget d) {
    final isWide = ResponsiveLayout.isDesktop(context) || ResponsiveLayout.isTablet(context);
    if (isWide) {
      return Row(children: [
        Expanded(child: a), SizedBox(width: 12.w),
        Expanded(child: b), SizedBox(width: 12.w),
        Expanded(child: c), SizedBox(width: 12.w),
        Expanded(child: d),
      ]);
    }
    return Column(children: [
      Row(children: [Expanded(child: a), SizedBox(width: 10.w), Expanded(child: b)]),
      SizedBox(height: 10.h),
      Row(children: [Expanded(child: c), SizedBox(width: 10.w), Expanded(child: d)]),
    ]);
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusTag(BuildContext context, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: active ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6.w, height: 6.h,
              decoration: BoxDecoration(color: active ? AppColors.success : Colors.grey, shape: BoxShape.circle)),
          SizedBox(width: 4.w),
          Text(active ? 'Active'.tr(context) : 'Inactive'.tr(context),
              style: TextStyle(color: active ? AppColors.success : Colors.grey, fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _avatar(String name, double size, Color color) {
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
}
