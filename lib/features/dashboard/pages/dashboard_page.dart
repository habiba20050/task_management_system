import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/notification_drawer.dart';
import '../../auth/cubit/auth_cubit.dart';

class DashboardPage extends StatefulWidget {
  final bool showMyTasks;
  const DashboardPage({super.key, this.showMyTasks = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.role;
    const isDark = false;

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      endDrawer: const NotificationDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.w : 16.w,
            vertical: 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              _buildHeader(context, user, isDark),
              SizedBox(height: 24.h),

              // Render Dashboard based on role
              if (role == 'Admin')
                _buildAdminDashboard(context, isDark)
              else if (role == 'Manager')
                _buildManagerDashboard(context, isDark)
              else if (role == 'Team Leader')
                _buildLeaderDashboard(context, isDark)
              else
                _buildMemberDashboard(context, user.id, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- Shared Header ---
  Widget _buildHeader(BuildContext context, user, bool isDark) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentLanguage == 'EN'
                    ? 'Dashboard Overview'
                    : 'لوحة التحكم العامة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isDesktop ? 22.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _currentLanguage == 'EN'
                    ? 'Welcome back, ${user.fullName} (${user.role})'
                    : 'مرحباً بعودتك، ${user.fullName} (${user.role})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isDesktop ? 13.sp : 11.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Notifications
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              MockDatabase.instance.markNotificationsRead(user.id);
              Scaffold.of(context).openEndDrawer();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242432) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20.sp,
                    color: isDark ? Colors.white70 : const Color(0xFF0A448C),
                  ),
                ),
                Positioned(
                  right: -2.w,
                  top: -2.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      MockDatabase.instance.notifications
                          .where((n) => n.userId == user.id && !n.isRead)
                          .length
                          .toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Language Toggle
        _buildLanguageSelector(context, isDark),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangBtn('EN', _currentLanguage == 'EN', isDark),
          _buildLangBtn('AR', _currentLanguage == 'AR', isDark),
        ],
      ),
    );
  }

  Widget _buildLangBtn(String label, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _currentLanguage = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.grey[600]),
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Admin Dashboard ---
  Widget _buildAdminDashboard(BuildContext context, bool isDark) {
    final db = MockDatabase.instance;
    final totalManagers = db.users.where((u) => u.role == 'Manager').length;
    final totalLeaders = db.users.where((u) => u.role == 'Team Leader').length;
    final totalMembers = db.users.where((u) => u.role == 'Team Member').length;
    final totalTeams = db.teams.length;
    final totalProjects = db.projects.length;
    final totalTickets = db.tickets.length;
    final totalTasks = db.tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(isDark, [
          _StatData(
            Icons.shield_outlined,
            'Managers',
            totalManagers.toString(),
            const Color(0xFF2F80ED),
            const Color(0xFFEAF2FF),
          ),
          _StatData(
            Icons.workspace_premium_outlined,
            'Leaders',
            totalLeaders.toString(),
            const Color(0xFF27AE60),
            const Color(0xFFE8F8EE),
          ),
          _StatData(
            Icons.people_outline,
            'Members',
            totalMembers.toString(),
            const Color(0xFFF2C94C),
            const Color(0xFFFFF9E6),
          ),
          _StatData(
            Icons.assignment_outlined,
            'Projects',
            totalProjects.toString(),
            const Color(0xFFEB5757),
            const Color(0xFFFFECEB),
          ),
        ]),
        SizedBox(height: 24.h),
        _buildStatsRow(isDark, [
          _StatData(
            Icons.group_work_outlined,
            'Teams',
            totalTeams.toString(),
            Colors.purple,
            const Color(0xFFF3E8FF),
          ),
          _StatData(
            Icons.label_outline,
            'Tickets',
            totalTickets.toString(),
            Colors.teal,
            const Color(0xFFE6FFFA),
          ),
          _StatData(
            Icons.checklist_outlined,
            'Tasks',
            totalTasks.toString(),
            Colors.indigo,
            const Color(0xFFE0E7FF),
          ),
        ]),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRankingsCard(isDark)),
            SizedBox(width: 24.w),
            Expanded(flex: 1, child: _buildRecentComplaintsPanel(isDark)),
          ],
        ),
      ],
    );
  }

  // --- Manager Dashboard ---
  Widget _buildManagerDashboard(BuildContext context, bool isDark) {
    final db = MockDatabase.instance;
    final totalTeams = db.teams.length;
    final totalLeaders = db.users.where((u) => u.role == 'Team Leader').length;
    final totalProjects = db.projects.length;
    final delayedTasks = db.tasks
        .where(
          (t) =>
              t.status != 'Approved' &&
              t.status != 'Completed' &&
              DateTime.tryParse(t.deadline)?.isBefore(DateTime.now()) == true,
        )
        .length;
    final pendingReviews = db.tasks
        .where((t) => t.status == 'Submitted' || t.status == 'Under Review')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(isDark, [
          _StatData(
            Icons.group_work_outlined,
            'Teams Count',
            totalTeams.toString(),
            const Color(0xFF2F80ED),
            const Color(0xFFEAF2FF),
          ),
          _StatData(
            Icons.workspace_premium_outlined,
            'Leaders Count',
            totalLeaders.toString(),
            const Color(0xFF27AE60),
            const Color(0xFFE8F8EE),
          ),
          _StatData(
            Icons.assignment_outlined,
            'Projects Count',
            totalProjects.toString(),
            const Color(0xFFF2C94C),
            const Color(0xFFFFF9E6),
          ),
          _StatData(
            Icons.warning_amber_outlined,
            'Delayed Tasks',
            delayedTasks.toString(),
            const Color(0xFFEB5757),
            const Color(0xFFFFECEB),
          ),
        ]),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildDeliverablesWaitingReviewCard(
                isDark,
                pendingReviews,
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(flex: 1, child: _buildProjectHealthScoreCard(isDark)),
          ],
        ),
      ],
    );
  }

  // --- Team Leader Dashboard ---
  Widget _buildLeaderDashboard(BuildContext context, bool isDark) {
    final db = MockDatabase.instance;
    final team = db.teams.firstWhere(
      (t) => t.leaderId == '3',
      orElse: () => MockTeam(
        id: '',
        name: 'My Team',
        managerId: '',
        department: '',
        leaderId: '',
        memberIds: [],
      ),
    );
    final memberCount = team.memberIds.length;
    final teamTasks = db.tasks
        .where((t) => team.memberIds.contains(t.assignedMemberId))
        .toList();
    final activeTasks = teamTasks
        .where((t) => t.status == 'Assigned' || t.status == 'In Progress')
        .length;
    final pendingReviews = teamTasks
        .where((t) => t.status == 'Submitted' || t.status == 'Under Review')
        .length;
    final delayedTasks = teamTasks
        .where(
          (t) =>
              t.status != 'Approved' &&
              t.status != 'Completed' &&
              DateTime.tryParse(t.deadline)?.isBefore(DateTime.now()) == true,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(isDark, [
          _StatData(
            Icons.people_outline,
            'Team Members',
            memberCount.toString(),
            const Color(0xFF2F80ED),
            const Color(0xFFEAF2FF),
          ),
          _StatData(
            Icons.checklist_outlined,
            'Active Tasks',
            activeTasks.toString(),
            const Color(0xFF27AE60),
            const Color(0xFFE8F8EE),
          ),
          _StatData(
            Icons.rate_review_outlined,
            'Pending Reviews',
            pendingReviews.toString(),
            const Color(0xFFF2C94C),
            const Color(0xFFFFF9E6),
          ),
          _StatData(
            Icons.warning_amber_outlined,
            'Delayed Tasks',
            delayedTasks.toString(),
            const Color(0xFFEB5757),
            const Color(0xFFFFECEB),
          ),
        ]),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTeamMembersActivity(isDark, team.memberIds),
            ),
            SizedBox(width: 24.w),
            Expanded(
              flex: 1,
              child: _buildTeamProductivityCard(isDark, teamTasks),
            ),
          ],
        ),
      ],
    );
  }

  // --- Team Member Dashboard ---
  Widget _buildMemberDashboard(
    BuildContext context,
    String memberId,
    bool isDark,
  ) {
    final db = MockDatabase.instance;
    final myTasks = db.tasks
        .where((t) => t.assignedMemberId == memberId)
        .toList();
    final userDetails = db.users.firstWhere(
      (u) => u.id == memberId,
      orElse: () =>
          MockUser(id: '', email: '', fullName: '', role: '', department: ''),
    );
    final completedCount = myTasks
        .where((t) => t.status == 'Approved' || t.status == 'Completed')
        .length;
    final pendingCount = myTasks
        .where(
          (t) =>
              t.status == 'Assigned' ||
              t.status == 'In Progress' ||
              t.status == 'Needs Changes',
        )
        .length;
    final overdueCount = myTasks
        .where(
          (t) =>
              t.status != 'Approved' &&
              t.status != 'Completed' &&
              DateTime.tryParse(t.deadline)?.isBefore(DateTime.now()) == true,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(isDark, [
          _StatData(
            Icons.emoji_events_outlined,
            'Current Points',
            userDetails.points.toString(),
            const Color(0xFF2F80ED),
            const Color(0xFFEAF2FF),
          ),
          _StatData(
            Icons.check_circle_outline,
            'Completed Tasks',
            completedCount.toString(),
            const Color(0xFF27AE60),
            const Color(0xFFE8F8EE),
          ),
          _StatData(
            Icons.hourglass_empty_outlined,
            'Pending Tasks',
            pendingCount.toString(),
            const Color(0xFFF2C94C),
            const Color(0xFFFFF9E6),
          ),
          _StatData(
            Icons.warning_amber_rounded,
            'Overdue Deadlines',
            overdueCount.toString(),
            const Color(0xFFEB5757),
            const Color(0xFFFFECEB),
          ),
        ]),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildMemberTasksList(isDark, myTasks)),
            SizedBox(width: 24.w),
            Expanded(
              flex: 1,
              child: _buildRankingProgressCard(isDark, userDetails),
            ),
          ],
        ),
      ],
    );
  }

  // --- Support Cards / Panels ---

  Widget _buildStatsRow(bool isDark, List<_StatData> items) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242432) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? item.bgColor.withOpacity(0.1)
                            : item.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRankingsCard(bool isDark) {
    final db = MockDatabase.instance;
    // Show teams or members rankings
    final teamsSorted = List<MockTeam>.from(db.teams)
      ..sort((a, b) => b.progress.compareTo(a.progress));

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Rankings (Progress)',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teamsSorted.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final team = teamsSorted[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.aituBlue.withOpacity(0.1),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.aituBlue,
                    ),
                  ),
                ),
                title: Text(
                  team.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Progress Percentage: ${team.progress.toInt()}%',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
                trailing: SizedBox(
                  width: 100.w,
                  child: LinearProgressIndicator(
                    value: team.progress / 100.0,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentComplaintsPanel(bool isDark) {
    final complaints = MockDatabase.instance.complaints;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Complaints',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          if (complaints.isEmpty)
            Text(
              'No complaints registered.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            )
          else
            Column(
              children: complaints
                  .map(
                    (c) => Card(
                      color: isDark
                          ? const Color(0xFF1E1E28)
                          : Colors.grey[100],
                      child: ListTile(
                        title: Text(
                          c.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${c.targetName} (${c.status})',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => context.go('/complaints'),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliverablesWaitingReviewCard(bool isDark, int pendingReviews) {
    final db = MockDatabase.instance;
    final submittedTasks = db.tasks
        .where((t) => t.status == 'Submitted')
        .toList();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deliverables Waiting Review ($pendingReviews)',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/review-center'),
                child: const Text('Go to Review Center'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (submittedTasks.isEmpty)
            Text(
              'No tasks awaiting review.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submittedTasks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final task = submittedTasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Submitted Work Notes: ${task.notes ?? 'No comments'}',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                  trailing: const Chip(
                    label: Text('Submitted'),
                    backgroundColor: Colors.amberAccent,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProjectHealthScoreCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Project Health Score',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 120.w,
            height: 120.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 10.w,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.aituRed,
                ),
                Center(
                  child: Text(
                    '85%',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'All systems operational',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembersActivity(bool isDark, List<String> memberIds) {
    final db = MockDatabase.instance;
    final members = db.users.where((u) => memberIds.contains(u.id)).toList();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Members Performance',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Column(
            children: members
                .map(
                  (m) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.aituRed.withOpacity(0.1),
                      child: Text(
                        m.fullName[0],
                        style: const TextStyle(
                          color: AppColors.aituRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      m.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Points: ${m.points} | Score: ${m.finalScore.toInt()}%',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => context.go('/evaluations'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('View Evaluation'),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamProductivityCard(bool isDark, List<MockTask> tasks) {
    final completed = tasks
        .where((t) => t.status == 'Approved' || t.status == 'Completed')
        .length;
    final total = tasks.length;
    final rate = total == 0 ? 0.0 : (completed / total);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Team Productivity',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 120.w,
            height: 120.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 10.w,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.success,
                ),
                Center(
                  child: Text(
                    '${(rate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '$completed of $total tasks completed',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTasksList(bool isDark, List<MockTask> tasks) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Tasks Feed',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/tasks'),
                child: const Text('Go to Planner'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (tasks.isEmpty)
            Text(
              'No tasks assigned to you.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Deadline: ${task.deadline} | Status: ${task.status}',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                  trailing: Icon(
                    task.status == 'Approved' || task.status == 'Completed'
                        ? Icons.check_circle
                        : (task.status == 'Needs Changes'
                              ? Icons.error
                              : Icons.radio_button_unchecked),
                    color:
                        task.status == 'Approved' || task.status == 'Completed'
                        ? Colors.green
                        : (task.status == 'Needs Changes'
                              ? Colors.red
                              : Colors.grey),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRankingProgressCard(bool isDark, MockUser user) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242432) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Score & Performance',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E28) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  'Total Points',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[500],
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  user.points.toString(),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.aituRed,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Efficiency Score: ${user.finalScore.toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Keep completing tasks early to boost points!',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;

  _StatData(this.icon, this.label, this.value, this.iconColor, this.bgColor);
}
