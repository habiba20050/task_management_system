import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class DashboardPage extends StatefulWidget {
  final bool showMyTasks;
  const DashboardPage({super.key, this.showMyTasks = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final db = MockDatabase.instance;

    // ── الحصول على المستخدم الحالي ──────────────────────────────────────
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';

    // جلب بيانات المستخدم من قاعدة البيانات للحصول على القسم والدور
    final mockManager = db.users.firstWhere(
      (u) => u.id == currentUserId,
      orElse: () => db.users.firstWhere(
        (u) => u.role == 'Manager',
        orElse: () => db.users.first,
      ),
    );
    final isAdmin = mockManager.role == 'Admin';
    final managerDept = mockManager.department;

    // ── نطاق البيانات (الأدمن يشاهد كل شيء، المدير يقتصر على قسمه) ────
    final List<MockTeam> myTeams;
    final Set<String> myTeamIds;
    final Set<String> myLeaderIds;
    final Set<String> myMemberIds;
    final Set<String> allSubordinateIds;
    final List<MockTask> deptTasks;

    if (isAdmin) {
      // كل الفرق وكل المهام وكل الموظفين
      myTeams = List.from(db.teams);
      myTeamIds = myTeams.map((t) => t.id).toSet();
      myLeaderIds = myTeams.map((t) => t.leaderId).toSet();
      myMemberIds = myTeams.expand((t) => t.memberIds).toSet();
      allSubordinateIds = db.users.where((u) => u.role != 'Admin').map((u) => u.id).toSet();
      deptTasks = List.from(db.tasks);
    } else {
      // الفرق المرتبطة بهذا المدير (managerId == currentUserId)
      myTeams = db.teams.where((t) => t.managerId == currentUserId).toList();
      myTeamIds = myTeams.map((t) => t.id).toSet();

      // Team Leaders التابعين لهذا المدير
      myLeaderIds = myTeams.map((t) => t.leaderId).toSet();

      // كل أعضاء الفرق التابعين لهذا المدير
      myMemberIds = myTeams.expand((t) => t.memberIds).toSet();

      // إجمالي الموظفين تحت المدير (Leaders + Members)
      allSubordinateIds = {...myLeaderIds, ...myMemberIds};

      // المهام الخاصة بقسم المدير أو الفرق التابعة له
      deptTasks = db.tasks.where((t) =>
        t.taskDepartment == managerDept ||
        (t.assignedTeamId != null && myTeamIds.contains(t.assignedTeamId))
      ).toList();
    }

    // Team Leaders التابعين للمستخدم
    final myLeaders = db.users.where((u) => myLeaderIds.contains(u.id)).toList();

    // إجمالي الموظفين
    final totalEmployees = allSubordinateIds.length;

    // ── KPI Cards ───────────────────────────────────────────────────
    final totalTasks      = deptTasks.length;
    final completedTasks  = deptTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final inProgressTasks = deptTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final pendingTasks    = deptTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final reviewTasks     = deptTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdueTasks    = deptTasks.where((t) => t.status == 'Overdue').length;

    final double avgPerformance = allSubordinateIds.isEmpty
        ? 0.0
        : db.users
            .where((u) => allSubordinateIds.contains(u.id))
            .map((u) => u.finalScore)
            .fold(0.0, (a, b) => a + b) /
          allSubordinateIds.length;

    // ── Widget Lists ────────────────────────────────────────────────
    final upcomingDeadlines = deptTasks
        .where((t) => t.status != 'Completed' && t.status != 'Approved')
        .toList()
      ..sort((a, b) =>
          (DateTime.tryParse(a.deadline) ?? DateTime(9999))
              .compareTo(DateTime.tryParse(b.deadline) ?? DateTime(9999)));

    final deptComplaints = db.complaints.take(5).toList();
    final topSubordinates = db.users
        .where((u) => allSubordinateIds.contains(u.id))
        .toList()
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));

    final delayedSubordinates = db.users
        .where((u) => allSubordinateIds.contains(u.id))
        .toList()
      ..sort((a, b) {
        final aOv = deptTasks.where((t) => t.currentOwnerId == a.id && t.status == 'Overdue').length;
        final bOv = deptTasks.where((t) => t.currentOwnerId == b.id && t.status == 'Overdue').length;
        return bOv.compareTo(aOv);
      });

    // أفضل وأسوأ 3 Team Members فقط (role == 'Team Member')
    final teamMembersOnly = db.users
        .where((u) => myMemberIds.contains(u.id) && u.role == 'Team Member')
        .toList();
    final bestMembers  = List<MockUser>.from(teamMembersOnly)..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final worstMembers = List<MockUser>.from(teamMembersOnly)..sort((a, b) => a.finalScore.compareTo(b.finalScore));

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.w : 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── رأس الصفحة ──────────────────────────────────────────
              _buildDeptHeader(
                context,
                isAdmin: isAdmin,
                dept: managerDept,
                managerName: mockManager.fullName,
                teamsCount: myTeams.length,
                empCount: totalEmployees,
              ),
              SizedBox(height: 20.h),

              // ── KPI Cards ───────────────────────────────────────────
              Text(
                'Performance Analytics Summary'.tr(context),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              SizedBox(height: 12.h),

              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 5;
                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 2;
                  } else if (constraints.maxWidth < 1100) {
                    crossAxisCount = 3;
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      mainAxisExtent: 72.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final statCards = [
                        StatCard(title: 'Total Tasks'.tr(context),            value: totalTasks.toString(),                          icon: Icons.checklist,              accentColor: AppColors.primary),
                        StatCard(title: 'Completed Tasks'.tr(context),        value: completedTasks.toString(),                      icon: Icons.check_circle_outline,   accentColor: AppColors.success),
                        StatCard(title: 'In Progress Tasks'.tr(context),      value: inProgressTasks.toString(),                     icon: Icons.pending_actions,        accentColor: AppColors.inProgress),
                        StatCard(title: 'Pending Tasks'.tr(context),          value: pendingTasks.toString(),                        icon: Icons.hourglass_empty,        accentColor: Colors.orange),
                        StatCard(title: 'Review Tasks'.tr(context),           value: reviewTasks.toString(),                         icon: Icons.rate_review,            accentColor: Colors.deepPurple),
                        StatCard(title: 'Overdue Tasks'.tr(context),          value: overdueTasks.toString(),                        icon: Icons.error_outline,          accentColor: AppColors.danger),
                        StatCard(title: 'My Teams'.tr(context),               value: myTeams.length.toString(),                      icon: Icons.groups_outlined,        accentColor: Colors.teal),
                        StatCard(title: 'Team Leaders'.tr(context),           value: myLeaders.length.toString(),                    icon: Icons.supervisor_account_outlined, accentColor: Colors.indigo),
                        StatCard(title: 'Total Employees'.tr(context),        value: totalEmployees.toString(),                      icon: Icons.people_outline,         accentColor: Colors.blueGrey),
                        StatCard(title: 'Average Performance Score'.tr(context), value: '${avgPerformance.toStringAsFixed(1)}%',     icon: Icons.trending_up,            accentColor: Colors.blueAccent),
                      ];
                      return statCards[index];
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),

              // ── Charts ──────────────────────────────────────────────
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTeamsProgressChart(myTeams)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildPriorityDistributionChart(deptTasks)),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMemberPerformanceChart(topSubordinates, db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildWeeklyCompletionTrendChart()),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildMonthlyPerformanceTrendChart()),
                  ],
                ),
              ] else ...[
                _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks),
                SizedBox(height: 16.h),
                _buildTeamsProgressChart(myTeams),
                SizedBox(height: 16.h),
                _buildPriorityDistributionChart(deptTasks),
                SizedBox(height: 16.h),
                _buildMemberPerformanceChart(topSubordinates, db),
                SizedBox(height: 16.h),
                _buildWeeklyCompletionTrendChart(),
                SizedBox(height: 16.h),
                _buildMonthlyPerformanceTrendChart(),
              ],
              SizedBox(height: 24.h),

              // ── Widget Cards Grid ────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  int cols = isDesktop ? 3 : (isTablet ? 2 : 1);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      mainAxisExtent: 220.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, idx) {
                      if (idx == 0) return _buildUpcomingDeadlinesWidget(upcomingDeadlines);
                      if (idx == 1) return _buildMyTeamsWidget(myTeams, db);
                      if (idx == 2) return _buildLatestComplaintsWidget(deptComplaints);
                      if (idx == 3) return _buildTopSubordinatesWidget(topSubordinates);
                      if (idx == 4) return _buildMostDelayedWidget(delayedSubordinates, deptTasks);
                      if (idx == 5) return _buildBestMembersWidget(bestMembers);
                      return _buildWorstMembersWidget(worstMembers);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── رأس الصفحة ────────────────────────────────────────────────────
  Widget _buildDeptHeader(BuildContext context,
      {required bool isAdmin,
      required String dept,
      required String managerName,
      required int teamsCount,
      required int empCount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gradientChip(Icons.dashboard_outlined, AppColors.primary, size: 44),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin ? 'Dashboard'.tr(context) : dept,
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 3.h),
                Text(
                  isAdmin
                      ? 'Track all departments, teams & employees'.tr(context)
                      : '${'Manager'.tr(context)}: $managerName',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeaderChip(Icons.groups, '$teamsCount ${'Teams'.tr(context)}', Colors.teal),
            SizedBox(height: 4.h),
            _buildHeaderChip(Icons.people, '$empCount ${'Employees'.tr(context)}', AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Donut Chart (Task Status) ─────────────────────────────────────
  Widget _buildStatusDonutChart(int comp, int prog, int pend, int rev, int ov) {
    final double total = (comp + prog + pend + rev + ov).toDouble();
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Status Distribution'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: total == 0
                ? Center(child: Text('No tasks available.'.tr(context)))
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 28.r,
                            sections: [
                              PieChartSectionData(color: AppColors.success,    value: comp.toDouble(), radius: 30.r, title: '${((comp/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: AppColors.inProgress, value: prog.toDouble(), radius: 30.r, title: '${((prog/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: Colors.orange,        value: pend.toDouble(), radius: 30.r, title: '${((pend/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: Colors.deepPurple,    value: rev.toDouble(),  radius: 30.r, title: '${((rev/total)*100).toStringAsFixed(0)}%',  titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: AppColors.danger,     value: ov.toDouble(),  radius: 30.r, title: '${((ov/total)*100).toStringAsFixed(0)}%',  titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendDot(AppColors.success,    'Done'.tr(context),       comp),
                          _legendDot(AppColors.inProgress, 'In Progress'.tr(context),prog),
                          _legendDot(Colors.orange,        'Pending'.tr(context),    pend),
                          _legendDot(Colors.deepPurple,    'Review'.tr(context),     rev),
                          _legendDot(AppColors.danger,     'Overdue'.tr(context),    ov),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8.w, height: 8.h, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 4.w),
          Text('$label ($count)', style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── Teams Progress Bar Chart ──────────────────────────────────────
  Widget _buildTeamsProgressChart(List<MockTeam> myTeams) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teams Progress'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: myTeams.isEmpty
                ? Center(child: Text('No teams assigned.'.tr(context)))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: TextStyle(fontSize: 7.sp)),
                          reservedSize: 28.w,
                        )),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            final idx = v.toInt();
                            if (idx >= 0 && idx < myTeams.length) {
                              final name = myTeams[idx].name;
                              final shortName = name.length > 6 ? name.substring(0, 6) : name;
                              return Text(shortName, style: TextStyle(fontSize: 7.sp));
                            }
                            return const Text('');
                          },
                        )),
                      ),
                      maxY: 100,
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(myTeams.length, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: (myTeams[i].progress * 100).clamp(0, 100),
                            color: [Colors.teal, AppColors.primary, Colors.indigo, Colors.deepPurple][i % 4],
                            width: 14.w,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.r),
                              topRight: Radius.circular(4.r),
                            ),
                          )
                        ]);
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Priority Distribution ──────────────────────────────────────────
  Widget _buildPriorityDistributionChart(List<MockTask> tasks) {
    final high = tasks.where((t) => t.priority == 'HIGH').length;
    final med  = tasks.where((t) => t.priority == 'MEDIUM').length;
    final low  = tasks.where((t) => t.priority == 'LOW').length;
    final double total = (high + med + low).toDouble();

    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Priority Distribution'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: total == 0
                ? Center(child: Text('No tasks available.'.tr(context)))
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 28.r,
                            sections: [
                              PieChartSectionData(color: AppColors.danger,  value: high.toDouble(), radius: 30.r, title: 'H', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: AppColors.primary, value: med.toDouble(),  radius: 30.r, title: 'M', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                              PieChartSectionData(color: AppColors.success, value: low.toDouble(),  radius: 30.r, title: 'L', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendDot(AppColors.danger,  'High'.tr(context),   high),
                          _legendDot(AppColors.primary, 'Medium'.tr(context), med),
                          _legendDot(AppColors.success, 'Low'.tr(context),    low),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Employee Performance Bar Chart ────────────────────────────────
  Widget _buildMemberPerformanceChart(List<MockUser> topUsers, MockDatabase db) {
    final display = topUsers.take(5).toList();
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employee Performance'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: display.isEmpty
                ? Center(child: Text('No employees found.'.tr(context)))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 7.sp)),
                          reservedSize: 24.w,
                        )),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            final idx = v.toInt();
                            if (idx >= 0 && idx < display.length) {
                              return Text(display[idx].fullName.split(' ')[0], style: TextStyle(fontSize: 7.sp));
                            }
                            return const Text('');
                          },
                        )),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(display.length, (idx) {
                        return BarChartGroupData(x: idx, barRods: [
                          BarChartRodData(
                            toY: display[idx].finalScore,
                            color: Colors.blueAccent,
                            width: 12.w,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.r),
                              topRight: Radius.circular(4.r),
                            ),
                          )
                        ]);
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Weekly Trend ──────────────────────────────────────────────────
  Widget _buildWeeklyCompletionTrendChart() {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Completion Trend'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8.sp)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    if (v >= 0 && v < days.length) return Text(days[v.toInt()], style: TextStyle(fontSize: 8.sp));
                    return const Text('');
                  })),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 4), FlSpot(4, 5)],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.w,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Monthly Trend ─────────────────────────────────────────────────
  Widget _buildMonthlyPerformanceTrendChart() {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Performance Trend'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8.sp)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                    if (v >= 0 && v < months.length) return Text(months[v.toInt()], style: TextStyle(fontSize: 8.sp));
                    return const Text('');
                  })),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 6), FlSpot(4, 7), FlSpot(5, 5), FlSpot(6, 8)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.w,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Upcoming Deadlines ────────────────────────────────────
  Widget _buildUpcomingDeadlinesWidget(List<MockTask> list) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Deadlines'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No upcoming deadlines.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: list.take(4).length,
                    itemBuilder: (context, idx) {
                      final task = list[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp), overflow: TextOverflow.ellipsis),
                        subtitle: Text(task.deadline, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Icon(Icons.alarm, size: 14.sp, color: AppColors.danger),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: My Teams ──────────────────────────────────────────────
  Widget _buildMyTeamsWidget(List<MockTeam> myTeams, MockDatabase db) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Teams'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: myTeams.isEmpty
                ? Center(child: Text('No teams assigned.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: myTeams.take(4).length,
                    itemBuilder: (context, idx) {
                      final team = myTeams[idx];
                      final leader = db.users.firstWhere(
                        (u) => u.id == team.leaderId,
                        orElse: () => MockUser(id: '', email: '', fullName: 'Unknown', role: '', department: ''),
                      );
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: Colors.teal.shade50,
                          child: Icon(Icons.group, size: 14.sp, color: Colors.teal),
                        ),
                        title: Text(team.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp), overflow: TextOverflow.ellipsis),
                        subtitle: Text('Leader: ${leader.fullName}', style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                        trailing: SizedBox(
                          width: 50.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${(team.progress * 100).toInt()}%', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColors.success)),
                              SizedBox(height: 2.h),
                              LinearProgressIndicator(
                                value: team.progress,
                                backgroundColor: Colors.grey.shade200,
                                color: AppColors.success,
                                minHeight: 4.h,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Latest Complaints ─────────────────────────────────────
  Widget _buildLatestComplaintsWidget(List<MockComplaint> list) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest Complaints'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No complaints.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: list.take(4).length,
                    itemBuilder: (context, idx) {
                      final c = list[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(c.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp), overflow: TextOverflow.ellipsis),
                        subtitle: Text('${c.category.tr(context)} | ${c.date}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4.r)),
                          child: Text(c.status.tr(context), style: TextStyle(color: AppColors.danger, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Top Subordinates ──────────────────────────────────────
  Widget _buildTopSubordinatesWidget(List<MockUser> list) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Performers'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No employees found.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: list.take(4).length,
                    itemBuilder: (context, idx) {
                      final user = list[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(user.fullName[0], style: TextStyle(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                        subtitle: Text(user.role.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Text(
                          '${user.finalScore.toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 11.sp),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Most Delayed ──────────────────────────────────────────
  Widget _buildMostDelayedWidget(List<MockUser> list, List<MockTask> deptTasks) {
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Delayed'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No employees found.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: list.take(4).length,
                    itemBuilder: (context, idx) {
                      final user = list[idx];
                      final overdueCount = deptTasks.where((t) => t.currentOwnerId == user.id && t.status == 'Overdue').length;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: Colors.red.shade50,
                          child: Text(user.fullName[0], style: TextStyle(fontSize: 11.sp, color: AppColors.danger, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                        subtitle: Text(user.role.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4.r)),
                          child: Text(
                            '$overdueCount ${'Overdue'.tr(context)}',
                            style: TextStyle(color: AppColors.danger, fontSize: 8.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Best 3 Team Members ───────────────────────────────────
  Widget _buildBestMembersWidget(List<MockUser> list) {
    final display = list.take(3).toList();
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, size: 16.sp, color: Colors.amber.shade700),
              SizedBox(width: 6.w),
              Text(
                'Best Team Members'.tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: display.isEmpty
                ? Center(child: Text('No members found.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: display.length,
                    itemBuilder: (context, idx) {
                      final user = display[idx];
                      final medals = ['🥇', '🥈', '🥉'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: SizedBox(
                          width: 36.w,
                          child: Center(
                            child: Text(medals[idx], style: TextStyle(fontSize: 20.sp)),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(user.department, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${user.finalScore.toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Worst 3 Team Members ──────────────────────────────────
  Widget _buildWorstMembersWidget(List<MockUser> list) {
    final display = list.take(3).toList();
    return _modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, size: 16.sp, color: AppColors.danger),
              SizedBox(width: 6.w),
              Text(
                'Needs Improvement'.tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: display.isEmpty
                ? Center(child: Text('No members found.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: display.length,
                    itemBuilder: (context, idx) {
                      final user = display[idx];
                      final score = user.finalScore;
                      final scoreColor = score >= 70 ? Colors.orange : AppColors.danger;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: Colors.red.shade50,
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(fontSize: 11.sp, color: AppColors.danger, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(user.department, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${score.toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Modern UI helpers ────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  Widget _gradientChip(IconData icon, Color color, {double size = 40}) {
    return Container(
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
  }

  Widget _modernCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
