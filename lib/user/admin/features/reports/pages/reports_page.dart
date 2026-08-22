import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../../core/localization/translate_extension.dart';
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
  String _timeframe = 'Weekly';
  DateTimeRange? _selectedDateRange;

  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _gradientChip(IconData icon, Color color, {double size = 44}) {
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

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title.tr(context),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _triggerExport(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(
              format == 'PDF' ? Icons.picture_as_pdf : (format == 'Excel' ? Icons.table_chart : Icons.print),
              color: format == 'PDF' ? AppColors.danger : (format == 'Excel' ? AppColors.success : AppColors.primary),
            ),
            SizedBox(width: 12.w),
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
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    // Filter computation
    final filteredTasks = db.tasks.where((t) {
      final matchesDept = _selectedDept == 'All' || t.taskDepartment == _selectedDept;
      final team = db.teams.firstWhere((tm) => tm.id == t.assignedTeamId, orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: []));
      final matchesTeam = _selectedTeam == 'All' || team.name == _selectedTeam;
      final matchesUser = _selectedUser == 'All' || t.currentOwnerId == _selectedUser || t.customAssigneeIds.contains(_selectedUser);
      final matchesStatus = _selectedStatus == 'All' || t.status == _selectedStatus;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final d = DateTime.tryParse(t.deadline);
        if (d != null) {
          matchesDate = d.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              d.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }
      return matchesDept && matchesTeam && matchesUser && matchesStatus && matchesDate;
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
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderToolbar(context),
              SizedBox(height: 24.h),
              _buildFilterBar(context, db),
              SizedBox(height: 24.h),
              _buildKpiMetricsGrid(context, totalTasks, completedTasks, inProgressTasks, pendingTasks, overdueTasks, completionRate),
              
              SizedBox(height: 32.h),
              _sectionTitle('System Overview', Icons.dashboard_outlined),
              SizedBox(height: 16.h),
              _buildSystemOverviewRow(context, totalTasks, comp: completedTasks, prog: inProgressTasks, pend: pendingTasks, rev: reviewTasks, ov: overdueTasks),
              
              SizedBox(height: 32.h),
              _sectionTitle('Department Analytics', Icons.domain_outlined),
              SizedBox(height: 16.h),
              _buildDepartmentAnalyticsRow(context, db),
              
              SizedBox(height: 32.h),
              _sectionTitle('Managers Analytics', Icons.manage_accounts_outlined),
              SizedBox(height: 16.h),
              _buildManagersAnalyticsRow(context, db),

              SizedBox(height: 32.h),
              _sectionTitle('Teams Analytics', Icons.groups_outlined),
              SizedBox(height: 16.h),
              _buildTeamsAnalyticsRow(context, db),
              
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. HEADER TOOLBAR ---
  Widget _buildHeaderToolbar(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientChip(Icons.analytics_outlined, AppColors.primary, size: 48),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports & Analytics'.tr(context),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Detailed insights and performance overview for the entire organization'.tr(context),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isDesktop) ...[
          _gradientButton(
            label: 'Export PDF'.tr(context),
            icon: Icons.picture_as_pdf,
            colors: [AppColors.danger, _darker(AppColors.danger)],
            onTap: () => _triggerExport('PDF'),
          ),
          SizedBox(width: 12.w),
          _gradientButton(
            label: 'Export Excel'.tr(context),
            icon: Icons.table_chart,
            colors: [AppColors.success, _darker(AppColors.success)],
            onTap: () => _triggerExport('Excel'),
          ),
        ],
      ],
    );
  }

  // --- 2. FILTER BAR ---
  Widget _buildFilterBar(BuildContext context, MockDatabase db) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Filter Analytics'.tr(context),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final cols = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 1000 ? 3 : 5);
              final fieldWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: 16.h,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
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
                          );
                          if (range != null) setState(() => _selectedDateRange = range);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          height: 44.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _selectedDateRange == null
                                      ? 'Select'.tr(context)
                                      : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Department'.tr(context),
                      child: _buildEnlargedDropdownBox(
                        value: _selectedDept,
                        items: ['All', 'Computer Science', 'Engineering', 'IT Services', 'Documentation', 'Administration'],
                        labelMap: {'All': 'All Departments'.tr(context)},
                        onChanged: (v) => setState(() => _selectedDept = v),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Team'.tr(context),
                      child: _buildEnlargedDropdownBox(
                        value: _selectedTeam,
                        items: ['All', ...db.teams.map((t) => t.name)],
                        labelMap: {'All': 'All Teams'.tr(context)},
                        onChanged: (v) => setState(() => _selectedTeam = v),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'User'.tr(context),
                      child: _buildEnlargedDropdownBox(
                        value: _selectedUser,
                        items: ['All', ...db.users.map((u) => u.id)],
                        labelMap: {'All': 'All Users'.tr(context), ...{for (var u in db.users) u.id: u.fullName}},
                        onChanged: (v) => setState(() => _selectedUser = v),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    height: 44.h,
                    child: TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                      label: Text('Reset Filters'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  Widget _buildEnlargedDropdownBox({
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
        return PopupMenuItem(
          value: o,
          height: 38.h,
          child: Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: o == value ? FontWeight.bold : FontWeight.normal)),
        );
      }).toList(),
      child: Container(
        width: double.infinity,
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // --- 3. TOP KPI METRICS GRID ---
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
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            mainAxisExtent: 110.h,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            final cards = [
              _buildStatCard('Total Tasks', '$total', Icons.playlist_add_check, AppColors.primary),
              _buildStatCard('Completed', '$comp', Icons.check_circle_outline, AppColors.success),
              _buildStatCard('In Progress', '$prog', Icons.pending_actions, AppColors.inProgress),
              _buildStatCard('Pending', '$pend', Icons.hourglass_empty, Colors.orange),
              _buildStatCard('Overdue', '$ov', Icons.error_outline, AppColors.danger),
              _buildStatCard('Completion Rate', '${rate.toInt()}%', Icons.pie_chart_outline, Colors.teal),
            ];
            return cards[index];
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: _modernCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  title.tr(context),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. SYSTEM OVERVIEW SECTION ---
  Widget _buildSystemOverviewRow(
    BuildContext context,
    int total, {
    required int comp,
    required int prog,
    required int pend,
    required int rev,
    required int ov,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildTaskStatusDistributionCard(total, comp, prog, pend, rev, ov),
              SizedBox(height: 16.h),
              _buildTasksOverTimeCard(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildTaskStatusDistributionCard(total, comp, prog, pend, rev, ov)),
            SizedBox(width: 24.w),
            Expanded(flex: 5, child: _buildTasksOverTimeCard()),
          ],
        );
      },
    );
  }

  Widget _buildTaskStatusDistributionCard(int total, int comp, int prog, int pend, int rev, int ov) {
    final double safeTotal = total == 0 ? 1 : total.toDouble();
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Status Distribution'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 24.h),
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
                          sectionsSpace: 4,
                          centerSpaceRadius: 50.r,
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
                          Text('$total', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Total Tasks'.tr(context), style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
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
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 8.w),
          Expanded(child: Text(label.tr(context), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          Text('$count', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTasksOverTimeCard() {
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasks Over Time'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _timeframe,
                  isDense: true,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                  items: ['Daily', 'Weekly', 'Monthly'].map((t) => DropdownMenuItem(value: t, child: Text(t.tr(context)))).toList(),
                  onChanged: (v) => setState(() => _timeframe = v!),
                ),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildSimpleLegendDot('Completed', AppColors.success),
              SizedBox(width: 16.w),
              _buildSimpleLegendDot('In Progress', AppColors.inProgress),
              SizedBox(width: 16.w),
              _buildSimpleLegendDot('Overdue', AppColors.danger),
            ],
          ),
          SizedBox(height: 24.h),
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
                      reservedSize: 32.w,
                      getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24.h,
                      getTitlesWidget: (v, m) {
                        const labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(labels[idx], style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold));
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
                    barWidth: 3.w,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 8), FlSpot(1, 14), FlSpot(2, 11), FlSpot(3, 12), FlSpot(4, 15)],
                    isCurved: true,
                    color: AppColors.inProgress,
                    barWidth: 3.w,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 3), FlSpot(4, 4)],
                    isCurved: true,
                    color: AppColors.danger,
                    barWidth: 3.w,
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

  // --- 5. DEPARTMENT ANALYTICS SECTION ---
  Widget _buildDepartmentAnalyticsRow(BuildContext context, MockDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildTasksByDepartmentCard(db),
              SizedBox(height: 16.h),
              _buildDepartmentCompletionRateCard(db),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildTasksByDepartmentCard(db)),
            SizedBox(width: 24.w),
            Expanded(flex: 1, child: _buildDepartmentCompletionRateCard(db)),
          ],
        );
      },
    );
  }

  Widget _buildTasksByDepartmentCard(MockDatabase db) {
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks by Department'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 24.h),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.w,
                      getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.h,
                      getTitlesWidget: (v, m) {
                        const depts = ['CS', 'ENG', 'IT', 'DOCS', 'ADMIN'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < depts.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(depts[idx], style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 35, color: Colors.indigo, width: 14.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 28, color: Colors.indigo, width: 14.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 40, color: Colors.indigo, width: 14.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 22, color: Colors.indigo, width: 14.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 18, color: Colors.indigo, width: 14.w, borderRadius: BorderRadius.circular(4.r))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCompletionRateCard(MockDatabase db) {
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Department Completion Rates'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Icon(Icons.bar_chart_outlined, color: AppColors.textHint, size: 20.sp),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                maxY: 100,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.h,
                      getTitlesWidget: (v, m) {
                        const depts = ['CS', 'ENG', 'IT', 'DOCS', 'ADMIN'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < depts.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(depts[idx], style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: Colors.teal, width: 16.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 72, color: Colors.teal, width: 16.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 94, color: Colors.teal, width: 16.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 65, color: Colors.teal, width: 16.w, borderRadius: BorderRadius.circular(4.r))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 88, color: Colors.teal, width: 16.w, borderRadius: BorderRadius.circular(4.r))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. MANAGERS ANALYTICS SECTION ---
  Widget _buildManagersAnalyticsRow(BuildContext context, MockDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildManagerWorkloadCard(db),
              SizedBox(height: 16.h),
              _buildManagerPerformanceCard(db),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildManagerWorkloadCard(db)),
            SizedBox(width: 24.w),
            Expanded(flex: 1, child: _buildManagerPerformanceCard(db)),
          ],
        );
      },
    );
  }

  Widget _buildManagerWorkloadCard(MockDatabase db) {
    final managers = db.users.where((u) => u.role == 'Manager').take(5).toList();
    
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Managers Workload Overview'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Icon(Icons.manage_accounts_outlined, color: AppColors.textHint, size: 20.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: managers.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.border, height: 16.h),
              itemBuilder: (context, index) {
                final manager = managers[index];
                final taskCount = 120 - (index * 15);
                final completedCount = taskCount - (20 + index * 5);
                final completionRate = (completedCount / taskCount) * 100;
                
                return Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        manager.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  manager.fullName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$taskCount Tasks',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: LinearProgressIndicator(
                                    value: completionRate / 100.0,
                                    color: completionRate > 75 ? AppColors.success : Colors.amber,
                                    backgroundColor: AppColors.border,
                                    minHeight: 6.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${completionRate.toInt()}%',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerPerformanceCard(MockDatabase db) {
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Managers Performance (Completed vs Overdue)'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildSimpleLegendDot('Completed', AppColors.success),
              SizedBox(width: 16.w),
              _buildSimpleLegendDot('Overdue', AppColors.danger),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.w,
                      getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.h,
                      getTitlesWidget: (v, m) {
                        final managers = db.users.where((u) => u.role == 'Manager').take(5).toList();
                        int idx = v.toInt();
                        if (idx >= 0 && idx < managers.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(managers[idx].fullName.split(' ').first, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 85, color: AppColors.success, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                    BarChartRodData(toY: 10, color: AppColors.danger, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 65, color: AppColors.success, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                    BarChartRodData(toY: 15, color: AppColors.danger, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 90, color: AppColors.success, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                    BarChartRodData(toY: 5, color: AppColors.danger, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 55, color: AppColors.success, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                    BarChartRodData(toY: 25, color: AppColors.danger, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(toY: 75, color: AppColors.success, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                    BarChartRodData(toY: 12, color: AppColors.danger, width: 10.w, borderRadius: BorderRadius.circular(2.r)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. TEAMS ANALYTICS SECTION ---
  Widget _buildTeamsAnalyticsRow(BuildContext context, MockDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildTasksByTeamCard(db),
              SizedBox(height: 16.h),
              _buildTopPerformersCard(db),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildTasksByTeamCard(db)),
            SizedBox(width: 24.w),
            Expanded(flex: 1, child: _buildTopPerformersCard(db)),
          ],
        );
      },
    );
  }

  Widget _buildTasksByTeamCard(MockDatabase db) {
    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks Distribution by Team'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 24.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40.r,
                      sections: [
                        PieChartSectionData(color: Colors.blueAccent, value: 35, radius: 20.r, showTitle: false),
                        PieChartSectionData(color: Colors.orangeAccent, value: 25, radius: 20.r, showTitle: false),
                        PieChartSectionData(color: Colors.purpleAccent, value: 20, radius: 20.r, showTitle: false),
                        PieChartSectionData(color: Colors.greenAccent, value: 15, radius: 20.r, showTitle: false),
                        PieChartSectionData(color: Colors.redAccent, value: 5, radius: 20.r, showTitle: false),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusLegendRow('Alpha Team', 35, 35, Colors.blueAccent),
                      _buildStatusLegendRow('Beta Squad', 25, 25, Colors.orangeAccent),
                      _buildStatusLegendRow('Gamma Crew', 20, 20, Colors.purpleAccent),
                      _buildStatusLegendRow('Delta Force', 15, 15, Colors.greenAccent),
                      _buildStatusLegendRow('Omega Ops', 5, 5, Colors.redAccent),
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

  Widget _buildTopPerformersCard(MockDatabase db) {
    final performers = List<MockUser>.from(db.users.where((u) => u.role == 'Team Member'))..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final top5 = performers.take(5).toList();

    return Container(
      height: 330.h,
      padding: EdgeInsets.all(20.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Team Members'.tr(context), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 20.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: top5.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.border),
              itemBuilder: (context, index) {
                final u = top5[index];
                final score = u.finalScore.toInt();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.fullName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: score / 100.0,
                                      color: AppColors.success,
                                      backgroundColor: AppColors.border,
                                      minHeight: 6.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '$score%',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text(label.tr(context), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
