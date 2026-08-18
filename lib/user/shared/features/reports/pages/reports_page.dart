import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';

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
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  String _timeframe = 'Weekly';
  DateTimeRange? _selectedDateRange;

  void _triggerExport(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg.r)),
        title: Row(
          children: [
            Icon(
              format == 'PDF' ? Icons.picture_as_pdf : (format == 'Excel' ? Icons.table_chart : Icons.print),
              color: format == 'PDF' ? AppColors.danger : (format == 'Excel' ? AppColors.success : AppColors.primary),
            ),
            SizedBox(width: 8.w),
            Text('${'Exporting Report'.tr(context)} ($format)'),
          ],
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Expanded(child: Text('Generating document... Please wait.'.tr(context))),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'Successfully exported report to'.tr(context)} $format'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedDept = 'All';
      _selectedTeam = 'All';
      _selectedUser = 'All';
      _selectedStatus = 'All';
      _selectedPriority = 'All';
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final currentUser = db.users.firstWhere((u) => u.id == currentUserId, orElse: () => db.users.first);
    final userRole = currentUser.role;

    final leaderTeam = db.teams.firstWhere(
      (tm) => tm.leaderId == currentUserId,
      orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
    );

    // Filter computation
    final filteredTasks = db.tasks.where((t) {
      final matchesDept = (userRole == 'Team Leader' || userRole == 'Manager')
          ? t.taskDepartment == currentUser.department
          : (_selectedDept == 'All' || t.taskDepartment == _selectedDept);

      final team = db.teams.firstWhere(
        (tm) => tm.id == t.assignedTeamId,
        orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: []),
      );

      final matchesTeam = (userRole == 'Team Leader')
          ? t.assignedTeamId == leaderTeam.id
          : (_selectedTeam == 'All' || team.name == _selectedTeam);
      final matchesUser = _selectedUser == 'All' ||
          t.currentOwnerId == _selectedUser ||
          t.customAssigneeIds.contains(_selectedUser);
      final matchesStatus = _selectedStatus == 'All' || t.status == _selectedStatus;
      final matchesPriority = _selectedPriority == 'All' || t.priority == _selectedPriority;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final d = DateTime.tryParse(t.deadline);
        if (d != null) {
          matchesDate = d.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              d.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }
      return matchesDept && matchesTeam && matchesUser && matchesStatus && matchesPriority && matchesDate;
    }).toList();

    // Data Metrics
    final totalTasks = filteredTasks.length;
    final completedTasks = filteredTasks.where((t) => t.status == 'Completed' || t.status == 'Approved').length;
    final inProgressTasks = filteredTasks.where((t) => t.status == 'In Progress' || t.status == 'Needs Changes').length;
    final pendingTasks = filteredTasks.where((t) => t.status == 'Pending' || t.status == 'Assigned').length;
    final reviewTasks = filteredTasks.where((t) => t.status == 'Submitted' || t.status == 'Under Review').length;
    final overdueTasks = filteredTasks.where((t) => t.status == 'Overdue').length;
    final completionRate = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 20.w : 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Toolbar
              _buildHeaderToolbar(context),
              SizedBox(height: 16.h),

              // 2. Enlarged Filter Bar matching Dashboard AppCard style
              _buildEnlargedFilterBar(context, db),
              SizedBox(height: 20.h),

              // 3. Executive KPI Summary Cards using Dashboard StatCard
              _buildKpiMetricsGrid(context, totalTasks, completedTasks, inProgressTasks, pendingTasks, overdueTasks, completionRate),
              SizedBox(height: 20.h),

              // 4. Primary Chart Section Row 1 (Wrapped in AppCard)
              _buildRow1Charts(context, totalTasks, completedTasks, inProgressTasks, pendingTasks, reviewTasks, overdueTasks),
              SizedBox(height: 20.h),

              // 5. Row 2: Tables & Priority Donut (Wrapped in AppCard)
              _buildRow2TablesAndPriority(context, db),
              SizedBox(height: 20.h),

              // 6. Row 3: Operational Breakdown (Wrapped in AppCard)
              _buildRow3OperationalBreakdown(context, db),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. HEADER TOOLBAR ---
  Widget _buildHeaderToolbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics'.tr(context),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Detailed insights and performance overview'.tr(context),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _triggerExport('PDF'),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 16),
              label: Text('Export PDF'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md.r)),
              ),
            ),
            SizedBox(width: 10.w),
            ElevatedButton.icon(
              onPressed: () => _triggerExport('Excel'),
              icon: const Icon(Icons.table_chart, color: Colors.white, size: 16),
              label: Text('Export Excel'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md.r)),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _triggerExport('Printer'),
              icon: const Icon(Icons.print_outlined, color: AppColors.textSecondary),
              tooltip: 'Print Report'.tr(context),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. ENLARGED FILTER BAR MATCHING DASHBOARD APPCARD STYLE ---
  Widget _buildEnlargedFilterBar(BuildContext context, MockDatabase db) {
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final currentUser = db.users.firstWhere((u) => u.id == currentUserId, orElse: () => db.users.first);
    final userRole = currentUser.role;

    return AppCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final cols = constraints.maxWidth < 600
                  ? 2
                  : constraints.maxWidth < 1000
                      ? 3
                      : 4;
              final fieldWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: 16.h,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  // 1. Date Range
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Date Range'.tr(context),
                      child: InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2025, 1, 1),
                            lastDate: DateTime(2027, 12, 31),
                            initialDateRange: _selectedDateRange ?? DateTimeRange(start: DateTime(2025, 8, 1), end: DateTime(2025, 8, 31)),
                          );
                          if (range != null) setState(() => _selectedDateRange = range);
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _selectedDateRange == null
                                      ? 'Select'.tr(context)
                                      : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Department
                  if (userRole != 'Team Leader' && userRole != 'Manager')
                    SizedBox(
                      width: fieldWidth,
                      child: _buildFilterField(
                        label: 'Department'.tr(context),
                        child: _buildEnlargedDropdownBox(
                          icon: Icons.business_outlined,
                          value: _selectedDept,
                          items: ['All', 'Computer Science', 'Engineering', 'IT Services', 'Documentation', 'Administration'],
                          labelMap: {'All': 'All Departments'.tr(context)},
                          onChanged: (v) => setState(() => _selectedDept = v),
                        ),
                      ),
                    ),

                  // 3. Team
                  if (userRole != 'Team Leader')
                    SizedBox(
                      width: fieldWidth,
                      child: _buildFilterField(
                        label: 'Team'.tr(context),
                        child: _buildEnlargedDropdownBox(
                          icon: Icons.group_outlined,
                          value: _selectedTeam,
                          items: ['All', ...db.teams.map((t) => t.name)],
                          labelMap: {'All': 'All Teams'.tr(context)},
                          onChanged: (v) => setState(() => _selectedTeam = v),
                        ),
                      ),
                    ),

                  // 4. User
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'User'.tr(context),
                      child: _buildEnlargedDropdownBox(
                        icon: Icons.person_outline,
                        value: _selectedUser,
                        items: ['All', ...db.users.map((u) => u.id)],
                        labelMap: {'All': 'All Users'.tr(context), ...{for (var u in db.users) u.id: u.fullName}},
                        onChanged: (v) => setState(() => _selectedUser = v),
                      ),
                    ),
                  ),

                  // 5. Task Status
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Task Status'.tr(context),
                      child: _buildEnlargedDropdownBox(
                        icon: Icons.circle_outlined,
                        value: _selectedStatus,
                        items: ['All', 'Completed', 'In Progress', 'Pending', 'Under Review', 'Overdue'],
                        labelMap: {'All': 'All Statuses'.tr(context)},
                        onChanged: (v) => setState(() => _selectedStatus = v),
                      ),
                    ),
                  ),

                  // 6. Reset Button
                  SizedBox(
                    width: fieldWidth,
                    height: 48.h,
                    child: TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                      label: Text('Reset'.tr(context), style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _buildEnlargedDropdownBox({
    required IconData icon,
    required String value,
    required List<String> items,
    required Map<String, String> labelMap,
    required ValueChanged<String> onChanged,
  }) {
    final displayValue = labelMap[value] ?? value.tr(context);
    return PopupMenuButton<String>(
      initialValue: items.contains(value) ? value : items.first,
      onSelected: onChanged,
      offset: Offset(0, 48.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => items.map((o) {
        final text = labelMap[o] ?? o.tr(context);
        final isSelected = o == value;
        return PopupMenuItem(
          value: o,
          height: 38.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) const Icon(Icons.check, size: 16, color: AppColors.primary) else const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: double.infinity,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // --- 3. TOP 6 EXECUTIVE KPI METRICS USING DASHBOARD STATCARD ---
  Widget _buildKpiMetricsGrid(
    BuildContext context,
    int total,
    int comp,
    int prog,
    int pend,
    int ov,
    double rate,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = constraints.maxWidth < 650 ? 2 : (constraints.maxWidth < 1100 ? 3 : 6);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 76.h,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            final cards = [
              StatCard(title: 'Total Tasks'.tr(context), value: '$total', icon: Icons.playlist_add_check, accentColor: AppColors.primary),
              StatCard(title: 'Completed'.tr(context), value: '$comp', icon: Icons.check_circle_outline, accentColor: AppColors.success),
              StatCard(title: 'In Progress'.tr(context), value: '$prog', icon: Icons.pending_actions, accentColor: AppColors.inProgress),
              StatCard(title: 'Pending'.tr(context), value: '$pend', icon: Icons.hourglass_empty, accentColor: Colors.purple),
              StatCard(title: 'Overdue'.tr(context), value: '$ov', icon: Icons.error_outline, accentColor: AppColors.danger),
              StatCard(title: 'Completion Rate'.tr(context), value: '${rate.toInt()}%', icon: Icons.pie_chart_outline, accentColor: Colors.teal),
            ];
            return cards[index];
          },
        );
      },
    );
  }

  // --- 4. PRIMARY CHARTS ROW 1 (ALL WRAPPED IN APPCARD) ---
  Widget _buildRow1Charts(
    BuildContext context,
    int total,
    int comp,
    int prog,
    int pend,
    int rev,
    int ov,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildTaskStatusDistributionCard(total, comp, prog, pend, rev, ov),
              SizedBox(height: 16.h),
              _buildTasksOverTimeCard(),
              SizedBox(height: 16.h),
              _buildCompletionRateTrendCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildTaskStatusDistributionCard(total, comp, prog, pend, rev, ov)),
            SizedBox(width: 14.w),
            Expanded(flex: 4, child: _buildTasksOverTimeCard()),
            SizedBox(width: 14.w),
            Expanded(flex: 3, child: _buildCompletionRateTrendCard()),
          ],
        );
      },
    );
  }

  // 1. Task Status Distribution (Donut Chart with Center Text & Legends inside AppCard)
  Widget _buildTaskStatusDistributionCard(int total, int comp, int prog, int pend, int rev, int ov) {
    final double safeTotal = total == 0 ? 1 : total.toDouble();

    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Status Distribution'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 16.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 44.r,
                          sections: [
                            PieChartSectionData(color: AppColors.success, value: comp == 0 ? 1 : comp.toDouble(), radius: 24.r, showTitle: false),
                            PieChartSectionData(color: AppColors.inProgress, value: prog.toDouble(), radius: 24.r, showTitle: false),
                            PieChartSectionData(color: Colors.orange, value: pend.toDouble(), radius: 24.r, showTitle: false),
                            PieChartSectionData(color: Colors.purple, value: rev.toDouble(), radius: 24.r, showTitle: false),
                            PieChartSectionData(color: AppColors.danger, value: ov.toDouble(), radius: 24.r, showTitle: false),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$total', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Total Tasks'.tr(context), style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusLegendRow('Completed', comp, (comp / safeTotal) * 100, AppColors.success),
                      _buildStatusLegendRow('In Progress', prog, (prog / safeTotal) * 100, AppColors.inProgress),
                      _buildStatusLegendRow('Pending', pend, (pend / safeTotal) * 100, Colors.orange),
                      _buildStatusLegendRow('Under Review', rev, (rev / safeTotal) * 100, Colors.purple),
                      _buildStatusLegendRow('Overdue', ov, (ov / safeTotal) * 100, AppColors.danger),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegendRow(String label, int count, double pct, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(width: 8.w, height: 8.h, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 6.w),
          Expanded(child: Text(label.tr(context), style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Text('$count', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(width: 4.w),
          Text('(${pct.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
        ],
      ),
    );
  }

  // 2. Tasks Over Time Multi-line Chart inside AppCard
  Widget _buildTasksOverTimeCard() {
    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasks Over Time'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _timeframe,
                  isDense: true,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                  items: ['Daily', 'Weekly', 'Monthly'].map((t) => DropdownMenuItem(value: t, child: Text(t.tr(context)))).toList(),
                  onChanged: (v) => setState(() => _timeframe = v!),
                ),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildSimpleLegendDot('Completed', AppColors.success),
              SizedBox(width: 12.w),
              _buildSimpleLegendDot('In Progress', AppColors.inProgress),
              SizedBox(width: 12.w),
              _buildSimpleLegendDot('Overdue', AppColors.danger),
            ],
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24.w,
                      getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22.h,
                      getTitlesWidget: (v, m) {
                        const labels = ['28 Jul-03 Aug', '04 Aug-10 Aug', '11 Aug-17 Aug', '18 Aug-24 Aug', '25 Aug-31 Aug'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(labels[idx], style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 18), FlSpot(1, 28), FlSpot(2, 22), FlSpot(3, 28), FlSpot(4, 25)],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.5.w,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 8), FlSpot(1, 14), FlSpot(2, 11), FlSpot(3, 12), FlSpot(4, 15)],
                    isCurved: true,
                    color: AppColors.inProgress,
                    barWidth: 2.5.w,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 3), FlSpot(4, 4)],
                    isCurved: true,
                    color: AppColors.danger,
                    barWidth: 2.5.w,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Completion Rate Over Time (%) Area Line Chart inside AppCard
  Widget _buildCompletionRateTrendCard() {
    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Completion Rate Over Time (%)'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 20.h),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28.w,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22.h,
                      getTitlesWidget: (v, m) {
                        const labels = ['28 Jul', '04 Aug', '11 Aug', '18 Aug', '25 Aug'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(labels[idx], style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 42), FlSpot(1, 48), FlSpot(2, 52), FlSpot(3, 56), FlSpot(4, 59)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3.w,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.h, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label.tr(context), style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // --- 5. ROW 2: TABLES & PRIORITY DONUT (ALL WRAPPED IN APPCARD) ---
  Widget _buildRow2TablesAndPriority(BuildContext context, MockDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildTopOverdueTasksCard(db),
              SizedBox(height: 16.h),
              _buildTopPerformersCard(db),
              SizedBox(height: 16.h),
              _buildPriorityDistributionCard(db),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildTopOverdueTasksCard(db)),
            SizedBox(width: 14.w),
            Expanded(flex: 4, child: _buildTopPerformersCard(db)),
            SizedBox(width: 14.w),
            Expanded(flex: 3, child: _buildPriorityDistributionCard(db)),
          ],
        );
      },
    );
  }

  // Table 1: Top 5 Overdue Tasks inside AppCard
  Widget _buildTopOverdueTasksCard(MockDatabase db) {
    final overdueList = db.tasks.where((t) => t.status == 'Overdue').take(5).toList();

    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 5 Overdue Tasks'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(24),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    children: [
                      _buildTableHeader('#'),
                      _buildTableHeader('Task'),
                      _buildTableHeader('Assigned To'),
                      _buildTableHeader('Due Date'),
                      _buildTableHeader('Days Overdue'),
                    ],
                  ),
                  ...overdueList.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final t = entry.value;
                    final assignee = db.users.firstWhere((u) => u.id == t.assignedMemberId, orElse: () => db.users.first);

                    return TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.background))),
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text('$idx', style: TextStyle(fontSize: 10.sp, color: Colors.grey))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text(t.title, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text(assignee.fullName, style: TextStyle(fontSize: 10.sp), overflow: TextOverflow.ellipsis)),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text(t.deadline, style: TextStyle(fontSize: 10.sp, color: AppColors.danger))),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                            child: Text('3 days', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColors.danger)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: TextButton(
              onPressed: () => context.go('/tasks'),
              child: Text('View All Overdue Tasks'.tr(context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  // Table 2: Top Performers (By Completion Rate) inside AppCard
  Widget _buildTopPerformersCard(MockDatabase db) {
    final performers = List<MockUser>.from(db.users.where((u) => u.role == 'Team Member'))..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final top5 = performers.take(5).toList();

    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Performers (By Completion Rate)'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(24),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(2.5),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    children: [
                      _buildTableHeader('#'),
                      _buildTableHeader('User'),
                      _buildTableHeader('Completion Rate'),
                      _buildTableHeader('Completed Tasks'),
                    ],
                  ),
                  ...top5.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final u = entry.value;
                    final score = u.finalScore.toInt();

                    return TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.background))),
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text('$idx', style: TextStyle(fontSize: 10.sp, color: Colors.grey))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text(u.fullName, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: LinearProgressIndicator(value: score / 100.0, color: AppColors.success, backgroundColor: AppColors.border, minHeight: 6.h),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text('$score%', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text('14', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold))),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: TextButton(
              onPressed: () => context.go('/evaluations'),
              child: Text('View All Performance'.tr(context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(text.tr(context), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  // Tasks by Priority Donut Chart inside AppCard
  Widget _buildPriorityDistributionCard(MockDatabase db) {
    final total = db.tasks.length;
    final low = db.tasks.where((t) => t.priority == 'LOW').length;
    final med = db.tasks.where((t) => t.priority == 'MEDIUM').length;
    final high = db.tasks.where((t) => t.priority == 'HIGH').length;
    final critical = db.tasks.where((t) => t.priority == 'CRITICAL' || t.priority == 'URGENT').length;
    final safeTotal = total == 0 ? 1 : total.toDouble();

    return AppCard(
      height: 310.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks by Priority'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 16.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 44.r,
                          sections: [
                            PieChartSectionData(color: AppColors.success, value: low == 0 ? 1 : low.toDouble(), radius: 22.r, showTitle: false),
                            PieChartSectionData(color: Colors.amber, value: med.toDouble(), radius: 22.r, showTitle: false),
                            PieChartSectionData(color: AppColors.danger, value: high.toDouble(), radius: 22.r, showTitle: false),
                            PieChartSectionData(color: Colors.purple, value: critical.toDouble(), radius: 22.r, showTitle: false),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$total', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Total Tasks'.tr(context), style: TextStyle(fontSize: 8.5.sp, color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusLegendRow('Low', low, (low / safeTotal) * 100, AppColors.success),
                      _buildStatusLegendRow('Medium', med, (med / safeTotal) * 100, Colors.amber),
                      _buildStatusLegendRow('High', high, (high / safeTotal) * 100, AppColors.danger),
                      _buildStatusLegendRow('Critical', critical, (critical / safeTotal) * 100, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. ROW 3: OPERATIONAL BREAKDOWN (ALL WRAPPED IN APPCARD) ---
  Widget _buildRow3OperationalBreakdown(BuildContext context, MockDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildAvgCompletionTimeCard(),
              SizedBox(height: 16.h),
              _buildOnTimeVsLateCard(),
              SizedBox(height: 16.h),
              _buildTasksByDepartmentCard(db),
              SizedBox(height: 16.h),
              _buildRecentActivityCard(db),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAvgCompletionTimeCard()),
            SizedBox(width: 14.w),
            Expanded(child: _buildOnTimeVsLateCard()),
            SizedBox(width: 14.w),
            Expanded(child: _buildTasksByDepartmentCard(db)),
            SizedBox(width: 14.w),
            Expanded(child: _buildRecentActivityCard(db)),
          ],
        );
      },
    );
  }

  // Average Completion Time Card + Sparkline inside AppCard
  Widget _buildAvgCompletionTimeCard() {
    return AppCard(
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Average Completion Time'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 14.h),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary, size: 24),
              SizedBox(width: 8.w),
              Text('6.2 Days', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 4.h),
          Text('↓ 0.8 days vs last month'.tr(context), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.success)),
          SizedBox(height: 16.h),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 8), FlSpot(1, 6), FlSpot(2, 7.5), FlSpot(3, 5.5), FlSpot(4, 6.2)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.w,
                    dotData: const FlDotData(show: false),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // On Time vs Late Tasks Donut inside AppCard
  Widget _buildOnTimeVsLateCard() {
    return AppCard(
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('On Time vs Late Tasks'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28.r,
                      sections: [
                        PieChartSectionData(color: AppColors.success, value: 86, radius: 18.r, showTitle: false),
                        PieChartSectionData(color: AppColors.danger, value: 42, radius: 18.r, showTitle: false),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimpleLegendDot('On Time: 86 (67.2%)', AppColors.success),
                    SizedBox(height: 8.h),
                    _buildSimpleLegendDot('Late: 42 (32.8%)', AppColors.danger),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tasks by Department Bar Chart inside AppCard
  Widget _buildTasksByDepartmentCard(MockDatabase db) {
    return AppCard(
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks by Department'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 65.w,
                      getTitlesWidget: (v, m) {
                        const depts = ['Admin', 'Dev', 'IT Support', 'Docs', 'QA'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < depts.length) {
                          return Text(depts[idx], style: TextStyle(fontSize: 8.5.sp, color: AppColors.textSecondary));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 35, color: AppColors.success, width: 8.w)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 28, color: AppColors.inProgress, width: 8.w)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 40, color: AppColors.danger, width: 8.w)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 22, color: AppColors.success, width: 8.w)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 18, color: AppColors.inProgress, width: 8.w)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recent Activity Feed inside AppCard
  Widget _buildRecentActivityCard(MockDatabase db) {
    return AppCard(
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem('New task "UI Design Update" created', '5 min ago', Icons.add_circle_outline, AppColors.primary),
                _buildActivityItem('Task "System Testing" submitted', '15 min ago', Icons.check_circle_outline, AppColors.success),
                _buildActivityItem('Task "Server Configuration" overdue', '30 min ago', Icons.warning_amber_rounded, AppColors.danger),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => context.go('/audit-logs'),
              child: Text('View All Activity'.tr(context), style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 6.w),
          Expanded(child: Text(text.tr(context), style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Text(time, style: TextStyle(fontSize: 8.5.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}
