import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/styles/app_spacing.dart';
import '../../../../../core/styles/app_radius.dart';
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
  double _activeTime = 0.0; // in seconds

  // Discussion controllers
  final TextEditingController _commentController = TextEditingController();
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
      setState(() {
        _activeTime += 1.0;
      });
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
        appBar: AppBar(title: Text('Task Details'.tr(context))),
        body: Center(child: Text('Task not found.'.tr(context))),
      );
    }

    final task = db.tasks[taskIdx];
    final authState = context.read<AuthCubit>().state;
    final String currentUserId = authState is AuthSuccess ? (authState.user.id as String? ?? '4') : '4';
    final String currentUserName = authState is AuthSuccess ? (authState.user.fullName as String? ?? 'Sarah Ahmed') : 'Sarah Ahmed';

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Task Header Summary Block
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
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6.r)),
                    child: Text(task.status.tr(context), style: TextStyle(color: Colors.orange.shade800, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
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

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(task),
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
  Widget _buildOverviewTab(MockTask task) {
    final db = MockDatabase.instance;
    final owner = db.users.firstWhere((u) => u.id == task.currentOwnerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
    final creator = db.users.firstWhere((u) => u.id == task.assignedById, orElse: () => MockUser(id: '', email: '', fullName: 'System', role: '', department: ''));

    // Dynamic Checklist calculations
    final int doneCount = task.checklist.where((c) => c.isDone).length;
    final int totalCount = task.checklist.length;
    final double checklistProgress = totalCount == 0 ? 0.0 : (doneCount / totalCount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Details
              Expanded(
                flex: 2,
                child: AppCard(
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
                      _buildDetailRow('Estimated Duration', '${task.estimatedHours} ' + 'Hours'.tr(context)),
                      _buildDetailRow('Reassignment Allowed', task.allowReassignment ? 'Yes'.tr(context) : 'No'.tr(context)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Time Tracker stopwatch
              Expanded(
                child: AppCard(
                  child: Column(
                    children: [
                      Text('Time Tracking'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      const Divider(),
                      Text(_formatStopwatch(_activeTime), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.primary)),
                      SizedBox(height: 12.h),
                      Text('Estimated Time: '.tr(context) + '${task.estimatedTime} ' + 'h'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!task.timerRunning) ...[
                            IconButton(icon: const Icon(Icons.play_arrow, color: AppColors.success), onPressed: () => _onStartStopwatch(task)),
                          ] else ...[
                            IconButton(icon: const Icon(Icons.pause, color: Colors.orange), onPressed: () => _onPauseStopwatch(task)),
                          ],
                          IconButton(icon: const Icon(Icons.stop, color: AppColors.danger), onPressed: () => _onStopStopwatch(task)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
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
                    Text('${(checklistProgress * 100).toInt()}% ' + 'Done'.tr(context)),
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
                          // Recalculate progress logic
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
                // Add checklist item form
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

          // Attachments
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attachments'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                const Divider(),
                if (task.attachments.isEmpty) ...[
                  Text('No attachments uploaded.'.tr(context), style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                ] else ...[
                  Wrap(
                    spacing: 8.w,
                    children: task.attachments.map((a) {
                      return Chip(
                        label: Text(a, style: TextStyle(fontSize: 10.sp)),
                        avatar: const Icon(Icons.file_present),
                      );
                    }).toList(),
                  )
                ]
              ],
            ),
          ),
        ],
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

  // --- DISCUSSION TAB (CHAT ROOM) ---
  Widget _buildDiscussionTab(MockTask task, String currentUserId, String currentUserName) {
    final db = MockDatabase.instance;
    final isParticipant = currentUserId == task.assignedById || currentUserId == task.currentOwnerId;

    if (!isParticipant) {
      return Center(child: Text('Discussion is restricted to task participants only.'.tr(context)));
    }

    return Column(
      children: [
        // Message thread
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: task.comments.length,
            itemBuilder: (context, idx) {
              final comment = task.comments[idx];
              final commentUser = db.users.firstWhere((u) => u.id == comment.userId, orElse: () => MockUser(id: '', email: '', fullName: comment.userName, role: 'Participant', department: ''));
              final displayName = commentUser.fullName.isNotEmpty ? commentUser.fullName : comment.userName;
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
                                    Text(comment.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp)),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        commentUser.role.tr(context),
                                        style: TextStyle(fontSize: 8.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
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
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border(left: BorderSide(color: AppColors.primary, width: 3.w)),
                                ),
                                child: Text(
                                  'Replying to'.tr(context) + ' ${comment.replyToName}',
                                  style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Text(comment.message, style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary)),
                            if (comment.attachments.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Wrap(
                                spacing: 6.w,
                                children: comment.attachments.map((att) => Chip(
                                  avatar: const Icon(Icons.attach_file, size: 12),
                                  label: Text(att, style: TextStyle(fontSize: 9.sp)),
                                )).toList(),
                              )
                            ],
                            Align(
                              alignment: Alignment.bottomRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _replyingTo = comment;
                                  });
                                },
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

        // Replying snippet preview
        if (_replyingTo != null) ...[
          Container(
            color: Colors.orange.shade50,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Replying to'.tr(context) + ' ${_replyingTo!.userName}', style: TextStyle(fontSize: 10.sp, fontStyle: FontStyle.italic)),
                IconButton(icon: const Icon(Icons.clear, size: 14), onPressed: () => setState(() => _replyingTo = null)),
              ],
            ),
          )
        ],

        // Input Form
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
                      db.addTaskComment(
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
            transitionText = 'Duration from previous step: '.tr(context) + '${difference.inMinutes} minutes';
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
              CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.attach_file, color: AppColors.primary)),
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
          title: Text('Field: '.tr(context) + hist.field),
          subtitle: Text('${hist.oldValue} -> ${hist.newValue} | ${hist.date}'),
          trailing: Text(hist.updatedBy, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}
