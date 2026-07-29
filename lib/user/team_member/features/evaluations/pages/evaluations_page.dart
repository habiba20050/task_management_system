import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../shared/features/auth/model/user_model.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
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
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(id: '1', email: 'admin@aitu.edu', username: 'admin', fullName: 'Dr. Ahmed Hassan', role: 'Admin');
    final mockUser = db.users.firstWhere((u) => u.id == user.id, orElse: () => db.users.first);

    // My evaluations only
    final myEvals = db.evaluations.where((e) => e.employeeId == user.id).toList();

    // Apply filters
    var filteredEvals = myEvals;
    if (_statusFilter == 'High') {
      filteredEvals = filteredEvals.where((e) => e.taskQuality >= 4.5).toList();
    } else if (_statusFilter == 'Medium') {
      filteredEvals = filteredEvals.where((e) => e.taskQuality >= 3.0 && e.taskQuality < 4.5).toList();
    } else if (_statusFilter == 'Low') {
      filteredEvals = filteredEvals.where((e) => e.taskQuality < 3.0).toList();
    }

    if (_dateRange != null) {
      filteredEvals = filteredEvals.where((e) {
        final d = DateTime.tryParse(e.date);
        return d != null && d.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date descending
    filteredEvals = List.from(filteredEvals)..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Score & Achievements'.tr(context),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your personal performance metrics and evaluation history'.tr(context),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),

              // My Score Summary Card
              _buildMyScoreSummary(mockUser),
              SizedBox(height: 20.h),

              // Filter bar
              _buildFilterBar(context),
              SizedBox(height: 16.h),

              // Evaluation History
              Text('Evaluation History'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),

              filteredEvals.isEmpty
                  ? Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Text('No evaluations found.'.tr(context)),
                    ))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvals.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, idx) {
                        final ev = filteredEvals[idx];
                        final avg = (ev.taskQuality + ev.communication + ev.teamwork + ev.discipline + ev.problemSolving + ev.deadlineCommitment) / 6.0;
                        final evaluator = db.users.firstWhere(
                          (u) => u.id == ev.evaluatorId,
                          orElse: () => MockUser(id: '', email: '', fullName: 'Unknown', role: '', department: ''),
                        );

                        return _buildEvaluationCard(ev, avg, evaluator.fullName, context);
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
            width: 110.w,
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
                items: ['All', 'High', 'Medium', 'Low'].map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context)))).toList(),
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

  Widget _buildMyScoreSummary(MockUser user) {
    // Build personal score gauge similar to dashboard
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Performance Score'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
            SizedBox(height: 16.h),
            Row(
              children: [
                // Circular gauge
                SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100.w,
                        height: 100.h,
                        child: CircularProgressIndicator(
                          value: user.finalScore / 100.0,
                          strokeWidth: 8.w,
                          backgroundColor: Colors.grey.shade100,
                          color: user.finalScore >= 80 ? AppColors.success : (user.finalScore >= 60 ? Colors.orange : AppColors.danger),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${user.finalScore.toInt()}%', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Overall'.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    children: [
                      _buildScoreRow('Productivity'.tr(context), user.productivityScore),
                      _buildScoreRow('Deadline'.tr(context), user.deadlineCommitment),
                      _buildScoreRow('Approval Rate'.tr(context), user.approvalRate),
                      _buildScoreRow('Rejection Rate'.tr(context), user.rejectionRate, invert: true),
                      _buildScoreRow('Leader Eval'.tr(context), user.leaderEvaluation),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text('Points: ${user.points}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, {bool invert = false}) {
    final displayScore = invert ? 100.0 - score : score;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(width: 80.w, child: Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: displayScore / 100.0,
                minHeight: 6.h,
                backgroundColor: Colors.grey.shade100,
                color: displayScore >= 80 ? AppColors.success : (displayScore >= 60 ? Colors.orange : AppColors.danger),
              ),
            ),
          ),
          SizedBox(width: 32.w, child: Text('${score.toInt()}%', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(MockEvaluation ev, double avg, String evaluatorName, BuildContext context) {
    return AppCard(
      compact: true,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text('${(avg * 20).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: AppColors.primary)),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evaluation ${ev.date}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('By ${evaluatorName}', style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: avg >= 4.0 ? AppColors.success.withValues(alpha: 0.12) : (avg >= 3.0 ? Colors.orange.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    avg >= 4.0 ? 'Good'.tr(context) : (avg >= 3.0 ? 'Average'.tr(context) : 'Needs Improvement'.tr(context)),
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: avg >= 4.0 ? AppColors.success : (avg >= 3.0 ? Colors.orange : AppColors.danger)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 4.h,
              children: [
                _buildChip('Quality'.tr(context), '${ev.taskQuality}/5'),
                _buildChip('Comm'.tr(context), '${ev.communication}/5'),
                _buildChip('Teamwork'.tr(context), '${ev.teamwork}/5'),
                _buildChip('Discipline'.tr(context), '${ev.discipline}/5'),
                _buildChip('Problem Solving'.tr(context), '${ev.problemSolving}/5'),
                _buildChip('Deadline'.tr(context), '${ev.deadlineCommitment}/5'),
              ],
            ),
            if (ev.managerNotes.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text('Notes: ${ev.managerNotes}', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text('$label: $value', style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary)),
    );
  }
}
