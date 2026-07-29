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
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Resolution controllers
  final TextEditingController _investigationController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();
  final TextEditingController _correctiveController = TextEditingController();
  bool _warning = false;
  bool _trainingRequired = false;

  @override
  void dispose() {
    _searchController.dispose();
    _investigationController.dispose();
    _resolutionController.dispose();
    _correctiveController.dispose();
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
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final userRole = authState is AuthSuccess ? authState.user.role : 'Admin';

    // Filter list
    final filtered = db.complaints.where((c) {
      if (userRole == 'Team Member' && c.submitterId != currentUserId) {
        return false;
      }
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        return c.title.toLowerCase().contains(query) || c.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Calculations for Analytics
    final resolvedCount = db.complaints.where((c) => c.status == 'Resolved' || c.status == 'Closed').length;
    final pendingCount = db.complaints.where((c) => c.status == 'Open' || c.status == 'Under Investigation').length;

    // Dept distribution
    final csCount = db.complaints.where((c) => c.targetName.contains('CS') || c.targetName.contains('Computer')).length;
    final engCount = db.complaints.where((c) => c.targetName.contains('ENG') || c.targetName.contains('Engineering')).length;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complaints & Investigations'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Quality management and employee behavior tracking'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                  PrimaryButton(
                    text: 'File Complaint'.tr(context),
                    onPressed: () => _showSubmitComplaintDialog(context, currentUserId),
                    prefixIcon: const Icon(Icons.add, color: Colors.white),
                  )
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
              SizedBox(height: 16.h),

              // Analytics Summary section
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint Analytics'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(child: _buildSmallStat('Resolved complaints', resolvedCount.toString(), AppColors.success)),
                        Expanded(child: _buildSmallStat('Pending complaints', pendingCount.toString(), AppColors.danger)),
                        Expanded(child: _buildSmallStat('Computer Science Issues', csCount.toString(), AppColors.primary)),
                        Expanded(child: _buildSmallStat('Engineering Issues', engCount.toString(), Colors.indigo)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Cards Layout Grid
              filtered.isEmpty
                  ? Center(child: Padding(padding: EdgeInsets.all(32.h), child: Text('No complaints registered.'.tr(context))))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = isDesktop ? 3 : (constraints.maxWidth < 600 ? 1 : 2);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            mainAxisExtent: 135.h,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final comp = filtered[idx];
                            final statusColor = _getStatusColor(comp.status);
                            return InkWell(
                              onTap: () => _showComplaintDetailDialog(context, comp, currentUserId, userRole),
                              borderRadius: BorderRadius.circular(AppRadius.lg.r),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.lg.r),
                                  border: Border.all(color: statusColor, width: 1.5.w),
                                  boxShadow: AppShadow.soft,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        Expanded(child: Text('Target: '.tr(context) + comp.targetName, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                        Text(comp.date, style: TextStyle(fontSize: 8.5.sp, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
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

  // --- File complaint dialog ---
  void _showSubmitComplaintDialog(BuildContext context, String currentUserId) {
    final db = MockDatabase.instance;
    final titleCon = TextEditingController();
    final descCon = TextEditingController();
    String category = 'Delay';
    String targetType = 'Member';
    String? targetUserId = '4';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 500.w,
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
                          Text(
                            'File Complaint'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Report an operational behavior or delay issue.'.tr(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Complaint Title'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: titleCon,
                    decoration: _buildInputDecoration('Enter a summary...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Description'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: descCon,
                    maxLines: 2,
                    decoration: _buildInputDecoration('Enter details...'),
                  ),
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
                    onChanged: (v) => setDialogState(() {
                      targetType = v!;
                      targetUserId = null;
                    }),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr(context),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Submit'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
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

  // --- Complaint details & resolution timeline dialog ---
  void _showComplaintDetailDialog(BuildContext context, MockComplaint comp, String currentUserId, String userRole) {
    final db = MockDatabase.instance;
    final isAuthorized = userRole == 'Admin' || userRole == 'Manager';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(comp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480.w,
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

                  // Timeline Display
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

                  // Resolved Display or Resolution Form
                  if (comp.status == 'Resolved') ...[
                    Text('Resolution Details'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.success)),
                    SizedBox(height: 4.h),
                    Text('Investigation Notes: '.tr(context) + comp.investigationNotes),
                    Text('Resolution decision: '.tr(context) + comp.resolution),
                    Text('Corrective Actions: '.tr(context) + comp.correctiveAction),
                    Text('Written Warning Issued: '.tr(context) + (comp.warning ? 'Yes'.tr(context) : 'No'.tr(context))),
                    Text('Mandatory Training Required: '.tr(context) + (comp.trainingRequired ? 'Yes'.tr(context) : 'No'.tr(context))),
                  ] else if (isAuthorized) ...[
                    Text('Resolve Investigation'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.orange)),
                    SizedBox(height: 6.h),
                    TextField(controller: _investigationController, decoration: InputDecoration(labelText: 'Investigation Notes'.tr(context))),
                    TextField(controller: _resolutionController, decoration: InputDecoration(labelText: 'Resolution'.tr(context))),
                    TextField(controller: _correctiveController, decoration: InputDecoration(labelText: 'Corrective Action'.tr(context))),
                    CheckboxListTile(
                      title: Text('Issue Written Warning'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      value: _warning,
                      onChanged: (v) => setDialogState(() => _warning = v ?? false),
                    ),
                    CheckboxListTile(
                      title: Text('Mandatory Training Required'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      value: _trainingRequired,
                      onChanged: (v) => setDialogState(() => _trainingRequired = v ?? false),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context))),
            if (comp.status != 'Resolved' && isAuthorized)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    db.resolveComplaint(
                      complaintId: comp.id,
                      investigationNotes: _investigationController.text,
                      resolution: _resolutionController.text,
                      correctiveAction: _correctiveController.text,
                      warning: _warning,
                      trainingRequired: _trainingRequired,
                      closedByUserId: currentUserId,
                    );
                    _investigationController.clear();
                    _resolutionController.clear();
                    _correctiveController.clear();
                    _warning = false;
                    _trainingRequired = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('Submit Resolution'.tr(context)),
              )
          ],
        ),
      ),
    );
  }
}
