import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import 'package:task_management_system/auth/model/user_model.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Evaluation history filters
  String _statusFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return Colors.orange;
    return AppColors.danger;
  }

  String _getScoreLabel(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Average';
    return 'Needs Improvement';
  }

  // ─── Modern UI helpers ────────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

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

  Widget _scorePill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.sp,
        color: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(
            id: '1',
            email: 'admin@aitu.edu',
            username: 'admin',
            fullName: 'Dr. Ahmed Hassan',
            role: 'Admin');
    final mockUser =
        db.users.firstWhere((u) => u.id == user.id, orElse: () => db.users.first);

    // My evaluations only
    final myEvals = db.evaluations.where((e) => e.employeeId == user.id).toList();

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientChip(Icons.insights_outlined, AppColors.primary, size: 44),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score & Achievements'.tr(context),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Your personal performance metrics and evaluation history'.tr(context),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.all(6.w),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: ResponsiveLayout.isMobile(context),
                  tabAlignment: ResponsiveLayout.isMobile(context)
                      ? TabAlignment.center
                      : TabAlignment.fill,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, _darker(AppColors.primary)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ResponsiveLayout.isMobile(context)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('My Score'.tr(context)),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('My Score'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ResponsiveLayout.isMobile(context)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.assessment_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Evaluation History'.tr(context)),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.assessment_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Evaluation History'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: My Score
                    _buildMyScoreTab(context, mockUser),

                    // Tab 2: Evaluation History
                    _buildHistoryTab(context, db, myEvals),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 1: My Score ─────────────────────────────────────────────────────
  Widget _buildMyScoreTab(BuildContext context, MockUser u) {
    final scoreColor = _getScoreColor(u.finalScore);
    final db = MockDatabase.instance;
    final completedTasks = db.tasks
        .where((t) => (t.currentOwnerId == u.id || (t.customAssigneeIds != null && t.customAssigneeIds!.contains(u.id))) && (t.status == 'Completed' || t.status == 'Approved'))
        .length;
    final activeTasks = db.tasks
        .where((t) => (t.currentOwnerId == u.id || (t.customAssigneeIds != null && t.customAssigneeIds!.contains(u.id))) && t.status != 'Completed' && t.status != 'Approved')
        .length;

    return SingleChildScrollView(
      key: const PageStorageKey('my_score_tab'),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: _modernCardDecoration(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                final scoreRing = Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 108.r,
                      height: 108.r,
                      child: CircularProgressIndicator(
                        value: u.finalScore / 100.0,
                        strokeWidth: 7.r,
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: scoreColor,
                      ),
                    ),
                    _avatar(u.fullName, 78, scoreColor),
                  ],
                );
                final info = Column(
                  crossAxisAlignment:
                      compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.fullName,
                      textAlign: compact ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${u.role.tr(context)} · ${u.department}',
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _getScoreLabel(u.finalScore).tr(context),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                    ),
                  ],
                );
                final scoreBox = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${u.finalScore.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: scoreColor),
                    ),
                    Text(
                      'Final Score'.tr(context),
                      style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                    ),
                  ],
                );

                if (compact) {
                  return Column(
                    children: [
                      scoreRing,
                      SizedBox(height: 16.h),
                      info,
                      SizedBox(height: 14.h),
                      scoreBox,
                    ],
                  );
                }
                return Row(
                  children: [
                    scoreRing,
                    SizedBox(width: 22.w),
                    Expanded(child: info),
                    scoreBox,
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Performance breakdown grid
          _sectionTitle('Performance Breakdown'.tr(context)),
          SizedBox(height: 12.h),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth < 600 ? 2 : 4;
            final metrics = [
              _MetricData('Productivity'.tr(context), u.productivityScore, Icons.speed_outlined, AppColors.primary),
              _MetricData('Deadline Commit.'.tr(context), u.deadlineCommitment, Icons.timer_outlined, Colors.indigo),
              _MetricData('Approval Rate'.tr(context), u.approvalRate, Icons.check_circle_outline, AppColors.success),
              _MetricData('Leader Eval.'.tr(context), u.leaderEvaluation, Icons.star_border_outlined, Colors.amber),
              _MetricData('Rejection Rate'.tr(context), u.rejectionRate, Icons.cancel_outlined, AppColors.danger),
              _MetricData('Tasks Done'.tr(context), completedTasks * 10.0, Icons.task_alt_outlined, Colors.teal),
              _MetricData('Active Tasks'.tr(context), activeTasks * 10.0, Icons.pending_actions_outlined, Colors.orange),
              _MetricData('Points'.tr(context), u.points.toDouble(), Icons.emoji_events_outlined, Colors.amber),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                mainAxisExtent: 86.h,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, i) {
                final m = metrics[i];
                final isTaskMetric = m.label == 'Tasks Done'.tr(context) || m.label == 'Active Tasks'.tr(context);
                final displayVal = m.label == 'Points'.tr(context)
                    ? u.points.toString()
                    : isTaskMetric
                        ? (m.label == 'Tasks Done'.tr(context) ? completedTasks.toString() : activeTasks.toString())
                        : '${m.value.toStringAsFixed(1)}%';
                return StatCard(
                  title: m.label,
                  value: displayVal,
                  icon: m.icon,
                  accentColor: m.color,
                );
              },
            );
          }),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ─── TAB 2: Evaluation History ───────────────────────────────────────────
  Widget _buildHistoryTab(BuildContext context, MockDatabase db, List<MockEvaluation> myEvals) {
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
        return d != null &&
            d.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date descending
    filteredEvals = List.from(filteredEvals)..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      key: const PageStorageKey('eval_history_tab'),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter bar
          _buildFilterBar(context),
          SizedBox(height: 16.h),

          _sectionTitle('Evaluation History'.tr(context)),
          SizedBox(height: 12.h),

          if (filteredEvals.isEmpty)
            _emptyState(context, 'No evaluations found.'.tr(context))
          else
            ...filteredEvals.map((ev) => _buildEvaluationCard(context, db, ev)),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _modernCardDecoration(),
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                '${'Filter by'.tr(context)}:',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isExpanded: true,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
                items: ['All', 'High', 'Medium', 'Low']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context))))
                    .toList(),
                onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range, size: 14),
            label: Text(
              _dateRange == null
                  ? 'Date Range'.tr(context)
                  : '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
              style: const TextStyle(fontSize: 10),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              minimumSize: Size.zero,
            ),
          ),
          if (_dateRange != null || _statusFilter != 'All')
            TextButton.icon(
              onPressed: () => setState(() {
                _statusFilter = 'All';
                _dateRange = null;
              }),
              icon: const Icon(Icons.clear, size: 14),
              label: Text('Clear'.tr(context), style: const TextStyle(fontSize: 10)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                minimumSize: Size.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(BuildContext context, MockDatabase db, MockEvaluation ev) {
    final avg = ((ev.taskQuality +
                ev.communication +
                ev.teamwork +
                ev.discipline +
                ev.problemSolving +
                ev.deadlineCommitment) /
            6 *
            20);
    final color = _getScoreColor(avg);
    final evaluator = db.users.firstWhere(
      (u) => u.id == ev.evaluatorId,
      orElse: () =>
          MockUser(id: '', email: '', fullName: 'Unknown', role: '', department: ''),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(Icons.assessment_outlined, AppColors.primary, size: 42),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evaluation – ${ev.date}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'By ${evaluator.fullName}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avg.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
                  ),
                  SizedBox(height: 3.h),
                  _scorePill(_getScoreLabel(avg).tr(context), color),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: const Color(0xFFF1F5F9), thickness: 1),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
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
            SizedBox(height: 12.h),
            _buildNoteBox(
              Icons.notes_rounded,
              'Manager Notes'.tr(context),
              ev.managerNotes,
              AppColors.primary,
            ),
          ],
          if (ev.recommendations.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _buildNoteBox(
              Icons.lightbulb_outline_rounded,
              'Recommendations'.tr(context),
              ev.recommendations,
              Colors.amber,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildNoteBox(IconData icon, String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String msg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: _modernCardDecoration(),
      child: Column(
        children: [
          _gradientChip(Icons.assessment_outlined, AppColors.textSecondary, size: 44),
          SizedBox(height: 10.h),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  const _MetricData(this.label, this.value, this.icon, this.color);
}
