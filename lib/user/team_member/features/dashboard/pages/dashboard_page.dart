import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';

import '../../../../shared/features/auth/cubit/auth_cubit.dart';
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
    final authState = context.watch<AuthCubit>().state;
    final userId = authState is AuthSuccess ? authState.user.id : '';

    final myTasks = db.tasks.where((t) =>
        t.currentOwnerId == userId || t.assignedMemberId == userId).toList();

    final totalTasks = myTasks.length;
    final completedTasks = myTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final inProgressTasks = myTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final pendingTasks = myTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final reviewTasks = myTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdueTasks = myTasks.where((t) => t.status == 'Overdue').length;
    final myUser = authState is AuthSuccess
        ? db.users.where((u) => u.id == authState.user.id).firstOrNull
        : null;

    // Widget Lists
    final upcomingDeadlines = myTasks.where((t) => t.status != 'Completed' && t.status != 'Approved').toList()
      ..sort((a, b) => (DateTime.tryParse(a.deadline) ?? DateTime(9999)).compareTo(DateTime.tryParse(b.deadline) ?? DateTime(9999)));

    final recentActivities = db.auditLogs.where((l) => l.userId == userId).take(5).toList();
    final myComplaints = db.complaints.where((c) => c.submitterId == userId).take(5).toList();

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

              // KPI Section: 6 personal stat cards
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 2;
                  } else if (constraints.maxWidth < 900) {
                    crossAxisCount = 3;
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      mainAxisExtent: 82.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final statCards = [
                        StatCard(title: 'My Tasks'.tr(context), value: totalTasks.toString(), icon: Icons.checklist, accentColor: AppColors.primary),
                        StatCard(title: 'Completed'.tr(context), value: completedTasks.toString(), icon: Icons.check_circle_outline, accentColor: AppColors.success),
                        StatCard(title: 'In Progress'.tr(context), value: inProgressTasks.toString(), icon: Icons.pending_actions, accentColor: AppColors.inProgress),
                        StatCard(title: 'Pending'.tr(context), value: pendingTasks.toString(), icon: Icons.hourglass_empty, accentColor: Colors.orange),
                        StatCard(title: 'Under Review'.tr(context), value: reviewTasks.toString(), icon: Icons.rate_review, accentColor: Colors.deepPurple),
                        StatCard(title: 'Overdue'.tr(context), value: overdueTasks.toString(), icon: Icons.error_outline, accentColor: AppColors.danger),
                      ];
                      return statCards[index];
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Charts Row 1: Status + Priority + Monthly trend
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildPriorityDistributionChart(myTasks)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildMyPerformanceScoreCard(myUser)),
                  ],
                ),
                SizedBox(height: 16.h),
              ] else ...[
                _buildStatusDonutChart(completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks),
                SizedBox(height: 16.h),
                _buildPriorityDistributionChart(myTasks),
                SizedBox(height: 16.h),
                _buildMyPerformanceScoreCard(myUser),
              ],
              SizedBox(height: 24.h),

              // Widgets Grid: personal widgets
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
                    itemCount: 4,
                    itemBuilder: (context, idx) {
                      if (idx == 0) return _buildUpcomingDeadlinesWidget(upcomingDeadlines);
                      if (idx == 1) return _buildRecentActivityWidget(recentActivities);
                      if (idx == 2) return _buildMyComplaintsWidget(myComplaints, db);
                      return _buildMyTeamWidget(db);
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

  // --- Priority Distribution Pie Chart ---
  Widget _buildPriorityDistributionChart(List<MockTask> tasks) {
    final high = tasks.where((t) => t.priority == 'HIGH').length;
    final med = tasks.where((t) => t.priority == 'MEDIUM').length;
    final low = tasks.where((t) => t.priority == 'LOW').length;
    final double total = (high + med + low).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Task Priorities'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
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
                        PieChartSectionData(color: AppColors.danger, value: high.toDouble(), radius: 30.r, title: 'H', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: AppColors.primary, value: med.toDouble(), radius: 30.r, title: 'M', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        PieChartSectionData(color: AppColors.success, value: low.toDouble(), radius: 30.r, title: 'L', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- My Performance Score Card ---
  Widget _buildMyPerformanceScoreCard(MockUser? user) {
    final score = user?.finalScore ?? 0.0;
    final gaugeColor = score >= 70 ? AppColors.success : (score >= 40 ? Colors.orange : AppColors.danger);

    return AppCard(
      child: Column(
        children: [
          Text('My Performance Score'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: Center(
              child: SizedBox(
                width: 90.w,
                height: 90.h,
                child: Stack(alignment: Alignment.center, children: [
                  PieChart(PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 28.r,
                    sections: [
                      PieChartSectionData(
                        color: gaugeColor,
                        value: score.clamp(5, 100),
                        radius: 38.r,
                        title: '',
                      ),
                      PieChartSectionData(
                        color: Colors.grey.shade200,
                        value: (100 - score).clamp(0, 95),
                        radius: 38.r,
                        title: '',
                      ),
                    ],
                  )),
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: gaugeColor),
                  ),
                ]),
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

  // --- My Complaints Widget ---
  Widget _buildMyComplaintsWidget(List<MockComplaint> list, MockDatabase db) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Complaints'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No complaints submitted.'.tr(context), style: TextStyle(fontSize: 10.sp, color: Colors.grey)))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final complaint = list[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(complaint.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                        subtitle: Text('${complaint.category.tr(context)} | ${complaint.date}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: complaint.status == 'Closed' || complaint.status == 'Resolved'
                                ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(complaint.status.tr(context), style: TextStyle(
                            color: complaint.status == 'Closed' || complaint.status == 'Resolved'
                                ? AppColors.success : AppColors.danger,
                            fontSize: 8.sp, fontWeight: FontWeight.bold,
                          )),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // --- My Team Widget ---
  Widget _buildMyTeamWidget(MockDatabase db) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Team'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: db.teams.length.clamp(0, 3),
              itemBuilder: (context, idx) {
                final team = db.teams[idx];
                final memberCount = team.memberIds.length;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(radius: 12.r, backgroundColor: AppColors.primary, child: Text(team.name[0], style: TextStyle(color: Colors.white, fontSize: 10.sp))),
                  title: Text(team.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  subtitle: Text('$memberCount members'.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                  trailing: Text('${team.progress}%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 11.sp)),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
