import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/language/cubit/language_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class DashboardPage extends StatefulWidget {
  final bool showMyTasks;
  const DashboardPage({super.key, this.showMyTasks = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _hoveredPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final db = MockDatabase.instance;

    // 1. Calculations for the 10 KPI Cards
    final totalTasks = db.tasks.length;
    final completedTasks = db.tasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final inProgressTasks = db.tasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final pendingTasks = db.tasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final reviewTasks = db.tasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdueTasks = db.tasks.where((t) => t.status == 'Overdue').length;
    final totalEmployees = db.users.where((u) => u.role != 'Admin').length;
    final totalDepts = db.departments.length;
    final openComplaints = db.complaints.where((c) => c.status != 'Closed' && c.status != 'Resolved').length;
    final totalTeams = db.teams.length;
    
    final double avgPerformance = db.users.isEmpty
        ? 0.0
        : db.users.map((u) => u.finalScore).reduce((a, b) => a + b) / db.users.length;

    final double avgTeamProgress = db.teams.isEmpty
        ? 0.0
        : db.teams.map((t) => t.progress).reduce((a, b) => a + b) / db.teams.length;

    // Lists for Widget Cards
    final upcomingDeadlines = db.tasks.where((t) => t.status != 'Completed' && t.status != 'Approved').toList()
      ..sort((a, b) => (DateTime.tryParse(a.deadline) ?? DateTime(9999)).compareTo(DateTime.tryParse(b.deadline) ?? DateTime(9999)));

    final recentActivities = db.auditLogs.take(5).toList();
    final latestComplaints = db.complaints.take(5).toList();
    
    final topEmployees = List<MockUser>.from(db.users.where((u) => u.role == 'Team Member'))
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));
      
    final delayedEmployees = List<MockUser>.from(db.users.where((u) => u.role == 'Team Member'))
      ..sort((a, b) {
        final aCount = db.tasks.where((t) => t.currentOwnerId == a.id && t.status == 'Overdue').length;
        final bCount = db.tasks.where((t) => t.currentOwnerId == b.id && t.status == 'Overdue').length;
        return bCount.compareTo(aCount);
      });

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Sub-header
              Text(
                'Performance Analytics Summary'.tr(context),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16.h),

              // KPI Section: Grid of 10 equal cards with fixed height
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 6;
                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 2;
                  } else if (constraints.maxWidth < 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth < 1200) {
                    crossAxisCount = 4;
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
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final statCards = [
                        StatCard(title: 'Total Tasks'.tr(context), value: totalTasks.toString(), icon: Icons.checklist, accentColor: AppColors.primary),
                        StatCard(title: 'Completed Tasks'.tr(context), value: completedTasks.toString(), icon: Icons.check_circle_outline, accentColor: AppColors.success),
                        StatCard(title: 'In Progress Tasks'.tr(context), value: inProgressTasks.toString(), icon: Icons.pending_actions, accentColor: AppColors.inProgress),
                        StatCard(title: 'Pending Tasks'.tr(context), value: pendingTasks.toString(), icon: Icons.hourglass_empty, accentColor: Colors.orange),
                        StatCard(title: 'Review Tasks'.tr(context), value: reviewTasks.toString(), icon: Icons.rate_review, accentColor: Colors.deepPurple),
                        StatCard(title: 'Overdue Tasks'.tr(context), value: overdueTasks.toString(), icon: Icons.error_outline, accentColor: AppColors.danger),
                        StatCard(title: 'Total Employees'.tr(context), value: totalEmployees.toString(), icon: Icons.people_outline, accentColor: Colors.teal),
                        StatCard(title: 'Total Departments'.tr(context), value: totalDepts.toString(), icon: Icons.business, accentColor: Colors.indigo),
                        StatCard(title: 'Open Complaints'.tr(context), value: openComplaints.toString(), icon: Icons.warning_amber_outlined, accentColor: Colors.redAccent),
                        StatCard(title: 'Average Performance Score'.tr(context), value: '${avgPerformance.toStringAsFixed(1)}%', icon: Icons.trending_up, accentColor: Colors.blueAccent),
                        StatCard(title: 'Total Teams'.tr(context), value: totalTeams.toString(), icon: Icons.groups, accentColor: Colors.deepOrange),
                        StatCard(title: 'Avg Team Progress'.tr(context), value: '${avgTeamProgress.toStringAsFixed(1)}%', icon: Icons.auto_graph, accentColor: Colors.lightGreen),
                      ];
                      return statCards[index];
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Charts Layout Grid 1
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildWeeklyCompletionTrendChart(db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildMonthlyPerformanceTrendChart(db)),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDepartmentPerformanceChart(db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildPriorityDistributionChart(db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildEmployeePerformanceRankingChart(db)),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTeamsProgressChart(db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildRoleDistributionChart(db)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildAssignmentModeChart(db)),
                  ],
                ),
              ] else ...[
                _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks),
                SizedBox(height: 16.h),
                _buildWeeklyCompletionTrendChart(db),
                SizedBox(height: 16.h),
                _buildMonthlyPerformanceTrendChart(db),
                SizedBox(height: 16.h),
                _buildDepartmentPerformanceChart(db),
                SizedBox(height: 16.h),
                _buildPriorityDistributionChart(db),
                SizedBox(height: 16.h),
                _buildEmployeePerformanceRankingChart(db),
                SizedBox(height: 16.h),
                _buildTeamsProgressChart(db),
                SizedBox(height: 16.h),
                _buildRoleDistributionChart(db),
                SizedBox(height: 16.h),
                _buildAssignmentModeChart(db),
              ],
              SizedBox(height: 24.h),

              // Widgets Layout Grid 2
              LayoutBuilder(
                builder: (context, constraints) {
                  int cols = isDesktop ? 3 : (isTablet ? 2 : 1);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      mainAxisExtent: 210.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, idx) {
                      if (idx == 0) return _buildUpcomingDeadlinesWidget(upcomingDeadlines);
                      if (idx == 1) return _buildRecentActivityWidget(recentActivities);
                      if (idx == 2) return _buildLatestComplaintsWidget(latestComplaints);
                      if (idx == 3) return _buildTopEmployeesWidget(topEmployees);
                      return _buildMostDelayedEmployeesWidget(delayedEmployees, db);
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

  // --- Donut Chart ---
  Widget _buildStatusDonutChart(int comp, int prog, int pend, int rev, int ov) {
    final double total = (comp + prog + pend + rev + ov).toDouble();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Status Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: total == 0
                ? Center(child: Text('No tasks available.'.tr(context)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 26.r,
                      sections: [
                        PieChartSectionData(color: AppColors.success, value: comp.toDouble(), radius: 30.r, title: '${((comp/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: AppColors.inProgress, value: prog.toDouble(), radius: 30.r, title: '${((prog/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: Colors.orange, value: pend.toDouble(), radius: 30.r, title: '${((pend/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: Colors.deepPurple, value: rev.toDouble(), radius: 30.r, title: '${((rev/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: AppColors.danger, value: ov.toDouble(), radius: 30.r, title: '${((ov/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Weekly Line Chart ---
  Widget _buildWeeklyCompletionTrendChart(MockDatabase db) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Completion Trend'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Monthly Performance Line Chart ---
  Widget _buildMonthlyPerformanceTrendChart(MockDatabase db) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Performance Trend'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Department Performance Bar Chart ---
  Widget _buildDepartmentPerformanceChart(MockDatabase db) {
    final csTotal = db.tasks.where((t) => t.taskDepartment == 'Computer Science').length;
    final itTotal = db.tasks.where((t) => t.taskDepartment == 'IT Services' || t.taskDepartment == 'IT').length;
    final engTotal = db.tasks.where((t) => t.taskDepartment == 'Engineering').length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Department Performance'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8.sp)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    final depts = ['CS', 'IT', 'ENG'];
                    if (v >= 0 && v < depts.length) return Text(depts[v.toInt()], style: TextStyle(fontSize: 8.sp));
                    return const Text('');
                  })),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: csTotal.toDouble(), color: AppColors.primary, width: 10.w)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: itTotal.toDouble(), color: Colors.teal, width: 10.w)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: engTotal.toDouble(), color: Colors.indigo, width: 10.w)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Priority Distribution Pie Chart ---
  Widget _buildPriorityDistributionChart(MockDatabase db) {
    final high = db.tasks.where((t) => t.priority == 'HIGH').length;
    final med = db.tasks.where((t) => t.priority == 'MEDIUM').length;
    final low = db.tasks.where((t) => t.priority == 'LOW').length;
    final critical = db.tasks.where((t) => t.priority == 'CRITICAL' || t.priority == 'URGENT').length;
    final double total = (high + med + low + critical).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Priority Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: total == 0
                ? Center(child: Text('No tasks available.'.tr(context)))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 36.r,
                          sections: [
                            PieChartSectionData(color: AppColors.success, value: low == 0 ? 1 : low.toDouble(), radius: 18.r, showTitle: false),
                            PieChartSectionData(color: Colors.amber, value: med.toDouble(), radius: 18.r, showTitle: false),
                            PieChartSectionData(color: AppColors.danger, value: high.toDouble(), radius: 18.r, showTitle: false),
                            PieChartSectionData(color: Colors.purple, value: critical.toDouble(), radius: 18.r, showTitle: false),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${total.toInt()}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Tasks'.tr(context), style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --- Employee Performance Ranking Bar Chart ---
  Widget _buildEmployeePerformanceRankingChart(MockDatabase db) {
    final sorted = List<MockUser>.from(db.users)..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final display = sorted.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employee Performance Ranking'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: display.isEmpty
                ? Center(child: Text('No rank data.'.tr(context)))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8.sp)))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                          if (v >= 0 && v < display.length) return Text(display[v.toInt()].fullName.split(' ')[0], style: TextStyle(fontSize: 8.sp));
                          return const Text('');
                        })),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(display.length, (idx) {
                        return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: display[idx].finalScore, color: Colors.blueAccent, width: 12.w)]);
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Teams Progress Bar Chart ---
  Widget _buildTeamsProgressChart(MockDatabase db) {
    final teams = db.teams.take(5).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teams Progress'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: teams.isEmpty
                ? Center(child: Text('No teams available.'.tr(context)))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8.sp)))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                          if (v >= 0 && v < teams.length) return Text(teams[v.toInt()].name, style: TextStyle(fontSize: 8.sp));
                          return const Text('');
                        })),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(teams.length, (idx) {
                        return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: teams[idx].progress, color: Colors.deepOrange, width: 12.w)]);
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Users by Role Pie Chart ---
  Widget _buildRoleDistributionChart(MockDatabase db) {
    final admins = db.users.where((u) => u.role == 'Admin').length;
    final managers = db.users.where((u) => u.role == 'Manager').length;
    final leaders = db.users.where((u) => u.role == 'Team Leader').length;
    final members = db.users.where((u) => u.role == 'Team Member').length;
    final total = (admins + managers + leaders + members).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users by Role'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: total == 0
                ? Center(child: Text('No users available.'.tr(context)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 26.r,
                      sections: [
                        if (admins > 0) PieChartSectionData(color: Colors.redAccent, value: admins.toDouble(), radius: 30.r, title: 'Ad', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        if (managers > 0) PieChartSectionData(color: Colors.blueAccent, value: managers.toDouble(), radius: 30.r, title: 'Mg', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        if (leaders > 0) PieChartSectionData(color: Colors.orangeAccent, value: leaders.toDouble(), radius: 30.r, title: 'TL', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        if (members > 0) PieChartSectionData(color: Colors.greenAccent, value: members.toDouble(), radius: 30.r, title: 'TM', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Tasks by Assignment Pie Chart ---
  Widget _buildAssignmentModeChart(MockDatabase db) {
    final ind = db.tasks.where((t) => t.assignmentMode == 'Individual').length;
    final team = db.tasks.where((t) => t.assignmentMode == 'Team').length;
    final dept = db.tasks.where((t) => t.assignmentMode == 'Department').length;
    final double total = (ind + team + dept).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks by Assignment'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: total == 0
                ? Center(child: Text('No tasks available.'.tr(context)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 26.r,
                      sections: [
                        if (ind > 0) PieChartSectionData(color: Colors.cyan, value: ind.toDouble(), radius: 30.r, title: 'Ind', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        if (team > 0) PieChartSectionData(color: Colors.purpleAccent, value: team.toDouble(), radius: 30.r, title: 'Team', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        if (dept > 0) PieChartSectionData(color: Colors.amber, value: dept.toDouble(), radius: 30.r, title: 'Dept', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Upcoming Deadlines Widget ---
  Widget _buildUpcomingDeadlinesWidget(List<MockTask> list) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Deadlines'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: list.take(3).length,
              itemBuilder: (context, idx) {
                final task = list[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  subtitle: Text(task.deadline, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                  trailing: Icon(Icons.alarm, size: 14.sp, color: AppColors.danger),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Recent Activity Widget ---
  Widget _buildRecentActivityWidget(List<MockAuditLog> logs) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activities'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: logs.take(3).length,
              itemBuilder: (context, idx) {
                final log = logs[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(log.operation, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp)),
                  subtitle: Text('${log.userEmail} | ${log.date}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Latest Complaints Widget ---
  Widget _buildLatestComplaintsWidget(List<MockComplaint> list) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest Complaints'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: list.take(3).length,
              itemBuilder: (context, idx) {
                final complaint = list[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(complaint.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  subtitle: Text('${complaint.category.tr(context)} | ${complaint.date}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4.r)),
                    child: Text(complaint.status.tr(context), style: TextStyle(color: AppColors.danger, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Top Employees Widget ---
  Widget _buildTopEmployeesWidget(List<MockUser> list) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Employees'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: list.take(3).length,
              itemBuilder: (context, idx) {
                final user = list[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(radius: 12.r, child: Text(user.fullName[0])),
                  title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  subtitle: Text(user.department.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                  trailing: Text('${user.finalScore.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 11.sp)),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Most Delayed Employees Widget ---
  Widget _buildMostDelayedEmployeesWidget(List<MockUser> list, MockDatabase db) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Delayed Employees'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: list.take(3).length,
              itemBuilder: (context, idx) {
                final user = list[idx];
                final overdueCount = db.tasks.where((t) => t.currentOwnerId == user.id && t.status == 'Overdue').length;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(radius: 12.r, child: Text(user.fullName[0])),
                  title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  subtitle: Text('${user.department.tr(context)}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4.r)),
                    child: Text('$overdueCount ' + 'Overdue'.tr(context), style: TextStyle(color: AppColors.danger, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
