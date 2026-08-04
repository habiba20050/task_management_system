import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../shared/features/language/cubit/language_cubit.dart';
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
    final db = MockDatabase.instance;
    final String currentUserId = 'U2'; // Manager User
    final user = db.users.firstWhere((u) => u.id == currentUserId, orElse: () => db.users.first);
    final String myDepartment = user.department;

    final myTeams = db.teams.where((t) => t.department == myDepartment).toList();
    final myUserIds = myTeams.expand((t) => t.memberIds).toSet()..addAll(myTeams.map((t) => t.leaderId));
    final myUsers = db.users.where((u) => myUserIds.contains(u.id)).toList();

    // Filter computation
    final filteredTasks = db.tasks.where((t) {
      if (t.taskDepartment != myDepartment) return false;
      
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

      return matchesTeam && matchesUser && matchesPriority && matchesStatus && matchesDate;
    }).toList();

    // KPI Cards data
    final total = filteredTasks.length;
    final completed = filteredTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final pending = filteredTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final inProgress = filteredTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final review = filteredTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdue = filteredTasks.where((t) => t.status == 'Overdue').length;
    final double completionRate = total == 0 ? 0.0 : (completed / total) * 100;
    
    // Average durations (mocked)
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
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports & Analytics'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Exportable compliance documentation and university statistics'.tr(context),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.w,
                    children: [
                      TextButton.icon(
                        onPressed: () => _triggerExport('PDF'),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: Text('Export PDF'.tr(context), style: TextStyle(fontSize: 10.sp)),
                      ),
                      TextButton.icon(
                        onPressed: () => _triggerExport('Excel'),
                        icon: const Icon(Icons.table_chart, color: Colors.green),
                        label: Text('Export Excel'.tr(context), style: TextStyle(fontSize: 10.sp)),
                      ),
                      IconButton(icon: const Icon(Icons.print), onPressed: () => _triggerExport('Printer')),
                    ],
                  )
                ],
              ),
              SizedBox(height: 16.h),

              // Filter Selectors Panel
              _buildFiltersPanel(myTeams, myUsers),
              SizedBox(height: 16.h),

              // Executive Summary Grid Cards
              Text('Executive Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildExecutiveSummaryCards(total, completed, pending, inProgress, review, overdue, rate: completionRate, time: avgCompletionTime),
              SizedBox(height: 24.h),

              // Visual Charts Panel
              Text('Detailed Performance Charts'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),
              _buildChartsGrid(db, comp: completed, prog: inProgress, pend: pending, rev: review, ov: overdue, myDepartment: myDepartment, myTeams: myTeams),
            ],
          ),
        ),
      ),
    );
  }

  // --- FILTERS PANEL ---
  Widget _buildFiltersPanel(List<MockTeam> myTeams, List<MockUser> myUsers) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 900 ? 5 : (width >= 560 ? 3 : 2);
              final gap = 12.w;
              final itemWidth = (width - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 12.h,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildFilterField(
                      label: 'Team',
                      icon: Icons.group_outlined,
                      value: _selectedTeam == 'All' ? 'All'.tr(context) : _selectedTeam,
                      options: ['All', ...myTeams.map((t) => t.name)],
                      onSelected: (val) => setState(() => _selectedTeam = val),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildFilterField(
                      label: 'Member',
                      icon: Icons.person_outline,
                      value: _selectedUser == 'All' ? 'All'.tr(context) : (myUsers.firstWhere((u) => u.id == _selectedUser, orElse: () => myUsers.first).fullName),
                      options: ['All', ...myUsers.map((u) => u.id)],
                      labelMap: {'All': 'All'.tr(context), ...{for (var u in myUsers) u.id: u.fullName}},
                      onSelected: (val) => setState(() => _selectedUser = val),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildFilterField(
                      label: 'Priority',
                      icon: Icons.flag_outlined,
                      value: _selectedPriority.tr(context),
                      options: ['All', 'HIGH', 'MEDIUM', 'LOW'],
                      labelMap: {'All': 'All'.tr(context), 'HIGH': 'HIGH'.tr(context), 'MEDIUM': 'MEDIUM'.tr(context), 'LOW': 'LOW'.tr(context)},
                      onSelected: (val) => setState(() => _selectedPriority = val),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildFilterField(
                      label: 'Status',
                      icon: Icons.circle_outlined,
                      value: _selectedStatus.tr(context),
                      options: ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'],
                      onSelected: (val) => setState(() => _selectedStatus = val),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDateRangeField(context),
                  ),
                ],
              );
            },
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        PopupMenuButton<String>(
          initialValue: options.contains(value) ? value : options.first,
          onSelected: onSelected,
          offset: Offset(0, 48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          itemBuilder: (context) => options.map((o) {
            final text = labelMap != null ? (labelMap[o] ?? o) : o.tr(context);
            final isSelected = o == value;
            return PopupMenuItem(
              value: o,
              height: 38.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) Icon(Icons.check, size: 16, color: AppColors.primary) else SizedBox(width: 16.w),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(text,
                        style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }).toList(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Expanded(child: Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 16.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date Range'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        PopupMenuButton<String>(
          offset: Offset(0, 48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          onSelected: (val) async {
            if (val == 'pick') {
              final range = await showDialog<DateTimeRange>(
                context: context,
                builder: (context) {
                  DateTime? start = _selectedDateRange?.start;
                  DateTime? end = _selectedDateRange?.end;
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          width: 400.w,
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Date Range'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 8.h),
                              Text('Choose the start and end dates for your filter.'.tr(context), style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                              SizedBox(height: 24.h),
                              _buildDateSelectionCard(
                                title: 'Start Date'.tr(context),
                                date: start,
                                icon: Icons.calendar_today,
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: start ?? DateTime.now(),
                                    firstDate: DateTime(2026),
                                    lastDate: DateTime(2030),
                                    builder: _buildDatePickerTheme,
                                  );
                                  if (d != null) setStateDialog(() => start = d);
                                },
                              ),
                              SizedBox(height: 16.h),
                              _buildDateSelectionCard(
                                title: 'End Date'.tr(context),
                                date: end,
                                icon: Icons.event,
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: end ?? start ?? DateTime.now(),
                                    firstDate: DateTime(2026),
                                    lastDate: DateTime(2030),
                                    builder: _buildDatePickerTheme,
                                  );
                                  if (d != null) setStateDialog(() => end = d);
                                },
                              ),
                              SizedBox(height: 32.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: 12.w),
                                  ElevatedButton(
                                    onPressed: (start != null && end != null && !end!.isBefore(start!))
                                        ? () => Navigator.pop(context, DateTimeRange(start: start!, end: end!))
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    ),
                                    child: Text('Apply'.tr(context), style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
              if (range != null) setState(() => _selectedDateRange = range);
            } else if (val == 'clear') {
              setState(() => _selectedDateRange = null);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 38.h,
              value: 'pick',
              child: Row(children: [Icon(Icons.date_range, size: 16, color: AppColors.primary), SizedBox(width: 8.w), Text('Pick Date Range'.tr(context), style: TextStyle(fontSize: 13.sp))]),
            ),
            if (_selectedDateRange != null)
              PopupMenuItem(
                height: 38.h,
                value: 'clear',
                child: Row(children: [Icon(Icons.clear, size: 16, color: AppColors.danger), SizedBox(width: 8.w), Text('Clear'.tr(context), style: TextStyle(fontSize: 13.sp, color: AppColors.danger))]),
              ),
          ],
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _selectedDateRange != null ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _selectedDateRange != null ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 14.sp, color: _selectedDateRange != null ? AppColors.primary : AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _selectedDateRange == null
                              ? 'Select'.tr(context)
                              : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _selectedDateRange != null ? AppColors.primary : AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 16.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: AppColors.textPrimary),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold))),
      ),
      child: Transform.scale(scale: 1.15, child: child!),
    );
  }

  Widget _buildDateSelectionCard({required String title, required DateTime? date, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12.r)),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 20)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 4.h),
                  Text(date != null ? DateFormat('MMMM d, yyyy').format(date) : 'Select date'.tr(context), style: TextStyle(fontSize: 13.sp, color: date != null ? AppColors.textSecondary : Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- EXECUTIVE SUMMARY CARDS ---
  Widget _buildExecutiveSummaryCards(int total, int completed, int pending, int inProgress, int review, int overdue, {required double rate, required double time}) {
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
  Widget _buildChartsGrid(MockDatabase db, {required int comp, required int prog, required int pend, required int rev, required int ov, required String myDepartment, required List<MockTeam> myTeams}) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final double total = (comp + prog + pend + rev + ov).toDouble();

    final displayTeams = myTeams.take(3).toList(); // Show top 3 teams in charts to prevent clutter

    int getTeamTaskCount(String teamId) => db.tasks.where((t) => t.taskDepartment == myDepartment && t.assignedTeamId == teamId).length;
    int getTeamOverdueCount(String teamId) => db.tasks.where((t) => t.taskDepartment == myDepartment && t.assignedTeamId == teamId && t.status == 'Overdue').length;

    final List<Widget> chartWidgets = [
      // 1. Task Status Donut Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Status Distribution'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 130.h,
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
              height: 130.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: const [FlSpot(0, 1), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3)], color: AppColors.success, barWidth: 2.w),
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
              height: 130.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: const [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 5), FlSpot(3, 4), FlSpot(4, 7)], color: AppColors.primary, barWidth: 2.w),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. Team Task Count Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Workload'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 130.h,
              child: displayTeams.isEmpty ? Center(child: Text('No Teams'.tr(context))) : BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(displayTeams.length, (index) {
                     return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: getTeamTaskCount(displayTeams[index].id).toDouble(), color: AppColors.primary, width: 10.w)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // 5. Team Overdue Bar Chart
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Overdue Tasks'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 130.h,
              child: displayTeams.isEmpty ? Center(child: Text('No Teams'.tr(context))) : BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(displayTeams.length, (index) {
                     return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: getTeamOverdueCount(displayTeams[index].id).toDouble(), color: AppColors.danger, width: 10.w)]);
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
            SizedBox(height: 10.h),
            SizedBox(
              height: 130.h,
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
            mainAxisExtent: 220.h,
          ),
          itemCount: chartWidgets.length,
          itemBuilder: (context, idx) => chartWidgets[idx],
        );
      },
    );
  }
}
