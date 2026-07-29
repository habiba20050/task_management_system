import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/styles/app_shadow.dart';
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskId;
  const TaskDetailsPage({super.key, required this.taskId});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _stopwatchTimer;
  double _activeTime = 0.0;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  MockTaskComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initStopwatch();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _tabController.dispose();
    _commentController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _initStopwatch() {
    final db = MockDatabase.instance;
    final taskIdx = db.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIdx != -1) {
      final task = db.tasks[taskIdx];
      _activeTime = task.actualTime;
      if (task.timerRunning && task.timerStartTime != null) {
        final elapsed = (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) / 1000.0;
        _activeTime = task.actualTime + elapsed;
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _activeTime += 1.0);
    });
  }

  void _onStartStopwatch(MockTask task) {
    setState(() {
      task.timerRunning = true;
      task.timerStartTime = DateTime.now().millisecondsSinceEpoch;
      MockDatabase.instance.updateTaskTimerState(task.id, true, task.timerStartTime);
      _startTimer();
    });
  }

  void _onPauseStopwatch(MockTask task) {
    _stopwatchTimer?.cancel();
    final elapsed = task.timerStartTime != null
        ? (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) / 1000.0
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
        ? (DateTime.now().millisecondsSinceEpoch - task.timerStartTime!) / 1000.0
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
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;
    final taskIdx = db.tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIdx == -1) {
      return Scaffold(
        appBar: AppBar(title: Text('Task Details'.tr(context))),
        body: Center(child: Text('Task not found.'.tr(context))),
      );
    }

    final task = db.tasks[taskIdx];
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '4';
    final currentUserName = authState is AuthSuccess ? (authState.user.fullName ?? 'Sarah Ahmed') : 'Sarah Ahmed';

    // Find TL's team
    final team = db.teams.firstWhere(
      (t) => t.leaderId == currentUserId,
      orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
    );
    final isTL = true;
    final isOwnTask = task.currentOwnerId == currentUserId;
    final isTeamTask = team.memberIds.contains(task.currentOwnerId);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 4.h),
                        Text(task.taskType.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: task.status == 'Overdue' ? AppColors.danger.withValues(alpha: 0.1) : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(task.status.tr(context), style: TextStyle(color: task.status == 'Overdue' ? AppColors.danger : Colors.orange.shade800, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Overview'.tr(context)),
                  Tab(text: 'Discussion'.tr(context)),
                  Tab(text: 'Activity Timeline'.tr(context)),
                  Tab(text: 'Attachments'.tr(context)),
                  Tab(text: 'History'.tr(context)),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(task, db, currentUserId, currentUserName, isTL, isOwnTask, isTeamTask, team),
                  _buildDiscussionTab(task, currentUserId, currentUserName),
                  _buildTimelineTab(task),
                  _buildAttachmentsTab(task),
                  _buildHistoryTab(task),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab(MockTask task, MockDatabase db, String currentUserId, String currentUserName, bool isTL, bool isOwnTask, bool isTeamTask, MockTeam team) {
    final owner = db.users.firstWhere((u) => u.id == task.currentOwnerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
    final creator = db.users.firstWhere((u) => u.id == task.assignedById, orElse: () => MockUser(id: '', email: '', fullName: 'System', role: '', department: ''));

    final int doneCount = task.checklist.where((c) => c.isDone).length;
    final int totalCount = task.checklist.length;
    final double checklistProgress = totalCount == 0 ? 0.0 : (doneCount / totalCount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTaskDetailsCard(task, owner, creator),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTimeTrackingCard(task),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTaskDetailsCard(task, owner, creator),
                    SizedBox(height: 16.h),
                    _buildTimeTrackingCard(task),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 16.h),

          // Checklist Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Task Checklist'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    Text('${(checklistProgress * 100).toInt()}% ${'Done'.tr(context)}'),
                  ],
                ),
                SizedBox(height: 6.h),
                LinearProgressIndicator(value: checklistProgress, color: checklistProgress == 1.0 ? AppColors.success : AppColors.primary),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCount,
                  itemBuilder: (context, idx) {
                    final item = task.checklist[idx];
                    return CheckboxListTile(
                      title: Text(item.title, style: TextStyle(fontSize: 12.sp, decoration: item.isDone ? TextDecoration.lineThrough : null)),
                      value: item.isDone,
                      onChanged: (bool? val) {
                        setState(() {
                          item.isDone = val ?? false;
                          final allDone = task.checklist.every((c) => c.isDone);
                          if (allDone && totalCount > 0) {
                            task.status = 'Completed';
                            MockDatabase.instance.updateTaskStatus(task.id, 'Completed', 'System');
                          }
                          MockDatabase.instance.updateTaskChecklist(task.id, task.checklist);
                        });
                      },
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Add checklist item...'.tr(context)),
                        onSubmitted: (val) {
                          if (val.isNotEmpty) {
                            setState(() {
                              task.checklist.add(MockChecklistItem(id: DateTime.now().millisecondsSinceEpoch.toString(), title: val));
                              MockDatabase.instance.updateTaskChecklist(task.id, task.checklist);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // TL Actions Section
          if (isTL && (isOwnTask || isTeamTask)) ...[
            _buildTLActionsCard(task, db, currentUserId, currentUserName, isOwnTask, team),
            SizedBox(height: 16.h),
          ],

          // Attachments
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attachments'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                const Divider(),
                if (task.attachments.isEmpty)
                  Text('No attachments uploaded.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp))
                else
                  Wrap(
                    spacing: 8.w,
                    children: task.attachments.map((a) => Chip(
                      label: Text(a, style: TextStyle(fontSize: 10.sp)),
                      avatar: const Icon(Icons.file_present),
                    )).toList(),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailsCard(MockTask task, MockUser owner, MockUser creator) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Details'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          const Divider(),
          _buildDetailRow('Assigned By', creator.fullName),
          _buildDetailRow('Current Owner', owner.fullName),
          _buildDetailRow('Department', task.taskDepartment.tr(context)),
          _buildDetailRow('Priority', task.priority.tr(context)),
          _buildDetailRow('Start Date & Time', '${task.startDate} | ${task.startTime}'),
          _buildDetailRow('Due Date & Time', '${task.deadline} | ${task.dueTime}'),
          _buildDetailRow('Estimated Duration', '${task.estimatedHours} ${'Hours'.tr(context)}'),
          _buildDetailRow('Reassignment Allowed', task.allowReassignment ? 'Yes'.tr(context) : 'No'.tr(context)),
        ],
      ),
    );
  }

  Widget _buildTimeTrackingCard(MockTask task) {
    return AppCard(
      child: Column(
        children: [
          Text('Time Tracking'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          const Divider(),
          Text(_formatStopwatch(_activeTime), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.primary)),
          SizedBox(height: 12.h),
          Text('${'Estimated Time:'.tr(context)} ${task.estimatedTime} h', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!task.timerRunning)
                IconButton(icon: const Icon(Icons.play_arrow, color: AppColors.success), onPressed: () => _onStartStopwatch(task))
              else
                IconButton(icon: const Icon(Icons.pause, color: Colors.orange), onPressed: () => _onPauseStopwatch(task)),
              IconButton(icon: const Icon(Icons.stop, color: AppColors.danger), onPressed: () => _onStopStopwatch(task)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTLActionsCard(MockTask task, MockDatabase db, String currentUserId, String currentUserName, bool isOwnTask, MockTeam team) {
    final teamMembers = db.users.where((u) => team.memberIds.contains(u.id)).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text('Team Leader Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.primary)),
            ],
          ),
          const Divider(),

          if (isOwnTask) ...[
            if (task.status != 'Submitted' && task.status != 'Approved' && task.status != 'Completed')
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Submit Task for Review'.tr(context),
                  onPressed: () {
                    setState(() {
                      MockDatabase.instance.updateTaskStatus(task.id, 'Submitted', currentUserName);
                    });
                  },
                  prefixIcon: const Icon(Icons.send, color: Colors.white, size: 16),
                ),
              ),
            if (task.status == 'Submitted' || task.status == 'Under Review')
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, size: 14.sp, color: Colors.orange),
                    SizedBox(width: 6.w),
                    Text('Task is under review'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.orange)),
                  ],
                ),
              ),
          ] else ...[
            // Team member review section
            _buildDetailRow('Current Status', task.status.tr(context)),
            SizedBox(height: 8.h),

            if (task.status == 'Submitted' || task.status == 'Under Review') ...[
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  hintText: 'Enter review feedback...'.tr(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  isDense: true,
                  contentPadding: EdgeInsets.all(10.w),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          task.status = 'Approved';
                          task.leaderFeedback = _feedbackController.text.isNotEmpty ? _feedbackController.text : 'Approved by Team Leader';
                          MockDatabase.instance.updateTaskStatus(task.id, 'Approved', currentUserName);
                          _feedbackController.clear();
                        });
                      },
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: Text('Approve'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          task.status = 'Needs Changes';
                          task.leaderFeedback = _feedbackController.text.isNotEmpty ? _feedbackController.text : 'Changes requested by Team Leader';
                          MockDatabase.instance.updateTaskStatus(task.id, 'Needs Changes', currentUserName);
                          _feedbackController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text('Needs Changes'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          task.status = 'Rejected';
                          task.leaderFeedback = _feedbackController.text.isNotEmpty ? _feedbackController.text : 'Rejected by Team Leader';
                          MockDatabase.instance.updateTaskStatus(task.id, 'Rejected', currentUserName);
                          _feedbackController.clear();
                        });
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: Text('Reject'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                ],
              ),
              if (task.leaderFeedback != null && task.leaderFeedback!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6.r)),
                  child: Row(
                    children: [
                      Icon(Icons.feedback, size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(task.leaderFeedback!, style: TextStyle(fontSize: 10.sp, color: AppColors.primary))),
                    ],
                  ),
                ),
              ],
            ],

            if (task.status != 'Submitted' && task.status != 'Under Review' && task.status != 'Approved' && task.status != 'Completed' && task.status != 'Rejected') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditTaskDialog(context, task, db, teamMembers),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text('Edit Task'.tr(context), style: TextStyle(fontSize: 11.sp)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                  if (task.allowReassignment) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAssignDialog(context, task, db, teamMembers),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text('Reassign'.tr(context), style: TextStyle(fontSize: 11.sp)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, MockTask task, MockDatabase db, List<MockUser> teamMembers) {
    final titleCon = TextEditingController(text: task.title);
    final descCon = TextEditingController(text: task.description);
    String priority = task.priority;
    String deadline = task.deadline;

    // Normalize priority to title case for dropdown items
    final priorityMap = {'HIGH': 'High', 'MEDIUM': 'Medium', 'LOW': 'Low'};
    priority = priorityMap[priority] ?? priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 480.w,
            padding: EdgeInsets.all(28.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Task'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  SizedBox(height: 16.h),
                  Text('Title'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                  SizedBox(height: 6.h),
                  TextFormField(controller: titleCon, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), isDense: true, contentPadding: EdgeInsets.all(12.w))),
                  SizedBox(height: 14.h),
                  Text('Description'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                  SizedBox(height: 6.h),
                  TextFormField(controller: descCon, maxLines: 2, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), isDense: true, contentPadding: EdgeInsets.all(12.w))),
                  SizedBox(height: 14.h),
                  Text('Priority'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                  SizedBox(height: 6.h),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)),
                    items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => priority = v!),
                    ),
                    SizedBox(height: 14.h),
                    Text('Deadline'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                    SizedBox(height: 6.h),
                    TextFormField(
                      initialValue: deadline,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), isDense: true, contentPadding: EdgeInsets.all(12.w), hintText: 'YYYY-MM-DD'),
                      onChanged: (v) => deadline = v,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: Text('Cancel'.tr(context), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (titleCon.text.isNotEmpty) {
                                final reverseMap = {'High': 'HIGH', 'Medium': 'MEDIUM', 'Low': 'LOW'};
                                final dbPriority = reverseMap[priority] ?? priority;
                                MockDatabase.instance.updateTaskDetails(
                                  task.id,
                                  title: titleCon.text,
                                  description: descCon.text,
                                  priority: dbPriority,
                                  deadline: deadline,
                                );
                                Navigator.pop(context);
                              }
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                          child: Text('Save'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAssignDialog(BuildContext context, MockTask task, MockDatabase db, List<MockUser> teamMembers) {
    String? selectedMemberId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reassign Task'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                SizedBox(height: 16.h),
                Text('Select Team Member'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String>(
                  initialValue: selectedMemberId,
                  hint: Text('Choose member...'.tr(context)),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)),
                  items: teamMembers.where((m) => m.id != task.currentOwnerId).map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedMemberId = v),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Text('Cancel'.tr(context), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedMemberId == null ? null : () {
                          if (selectedMemberId != null) {
                            setState(() {
                              task.currentOwnerId = selectedMemberId!;
                              task.assignedMemberId = selectedMemberId!;
                              task.status = 'Assigned';
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        child: Text('Assign'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // --- DISCUSSION TAB ---
  Widget _buildDiscussionTab(MockTask task, String currentUserId, String currentUserName) {
    final db = MockDatabase.instance;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: task.comments.length,
            itemBuilder: (context, idx) {
              final comment = task.comments[idx];
              final commentUser = db.users.firstWhere((u) => u.id == comment.userId, orElse: () => MockUser(id: '', email: '', fullName: comment.userName, role: 'Participant', department: ''));
              final displayName = commentUser.fullName.isNotEmpty ? commentUser.fullName : comment.userName;
              final initials = displayName.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase()).join();

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(initials, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadow.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(comment.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp), overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4.r)),
                                      child: Text(commentUser.role.tr(context), style: TextStyle(fontSize: 8.sp, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                Text(comment.date, style: TextStyle(fontSize: 8.5.sp, color: Colors.grey)),
                              ],
                            ),
                            if (comment.replyToName != null) ...[
                              Container(
                                margin: EdgeInsets.only(top: 6.h, bottom: 4.h),
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(4.r), border: Border(left: BorderSide(color: AppColors.primary, width: 3.w))),
                                child: Text('${'Replying to'.tr(context)} ${comment.replyToName}', style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Text(comment.message, style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary)),
                            if (comment.attachments.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Wrap(spacing: 6.w, children: comment.attachments.map((att) => Chip(avatar: const Icon(Icons.attach_file, size: 12), label: Text(att, style: TextStyle(fontSize: 9.sp)))).toList()),
                            ],
                            Align(
                              alignment: Alignment.bottomRight,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _replyingTo = comment),
                                icon: const Icon(Icons.reply, size: 12),
                                label: Text('Reply'.tr(context), style: TextStyle(fontSize: 9.5.sp)),
                              ),
                            )
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
                Text('${'Replying to'.tr(context)} ${_replyingTo!.userName}', style: TextStyle(fontSize: 10.sp, fontStyle: FontStyle.italic)),
                IconButton(icon: const Icon(Icons.clear, size: 14), onPressed: () => setState(() => _replyingTo = null)),
              ],
            ),
          )
        ],

        Container(
          padding: EdgeInsets.all(10.w),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(hintText: 'Write message...'.tr(context), border: const OutlineInputBorder()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    setState(() {
                      MockDatabase.instance.addTaskComment(
                        task.id,
                        MockTaskComment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: currentUserId,
                          userName: currentUserName,
                          message: _commentController.text,
                          date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                          replyToId: _replyingTo?.id,
                          replyToName: _replyingTo?.userName,
                        ),
                      );
                      _commentController.clear();
                      _replyingTo = null;
                    });
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }

  // --- ACTIVITY TIMELINE TAB ---
  Widget _buildTimelineTab(MockTask task) {
    if (task.activities.isEmpty) {
      return Center(child: Text('No activities recorded.'.tr(context)));
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
            transitionText = '${'Duration from previous step:'.tr(context)} ${difference.inMinutes} minutes';
          }
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(act.action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.primary)),
              SizedBox(height: 4.h),
              Text('${act.user} | ${act.date}', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
              if (transitionText.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(transitionText, style: TextStyle(fontSize: 9.sp, color: Colors.indigo, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        );
      },
    );
  }

  // --- ATTACHMENTS TAB ---
  Widget _buildAttachmentsTab(MockTask task) {
    if (task.attachments.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.all(16.w), child: Text('No attachments uploaded.'.tr(context))));
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: task.attachments.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final attachment = task.attachments[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.attach_file, color: AppColors.primary)),
              SizedBox(width: 10.w),
              Expanded(child: Text(attachment, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600))),
            ],
          ),
        );
      },
    );
  }

  // --- HISTORY TAB ---
  Widget _buildHistoryTab(MockTask task) {
    if (task.history.isEmpty) {
      return Center(child: Text('No history available for this task.'.tr(context)));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: task.history.length,
      itemBuilder: (context, idx) {
        final hist = task.history[idx];
        return ListTile(
          title: Text('${'Field:'.tr(context)} ${hist.field}'),
          subtitle: Text('${hist.oldValue} -> ${hist.newValue} | ${hist.date}'),
          trailing: Text(hist.updatedBy, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}
