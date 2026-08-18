import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../responsive/responsive_layout.dart';
import '../../../../../../core/widgets/cards/app_cards.dart';

class TeamDetailsScreen extends StatelessWidget {
  final TeamModel team;

  const TeamDetailsScreen({super.key, required this.team});

  bool _isCompleted(String s) =>
      s == 'Completed' || s == 'Approved' || s == 'Approved With Suggestions';

  bool _isInProgress(String s) =>
      s == 'In Progress' ||
      s == 'Submitted' ||
      s == 'Under Review' ||
      s == 'Needs Changes' ||
      s == 'Reopened' ||
      s == 'Overdue';

  bool _isPending(String s) => s == 'Pending' || s == 'Assigned';

  Color _statusColor(String s) =>
      _isCompleted(s) ? AppColors.success : (_isInProgress(s) ? Colors.orange : AppColors.textSecondary);

  Color _priorityColor(String p) =>
      p == 'High' ? AppColors.error : (p == 'Medium' ? Colors.orange : AppColors.success);

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

    // Fetch live data from MockDatabase using the team's id
    final mockTeam = db.teams.firstWhere(
      (t) => t.id == team.id,
      orElse: () => MockTeam(
        id: team.id,
        name: team.name,
        managerId: '2', // default manager Prof. Khalid
        department: team.department,
        leaderId: '3', // default leader Eng. Nour
        memberIds: const ['4', '5'],
      ),
    );

    // Fetch Manager
    final manager = db.users.firstWhere(
      (u) => u.id == mockTeam.managerId,
      orElse: () => MockUser(
        id: '2',
        email: 'manager@aitu.edu',
        fullName: 'Prof. Khalid Mansour',
        role: 'Manager',
        department: team.department,
      ),
    );

    // Fetch Team Leader
    final leader = db.users.firstWhere(
      (u) => u.id == mockTeam.leaderId,
      orElse: () => MockUser(
        id: '3',
        email: 'leader@aitu.edu',
        fullName: team.leaderName,
        role: 'Team Leader',
        department: team.department,
      ),
    );

    // Fetch members
    final members = db.users.where((u) => mockTeam.memberIds.contains(u.id)).toList();

    // Fetch team tasks (assigned directly to the team or to its members)
    final memberIdsSet = mockTeam.memberIds.toSet();
    final tasks = db.tasks
        .where((t) => t.assignedTeamId == team.id || memberIdsSet.contains(t.assignedMemberId))
        .toList();

    final completedTasks = tasks.where((t) => _isCompleted(t.status)).toList();
    final pendingTasks = tasks.where((t) => _isPending(t.status)).toList();
    final inProgressTasks = tasks.where((t) => _isInProgress(t.status)).toList();
    final totalTasksCount = tasks.length;
    final completedTasksCount = completedTasks.length;
    final double completionRate =
        totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

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
              team.name,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Team Details'.tr(context),
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
              // ── 1. Team Information ──────────────────────────────
              _sectionCard(
                title: 'Team Information'.tr(context),
                icon: Icons.badge_outlined,
                iconColor: AppColors.primary,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _gradientChip(Icons.group_work_outlined, AppColors.primary, size: 48),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.name,
                                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              _deptBadge(context, team.department),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${team.membersCount} ${'Members'.tr(context)}',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            SizedBox(height: 2.h),
                            Text('$totalTasksCount ${'Tasks'.tr(context)}',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    const Divider(color: Color(0xFFF1F5F9)),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.person_pin_outlined,
                            color: Colors.orange,
                            label: 'Team Leader'.tr(context),
                            value: leader.fullName,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.manage_accounts_outlined,
                            color: Colors.blue,
                            label: 'Manager'.tr(context),
                            value: manager.fullName,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.apartment_outlined,
                            color: AppColors.primary,
                            label: 'Department'.tr(context),
                            value: team.department.tr(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.people_alt_outlined,
                            color: Colors.teal,
                            label: 'Team Size'.tr(context),
                            value: '${team.membersCount} ${'members'.tr(context)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── 2. Task Overview Stats ───────────────────────────
              _sectionCard(
                title: 'Task Overview'.tr(context),
                icon: Icons.insights_outlined,
                iconColor: AppColors.primary,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth < 600 ? 2 : 4;
                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        mainAxisExtent: 82.h,
                      ),
                      children: [
                        StatCard(
                          title: 'Total Tasks'.tr(context),
                          value: totalTasksCount.toString(),
                          icon: Icons.assignment_outlined,
                          accentColor: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Completed'.tr(context),
                          value: completedTasksCount.toString(),
                          icon: Icons.check_circle_outline,
                          accentColor: AppColors.success,
                        ),
                        StatCard(
                          title: 'In Progress'.tr(context),
                          value: inProgressTasks.length.toString(),
                          icon: Icons.hourglass_top_outlined,
                          accentColor: Colors.orange,
                        ),
                        StatCard(
                          title: 'Pending'.tr(context),
                          value: pendingTasks.length.toString(),
                          icon: Icons.schedule_outlined,
                          accentColor: AppColors.textSecondary,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // ── 3. Task Progress ─────────────────────────────────
              _sectionCard(
                title: 'Task Progress'.tr(context),
                icon: Icons.trending_up_outlined,
                iconColor: Colors.purple,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Completion Rate'.tr(context),
                            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 10.h,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: _miniStat('Completed'.tr(context), '$completedTasksCount', AppColors.success)),
                        Container(width: 1, height: 28.h, color: const Color(0xFFE2E8F0)),
                        Expanded(child: _miniStat('In Progress'.tr(context), '${inProgressTasks.length}', Colors.orange)),
                        Container(width: 1, height: 28.h, color: const Color(0xFFE2E8F0)),
                        Expanded(child: _miniStat('Pending'.tr(context), '${pendingTasks.length}', AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── 4. Team Members ──────────────────────────────────
              _sectionCard(
                title: 'Team Members'.tr(context),
                icon: Icons.people_outline,
                iconColor: Colors.indigo,
                trailing: Text('(${members.length})',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                child: members.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text('No members assigned to this team.'.tr(context),
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                      )
                    : Column(
                        children: members.map((m) {
                          final memberTasks = tasks.where((t) => t.assignedMemberId == m.id).toList();
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              children: [
                                _avatar(m.fullName, 38, AppColors.primary),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.fullName,
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${memberTasks.length} ${'tasks taken'.tr(context)}',
                                        style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F8EE),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '${m.points} ${'Points'.tr(context)}',
                                    style: TextStyle(color: const Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 11.sp),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(height: 16.h),

              // ── 5. Team Tasks ────────────────────────────────────
              _sectionCard(
                title: 'Team Tasks'.tr(context),
                icon: Icons.assignment_outlined,
                iconColor: Colors.deepOrange,
                trailing: Text('($totalTasksCount)',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                child: tasks.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text('No tasks assigned to this team.'.tr(context),
                              style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                        ),
                      )
                    : Column(
                        children: tasks.map((task) {
                          final assignee = members.firstWhere(
                            (u) => u.id == task.assignedMemberId,
                            orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''),
                          );
                          return InkWell(
                            onTap: () => context.go('/tasks/${task.id}'),
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
                                      _gradientChip(Icons.task_alt_outlined, AppColors.primary, size: 34),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '${task.ticketId} | ${'Assigned to'.tr(context)}: ${assignee.fullName}',
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
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 6.h,
                                    children: [
                                      _tag(task.priority.tr(context), _priorityColor(task.priority), _priorityColor(task.priority).withValues(alpha: 0.1)),
                                      _tag(task.status.tr(context), _statusColor(task.status), _statusColor(task.status).withValues(alpha: 0.1)),
                                      _tag(task.deadline, AppColors.textSecondary, AppColors.background),
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

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
      ],
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
