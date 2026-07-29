import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedUser = 'All';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;

  void _triggerExport(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exporting Report'.tr(context)),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Text('Generating document... Please wait.'.tr(context)),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully exported report to '.tr(context) + format)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final leaderTeam = db.teams.cast<MockTeam?>().firstWhere(
      (t) => t!.leaderId == currentUserId,
      orElse: () => null,
    );
    final teamMemberIds = leaderTeam != null ? [currentUserId, ...leaderTeam.memberIds] : <String>[currentUserId];
    final teamMembers = db.users.where((u) => teamMemberIds.contains(u.id)).toList();
    final teamTasks = db.tasks.where((t) => teamMemberIds.contains(t.currentOwnerId)).toList();

    final filteredTasks = teamTasks.where((t) {
      final matchesUser = _selectedUser == 'All' || t.currentOwnerId == _selectedUser;
      final matchesPriority = _selectedPriority == 'All' || t.priority == _selectedPriority;
      final matchesStatus = _selectedStatus == 'All' || t.status == _selectedStatus;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final d = DateTime.tryParse(t.deadline);
        if (d != null) {
          matchesDate = d.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              d.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }

      return matchesUser && matchesPriority && matchesStatus && matchesDate;
    }).toList();

    final total = filteredTasks.length;
    final completed = filteredTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final pending = filteredTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final inProgress = filteredTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final review = filteredTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdue = filteredTasks.where((t) => t.status == 'Overdue').length;
    final double completionRate = total == 0 ? 0.0 : (completed / total) * 100;
    final double avgCompletionTime = total == 0 ? 0.0 : 6.2;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reports & Analytics'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text('Exportable compliance documentation and university statistics'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Wrap(
                      spacing: 4.w,
                      children: [
                        TextButton.icon(
                          onPressed: () => _triggerExport('PDF'),
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                          label: Text('Export PDF'.tr(context), style: TextStyle(fontSize: 10.sp)),
                        ),
                        TextButton.icon(
                          onPressed: () => _triggerExport('Excel'),
                          icon: const Icon(Icons.table_chart, color: Colors.green, size: 16),
                          label: Text('Export Excel'.tr(context), style: TextStyle(fontSize: 10.sp)),
                        ),
                        IconButton(icon: const Icon(Icons.print, size: 20), onPressed: () => _triggerExport('Printer')),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.h),

              _buildFiltersPanel(teamMembers),
              SizedBox(height: 16.h),

              Text('Executive Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildExecutiveSummaryCards(total, completed, pending, inProgress, review, overdue, completionRate, avgCompletionTime),
              SizedBox(height: 24.h),

              Text('Detailed Performance Charts'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildChartsGrid(teamTasks, teamMembers, completed, inProgress, pending, review, overdue),
            ],
          ),
        ),
      ),
    );
  }

  // --- FILTERS PANEL ---
  Widget _buildFiltersPanel(List<MockUser> teamMembers) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _buildFilterField(
              label: 'Priority',
              icon: Icons.flag_outlined,
              value: _selectedPriority.tr(context),
              options: ['All', 'HIGH', 'MEDIUM', 'LOW'],
              labelMap: {'All': 'All'.tr(context), 'HIGH': 'HIGH'.tr(context), 'MEDIUM': 'MEDIUM'.tr(context), 'LOW': 'LOW'.tr(context)},
              onSelected: (val) => setState(() => _selectedPriority = val),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildFilterField(
              label: 'Status',
              icon: Icons.circle_outlined,
              value: _selectedStatus.tr(context),
              options: ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'],
              onSelected: (val) => setState(() => _selectedStatus = val),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: _buildDateRangeField(context)),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    Map<String, String>? labelMap,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.tr(context), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        SizedBox(height: 4.h),
        PopupMenuButton<String>(
          initialValue: options.contains(value) ? value : options.first,
          onSelected: onSelected,
          offset: Offset(0, 42.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          itemBuilder: (context) => options.map((o) {
            final text = labelMap != null ? (labelMap[o] ?? o) : o.tr(context);
            final isSelected = o == value;
            return PopupMenuItem(
              value: o,
              height: 34.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) Icon(Icons.check, size: 14, color: AppColors.primary) else SizedBox(width: 14.w),
                  SizedBox(width: 6.w),
                  Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(child: Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date Range'.tr(context), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        SizedBox(height: 4.h),
        PopupMenuButton<String>(
          offset: Offset(0, 42.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          onSelected: (val) async {
            if (val == 'pick') {
              final range = await showDateRangePicker(context: context, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
              if (range != null) setState(() => _selectedDateRange = range);
            } else if (val == 'clear') {
              setState(() => _selectedDateRange = null);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 34.h,
              value: 'pick',
              child: Row(children: [Icon(Icons.date_range, size: 14, color: AppColors.primary), SizedBox(width: 6.w), Text('Pick Date Range'.tr(context), style: TextStyle(fontSize: 12.sp))]),
            ),
            if (_selectedDateRange != null)
              PopupMenuItem(
                height: 34.h,
                value: 'clear',
                child: Row(children: [Icon(Icons.clear, size: 14, color: AppColors.danger), SizedBox(width: 6.w), Text('Clear'.tr(context), style: TextStyle(fontSize: 12.sp, color: AppColors.danger))]),
              ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _selectedDateRange != null ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _selectedDateRange != null ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, size: 14, color: _selectedDateRange != null ? AppColors.primary : AppColors.textSecondary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _selectedDateRange == null
                        ? 'Select'.tr(context)
                        : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _selectedDateRange != null ? AppColors.primary : AppColors.textPrimary),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- EXECUTIVE SUMMARY CARDS ---
  Widget _buildExecutiveSummaryCards(int total, int completed, int pending, int inProgress, int review, int overdue, double rate, double time) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 1100 ? 3 : 4);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 85.h,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, index) {
            final cards = [
              StatCard(title: 'Total Tasks'.tr(context), value: total.toString(), icon: Icons.playlist_add_check, accentColor: AppColors.primary),
              StatCard(title: 'Completed'.tr(context), value: completed.toString(), icon: Icons.check_circle_outline, accentColor: AppColors.success),
              StatCard(title: 'Pending'.tr(context), value: pending.toString(), icon: Icons.hourglass_empty, accentColor: Colors.orange),
              StatCard(title: 'In Progress'.tr(context), value: inProgress.toString(), icon: Icons.pending_actions, accentColor: AppColors.inProgress),
              StatCard(title: 'Review'.tr(context), value: review.toString(), icon: Icons.rate_review, accentColor: Colors.deepPurple),
              StatCard(title: 'Overdue'.tr(context), value: overdue.toString(), icon: Icons.error_outline, accentColor: AppColors.danger),
              StatCard(title: 'Completion Rate %'.tr(context), value: '${rate.toStringAsFixed(1)}%', icon: Icons.pie_chart, accentColor: Colors.teal),
              StatCard(title: 'Average Completion Time'.tr(context), value: '${time.toStringAsFixed(1)} ' + 'Hours'.tr(context), icon: Icons.timer, accentColor: Colors.blueAccent),
            ];
            return cards[index];
          },
        );
      },
    );
  }

  // --- CHARTS GRID ---
  Widget _buildChartsGrid(List<MockTask> teamTasks, List<MockUser> teamMembers, int comp, int prog, int pend, int rev, int ov) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final double total = (comp + prog + pend + rev + ov).toDouble();

    final memberTaskCounts = teamMembers.map((u) {
      final count = teamTasks.where((t) => t.currentOwnerId == u.id).length;
      return (name: u.fullName, count: count);
    }).toList();
    final maxMemberCount = memberTaskCounts.fold(0, (max, m) => m.count > max ? m.count : max);

    final memberOverdue = teamMembers.map((u) {
      final count = teamTasks.where((t) => t.currentOwnerId == u.id && t.status == 'Overdue').length;
      return (name: u.fullName, count: count);
    }).toList();
    final maxOverdue = memberOverdue.fold(0, (max, m) => m.count > max ? m.count : max);

    final memberCompleted = teamMembers.map((u) {
      final count = teamTasks.where((t) => t.currentOwnerId == u.id && (t.status == 'Completed' || t.status == 'Approved')).length;
      return (name: u.fullName, count: count);
    }).toList();

    final highP = teamTasks.where((t) => t.priority == 'HIGH').length;
    final medP = teamTasks.where((t) => t.priority == 'MEDIUM').length;
    final lowP = teamTasks.where((t) => t.priority == 'LOW').length;
    final pTotal = (highP + medP + lowP).toDouble();

    final List<Color> memberColors = [
      AppColors.primary, Colors.teal, Colors.indigo, Colors.deepOrange,
      Colors.pink, Colors.brown, Colors.cyan, Colors.amber,
    ];

    final List<Widget> chartWidgets = [
      // 1. Task Status Donut Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Status Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: total == 0
                  ? Center(child: Text('No tasks available.'.tr(context)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 24.r,
                        sections: [
                          PieChartSectionData(color: AppColors.success, value: comp.toDouble(), radius: 26.r, title: 'C', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.inProgress, value: prog.toDouble(), radius: 26.r, title: 'I', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: Colors.orange, value: pend.toDouble(), radius: 26.r, title: 'P', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.danger, value: ov.toDouble(), radius: 26.r, title: 'O', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // 2. Weekly Performance Line Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Performance'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 1), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3)],
                      color: AppColors.success,
                      barWidth: 2.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 3. Monthly Performance Trend Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Trend'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 5), FlSpot(3, 4), FlSpot(4, 7)],
                      color: AppColors.primary,
                      barWidth: 2.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. Member Task Count Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member Task Load'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: maxMemberCount > 0 ? maxMemberCount * 1.3 : 5,
                  barGroups: List.generate(memberTaskCounts.length, (i) {
                    final c = memberTaskCounts[i];
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: c.count.toDouble(), color: memberColors[i % memberColors.length], width: 12.w)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // 5. Member Completion Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member Completions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: maxMemberCount > 0 ? maxMemberCount * 1.3 : 5,
                  barGroups: List.generate(memberCompleted.length, (i) {
                    final c = memberCompleted[i];
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: c.count.toDouble(), color: AppColors.success, width: 12.w)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // 6. Priority Pie Distribution Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: pTotal == 0
                  ? Center(child: Text('No tasks available.'.tr(context)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 24.r,
                        sections: [
                          PieChartSectionData(color: AppColors.danger, value: highP.toDouble(), radius: 26.r, title: 'H', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.primary, value: medP.toDouble(), radius: 26.r, title: 'M', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.success, value: lowP.toDouble(), radius: 26.r, title: 'L', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // 7. Member Overdue Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overdue by Member'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: maxOverdue > 0 ? maxOverdue * 1.3 : 1,
                  barGroups: List.generate(memberOverdue.length, (i) {
                    final c = memberOverdue[i];
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: c.count.toDouble(), color: AppColors.danger, width: 12.w)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // 8. Completion Time by Member (mocked)
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completion Time'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 6.h),
            SizedBox(
              height: 120.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: 10,
                  barGroups: List.generate(teamMembers.length, (i) {
                    final mockHours = 4.0 + (i * 0.8);
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: mockHours, color: memberColors[i % memberColors.length], width: 12.w)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop ? 3 : (constraints.maxWidth < 600 ? 1 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
            mainAxisExtent: 200.h,
          ),
          itemCount: chartWidgets.length,
          itemBuilder: (context, idx) => chartWidgets[idx],
        );
      },
    );
  }
}
