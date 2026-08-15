import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/colors/app_colors.dart';
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
    final teamIds = [user.id, ...team.memberIds];

    // Tasks submitted by the leader or their team members
    final tasksWaitingReview = MockDatabase.instance.tasks
        .where(
          (t) =>
              t.status == 'Submitted' &&
              (teamIds.contains(t.currentOwnerId)),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Center',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Review and evaluate submitted deliverables from your team members',
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: tasksWaitingReview.isEmpty
                    ? const Center(
                        child: Text(
                          'No deliverables currently waiting for review.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasksWaitingReview.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final task = tasksWaitingReview[index];
                          final submitter = MockDatabase.instance.users
                              .firstWhere(
                                (u) => u.id == task.assignedMemberId,
                                orElse: () => MockUser(
                                  id: '',
                                  email: '',
                                  fullName: 'Unknown Member',
                                  role: '',
                                  department: '',
                                ),
                              );

                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Chip(
                                        label: Text(
                                          'Priority: ${task.priority}',
                                        ),
                                        backgroundColor: const Color(
                                          0xFFEFF6FF,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Submitted by: ${submitter.fullName} (${submitter.email})',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Submission Notes: ${task.notes ?? 'No comments provided.'}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Wrap(
                                    spacing: 12.w,
                                    children: [
                                      if (task.githubLink != null &&
                                          task.githubLink!.isNotEmpty)
                                        _buildLinkChip(
                                          Icons.code,
                                          'GitHub Repo',
                                          task.githubLink!,
                                        ),
                                      if (task.prLink != null &&
                                          task.prLink!.isNotEmpty)
                                        _buildLinkChip(
                                          Icons.alt_route,
                                          'Pull Request',
                                          task.prLink!,
                                        ),
                                    ],
                                  ),
                                  const Divider(),
                                  SizedBox(height: 8.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _handleReview(
                                          context,
                                          task.id,
                                          'Needs Changes',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.orange,
                                          side: const BorderSide(
                                            color: Colors.orange,
                                          ),
                                        ),
                                        child: const Text('Request Changes'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _handleReview(
                                          context,
                                          task.id,
                                          'Rejected',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        child: const Text('Reject Deliverable'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _handleReview(
                                          context,
                                          task.id,
                                          'Approved With Suggestions',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[700],
                                        ),
                                        child: const Text(
                                          'Approve with Suggestions',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _handleReview(
                                          context,
                                          task.id,
                                          'Approved',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                        ),
                                        child: const Text(
                                          'Approve Task',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _buildLinkChip(IconData icon, String label, String url) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
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
    );
  }

  void _handleReview(BuildContext context, String taskId, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Review Action: $status',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _feedbackController,
          decoration: const InputDecoration(
            labelText: 'Feedback & Review Comments',
            hintText: 'Enter suggestions, issues, or details...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                  content: Text(
                    'Review completed successfully with status: $status',
                  ),
                ),
              );
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
