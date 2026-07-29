import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/model/user_model.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  // Assessment fields
  double _qQuality = 4.0;
  double _qComm = 4.0;
  double _qTeam = 4.0;
  double _qDisc = 4.0;
  double _qProb = 4.0;
  double _qDead = 4.0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _recController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _recController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(id: '1', email: 'admin@aitu.edu', username: 'admin', fullName: 'Dr. Ahmed Hassan', role: 'Admin');
    final role = user.role.isEmpty ? 'Admin' : user.role;

    // Filter to show active team members for evaluation
    final employees = db.users.where((u) => u.role == 'Team Member').toList();

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
                role == 'Team Member' ? 'Score & Achievements'.tr(context) : 'Performance Evaluation'.tr(context),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4.h),
              Text(
                'Autocalculated weight-based metrics and rankings'.tr(context),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),

              // Performance Dashboard top metrics
              _buildPerformanceDashboardSummary(db),
              SizedBox(height: 20.h),

              // Employee Card Grid
              Text('Employee Directory & Scores'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),

              employees.isEmpty
                  ? Center(child: Text('No employees found.'.tr(context)))
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
                          itemCount: employees.length,
                          itemBuilder: (context, idx) {
                            final emp = employees[idx];
                            final initials = emp.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                            final score = emp.finalScore;

                            return InkWell(
                              onTap: () => _showEmployee360Modal(context, emp, user.id, role),
                              borderRadius: BorderRadius.circular(AppRadius.lg.r),
                              child: AppCard(
                                compact: true,
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(radius: 18.r, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Text(initials, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: AppColors.primary))),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emp.fullName, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                                              Text(emp.department.tr(context), style: TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 36.w,
                                          height: 36.h,
                                          child: CircularProgressIndicator(
                                            value: score / 100.0,
                                            strokeWidth: 3.5.w,
                                            backgroundColor: Colors.grey.shade100,
                                            color: score >= 80 ? AppColors.success : (score >= 60 ? Colors.orange : AppColors.danger),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${score.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                              Text(emp.finalScore >= 80 ? 'Excellent Performance'.tr(context) : 'Needs Focus'.tr(context), style: TextStyle(fontSize: 8.5.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                                              Text('Monthly Score'.tr(context) + ': ${emp.points}', style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                            ],
                                          ),
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

  // --- Top ranking performance summary panel ---
  Widget _buildPerformanceDashboardSummary(MockDatabase db) {
    final sorted = List<MockUser>.from(db.users.where((u) => u.role == 'Team Member'))..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final top = sorted.isNotEmpty ? sorted.first.fullName : 'N/A';
    final lowest = sorted.isNotEmpty ? sorted.last.fullName : 'N/A';

    return AppCard(
      child: Row(
        children: [
          Expanded(child: _buildMetricTile('Top Employee', top, Icons.emoji_events, Colors.amber)),
          Expanded(child: _buildMetricTile('Lowest Performance', lowest, Icons.trending_down, AppColors.danger)),
          Expanded(child: _buildMetricTile('Average Department Score', '84.2%', Icons.business, AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.tr(context), style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }

  // --- 360 Employee Overview Profile ---
  void _showEmployee360Modal(BuildContext context, MockUser emp, String currentUserId, String userRole) {
    final db = MockDatabase.instance;
    final isAuthorized = userRole == 'Admin' || userRole == 'Manager' || userRole == 'Team Leader';

    // Tasks counts
    final activeTasks = db.tasks.where((t) => t.currentOwnerId == emp.id && t.status != 'Completed' && t.status != 'Approved').toList();
    final completedTasks = db.tasks.where((t) => t.currentOwnerId == emp.id && (t.status == 'Completed' || t.status == 'Approved')).toList();
    final overdueCount = db.tasks.where((t) => t.currentOwnerId == emp.id && t.status == 'Overdue').length;

    // Complaints counts
    final empComplaints = db.complaints.where((c) => c.targetId == emp.id).toList();

    // Evaluations
    final empEvals = db.evaluations.where((e) => e.employeeId == emp.id).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('360° Employee Overview'.tr(context) + ': ${emp.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 580.w,
            height: 520.h,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(text: 'Basic Profile'.tr(context)),
                      Tab(text: 'Tasks & Quality'.tr(context)),
                      Tab(text: 'Evaluation Form'.tr(context)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Basic Profile
                        ListView(
                          padding: EdgeInsets.all(8.w),
                          children: [
                            ListTile(title: Text('Full Name'.tr(context)), subtitle: Text(emp.fullName)),
                            ListTile(title: Text('Email'.tr(context)), subtitle: Text(emp.email)),
                            ListTile(title: Text('Phone'.tr(context)), subtitle: Text(emp.phone)),
                            ListTile(title: Text('Department'.tr(context)), subtitle: Text(emp.department.tr(context))),
                            ListTile(title: Text('Overall Rating Score'.tr(context)), subtitle: Text('${emp.finalScore.toInt()}%')),
                            ListTile(title: Text('Productivity Rating'.tr(context)), subtitle: Text('${emp.productivityScore.toInt()}%')),
                            ListTile(title: Text('Deadline Commitment'.tr(context)), subtitle: Text('${emp.deadlineCommitment.toInt()}%')),
                          ],
                        ),

                        // Tab 2: Tasks & Quality (including Complaints Integration)
                        ListView(
                          padding: EdgeInsets.all(8.w),
                          children: [
                            Text('Task Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const Divider(),
                            Text('Active Tasks: '.tr(context) + '${activeTasks.length}'),
                            Text('Completed Tasks: '.tr(context) + '${completedTasks.length}'),
                            Text('Overdue Tasks Count: '.tr(context) + '$overdueCount', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12.h),

                            Text('Complaints Log'.tr(context) + ' (${empComplaints.length})', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                            const Divider(),
                            if (empComplaints.isEmpty) ...[
                              Text('No registered behavior/delay complaints.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                            ] else ...[
                              ...empComplaints.map((c) => ListTile(
                                    dense: true,
                                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${c.category.tr(context)} | ${c.date}'),
                                    trailing: Text(c.status.tr(context), style: TextStyle(color: _getStatusColor(c.status))),
                                  ))
                            ],
                            SizedBox(height: 12.h),

                            Text('Evaluation History'.tr(context) + ' (${empEvals.length})', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            const Divider(),
                            if (empEvals.isEmpty) ...[
                              Text('No evaluations documented yet.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                            ] else ...[
                              ...empEvals.map((ev) => ListTile(
                                    dense: true,
                                    title: Text('Date: '.tr(context) + ev.date),
                                    subtitle: Text('Task Quality: ${ev.taskQuality}/5 | Notes: ${ev.managerNotes}'),
                                  ))
                            ],
                          ],
                        ),

                        // Tab 3: Evaluation Form
                        ListView(
                          padding: EdgeInsets.all(8.w),
                          children: [
                            if (!isAuthorized) ...[
                              Center(child: Text('Only Admin/Managers can evaluate employees.'.tr(context))),
                            ] else ...[
                              _buildRatingSlider('Task Quality', _qQuality, (v) => setDialogState(() => _qQuality = v)),
                              _buildRatingSlider('Communication', _qComm, (v) => setDialogState(() => _qComm = v)),
                              _buildRatingSlider('Teamwork', _qTeam, (v) => setDialogState(() => _qTeam = v)),
                              _buildRatingSlider('Discipline', _qDisc, (v) => setDialogState(() => _qDisc = v)),
                              _buildRatingSlider('Problem Solving', _qProb, (v) => setDialogState(() => _qProb = v)),
                              _buildRatingSlider('Deadline Commitment', _qDead, (v) => setDialogState(() => _qDead = v)),
                              TextField(controller: _notesController, decoration: InputDecoration(labelText: 'Manager Notes'.tr(context))),
                              TextField(controller: _recController, decoration: InputDecoration(labelText: 'Recommendations'.tr(context))),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context))),
            if (isAuthorized)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    db.addEvaluation(
                      MockEvaluation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        evaluatorId: currentUserId,
                        employeeId: emp.id,
                        taskQuality: _qQuality,
                        communication: _qComm,
                        teamwork: _qTeam,
                        discipline: _qDisc,
                        problemSolving: _qProb,
                        deadlineCommitment: _qDead,
                        managerNotes: _notesController.text,
                        recommendations: _recController.text,
                        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      ),
                      currentUserId,
                    );
                    _notesController.clear();
                    _recController.clear();
                    _qQuality = 4.0;
                    _qComm = 4.0;
                    _qTeam = 4.0;
                    _qDisc = 4.0;
                    _qProb = 4.0;
                    _qDead = 4.0;
                  });
                  Navigator.pop(context);
                },
                child: Text('Submit Evaluation'.tr(context)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tr(context) + ': ${val.toStringAsFixed(1)} / 5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
        Slider(
          value: val,
          min: 1.0,
          max: 5.0,
          divisions: 4,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved') return AppColors.success;
    if (status == 'Open') return AppColors.danger;
    return Colors.orange;
  }
}
