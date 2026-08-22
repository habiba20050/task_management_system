import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';

class ReviewCenterPage extends StatefulWidget {
  const ReviewCenterPage({super.key});

  @override
  State<ReviewCenterPage> createState() => _ReviewCenterPageState();
}

class _ReviewCenterPageState extends State<ReviewCenterPage> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // --- UI Helpers ---
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _gradientChip(IconData icon, Color color, {double size = 48}) {
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
                Icon(icon, color: Colors.white, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Filter for Admin: Tasks assigned to Managers that are 'Submitted'
    final tasksWaitingReview = MockDatabase.instance.tasks.where((t) {
      if (t.status != 'Submitted') return false;
      final assignee = MockDatabase.instance.users.firstWhere(
        (u) => u.id == t.assignedMemberId,
        orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''),
      );
      // Admin reviews Managers
      return assignee.role == 'Manager';
    }).toList();

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              Expanded(
                child: tasksWaitingReview.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: tasksWaitingReview.length,
                        separatorBuilder: (context, index) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return _buildTaskCard(tasksWaitingReview[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientChip(Icons.rate_review_outlined, AppColors.primary),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manager Review Center'.tr(context),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Review and evaluate final deliverables submitted by Department Managers'.tr(context),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all, size: 64.sp, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          SizedBox(height: 16.h),
          Text(
            'All Caught Up!'.tr(context),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            'No deliverables from managers are currently waiting for your review.'.tr(context),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(MockTask task) {
    final submitter = MockDatabase.instance.users.firstWhere(
      (u) => u.id == task.assignedMemberId,
      orElse: () => MockUser(id: '', email: '', fullName: 'Unknown Manager', role: 'Manager', department: ''),
    );

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Priority: ${task.priority}'.tr(context),
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                child: Text(
                  submitter.fullName[0].toUpperCase(),
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${submitter.fullName} (${submitter.department} Manager)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Submitted on: ${task.deadline}', // Assuming deadline/submitted date
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_outlined, size: 16.sp, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      'Manager Notes'.tr(context),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  task.notes ?? 'No comments provided.'.tr(context),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
          if ((task.githubLink != null && task.githubLink!.isNotEmpty) || (task.prLink != null && task.prLink!.isNotEmpty)) ...[
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              children: [
                if (task.githubLink != null && task.githubLink!.isNotEmpty)
                  _buildLinkChip(Icons.code, 'Repository / Files', task.githubLink!),
                if (task.prLink != null && task.prLink!.isNotEmpty)
                  _buildLinkChip(Icons.alt_route, 'Pull Request / Doc', task.prLink!),
              ],
            ),
          ],
          SizedBox(height: 24.h),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _outlineButton(
                label: 'Reject'.tr(context),
                color: AppColors.danger,
                onTap: () => _handleReview(context, task.id, 'Rejected'),
              ),
              SizedBox(width: 12.w),
              _outlineButton(
                label: 'Request Changes'.tr(context),
                color: Colors.orange,
                onTap: () => _handleReview(context, task.id, 'Needs Changes'),
              ),
              SizedBox(width: 12.w),
              _gradientButton(
                label: 'Approve Deliverable'.tr(context),
                icon: Icons.check_circle_outline,
                colors: [AppColors.success, _darker(AppColors.success)],
                onTap: () => _handleReview(context, task.id, 'Approved'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkChip(IconData icon, String label, String url) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  void _handleReview(BuildContext context, String taskId, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(
              status == 'Approved' ? Icons.check_circle : (status == 'Rejected' ? Icons.cancel : Icons.warning_amber_rounded),
              color: status == 'Approved' ? AppColors.success : (status == 'Rejected' ? AppColors.danger : Colors.orange),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Review Action: $status'.tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _feedbackController,
          decoration: InputDecoration(
            labelText: 'Admin Feedback & Review Comments'.tr(context),
            hintText: 'Enter suggestions, issues, or details for the manager...'.tr(context),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          maxLines: 4,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        actions: [
          TextButton(
            onPressed: () {
              _feedbackController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'.tr(context), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            onPressed: () {
              setState(() {
                MockDatabase.instance.reviewTask(
                  taskId: taskId,
                  status: status,
                  feedback: _feedbackController.text,
                );
              });
              _feedbackController.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Review completed successfully with status: $status'.tr(context)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
            },
            child: Text('Submit Review'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
