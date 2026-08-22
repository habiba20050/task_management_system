import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../responsive/responsive_layout.dart';

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

  InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: EdgeInsets.all(14.w),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.sp,
        color: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    // Filtered logs
    final logs = db.auditLogs.where((log) {
      final matchesSearch = log.operation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesModule = _selectedModule == 'All' || log.module == _selectedModule;
      final matchesUser = _selectedUser == 'All' || log.userId == _selectedUser;

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final logDate = DateTime.tryParse(log.date);
        if (logDate != null) {
          matchesDate = logDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              logDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }
      return matchesSearch && matchesModule && matchesUser && matchesDate;
    }).toList().reversed.toList(); // show newest first

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientChip(Icons.history_edu_outlined, Colors.blueGrey, size: 44),
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
                          'Full history of administrative user adjustments, roles, and actions'.tr(context),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
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
                  children: [
                    if (!isDesktop) ...[
                      // Mobile layout
                      TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: _fieldDecoration('Search operations...'.tr(context),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textHint)),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: _selectedModule,
                              items: ['All', 'Users', 'Departments', 'Roles', 'Complaints', 'Evaluations'],
                              onChanged: (v) => setState(() => _selectedModule = v!),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildUserDropdown(db),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _buildDateRangePicker(),
                    ] else ...[
                      // Desktop/Tablet layout
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              decoration: _fieldDecoration('Search operations...'.tr(context),
                                  prefixIcon: const Icon(Icons.search, color: AppColors.textHint)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildDropdown(
                              value: _selectedModule,
                              items: ['All', 'Users', 'Departments', 'Roles', 'Complaints', 'Evaluations'],
                              onChanged: (v) => setState(() => _selectedModule = v!),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildUserDropdown(db),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildDateRangePicker(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              _sectionTitle('Activity Feed'.tr(context)),
              SizedBox(height: 12.h),

              // Log Table List
              Expanded(
                child: logs.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(28.w),
                        decoration: _modernCardDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _gradientChip(Icons.history_outlined, AppColors.textSecondary, size: 44),
                            SizedBox(height: 10.h),
                            Text(
                              'No audit logs registered.'.tr(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, idx) {
                          final log = logs[idx];
                          Color moduleColor = Colors.blueGrey;
                          IconData moduleIcon = Icons.auto_awesome_mosaic_outlined;

                          switch (log.module) {
                            case 'Users':
                              moduleColor = Colors.indigo;
                              moduleIcon = Icons.group_outlined;
                              break;
                            case 'Departments':
                              moduleColor = Colors.teal;
                              moduleIcon = Icons.domain_outlined;
                              break;
                            case 'Roles':
                              moduleColor = Colors.purple;
                              moduleIcon = Icons.admin_panel_settings_outlined;
                              break;
                            case 'Complaints':
                              moduleColor = AppColors.danger;
                              moduleIcon = Icons.report_outlined;
                              break;
                            case 'Evaluations':
                              moduleColor = Colors.amber;
                              moduleIcon = Icons.assessment_outlined;
                              break;
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.r,
                                  height: 36.r,
                                  decoration: BoxDecoration(
                                    color: moduleColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(moduleIcon, color: moduleColor, size: 18.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.operation,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline, size: 12.sp, color: AppColors.textSecondary),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              '${log.userEmail} · ${log.module.tr(context)}',
                                              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      log.date.split(' ').first,
                                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                    ),
                                    if (log.date.contains(' ')) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        log.date.split(' ').last,
                                        style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          onChanged: onChanged,
          items: items.map((m) => DropdownMenuItem(value: m, child: Text(m.tr(context)))).toList(),
        ),
      ),
    );
  }

  Widget _buildUserDropdown(MockDatabase db) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUser,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          onChanged: (v) {
            if (v != null) setState(() => _selectedUser = v);
          },
          items: [
            DropdownMenuItem(value: 'All', child: Text('All Users'.tr(context))),
            ...db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2026, 1, 1),
              lastDate: DateTime(2027, 12, 31),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (range != null) setState(() => _selectedDateRange = range);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                Icon(Icons.date_range, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _selectedDateRange == null
                        ? 'Date Range'.tr(context)
                        : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                    style: TextStyle(
                      color: _selectedDateRange == null ? AppColors.textHint : AppColors.textPrimary,
                      fontWeight: _selectedDateRange == null ? FontWeight.normal : FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedDateRange != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedDateRange = null),
                    child: Icon(Icons.close, color: AppColors.danger, size: 16.sp),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
