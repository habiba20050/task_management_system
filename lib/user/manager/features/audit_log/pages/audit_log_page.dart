import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/network/mock_database.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import 'package:task_management_system/auth/model/user_model.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  String _searchQuery = '';
  String _selectedModule = 'All';
  String _selectedUser = 'All';
  DateTimeRange? _selectedDateRange;

  // ─── Modern UI helpers ────────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

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

  ({IconData icon, Color color}) _moduleStyle(String module) {
    switch (module) {
      case 'Users':
        return (icon: Icons.person_outline, color: AppColors.primary);
      case 'Departments':
        return (icon: Icons.business_outlined, color: Colors.indigo);
      case 'Roles':
        return (icon: Icons.admin_panel_settings_outlined, color: AppColors.success);
      case 'Complaints':
        return (icon: Icons.report_outlined, color: AppColors.danger);
      case 'Evaluations':
        return (icon: Icons.assessment_outlined, color: Colors.orange);
      default:
        return (icon: Icons.history, color: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(id: '1', email: '', username: '', fullName: 'Manager', role: 'Manager');

    // Get manager info
    final managerMock = db.users.cast<MockUser?>().firstWhere(
          (u) => u?.id == user.id,
          orElse: () => null,
        );
    final myDept = managerMock?.department ?? 'Computer Science';

    // Users in my department
    final deptUsers = db.users.where((u) => u.department == myDept).toList();
    final deptUserIds = deptUsers.map((u) => u.id).toSet();

    // Filtered logs
    final logs = db.auditLogs.where((log) {
      // Logic constraint: Only see logs from users in my department
      if (!deptUserIds.contains(log.userId)) return false;

      final matchesSearch = log.operation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesModule = _selectedModule == 'All' || log.module == _selectedModule;
      final matchesUser = _selectedUser == 'All' || log.userId == _selectedUser;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final logDate = DateTime.tryParse(log.date);
        if (logDate != null) {
          matchesDate =
              logDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                  logDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }
      return matchesSearch && matchesModule && matchesUser && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientChip(Icons.fact_check_outlined, AppColors.primary, size: 44),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audit Logbook'.tr(context),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '$myDept · ${'Department History'.tr(context)}',
                          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Filters Panel
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _modernCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search operations...'.tr(context),
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Filter fields
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 12.0;
                        final cols = constraints.maxWidth < 600 ? 2 : 3;
                        final fieldWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
                        return Wrap(
                          spacing: gap,
                          runSpacing: 14.h,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: _buildFilterField(
                                context: context,
                                icon: Icons.view_module_outlined,
                                label: 'Module',
                                value: _selectedModule == 'All' ? 'All'.tr(context) : _selectedModule,
                                items: ['All', 'Users', 'Departments', 'Roles', 'Complaints', 'Evaluations'],
                                onSelected: (val) => setState(() => _selectedModule = val),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _buildFilterField(
                                context: context,
                                icon: Icons.person_outline,
                                label: 'User',
                                value: _selectedUser == 'All'
                                    ? 'All'.tr(context)
                                    : deptUsers
                                        .firstWhere(
                                          (u) => u.id == _selectedUser,
                                          orElse: () => MockUser(
                                            id: '',
                                            fullName: 'Unknown',
                                            email: '',
                                            role: '',
                                            department: '',
                                          ),
                                        )
                                        .fullName,
                                items: ['All', ...deptUsers.map((e) => e.id)],
                                itemLabels: ['All'.tr(context), ...deptUsers.map((e) => e.fullName)],
                                onSelected: (val) => setState(() => _selectedUser = val),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _buildDateRangeField(context),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Log Table List
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: _modernCardDecoration(),
                  child: logs.isEmpty
                      ? _emptyState(context)
                      : ListView.separated(
                          padding: EdgeInsets.all(12.w),
                          itemCount: logs.length,
                          separatorBuilder: (context, idx) => SizedBox(height: 8.h),
                          itemBuilder: (context, idx) {
                            final log = logs[idx];
                            final style = _moduleStyle(log.module);
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  _gradientChip(style.icon, style.color, size: 40),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.operation,
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '${log.userEmail} · ${'Module:'.tr(context)} ${log.module}',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      log.date,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gradientChip(Icons.history, AppColors.textSecondary, size: 52),
            SizedBox(height: 12.h),
            Text(
              'No audit logs registered for this department.'.tr(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    List<String>? itemLabels,
    required void Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.tr(context),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        PopupMenuButton<String>(
          initialValue: items.contains(value) ? value : items.first,
          onSelected: onSelected,
          offset: Offset(0, 48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          itemBuilder: (context) => List.generate(items.length, (index) {
            final o = items[index];
            final display = itemLabels != null ? itemLabels[index] : o.tr(context);
            final isSelected = o == value;
            return PopupMenuItem(
              value: o,
              height: 38.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) Icon(Icons.check, size: 16, color: AppColors.primary) else SizedBox(width: 16.w),
                  SizedBox(width: 8.w),
                  Text(display, style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }),
          child: Container(
            width: double.infinity,
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          value == 'All' ? 'All'.tr(context) : value,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    final hasDate = _selectedDateRange != null;
    final labelText = hasDate
        ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
        : 'Select'.tr(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date Range'.tr(context),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () async {
            if (hasDate) {
              setState(() => _selectedDateRange = null);
              return;
            }
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2026, 1, 1),
              lastDate: DateTime(2027, 12, 31),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (range != null) setState(() => _selectedDateRange = range);
          },
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            width: double.infinity,
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        hasDate ? Icons.close : Icons.calendar_today_outlined,
                        size: 16.sp,
                        color: hasDate ? AppColors.danger : AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          labelText,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
