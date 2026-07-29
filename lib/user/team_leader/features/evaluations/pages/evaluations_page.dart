import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
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

    // Find TL's team
    final team = db.teams.firstWhere(
      (t) => t.leaderId == user.id,
      orElse: () => MockTeam(
        id: '', name: '', managerId: '', department: '',
        leaderId: '', memberIds: [],
      ),
    );

    // Team members (only those in TL's team)
    final teamMembers = db.users.where((u) => team.memberIds.contains(u.id)).toList();

    // Top member by finalScore
    final sorted = List<MockUser>.from(teamMembers)..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final top = sorted.isNotEmpty ? sorted.first : null;
    final teamAvg = teamMembers.isEmpty ? 0.0 : teamMembers.fold(0.0, (sum, m) => sum + m.finalScore) / teamMembers.length;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team Performance & Scores'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 4.h),
              Text('Your team\'s evaluation metrics and member rankings'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
              SizedBox(height: 16.h),

              _buildYourScoreCard(db, user.id),
              SizedBox(height: 16.h),

              _buildTeamDashboard(db, top, teamAvg, teamMembers.length),
              SizedBox(height: 20.h),

              Text('Team Members Scores'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              SizedBox(height: 10.h),

              teamMembers.isEmpty
                  ? Center(child: Text('No team members found.'.tr(context)))
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
                            mainAxisExtent: 145.h,
                          ),
                          itemCount: teamMembers.length,
                          itemBuilder: (context, idx) {
                            final emp = teamMembers[idx];
                            final initials = emp.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                            final score = emp.finalScore;

                            return InkWell(
                              onTap: () => _showEmployee360Modal(context, emp, user.id),
                              borderRadius: BorderRadius.circular(AppRadius.lg.r),
                              child: AppCard(
                                compact: true,
                                padding: EdgeInsets.all(8.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(radius: 12.r, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Text(initials, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.sp, color: AppColors.primary))),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emp.fullName, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                                              Text(emp.department.tr(context), style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child: CircularProgressIndicator(
                                            value: score / 100.0,
                                            strokeWidth: 2.5.w,
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
                                              Text(score >= 80 ? 'Excellent'.tr(context) : 'Needs Focus'.tr(context), style: TextStyle(fontSize: 8.5.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                                              Text('Points: ${emp.points}', style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

  Widget _buildYourScoreCard(MockDatabase db, String currentUserId) {
    final leader = db.users.firstWhere((u) => u.id == currentUserId);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20.r, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Icon(Icons.person, color: AppColors.primary, size: 20.sp)),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Score'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  Text(leader.fullName, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 48.w,
                height: 48.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: leader.finalScore / 100.0,
                      strokeWidth: 4.w,
                      backgroundColor: Colors.grey.shade100,
                      color: leader.finalScore >= 80 ? AppColors.success : (leader.finalScore >= 60 ? Colors.orange : AppColors.danger),
                    ),
                    Text('${leader.finalScore.toInt()}%', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _buildMiniStat('Productivity', '${leader.productivityScore.toInt()}%', Colors.blue)),
              Expanded(child: _buildMiniStat('Deadlines', '${leader.deadlineCommitment.toInt()}%', Colors.green)),
              Expanded(child: _buildMiniStat('Approval Rate', '${leader.approvalRate.toInt()}%', Colors.orange)),
              Expanded(child: _buildMiniStat('Points', '${leader.points}', AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label.tr(context), style: TextStyle(fontSize: 8.5.sp, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTeamDashboard(MockDatabase db, MockUser? top, double teamAvg, int memberCount) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: _buildMetricTile('Top Member', top?.fullName ?? 'N/A', Icons.emoji_events, Colors.amber)),
          Expanded(child: _buildMetricTile('Team Avg Score', '${teamAvg.toStringAsFixed(1)}%', Icons.people, AppColors.primary)),
          Expanded(child: _buildMetricTile('Team Size', '$memberCount', Icons.group, Colors.indigo)),
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

  void _showEmployee360Modal(BuildContext context, MockUser emp, String currentUserId) {
    final db = MockDatabase.instance;

    final activeTasks = db.tasks.where((t) => t.currentOwnerId == emp.id && t.status != 'Completed' && t.status != 'Approved').toList();
    final completedTasks = db.tasks.where((t) => t.currentOwnerId == emp.id && (t.status == 'Completed' || t.status == 'Approved')).toList();
    final overdueCount = db.tasks.where((t) => t.currentOwnerId == emp.id && t.status == 'Overdue').length;
    final empComplaints = db.complaints.where((c) => c.targetId == emp.id).toList();
    final empEvals = db.evaluations.where((e) => e.employeeId == emp.id).toList();

    // Reset assessment fields
    _qQuality = 4.0;
    _qComm = 4.0;
    _qTeam = 4.0;
    _qDisc = 4.0;
    _qProb = 4.0;
    _qDead = 4.0;
    _notesController.clear();
    _recController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600.w,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${emp.fullName} — 360° Overview', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF94A3B8))),
                  ],
                ),
                SizedBox(height: 8.h),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: [
                            Tab(text: 'Profile'.tr(context)),
                            Tab(text: 'Tasks & Quality'.tr(context)),
                            Tab(text: 'Evaluate'.tr(context)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView(
                                padding: EdgeInsets.all(8.w),
                                children: [
                                  _buildInfoTile(Icons.person, 'Full Name', emp.fullName),
                                  _buildInfoTile(Icons.email, 'Email', emp.email),
                                  _buildInfoTile(Icons.phone, 'Phone', emp.phone),
                                  _buildInfoTile(Icons.business, 'Department', emp.department.tr(context)),
                                  const Divider(),
                                  _buildInfoTile(Icons.star, 'Overall Score', '${emp.finalScore.toInt()}%'),
                                  _buildInfoTile(Icons.trending_up, 'Productivity', '${emp.productivityScore.toInt()}%'),
                                  _buildInfoTile(Icons.schedule, 'Deadline Commitment', '${emp.deadlineCommitment.toInt()}%'),
                                  _buildInfoTile(Icons.thumb_up, 'Approval Rate', '${emp.approvalRate.toInt()}%'),
                                  _buildInfoTile(Icons.thumb_down, 'Rejection Rate', '${emp.rejectionRate.toInt()}%'),
                                  _buildInfoTile(Icons.assignment, 'Leader Eval', '${emp.leaderEvaluation.toInt()}%'),
                                  _buildInfoTile(Icons.monetization_on, 'Points', '${emp.points}'),
                                ],
                              ),

                              ListView(
                                padding: EdgeInsets.all(8.w),
                                children: [
                                  Text('Task Summary'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const Divider(),
                                  _buildInfoTile(Icons.play_arrow, 'Active Tasks', '${activeTasks.length}'),
                                  _buildInfoTile(Icons.check_circle, 'Completed Tasks', '${completedTasks.length}'),
                                  _buildInfoTile(Icons.error, 'Overdue Tasks', '$overdueCount'),
                                  SizedBox(height: 12.h),

                                  Text('${'Complaints Log'.tr(context)} (${empComplaints.length})', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                                  const Divider(),
                                  if (empComplaints.isEmpty)
                                    Text('No complaints.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp))
                                  else
                                    ...empComplaints.map((c) => _buildInfoTile(Icons.report, c.title, '${c.category.tr(context)} | ${c.status.tr(context)}')),
                                  SizedBox(height: 12.h),

                                  Text('${'Evaluation History'.tr(context)} (${empEvals.length})', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  const Divider(),
                                  if (empEvals.isEmpty)
                                    Text('No evaluations yet.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp))
                                  else
                                    ...empEvals.map((ev) => _buildInfoTile(Icons.history, ev.date, 'Quality: ${ev.taskQuality}/5 | ${ev.managerNotes}')),
                                ],
                              ),

                              ListView(
                                padding: EdgeInsets.all(8.w),
                                children: [
                                  _buildRatingSlider('Task Quality', _qQuality, (v) => setDialogState(() => _qQuality = v)),
                                  _buildRatingSlider('Communication', _qComm, (v) => setDialogState(() => _qComm = v)),
                                  _buildRatingSlider('Teamwork', _qTeam, (v) => setDialogState(() => _qTeam = v)),
                                  _buildRatingSlider('Discipline', _qDisc, (v) => setDialogState(() => _qDisc = v)),
                                  _buildRatingSlider('Problem Solving', _qProb, (v) => setDialogState(() => _qProb = v)),
                                  _buildRatingSlider('Deadline Commitment', _qDead, (v) => setDialogState(() => _qDead = v)),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    controller: _notesController,
                                    decoration: InputDecoration(labelText: 'Manager Notes'.tr(context), isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: _recController,
                                    decoration: InputDecoration(labelText: 'Recommendations'.tr(context), isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 16.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
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
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        elevation: 0,
                                      ),
                                      child: Text('Submit Evaluation'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF94A3B8)),
          SizedBox(width: 8.w),
          Text('${label.tr(context)}: ', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)))),
        ],
      ),
    );
  }

  Widget _buildRatingSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${label.tr(context)}: ${val.toStringAsFixed(1)} / 5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
        Slider(value: val, min: 1.0, max: 5.0, divisions: 4, onChanged: onChanged),
      ],
    );
  }
}
