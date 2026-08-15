import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../responsive/responsive_layout.dart';

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

  // ─── Modern UI helpers ────────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  Widget _headerActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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

  Widget _gradientButton(BuildContext context, String text, VoidCallback onTap,
      {Color color = AppColors.primary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, _darker(color)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text.tr(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
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

  ({IconData icon, Color color}) _categoryStyle(String category) {
    switch (category) {
      case 'Delay':
        return (icon: Icons.schedule, color: Colors.orange);
      case 'Poor Quality':
        return (icon: Icons.verified_outlined, color: AppColors.danger);
      case 'Communication':
        return (icon: Icons.forum_outlined, color: AppColors.primary);
      case 'Attendance':
        return (icon: Icons.event_busy_outlined, color: Colors.indigo);
      case 'Behavior':
        return (icon: Icons.psychology_outlined, color: Colors.purple);
      default:
        return (icon: Icons.report_outlined, color: AppColors.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';
    final userRole = authState is AuthSuccess ? authState.user.role : 'Admin';

    final currentMockUser =
        db.users.cast<MockUser?>().firstWhere((u) => u?.id == currentUserId, orElse: () => null);
    final userDept = currentMockUser?.department ?? '';

    // Filter list
    final filtered = db.complaints.where((c) {
      if (userRole == 'Team Member' && c.submitterId != currentUserId) {
        return false;
      }

      if (userRole == 'Manager' || userRole == 'Team Leader') {
        final submitter =
            db.users.cast<MockUser?>().firstWhere((u) => u?.id == c.submitterId, orElse: () => null);
        final targetUser =
            db.users.cast<MockUser?>().firstWhere((u) => u?.id == c.targetId, orElse: () => null);

        bool isRelated = false;
        if (c.submitterId == currentUserId) isRelated = true;
        if (c.targetId == currentUserId) isRelated = true;
        if (submitter != null && submitter.department == userDept) isRelated = true;
        if (targetUser != null && targetUser.department == userDept) isRelated = true;
        if (userDept.isNotEmpty && c.targetName.toLowerCase().contains(userDept.toLowerCase())) isRelated = true;

        if (!isRelated) return false;
      }

      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        return c.title.toLowerCase().contains(query) || c.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Calculations for Analytics
    final resolvedCount = filtered.where((c) => c.status == 'Resolved' || c.status == 'Closed').length;
    final pendingCount = filtered.where((c) => c.status == 'Open' || c.status == 'Under Investigation').length;

    // Dept distribution
    final csCount = filtered.where((c) => c.targetName.contains('CS') || c.targetName.contains('Computer')).length;
    final engCount = filtered.where((c) => c.targetName.contains('ENG') || c.targetName.contains('Engineering')).length;

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientChip(Icons.warning_amber_rounded, AppColors.danger, size: 44),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaints & Investigations'.tr(context),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Quality management and employee behavior tracking'.tr(context),
                          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _headerActionButton(
                    label: 'File Complaint'.tr(context),
                    icon: Icons.add,
                    onTap: () => _showSubmitComplaintDialog(context, currentUserId),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Search
              Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search complaints...'.tr(context),
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Analytics Summary
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _modernCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _gradientChip(Icons.insights_outlined, AppColors.primary, size: 32),
                        SizedBox(width: 10.w),
                        Text(
                          'Complaint Analytics'.tr(context),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 12.0;
                        final cols = constraints.maxWidth < 500 ? 2 : 4;
                        final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
                        return Wrap(
                          spacing: gap,
                          runSpacing: 12.h,
                          children: [
                            SizedBox(
                              width: w,
                              child: _statTile('Resolved'.tr(context), resolvedCount, AppColors.success, Icons.check_circle_outline),
                            ),
                            SizedBox(
                              width: w,
                              child: _statTile('Pending'.tr(context), pendingCount, AppColors.danger, Icons.pending_outlined),
                            ),
                            SizedBox(
                              width: w,
                              child: _statTile('Computer Science'.tr(context), csCount, AppColors.primary, Icons.school_outlined),
                            ),
                            SizedBox(
                              width: w,
                              child: _statTile('Engineering'.tr(context), engCount, Colors.indigo, Icons.engineering_outlined),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Cards Layout Grid
              filtered.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      decoration: _modernCardDecoration(),
                      child: Column(
                        children: [
                          _gradientChip(Icons.report_outlined, AppColors.textSecondary, size: 52),
                          SizedBox(height: 12.h),
                          Text(
                            'No complaints registered.'.tr(context),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth < 600
                            ? 1
                            : (constraints.maxWidth < 1100 ? 2 : 3);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            mainAxisExtent: 168.h,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final comp = filtered[idx];
                            final statusColor = _getStatusColor(comp.status);
                            final style = _categoryStyle(comp.category);
                            return InkWell(
                              onTap: () => _showComplaintDetailDialog(context, comp, currentUserId, userRole),
                              borderRadius: BorderRadius.circular(16.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _gradientChip(style.icon, style.color, size: 40),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comp.title,
                                                style: TextStyle(
                                                  fontSize: 12.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 3.h),
                                              Text(
                                                comp.category.tr(context),
                                                style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            comp.status.tr(context),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      comp.description,
                                      style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    const Divider(height: 1),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Target: '.tr(context) + comp.targetName,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          comp.date,
                                          style: TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary),
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
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, int value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, _darker(color)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientChip(Icons.warning_amber_rounded, AppColors.danger, size: 52),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Complaint'.tr(context),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Report an operational behavior or delay issue.'.tr(context),
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    SizedBox(height: 20.h),

                    _buildFieldLabel('Complaint Title'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: titleCon,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration('Enter a summary...'),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel('Description'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: descCon,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration('Enter details...'),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel('Category'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(''),
                      items: ['Delay', 'Poor Quality', 'Communication', 'Attendance', 'Behavior', 'Other']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.tr(context), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel('Target Type'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: targetType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(''),
                      items: ['Member', 'Team', 'Workload Issue']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.tr(context), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        targetType = v!;
                        targetUserId = null;
                      }),
                    ),
                    SizedBox(height: 18.h),

                    if (targetType == 'Member') ...[
                      _buildFieldLabel('Target Employee'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        initialValue: targetUserId,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        decoration: _buildInputDecoration(''),
                        items: db.users
                            .where((u) => u.id != currentUserId)
                            .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(u.fullName, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => targetUserId = v),
                      ),
                    ],

                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
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
                          child: _gradientButton(context, 'Submit', () {
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
                                  timeline: ['Submitted on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'],
                                ));
                              });
                              Navigator.pop(context);
                            }
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
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
    final statusColor = _getStatusColor(comp.status);
    final style = _categoryStyle(comp.category);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientChip(style.icon, statusColor, size: 52),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comp.title,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${comp.category.tr(context)} · ${comp.date}',
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Text(
                      comp.description,
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, height: 1.5),
                    ),
                    SizedBox(height: 18.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _infoRow(Icons.person_outline, 'Reported By', comp.submitterName, AppColors.primary),
                          SizedBox(height: 10.h),
                          _infoRow(Icons.gps_fixed, 'Target', comp.targetName, Colors.indigo),
                          SizedBox(height: 10.h),
                          _infoRow(Icons.category_outlined, 'Category', comp.category.tr(context), Colors.orange),
                          SizedBox(height: 10.h),
                          _infoRow(Icons.event_outlined, 'Status', comp.status.tr(context), statusColor),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        const Icon(Icons.timeline, size: 16, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Text(
                          'Processing Timeline'.tr(context),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...comp.timeline.map((t) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.success, _darker(AppColors.success)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(7.r),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 13),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  t,
                                  style: TextStyle(fontSize: 11.5.sp, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 20.h),

                    // Resolved Display or Resolution Form
                    if (comp.status == 'Resolved') ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_outlined, size: 16, color: AppColors.success),
                                SizedBox(width: 8.w),
                                Text(
                                  'Resolution Details'.tr(context),
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _resolvedLine('Investigation Notes', comp.investigationNotes),
                            _resolvedLine('Resolution Decision', comp.resolution),
                            _resolvedLine('Corrective Actions', comp.correctiveAction),
                            _resolvedLine('Written Warning', comp.warning ? 'Yes'.tr(context) : 'No'.tr(context)),
                            _resolvedLine('Training Required', comp.trainingRequired ? 'Yes'.tr(context) : 'No'.tr(context)),
                          ],
                        ),
                      ),
                    ] else if (isAuthorized) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.medical_services_outlined, size: 16, color: Colors.orange),
                                SizedBox(width: 8.w),
                                Text(
                                  'Resolve Investigation'.tr(context),
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            TextField(
                              controller: _investigationController,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 13.5),
                              decoration: _buildInputDecoration('Investigation Notes'.tr(context)),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _resolutionController,
                              style: const TextStyle(fontSize: 13.5),
                              decoration: _buildInputDecoration('Resolution'.tr(context)),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _correctiveController,
                              style: const TextStyle(fontSize: 13.5),
                              decoration: _buildInputDecoration('Corrective Action'.tr(context)),
                            ),
                            SizedBox(height: 12.h),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                'Issue Written Warning'.tr(context),
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
                              ),
                              value: _warning,
                              onChanged: (v) => setDialogState(() => _warning = v ?? false),
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                'Mandatory Training Required'.tr(context),
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
                              ),
                              value: _trainingRequired,
                              onChanged: (v) => setDialogState(() => _trainingRequired = v ?? false),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),
                    if (comp.status != 'Resolved' && isAuthorized)
                      _gradientButton(context, 'Submit Resolution', () {
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
                      }, color: AppColors.success)
                    else
                      _gradientButton(context, 'Close', () => Navigator.pop(context),
                          color: const Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        SizedBox(width: 8.w),
        Text(
          '${label.tr(context)}:',
          style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _resolvedLine(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right_alt, size: 16, color: AppColors.success),
          SizedBox(width: 6.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${label.tr(context)}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
