import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.role;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evaluation Center',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Autocalculated weight-based metrics and rankings',
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),

              if (role == 'Team Member')
                _buildMemberEvaluationBreakdown(context, user.id)
              else if (role == 'Team Leader')
                _buildLeaderEvaluationBreakdown(context, user.id)
              else if (role == 'Manager')
                _buildManagerEvaluationBreakdown(context, user.id)
              else
                _buildAdminEvaluationOverview(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberEvaluationBreakdown(BuildContext context, String memberId) {
    final user = MockDatabase.instance.users.firstWhere(
      (u) => u.id == memberId,
      orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Member Score: ${user.fullName}',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Points: ${user.points}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.aituRed),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text('Final Score: ${user.finalScore.toInt()}%', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(height: 32),
                
                _buildWeightedIndicator('Productivity Score', user.productivityScore, 30),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Deadline Commitment', user.deadlineCommitment, 25),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Approval Rate', user.approvalRate, 25),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Rejection Rate (Negative Weight)', user.rejectionRate, 10),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Team Leader Evaluation', user.leaderEvaluation, 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightedIndicator(String title, double score, int weight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title ($weight% Weight)', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${score.toInt()}%'),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: score / 100.0,
          backgroundColor: Colors.grey[200],
          color: title.contains('Rejection') ? Colors.red : AppColors.primary,
          minHeight: 8.h,
        ),
      ],
    );
  }

  Widget _buildLeaderEvaluationBreakdown(BuildContext context, String leaderId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Leader Evaluation Metrics',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Divider(height: 32),
                _buildWeightedIndicator('Team Productivity', 88, 30),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Team Satisfaction', 92, 25),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Delivery Quality', 85, 25),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Manager Feedback', 80, 20),
                SizedBox(height: 24.h),
                Text('Leader Health Index: 86.8%', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagerEvaluationBreakdown(BuildContext context, String managerId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager Evaluation Metrics',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Divider(height: 32),
                _buildWeightedIndicator('Team Performance', 90, 40),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Delivery Success', 95, 30),
                SizedBox(height: 16.h),
                _buildWeightedIndicator('Admin Evaluation', 85, 30),
                SizedBox(height: 24.h),
                Text('Managerial Score: 90.5%', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminEvaluationOverview(BuildContext context) {
    final members = MockDatabase.instance.users.where((u) => u.role == 'Team Member').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'University Evaluations Overview',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final m = members[index];
            return Card(
              color: Colors.white,
              child: ListTile(
                title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Productivity: ${m.productivityScore.toInt()}% | Commitment: ${m.deadlineCommitment.toInt()}%'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${m.finalScore.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    Text('Points: ${m.points}', style: const TextStyle(color: Colors.red, fontSize: 11)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
