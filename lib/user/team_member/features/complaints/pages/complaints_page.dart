import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';
  DateTimeRange? _dateRange;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.danger;
      case 'Under Investigation':
        return Colors.orange;
      case 'Resolved':
        return AppColors.success;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final userRole = authState is AuthSuccess ? authState.user.role : 'Admin';

    // My complaints only
    final myComplaints = db.complaints.where((c) => c.submitterId == currentUserId).toList();

    // Apply filters
    var filtered = myComplaints;
    if (_statusFilter != 'All') {
      filtered = filtered.where((c) => c.status == _statusFilter).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      filtered = filtered.where((c) => c.title.toLowerCase().contains(q) || c.description.toLowerCase().contains(q)).toList();
    }
    if (_dateRange != null) {
      filtered = filtered.where((c) {
        final d = DateTime.tryParse(c.date);
        return d != null && d.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    filtered = List.from(filtered)..sort((a, b) => b.date.compareTo(a.date));

    // Personal analytics
    final resolvedCount = myComplaints.where((c) => c.status == 'Resolved' || c.status == 'Closed').length;
    final pendingCount = myComplaints.where((c) => c.status == 'Open' || c.status == 'Under Investigation').length;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('My Complaints'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            ),
                            PrimaryButton(
                              text: 'File Complaint'.tr(context),
                              onPressed: () => _showSubmitComplaintDialog(context, currentUserId),
                              prefixIcon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text('Track and manage your submitted complaints'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Complaints'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.h),
                            Text('Track and manage your submitted complaints'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                          ],
                        ),
                        PrimaryButton(
                          text: 'File Complaint'.tr(context),
                          onPressed: () => _showSubmitComplaintDialog(context, currentUserId),
                          prefixIcon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
              SizedBox(height: 16.h),

              // Search
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search complaints...'.tr(context),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Filter bar
              _buildFilterBar(context),
              SizedBox(height: 16.h),

              // Personal Analytics
              AppCard(
                compact: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Complaint Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(child: _buildSmallStat('Total', '${myComplaints.length}', AppColors.primary)),
                        Expanded(child: _buildSmallStat('Resolved', resolvedCount.toString(), AppColors.success)),
                        Expanded(child: _buildSmallStat('Pending', pendingCount.toString(), AppColors.danger)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Cards
              filtered.isEmpty
                  ? Center(child: Padding(padding: EdgeInsets.all(32.h), child: Text('No complaints found.'.tr(context))))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, idx) {
                        final comp = filtered[idx];
                        final statusColor = _getStatusColor(comp.status);
                        return InkWell(
                          onTap: () => _showComplaintDetailDialog(context, comp, currentUserId, userRole),
                          borderRadius: BorderRadius.circular(AppRadius.lg.r),
                          child: AppCard(
                            compact: true,
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(comp.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp), overflow: TextOverflow.ellipsis)),
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                                        child: Text(comp.status.tr(context), style: TextStyle(color: statusColor, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(comp.description, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const Divider(height: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('Category: '.tr(context) + comp.category.tr(context), style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                                      Text(comp.date, style: TextStyle(fontSize: 8.5.sp, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return AppCard(
      compact: true,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.filter_list, size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text('Filter by'.tr(context) + ':', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isExpanded: true,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary),
                items: ['All', 'Open', 'Under Investigation', 'Resolved', 'Closed'].map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context)))).toList(),
                onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: Icon(Icons.date_range, size: 14.sp),
            label: Text(
              _dateRange == null
                  ? 'Date Range'.tr(context)
                  : '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
              style: TextStyle(fontSize: 10.sp),
            ),
            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), minimumSize: Size.zero),
          ),
          if (_dateRange != null || _statusFilter != 'All')
            TextButton.icon(
              onPressed: () => setState(() { _statusFilter = 'All'; _dateRange = null; }),
              icon: Icon(Icons.clear, size: 14.sp),
              label: Text('Clear'.tr(context), style: TextStyle(fontSize: 10.sp)),
              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h), minimumSize: Size.zero),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }

  void _showSubmitComplaintDialog(BuildContext context, String currentUserId) {
    final db = MockDatabase.instance;
    final titleCon = TextEditingController();
    final descCon = TextEditingController();
    String category = 'Delay';
    String targetType = 'Member';
    String? targetUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
              width: MediaQuery.of(context).size.width < 600 ? double.infinity : 500.w,
            padding: EdgeInsets.all(32.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File Complaint'.tr(context), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          SizedBox(height: 4.h),
                          Text('Report an operational behavior or delay issue.'.tr(context), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Complaint Title'),
                  SizedBox(height: 8.h),
                  TextFormField(controller: titleCon, decoration: _buildInputDecoration('Enter a summary...')),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Description'),
                  SizedBox(height: 8.h),
                  TextFormField(controller: descCon, maxLines: 2, decoration: _buildInputDecoration('Enter details...')),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Category'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: category,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Delay', 'Poor Quality', 'Communication', 'Attendance', 'Behavior', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => category = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Target Type'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: targetType,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Member', 'Team', 'Workload Issue'].map((t) => DropdownMenuItem(value: t, child: Text(t.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() { targetType = v!; targetUserId = null; }),
                  ),
                  SizedBox(height: 20.h),

                  if (targetType == 'Member') ...[
                    _buildFieldLabel('Target Employee'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: targetUserId,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(''),
                      items: db.users.where((u) => u.id != currentUserId).map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                      onChanged: (v) => setDialogState(() => targetUserId = v),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Text('Cancel'.tr(context), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCon.text.isNotEmpty) {
                              final reporter = db.users.firstWhere((u) => u.id == currentUserId);
                              var targetName = 'General Workload';
                              if (targetType == 'Member' && targetUserId != null) {
                                targetName = db.users.firstWhere((u) => u.id == targetUserId).fullName;
                              }
                              setState(() {
                                db.addComplaint(MockComplaint(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  submitterId: currentUserId,
                                  submitterName: reporter.fullName,
                                  submitterRole: reporter.role,
                                  targetType: targetType,
                                  targetId: targetUserId ?? 't1',
                                  targetName: targetName,
                                  title: titleCon.text,
                                  description: descCon.text,
                                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                  category: category,
                                  timeline: ['Submitted on ' + DateFormat('yyyy-MM-dd').format(DateTime.now())],
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                          child: Text('Submit'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComplaintDetailDialog(BuildContext context, MockComplaint comp, String currentUserId, String userRole) {
    final db = MockDatabase.instance;
    final isAuthorized = userRole == 'Admin' || userRole == 'Manager';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(comp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width < 600 ? double.infinity : 480.w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comp.description),
                  const Divider(),
                  Text('Category: '.tr(context) + comp.category.tr(context)),
                  Text('Reported By: '.tr(context) + comp.submitterName),
                  Text('Target: '.tr(context) + comp.targetName),
                  Text('Date: '.tr(context) + comp.date),
                  const Divider(),

                  Text('Processing Timeline'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.primary)),
                  SizedBox(height: 6.h),
                  ...comp.timeline.map((t) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(t, style: TextStyle(fontSize: 10.5.sp)),
                          ],
                        ),
                      )),
                  const Divider(),

                  if (comp.status == 'Resolved') ...[
                    Text('Resolution Details'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.success)),
                    SizedBox(height: 4.h),
                    Text('Investigation Notes: '.tr(context) + comp.investigationNotes),
                    Text('Resolution decision: '.tr(context) + comp.resolution),
                    Text('Corrective Actions: '.tr(context) + comp.correctiveAction),
                    Text('Written Warning Issued: '.tr(context) + (comp.warning ? 'Yes'.tr(context) : 'No'.tr(context))),
                    Text('Mandatory Training Required: '.tr(context) + (comp.trainingRequired ? 'Yes'.tr(context) : 'No'.tr(context))),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context))),
          ],
        ),
      ),
    );
  }
}
