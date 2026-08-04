import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../responsive/responsive_layout.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskId;
  const TaskDetailsPage({super.key, required this.taskId});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  // Time tracking (Team Member)
  Timer? _stopwatchTimer;
  double _activeTime = 0.0; // in seconds

  // Discussion controllers
  final TextEditingController _commentController = TextEditingController();
  MockTaskComment? _replyingTo;

  // Deliverables (files + notes)
  final List<PlatformFile> _pickedFiles = [];
  final TextEditingController _deliverableNoteController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _initStopwatch();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _stopwatchTimer?.cancel();
    _tabController.dispose();
    _commentController.dispose();
    _deliverableNoteController.dispose();
    super.dispose();
  }

  DateTime? _parseDeadline(MockTask task) {
    return DateTime.tryParse('${task.deadline} ${task.dueTime}') ??
        DateTime.tryParse(task.deadline);
  }

  String _formatDeadlineRemaining(Duration d) {
    final Duration abs = d.isNegative ? d.abs() : d;
    final int days = abs.inDays;
    final int hours = abs.inHours.remainder(24);
    final int minutes = abs.inMinutes.remainder(60);
    if (days > 0)
      return '$days ${'days'.tr(context)} $hours ${'hours'.tr(context)}';
    if (hours > 0)
      return '$hours ${'hours'.tr(context)} $minutes ${'minutes'.tr(context)}';
    return '$minutes ${'minutes'.tr(context)}';
  }

  // ─── STOPWATCH ─────────────────────────────────────────────────────────────
  void _initStopwatch() {
    final db = MockDatabase.instance;
    final taskIdx = db.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIdx != -1) {
      final task = db.tasks[taskIdx];
      _activeTime = task.actualTime;
      if (task.timerRunning && task.timerStartTime != null) {
        final elapsed =
            (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) /
            1000.0;
        _activeTime = task.actualTime + elapsed;
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _activeTime += 1.0;
      });
    });
  }

  void _onStartStopwatch(MockTask task) {
    setState(() {
      task.timerRunning = true;
      task.timerStartTime = DateTime.now().millisecondsSinceEpoch;
      MockDatabase.instance.updateTaskTimerState(
        task.id,
        true,
        task.timerStartTime,
      );
      _startTimer();
    });
  }

  void _onPauseStopwatch(MockTask task) {
    _stopwatchTimer?.cancel();
    final elapsed = task.timerStartTime != null
        ? (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) /
              1000.0
        : 0.0;
    final totalSec = task.actualTime + elapsed;
    setState(() {
      task.timerRunning = false;
      task.actualTime = totalSec;
      _activeTime = totalSec;
      MockDatabase.instance.updateTaskTime(task.id, totalSec);
      MockDatabase.instance.updateTaskTimerState(task.id, false, null);
    });
  }

  void _onStopStopwatch(MockTask task) {
    _stopwatchTimer?.cancel();
    final elapsed = task.timerStartTime != null
        ? (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) /
              1000.0
        : 0.0;
    final totalSec = task.actualTime + elapsed;
    setState(() {
      task.timerRunning = false;
      task.actualTime = totalSec;
      _activeTime = totalSec;
      MockDatabase.instance.updateTaskTime(task.id, totalSec);
      MockDatabase.instance.updateTaskTimerState(task.id, false, null);
    });
  }

  String _formatStopwatch(double sec) {
    final int hours = (sec / 3600).floor();
    final int minutes = ((sec % 3600) / 60).floor();
    final int seconds = (sec % 60).floor();

    final hStr = hours < 10 ? '0$hours' : '$hours';
    final mStr = minutes < 10 ? '0$minutes' : '$minutes';
    final sStr = seconds < 10 ? '0$seconds' : '$seconds';

    return '$hStr:$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final taskIdx = db.tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIdx == -1) {
      return Scaffold(
        backgroundColor: AppColors.dashboardBg,
        appBar: AppBar(title: Text('Task Details'.tr(context))),
        body: Center(child: Text('Task not found.'.tr(context))),
      );
    }

    final task = db.tasks[taskIdx];
    final authState = context.read<AuthCubit>().state;
    final String currentUserId = authState is AuthSuccess
        ? (authState.user.id as String? ?? '4')
        : '4';
    final String currentUserName = authState is AuthSuccess
        ? (authState.user.fullName ?? 'Sarah Ahmed')
        : 'Sarah Ahmed';

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(task),
            _buildTabBar(task),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(task, db, currentUserId, currentUserName),
                  _buildDiscussionTab(task, currentUserId, currentUserName),
                  _buildTimelineTab(task),
                  _buildAttachmentsTab(task),
                  _buildDeliverablesTab(task, currentUserId, currentUserName),
                  _buildHistoryTab(task),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(MockTask task) {
    final statusColor = _statusColor(task.status);
    final priorityColor = _priorityColor(task.priority);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _gradientChip(
            task.taskType == 'Team Task'
                ? Icons.groups_rounded
                : Icons.task_alt_rounded,
            statusColor,
            size: 48,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${task.taskType.tr(context)} · ${task.ticketId}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _statusChip(
                      task.status.tr(context),
                      statusColor,
                      Icons.circle,
                    ),
                    _statusChip(
                      '${'Priority'.tr(context)}: ${task.priority.tr(context)}',
                      priorityColor,
                      Icons.flag_rounded,
                    ),
                    _statusChip(
                      task.status == 'Overdue'
                          ? '${'Overdue'.tr(context)} · ${task.deadline}'
                          : task.deadline,
                      task.status == 'Overdue'
                          ? AppColors.danger
                          : Colors.indigo,
                      Icons.event_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────────────────
  Widget _buildTabBar(MockTask task) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: ResponsiveLayout.isMobile(context),
        tabAlignment: ResponsiveLayout.isMobile(context)
            ? TabAlignment.center
            : TabAlignment.fill,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13.sp,
        ),
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, _darker(AppColors.primary)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        tabs: [
          _taskTab(
            index: 0,
            icon: Icons.dashboard_outlined,
            label: 'Overview',
            count: task.checklist.length,
          ),
          _taskTab(
            index: 1,
            icon: Icons.chat_bubble_outline,
            label: 'Discussion',
            count: task.comments.length,
          ),
          _taskTab(
            index: 2,
            icon: Icons.timeline,
            label: 'Activity Timeline',
            count: task.activities.length,
          ),
          _taskTab(
            index: 3,
            icon: Icons.attach_file,
            label: 'Attachments',
            count: task.attachments.length,
          ),
          _taskTab(
            index: 4,
            icon: Icons.upload_file,
            label: 'Deliverables',
            count: _pickedFiles.length,
          ),
          _taskTab(
            index: 5,
            icon: Icons.history,
            label: 'History',
            count: task.history.length,
          ),
        ],
      ),
    );
  }

  Widget _taskTab({
    required int index,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final Widget badge = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _tabController.index == index
            ? Colors.white
            : AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
    return Tab(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: ResponsiveLayout.isMobile(context)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 16),
                  SizedBox(width: 8),
                  Text(label.tr(context)),
                  SizedBox(width: 8),
                  badge,
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 16),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label.tr(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  badge,
                ],
              ),
      ),
    );
  }

  // ─── OVERVIEW TAB ─────────────────────────────────────────────────────────
  Widget _buildOverviewTab(
    MockTask task,
    MockDatabase db,
    String currentUserId,
    String currentUserName,
  ) {
    final owner = db.users.firstWhere(
      (u) => u.id == task.currentOwnerId,
      orElse: () => MockUser(
        id: '',
        email: '',
        fullName: 'Unassigned',
        role: '',
        department: '',
      ),
    );
    final creator = db.users.firstWhere(
      (u) => u.id == task.assignedById,
      orElse: () => MockUser(
        id: '',
        email: '',
        fullName: 'System',
        role: '',
        department: '',
      ),
    );

    final int doneCount = task.checklist.where((c) => c.isDone).length;
    final int totalCount = task.checklist.length;
    final double checklistProgress = totalCount == 0
        ? 0.0
        : (doneCount / totalCount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTaskDetailsCard(task, owner, creator),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(flex: 2, child: _buildDeadlineCard(task)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildTaskDetailsCard(task, owner, creator),
                  SizedBox(height: 16.h),
                  _buildDeadlineCard(task),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          _buildChecklistCard(task, totalCount, checklistProgress),
          SizedBox(height: 16.h),
          _buildMyWorkCard(task, currentUserId, currentUserName),
          SizedBox(height: 16.h),
          _buildAttachmentsCard(task),
        ],
      ),
    );
  }

  Widget _buildTaskDetailsCard(
    MockTask task,
    MockUser owner,
    MockUser creator,
  ) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(
                Icons.description_outlined,
                AppColors.primary,
                size: 34,
              ),
              SizedBox(width: 10.w),
              Text(
                'Task Details'.tr(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (task.description.isNotEmpty) ...[
            Text(
              task.description,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            Divider(height: 24.h, color: const Color(0xFFE2E8F0)),
          ],
          _detailRow(Icons.person_outline, 'Assigned By', creator.fullName),
          _detailRow(
            Icons.person_pin_outlined,
            'Current Owner',
            owner.fullName,
          ),
          _detailRow(
            Icons.business_outlined,
            'Department',
            task.taskDepartment.tr(context),
          ),
          _detailRow(
            Icons.flag_outlined,
            'Priority',
            task.priority.tr(context),
          ),
          _detailRow(
            Icons.calendar_today_outlined,
            'Start Date & Time',
            '${task.startDate} | ${task.startTime}',
          ),
          _detailRow(
            Icons.event_outlined,
            'Due Date & Time',
            '${task.deadline} | ${task.dueTime}',
          ),
          _detailRow(
            Icons.timer_outlined,
            'Estimated Duration',
            '${task.estimatedHours} ${'Hours'.tr(context)}',
          ),
          _detailRow(
            Icons.swap_horiz_outlined,
            'Reassignment Allowed',
            task.allowReassignment ? 'Yes'.tr(context) : 'No'.tr(context),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: Text(
              label.tr(context),
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(MockTask task) {
    final DateTime? deadline = _parseDeadline(task);
    final bool isOverdue = deadline != null && _now.isAfter(deadline);
    final Duration remaining = deadline != null
        ? deadline.difference(_now)
        : Duration.zero;
    final String remainingLabel = deadline == null
        ? '${task.deadline} | ${task.dueTime}'
        : (isOverdue
              ? '${'Overdue by'.tr(context)} ${_formatDeadlineRemaining(remaining)}'
              : '${'Remaining Time'.tr(context)}: ${_formatDeadlineRemaining(remaining)}');
    final Color accent = isOverdue ? AppColors.danger : Colors.indigo;

    // Elapsed fraction between start date & deadline
    double elapsed = 0.0;
    final DateTime? start = DateTime.tryParse(task.startDate);
    if (deadline != null && start != null && deadline.isAfter(start)) {
      final total = deadline.difference(start).inMilliseconds;
      final passed = _now.difference(start).inMilliseconds;
      if (total > 0) elapsed = (passed / total).clamp(0.0, 1.0);
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(Icons.event_available_rounded, accent, size: 34),
              SizedBox(width: 10.w),
              Text(
                'Deadline'.tr(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                isOverdue
                    ? Icons.error_outline_rounded
                    : Icons.calendar_month_rounded,
                size: 16,
                color: accent,
              ),
              SizedBox(width: 6.w),
              Text(
                '${task.deadline} | ${task.dueTime}',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.4.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Text(
              remainingLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: elapsed,
              color: accent,
              backgroundColor: const Color(0xFFE2E8F0),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start: ${task.startDate}',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(elapsed * 100).round()}%',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('Estimated'.tr(context), '${task.estimatedTime} h'),
              _miniStat(
                'Overdue'.tr(context),
                isOverdue ? 'Yes'.tr(context) : 'No'.tr(context),
              ),
              _miniStat('Status'.tr(context), task.status.tr(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistCard(
    MockTask task,
    int totalCount,
    double checklistProgress,
  ) {
    final int doneCount = task.checklist.where((c) => c.isDone).length;
    final int percent = (checklistProgress * 100).toInt();
    final bool allDone = checklistProgress == 1.0 && totalCount > 0;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _gradientChip(
                    Icons.checklist_rounded,
                    AppColors.success,
                    size: 34,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Task Checklist'.tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$doneCount / $totalCount',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: allDone ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: checklistProgress,
                    color: allDone ? AppColors.success : AppColors.primary,
                    backgroundColor: const Color(0xFFE2E8F0),
                    minHeight: 8,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: (allDone ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$percent% ${'Done'.tr(context)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: allDone ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (totalCount > 0)
            ...task.checklist.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _checklistItemTile(task, item),
              );
            })
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'No checklist items yet.'.tr(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          SizedBox(height: 10.h),
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add checklist item...'.tr(context),
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  setState(() {
                    task.checklist.add(
                      MockChecklistItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: val.trim(),
                      ),
                    );
                    MockDatabase.instance.updateTaskChecklist(
                      task.id,
                      task.checklist,
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistItemTile(MockTask task, MockChecklistItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmToggleChecklistItem(task, item),
        borderRadius: BorderRadius.circular(12.r),
        highlightColor: Colors.transparent,
        splashColor: AppColors.success.withValues(alpha: 0.35),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: item.isDone
                ? AppColors.success.withValues(alpha: 0.06)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: item.isDone
                  ? AppColors.success.withValues(alpha: 0.35)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  gradient: item.isDone
                      ? LinearGradient(
                          colors: [
                            AppColors.success,
                            _darker(AppColors.success),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: item.isDone ? null : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isDone
                        ? Colors.transparent
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: item.isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: item.isDone ? FontWeight.w500 : FontWeight.w600,
                    color: item.isDone
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: item.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmToggleChecklistItem(
    MockTask task,
    MockChecklistItem item,
  ) async {
    final bool markDone = !item.isDone;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _gradientChip(
                      markDone
                          ? Icons.check_circle_outline
                          : Icons.undo_rounded,
                      markDone ? AppColors.success : Colors.orange,
                      size: 52,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        markDone
                            ? 'Mark as Complete?'.tr(context)
                            : 'Mark as Incomplete?'.tr(context),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  markDone
                      ? 'Are you sure you want to mark this item as complete?'
                            .tr(context)
                      : 'Are you sure you want to reopen this item?'.tr(
                          context,
                        ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr(context),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 150.w,
                      child: _gradientButton(
                        dialogContext,
                        markDone ? 'Complete' : 'Reopen',
                        () {
                          Navigator.pop(dialogContext, true);
                        },
                        color: markDone ? AppColors.success : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        item.isDone = markDone;
        final allDone = task.checklist.every((c) => c.isDone);
        if (allDone &&
            task.checklist.isNotEmpty &&
            task.status != 'Completed') {
          task.status = 'Completed';
          MockDatabase.instance.updateTaskStatus(
            task.id,
            'Completed',
            'System',
          );
        }
        MockDatabase.instance.updateTaskChecklist(task.id, task.checklist);
      });
    }
  }

  // ─── MY WORK (TEAM MEMBER) ─────────────────────────────────────────────────
  Widget _buildMyWorkCard(
    MockTask task,
    String currentUserId,
    String currentUserName,
  ) {
    final bool isSubmitted =
        task.status == 'Submitted' ||
        task.status == 'Under Review' ||
        task.status == 'Approved' ||
        task.status == 'Completed';
    final bool hasSubmission =
        (task.githubLink != null && task.githubLink!.isNotEmpty) ||
        (task.prLink != null && task.prLink!.isNotEmpty);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(Icons.work_outline, AppColors.primary, size: 34),
              SizedBox(width: 10.w),
              Text(
                'My Work'.tr(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _detailRow(
            Icons.circle_outlined,
            'Current Status',
            task.status.tr(context),
          ),

          Divider(height: 24.h, color: const Color(0xFFE2E8F0)),
          Row(
            children: [
              _gradientChip(
                Icons.timer_outlined,
                AppColors.inProgress,
                size: 30,
              ),
              SizedBox(width: 8.w),
              Text(
                'Time Tracking'.tr(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatStopwatch(_activeTime),
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Estimated: ${task.estimatedTime} h'.tr(context),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!task.timerRunning) ...[
                IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    color: AppColors.success,
                    size: 26,
                  ),
                  onPressed: () => _onStartStopwatch(task),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.orange, size: 26),
                  onPressed: () => _onPauseStopwatch(task),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.stop, color: AppColors.danger, size: 26),
                onPressed: () => _onStopStopwatch(task),
              ),
            ],
          ),

          Divider(height: 24.h, color: const Color(0xFFE2E8F0)),
          Row(
            children: [
              Icon(Icons.upload_file_rounded, size: 16, color: Colors.indigo),
              SizedBox(width: 6.w),
              Text(
                'Submission'.tr(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (hasSubmission) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (task.githubLink != null && task.githubLink!.isNotEmpty)
                  _linkChip(
                    Icons.code_rounded,
                    'GitHub Repo'.tr(context),
                    task.githubLink!,
                  ),
                if (task.prLink != null && task.prLink!.isNotEmpty)
                  _linkChip(
                    Icons.alt_route_rounded,
                    'Pull Request'.tr(context),
                    task.prLink!,
                  ),
              ],
            ),
            if (task.submissionReport != null &&
                task.submissionReport!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  task.submissionReport!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            SizedBox(height: 10.h),
          ],
          if (!isSubmitted) ...[
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: _actionButton(
                label: 'Submit Deliverables'.tr(context),
                icon: Icons.send_rounded,
                color: AppColors.primary,
                filled: true,
                onTap: () => _showSubmitDialog(task),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'Deliverables submitted and awaiting review.'.tr(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSubmitDialog(MockTask task) {
    final githubCon = TextEditingController(text: task.githubLink ?? '');
    final prCon = TextEditingController(text: task.prLink ?? '');
    final notesCon = TextEditingController(text: task.notes ?? '');
    final reportCon = TextEditingController(text: task.submissionReport ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _gradientChip(
                        Icons.upload_file_rounded,
                        AppColors.primary,
                        size: 52,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Deliverables'.tr(context),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Share your work for review.'.tr(context),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  _fieldLabel(context, 'GitHub Repo', icon: Icons.code_rounded),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: githubCon,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      'https://github.com/...',
                      Icons.code_rounded,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _fieldLabel(
                    context,
                    'Pull Request',
                    icon: Icons.alt_route_rounded,
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: prCon,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      'https://github.com/.../pull/...',
                      Icons.alt_route_rounded,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _fieldLabel(context, 'Notes', icon: Icons.notes_rounded),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: notesCon,
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      'Add a short note...'.tr(context),
                      Icons.notes_rounded,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _fieldLabel(
                    context,
                    'Submission Report',
                    icon: Icons.description_outlined,
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: reportCon,
                    maxLines: 3,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      'Describe what was done...'.tr(context),
                      Icons.description_outlined,
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
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr(context),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                _darker(AppColors.primary),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
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
                              borderRadius: BorderRadius.circular(14.r),
                              highlightColor: Colors.transparent,
                              splashColor: AppColors.primary.withValues(
                                alpha: 0.45,
                              ),
                              onTap: () {
                                MockDatabase.instance.submitTask(
                                  taskId: task.id,
                                  githubLink: githubCon.text.trim(),
                                  prLink: prCon.text.trim(),
                                  notes: notesCon.text.trim(),
                                  report: reportCon.text.trim(),
                                );
                                setState(() {});
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Deliverables submitted successfully',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  'Submit'.tr(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    if (filled) {
      return SizedBox(
        height: 46.h,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            highlightColor: Colors.transparent,
            splashColor: color.withValues(alpha: 0.45),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, _darker(color)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    SizedBox(width: 8.w),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        overlayColor: color.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _linkChip(IconData icon, String label, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.r),
        highlightColor: Colors.transparent,
        splashColor: AppColors.primary.withValues(alpha: 0.35),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ATTACHMENTS CARD (OVERVIEW) ──────────────────────────────────────────
  Widget _buildAttachmentsCard(MockTask task) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(
                Icons.attach_file_rounded,
                AppColors.inProgress,
                size: 34,
              ),
              SizedBox(width: 10.w),
              Text(
                'Attachments'.tr(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (task.attachments.isEmpty)
            Text(
              'No attachments uploaded.'.tr(context),
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: task.attachments.map((a) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.file_present_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        a,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ─── DISCUSSION TAB ───────────────────────────────────────────────────────
  Widget _buildDiscussionTab(
    MockTask task,
    String currentUserId,
    String currentUserName,
  ) {
    final db = MockDatabase.instance;
    final isParticipant =
        currentUserId == task.assignedById ||
        currentUserId == task.currentOwnerId;

    if (!isParticipant) {
      return Center(
        child: Text(
          'Discussion is restricted to task participants only.'.tr(context),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: task.comments.length,
            itemBuilder: (context, idx) {
              final comment = task.comments[idx];
              final commentUser = db.users.firstWhere(
                (u) => u.id == comment.userId,
                orElse: () => MockUser(
                  id: '',
                  email: '',
                  fullName: comment.userName,
                  role: 'Participant',
                  department: '',
                ),
              );
              final displayName = commentUser.fullName.isNotEmpty
                  ? commentUser.fullName
                  : comment.userName;
              final initials = displayName
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .take(2)
                  .map((part) => part[0].toUpperCase())
                  .join();

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: _modernCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          comment.userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          commentUser.role.tr(context),
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  comment.date,
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (comment.replyToName != null) ...[
                              Container(
                                margin: EdgeInsets.only(top: 6.h, bottom: 4.h),
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: 3.w,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${'Replying to'.tr(context)} ${comment.replyToName}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Text(
                              comment.message,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (comment.attachments.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Wrap(
                                spacing: 6.w,
                                children: comment.attachments
                                    .map(
                                      (att) => Chip(
                                        avatar: const Icon(
                                          Icons.attach_file,
                                          size: 12,
                                        ),
                                        label: Text(
                                          att,
                                          style: TextStyle(fontSize: 9.sp),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            Align(
                              alignment: Alignment.bottomRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => _replyingTo = comment),
                                icon: const Icon(Icons.reply, size: 12),
                                label: Text(
                                  'Reply'.tr(context),
                                  style: TextStyle(fontSize: 9.5.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        if (_replyingTo != null) ...[
          Container(
            color: Colors.orange.shade50,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Replying to'.tr(context)} ${_replyingTo!.userName}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, size: 14),
                  onPressed: () => setState(() => _replyingTo = null),
                ),
              ],
            ),
          ),
        ],

        Container(
          padding: EdgeInsets.all(10.w),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write message...'.tr(context),
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    fillColor: const Color(0xFFF1F5F9),
                    filled: true,
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
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, _darker(AppColors.primary)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      setState(() {
                        db.addTaskComment(
                          task.id,
                          MockTaskComment(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            userId: currentUserId,
                            userName: currentUserName,
                            message: _commentController.text.trim(),
                            date: DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(DateTime.now()),
                            replyToId: _replyingTo?.id,
                            replyToName: _replyingTo?.userName,
                          ),
                        );
                        _commentController.clear();
                        _replyingTo = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── ACTIVITY TIMELINE TAB ────────────────────────────────────────────────
  Widget _buildTimelineTab(MockTask task) {
    if (task.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gradientChip(
              Icons.timeline_rounded,
              AppColors.textSecondary,
              size: 52,
            ),
            SizedBox(height: 12.h),
            Text(
              'No activities recorded.'.tr(context),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: task.activities.length,
      itemBuilder: (context, idx) {
        final act = task.activities[idx];
        String transitionText = '';
        if (idx > 0) {
          final prevDate = DateTime.tryParse(task.activities[idx - 1].date);
          final currDate = DateTime.tryParse(act.date);
          if (prevDate != null && currDate != null) {
            final difference = currDate.difference(prevDate);
            transitionText =
                '${'Duration from previous step:'.tr(context)} ${difference.inMinutes} minutes';
          }
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: _modernCardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradientChip(Icons.bolt_rounded, AppColors.primary, size: 34),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act.action,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${act.user} | ${act.date}',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                    if (transitionText.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        transitionText,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── ATTACHMENTS TAB ──────────────────────────────────────────────────────
  Widget _buildAttachmentsTab(MockTask task) {
    if (task.attachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gradientChip(
              Icons.attach_file_rounded,
              AppColors.textSecondary,
              size: 52,
            ),
            SizedBox(height: 12.h),
            Text(
              'No attachments uploaded.'.tr(context),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: task.attachments.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final attachment = task.attachments[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: _modernCardDecoration(),
          child: Row(
            children: [
              _gradientChip(
                Icons.file_present_rounded,
                AppColors.primary,
                size: 36,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  attachment,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── DELIVERABLES TAB (UPLOAD FILES + NOTES) ─────────────────────────────
  Future<void> _pickDeliverableFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null && mounted) {
      setState(() {
        _pickedFiles.addAll(result.files);
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _sendDeliverables(
    MockTask task,
    String currentUserId,
    String currentUserName,
  ) {
    final note = _deliverableNoteController.text.trim();
    final fileNames = _pickedFiles.map((f) => f.name).toList();

    if (fileNames.isEmpty && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please attach a file or write a note first'.tr(context),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (fileNames.isNotEmpty) {
        MockDatabase.instance.addTaskAttachments(task.id, fileNames);
      }
      if (note.isNotEmpty) {
        MockDatabase.instance.addTaskComment(
          task.id,
          MockTaskComment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: currentUserId,
            userName: currentUserName,
            message: note,
            date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
            attachments: fileNames,
          ),
        );
      }
      task.notes = note.isNotEmpty ? note : task.notes;
      _pickedFiles.clear();
      _deliverableNoteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deliverables sent successfully'.tr(context)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDeliverablesTab(
    MockTask task,
    String currentUserId,
    String currentUserName,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: _modernCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _gradientChip(
                      Icons.upload_file_rounded,
                      AppColors.primary,
                      size: 34,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Files'.tr(context),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Attach any file type to help solve this task.'.tr(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickDeliverableFiles,
                    borderRadius: BorderRadius.circular(14.r),
                    highlightColor: Colors.transparent,
                    splashColor: AppColors.primary.withValues(alpha: 0.25),
                    child: Ink(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap to choose files'.tr(context),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Any file type is supported (images, PDFs, zip, code...)'
                                .tr(context),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_pickedFiles.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(
                    'Selected Files'.tr(context),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ..._pickedFiles.asMap().entries.map((entry) {
                    final file = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _formatFileSize(file.size),
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(
                                () => _pickedFiles.removeAt(entry.key),
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: _modernCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _gradientChip(Icons.notes_rounded, Colors.indigo, size: 34),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send Notes'.tr(context),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Add a note or message to help solve this task.'.tr(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: _deliverableNoteController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Write a note, explain your solution, or describe what you need...'
                            .tr(context),
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    fillColor: const Color(0xFFF1F5F9),
                    filled: true,
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(14.w),
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
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: _actionButton(
                    label: 'Send Deliverables'.tr(context),
                    icon: Icons.send_rounded,
                    color: AppColors.primary,
                    filled: true,
                    onTap: () =>
                        _sendDeliverables(task, currentUserId, currentUserName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HISTORY TAB ──────────────────────────────────────────────────────────
  Widget _buildHistoryTab(MockTask task) {
    if (task.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gradientChip(
              Icons.history_rounded,
              AppColors.textSecondary,
              size: 52,
            ),
            SizedBox(height: 12.h),
            Text(
              'No history available for this task.'.tr(context),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: task.history.length,
      itemBuilder: (context, idx) {
        final hist = task.history[idx];
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: _modernCardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradientChip(
                Icons.history_rounded,
                AppColors.inProgress,
                size: 34,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'Field:'.tr(context)} ${hist.field}',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${hist.oldValue} → ${hist.newValue}',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${hist.updatedBy} · ${hist.date}',
                      style: TextStyle(fontSize: 9.5.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── COLOR HELPERS ────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    if (status == 'Completed' || status == 'Approved') return AppColors.success;
    if (status == 'Overdue' || status == 'Rejected') return AppColors.danger;
    if (status == 'In Progress' ||
        status == 'Submitted' ||
        status == 'Under Review' ||
        status == 'Needs Changes')
      return Colors.orange;
    return AppColors.primary;
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return AppColors.danger;
      case 'LOW':
        return AppColors.success;
      default:
        return Colors.orange;
    }
  }

  Widget _fieldLabel(
    BuildContext context,
    String label, {
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(
          label.tr(context),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: EdgeInsets.all(14.w),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // ─── MODERN UI HELPERS ────────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
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

  Widget _gradientButton(
    BuildContext context,
    String text,
    VoidCallback onTap, {
    Color color = AppColors.primary,
  }) {
    return Container(
      width: double.infinity,
      height: 50.h,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          highlightColor: Colors.transparent,
          splashColor: color.withValues(alpha: 0.45),
          child: Center(
            child: Text(
              text.tr(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
