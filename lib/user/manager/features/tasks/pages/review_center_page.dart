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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.role;

    // Determine tasks waiting review based on role
    List<MockTask> tasksWaitingReview = [];
    if (role == 'Team Leader') {
      // Find team leader's team
      final team = MockDatabase.instance.teams.firstWhere(
        (t) => t.leaderId == user.id,
        orElse: () => MockTeam(
          id: '',
          name: '',
          managerId: '',
          department: '',
          leaderId: '',
          memberIds: [],
        ),
      );
      tasksWaitingReview = MockDatabase.instance.tasks
          .where(
            (t) =>
                t.status == 'Submitted' &&
                team.memberIds.contains(t.assignedMemberId),
          )
          .toList();
    } else if (role == 'Manager') {
      // Show all submitted tasks or tickets
      tasksWaitingReview = MockDatabase.instance.tasks
          .where((t) => t.status == 'Submitted')
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Center'.tr(context),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                role == 'Manager'
                    ? 'Review final deliverables from Team Leaders'.tr(context)
                    : 'Evaluate and grade submitted member task deliverables'.tr(context),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: tasksWaitingReview.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 52.sp, color: Colors.grey.shade300),
                            SizedBox(height: 12.h),
                            Text(
                              'No deliverables currently waiting for review.'.tr(context),
                              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasksWaitingReview.length,
                        separatorBuilder: (context, index) => SizedBox(height: 14.h),
                        itemBuilder: (context, index) {
                          final task = tasksWaitingReview[index];
                          final submitter = MockDatabase.instance.users.firstWhere(
                            (u) => u.id == task.assignedMemberId,
                            orElse: () => MockUser(
                              id: '',
                              email: '',
                              fullName: 'Unknown Member',
                              role: '',
                              department: '',
                            ),
                          );

                          return _buildReviewCard(context, task, submitter);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, MockTask task, MockUser submitter) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradientChip(Icons.assignment_outlined, AppColors.primary, size: 40),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _priorityBadge(task.priority),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Submitter
          Row(
            children: [
              _avatar(submitter.fullName, 34, AppColors.aituRed),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted by: ${submitter.fullName}'.tr(context),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      submitter.email,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Submission notes
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 14.sp, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      'Submission Notes'.tr(context),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  task.notes ?? 'No comments provided.'.tr(context),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, height: 1.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Links
          if (task.githubLink != null || task.prLink != null)
            Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: [
                if (task.githubLink != null && task.githubLink!.isNotEmpty)
                  _buildLinkChip(Icons.code, 'GitHub Repo'.tr(context), task.githubLink!),
                if (task.prLink != null && task.prLink!.isNotEmpty)
                  _buildLinkChip(Icons.alt_route, 'Pull Request'.tr(context), task.prLink!),
              ],
            ),
          SizedBox(height: 14.h),

          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.h),

          // Actions
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _outlinedAction(
                label: 'Request Changes'.tr(context),
                icon: Icons.edit_note,
                color: Colors.orange,
                onTap: () => _handleReview(context, task.id, 'Needs Changes'),
              ),
              _outlinedAction(
                label: 'Reject Deliverable'.tr(context),
                icon: Icons.cancel_outlined,
                color: AppColors.danger,
                onTap: () => _handleReview(context, task.id, 'Rejected'),
              ),
              _gradientAction(
                label: 'Approve with Suggestions'.tr(context),
                icon: Icons.thumb_up_outlined,
                colors: [AppColors.primary, _darker(AppColors.primary)],
                onTap: () => _handleReview(context, task.id, 'Approved With Suggestions'),
              ),
              _gradientAction(
                label: 'Approve Task'.tr(context),
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

  Widget _priorityBadge(String priority) {
    final data = {
      'HIGH': [AppColors.danger, const Color(0xFFFFEBEE)],
      'MEDIUM': [Colors.orange, const Color(0xFFFFF3E0)],
      'LOW': [AppColors.success, const Color(0xFFE8F5E9)],
    };
    final c = data[priority] ?? [AppColors.textSecondary, Colors.grey.shade100];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c[1],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined, size: 11.sp, color: c[0]),
          SizedBox(width: 4.w),
          Text(
            'Priority: ${priority.tr(context)}'.tr(context),
            style: TextStyle(color: c[0], fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkChip(IconData icon, String label, String url) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: const Color(0xFF0F4C81)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF334155),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _gradientAction({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: Colors.white),
                  SizedBox(width: 6.w),
                  Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleReview(BuildContext context, String taskId, String status) {
    final statusData = _statusData(status);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusData.color, _darker(statusData.color)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: statusData.color.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(statusData.icon, color: Colors.white, size: 26),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.tr(context),
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Provide feedback & review comments'.tr(context),
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

                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 15, color: AppColors.textSecondary),
                      SizedBox(width: 6.w),
                      Text(
                        'Feedback & Review Comments'.tr(context),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter suggestions, issues, or details...'.tr(context),
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      contentPadding: EdgeInsets.all(16.w),
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.h),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text(
                            'Cancel'.tr(context),
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: () {
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
                                    content: Text(
                                      'Review completed successfully with status: $status'.tr(context),
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [statusData.color, _darker(statusData.color)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusData.color.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Submit Review'.tr(context),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
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

  ({Color color, IconData icon}) _statusData(String status) {
    switch (status) {
      case 'Approved':
        return (color: AppColors.success, icon: Icons.check_circle_outline);
      case 'Approved With Suggestions':
        return (color: AppColors.primary, icon: Icons.thumb_up_outlined);
      case 'Rejected':
        return (color: AppColors.danger, icon: Icons.cancel_outlined);
      default:
        return (color: Colors.orange, icon: Icons.edit_note);
    }
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  Widget _gradientChip(IconData icon, Color color, {double size = 40}) => Container(
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

  Widget _avatar(String name, double size, Color color) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: color,
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
