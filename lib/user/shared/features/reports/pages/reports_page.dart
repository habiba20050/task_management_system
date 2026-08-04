import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../language/cubit/language_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Filter states
  String _selectedDept = 'All';
  String _selectedTeam = 'All';
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
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    // Filter computation
    final filteredTasks = db.tasks.where((t) {
      final matchesDept = _selectedDept == 'All' || t.taskDepartment == _selectedDept;
      
      final team = db.teams.firstWhere(
        (tm) => tm.id == t.assignedTeamId,
        orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: [])
      );
      final matchesTeam = _selectedTeam == 'All' || team.name == _selectedTeam;
      
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

      return matchesDept && matchesTeam && matchesUser && matchesPriority && matchesStatus && matchesDate;
    }).toList();

    // KPI Cards data
    final total = filteredTasks.length;
    final completed = filteredTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final pending = filteredTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final inProgress = filteredTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final review = filteredTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdue = filteredTasks.where((t) => t.status == 'Overdue').length;
    final double completionRate = total == 0 ? 0.0 : (completed / total) * 100;
    
    // Average durations (mocked or average checklist durations)
    final double avgCompletionTime = total == 0 ? 0.0 : 6.2; 

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Export options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports & Analytics'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Exportable compliance documentation and university statistics'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _triggerExport('PDF'),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: Text('Export PDF'.tr(context), style: TextStyle(fontSize: 10.sp)),
                      ),
                      SizedBox(width: 8.w),
                      TextButton.icon(
                        onPressed: () => _triggerExport('Excel'),
                        icon: const Icon(Icons.table_chart, color: Colors.green),
                        label: Text('Export Excel'.tr(context), style: TextStyle(fontSize: 10.sp)),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(icon: const Icon(Icons.print), onPressed: () => _triggerExport('Printer')),
                    ],
                  )
                ],
              ),
              SizedBox(height: 16.h),

              // Filter Selectors Panel
              _buildFiltersPanel(db),
              SizedBox(height: 16.h),

              // Executive Summary Grid Cards
              Text('Executive Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildExecutiveSummaryCards(total, completed, pending, inProgress, review, overdue, completionRate, avgCompletionTime),
              SizedBox(height: 24.h),

              // Visual Charts Panel
              Text('Detailed Performance Charts'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildChartsGrid(db, completed, inProgress, pending, review, overdue),
            ],
          ),
        ),
      ),
    );
  }

  // --- FILTERS PANEL ---
  Widget _buildFiltersPanel(MockDatabase db) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              _buildDropdown('Department', _selectedDept, ['All', 'Computer Science', 'Engineering', 'IT Services'], (v) => setState(() => _selectedDept = v!)),
              SizedBox(width: 10.w),
              _buildDropdown('Team', _selectedTeam, ['All', ...db.teams.map((t) => t.name)], (v) => setState(() => _selectedTeam = v!)),
              SizedBox(width: 10.w),
              _buildDropdown('User', _selectedUser, ['All', ...db.users.map((u) => u.id)], (v) => setState(() => _selectedUser = v!), labelMap: {'All': 'All Users'.tr(context), ...{for (var u in db.users) u.id: u.fullName}}),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildDropdown('Priority', _selectedPriority, ['All', 'HIGH', 'MEDIUM', 'LOW'], (v) => setState(() => _selectedPriority = v!)),
              SizedBox(width: 10.w),
              _buildDropdown('Status', _selectedStatus, ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'], (v) => setState(() => _selectedStatus = v!)),
              SizedBox(width: 10.w),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(context: context, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                    if (range != null) setState(() => _selectedDateRange = range);
                  },
                  icon: const Icon(Icons.date_range, size: 14),
                  label: Text(_selectedDateRange == null ? 'Date Range'.tr(context) : 'Selected', style: TextStyle(fontSize: 11.sp)),
                  style: TextButton.styleFrom(side: const BorderSide(color: AppColors.border)),
                ),
              ),
              if (_selectedDateRange != null) ...[
                IconButton(icon: const Icon(Icons.clear, color: AppColors.danger), onPressed: () => setState(() => _selectedDateRange = null))
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged, {Map<String, String>? labelMap}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(label.tr(context), style: TextStyle(fontSize: 11.sp)),
            items: options.map((o) {
              final text = labelMap != null ? (labelMap[o] ?? o) : o.tr(context);
              return DropdownMenuItem(value: o, child: Text(text, style: TextStyle(fontSize: 11.sp)));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
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
            mainAxisExtent: 72.h,
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
  Widget _buildChartsGrid(MockDatabase db, int comp, int prog, int pend, int rev, int ov) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final double total = (comp + prog + pend + rev + ov).toDouble();

    final csTotal = db.tasks.where((t) => t.taskDepartment == 'Computer Science').length;
    final itTotal = db.tasks.where((t) => t.taskDepartment == 'IT Services' || t.taskDepartment == 'IT').length;
    final engTotal = db.tasks.where((t) => t.taskDepartment == 'Engineering').length;

    final csOverdue = db.tasks.where((t) => t.taskDepartment == 'Computer Science' && t.status == 'Overdue').length;
    final itOverdue = db.tasks.where((t) => t.taskDepartment == 'IT Services' && t.status == 'Overdue').length;
    final engOverdue = db.tasks.where((t) => t.taskDepartment == 'Engineering' && t.status == 'Overdue').length;

    final List<Widget> chartWidgets = [
      // 1. Task Status Donut Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Status Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
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
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
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
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
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

      // 4. Department Task Count Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Department Performance'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
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
      ),

      // 5. Team Task Completion Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Performance'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: csTotal.toDouble(), color: Colors.teal, width: 10.w)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 6. User Task Completion Count
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Performance'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: csTotal.toDouble(), color: Colors.purple, width: 10.w)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 7. Priority Pie Distribution Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: total == 0
                  ? Center(child: Text('No tasks available.'.tr(context)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 24.r,
                        sections: [
                          PieChartSectionData(color: AppColors.danger, value: 3.0, radius: 26.r, title: 'H', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.primary, value: 5.0, radius: 26.r, title: 'M', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                          PieChartSectionData(color: AppColors.success, value: 2.0, radius: 26.r, title: 'L', titleStyle: TextStyle(fontSize: 8.sp, color: Colors.white)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // 8. Completion Time per department CS: 5.5, IT: 6.8, ENG: 7.2
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completion Time'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5.5, color: AppColors.primary, width: 10.w)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6.8, color: Colors.teal, width: 10.w)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7.2, color: Colors.indigo, width: 10.w)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 9. Overdue Analysis per department CS: 1, IT: 2, ENG: 0
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overdue Analysis'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 82.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: csOverdue.toDouble(), color: AppColors.danger, width: 10.w)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: itOverdue.toDouble(), color: AppColors.danger, width: 10.w)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: engOverdue.toDouble(), color: AppColors.danger, width: 10.w)]),
                  ],
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
            mainAxisExtent: 180.h,
          ),
          itemCount: chartWidgets.length,
          itemBuilder: (context, idx) => chartWidgets[idx],
        );
      },
    );
  }
}
