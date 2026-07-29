import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/styles/app_spacing.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

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

  @override
  Widget build(BuildContext context) {
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
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Logbook'.tr(context),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4.h),
              Text(
                'Full history of administrative user adjustments, roles, and complaints closing'.tr(context),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),

              // Filters Panel
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search operations...'.tr(context),
                                border: InputBorder.none,
                                icon: const Icon(Icons.search),
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedModule,
                                isExpanded: true,
                                items: ['All', 'Users', 'Departments', 'Roles', 'Complaints', 'Evaluations'].map((m) {
                                  return DropdownMenuItem(value: m, child: Text(m.tr(context), style: TextStyle(fontSize: 11.sp)));
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedModule = v!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedUser,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(value: 'All', child: Text('All Users'.tr(context), style: TextStyle(fontSize: 11.sp))),
                                  ...db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName, style: TextStyle(fontSize: 11.sp)))),
                                ],
                                onChanged: (v) => setState(() => _selectedUser = v!),
                              ),
                            ),
                          ),
                        ),
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
              ),
              SizedBox(height: 16.h),

              // Log Table List
              Expanded(
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: logs.isEmpty
                      ? Center(child: Text('No audit logs registered.'.tr(context)))
                      : ListView.separated(
                          itemCount: logs.length,
                          separatorBuilder: (context, idx) => const Divider(),
                          itemBuilder: (context, idx) {
                            final log = logs[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14.r,
                                backgroundColor: Colors.grey.shade100,
                                child: Icon(Icons.history, size: 14.sp, color: AppColors.primary),
                              ),
                              title: Text(log.operation, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp)),
                              subtitle: Text('${log.userEmail} | ' + 'Module: '.tr(context) + '${log.module}', style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                              trailing: Text(log.date, style: TextStyle(fontSize: 8.5.sp, color: Colors.grey)),
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
}
