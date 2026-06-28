import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';
import 'package:intl/intl.dart';
import '../../reports/pages/reports_page.dart';

enum KanbanStatus { pending, todo, inProgress, complete }

class KanbanTask {
  final String id;
  final String title;
  final String description;
  final String priority; // 'HIGH' | 'MEDIUM' | 'LOW'
  KanbanStatus status;
  final String? department;
  final String author;
  final String authorInitials;
  final String? dueDate;
  final int attachmentsCount;
  final int commentsCount;
  final bool isOverdue;
  final String dayOfWeek;
  final int startHour;
  final int durationHours;

  KanbanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.department,
    required this.author,
    required this.authorInitials,
    this.dueDate,
    this.attachmentsCount = 0,
    this.commentsCount = 0,
    this.isOverdue = false,
    this.dayOfWeek = 'Sunday',
    this.startHour = 9,
    this.durationHours = 2,
  });

  KanbanTask copyWith({KanbanStatus? status}) {
    return KanbanTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: status ?? this.status,
      department: department,
      author: author,
      authorInitials: authorInitials,
      dueDate: dueDate,
      attachmentsCount: attachmentsCount,
      commentsCount: commentsCount,
      isOverdue: isOverdue,
      dayOfWeek: dayOfWeek,
      startHour: startHour,
      durationHours: durationHours,
    );
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _boardSearchController = TextEditingController();

  bool _filterOverdueOnly = false;
  bool _isSchedulerView = true;
  String _schedulerScope = 'Week';
  DateTimeRange? _selectedDateRange;
  String _selectedTaskView = 'Week'; // 'Day' | 'Week' | 'Month' | 'Kanban'
  DateTime _focusedDate = DateTime(
    2026,
    6,
    21,
  ); // Sunday, June 21, 2026 (matching Sunday in mock data/header)

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }

  final List<KanbanTask> _tasks = [
    KanbanTask(
      id: '1',
      title: 'Annual Budget Report',
      description:
          'Prepare and submit the annual financial report for academic year 2025-20...',
      priority: 'HIGH',
      status: KanbanStatus.pending,
      department: 'Business',
      author: 'Samira',
      authorInitials: 'SH',
      dueDate: 'Jun 15',
      attachmentsCount: 7,
      commentsCount: 12,
      isOverdue: true,
      dayOfWeek: 'Sunday',
      startHour: 9,
      durationHours: 2,
    ),
    KanbanTask(
      id: '2',
      title: 'Network Infrastructure Audit',
      description:
          'Comprehensive review of campus network infrastructure and security proto...',
      priority: 'HIGH',
      status: KanbanStatus.todo,
      department: 'IT Services',
      author: 'Hassan',
      authorInitials: 'HF',
      dueDate: 'Jun 25',
      attachmentsCount: 3,
      commentsCount: 5,
      dayOfWeek: 'Monday',
      startHour: 11,
      durationHours: 2,
    ),
    KanbanTask(
      id: '3',
      title: 'Website Redesign Proposal',
      description:
          'Create wireframes and design proposal for the new AITU public-facing...',
      priority: 'MEDIUM',
      status: KanbanStatus.todo,
      author: 'Karim',
      authorInitials: 'KT',
      dayOfWeek: 'Tuesday',
      startHour: 13,
      durationHours: 2,
    ),
    KanbanTask(
      id: '4',
      title: 'Course Management Portal',
      description:
          'Development of the new LMS course management and enrollment tracking sys...',
      priority: 'HIGH',
      status: KanbanStatus.inProgress,
      department: 'CS Dept',
      author: 'Sarah',
      authorInitials: 'SA',
      dueDate: 'Jul 15',
      attachmentsCount: 8,
      commentsCount: 15,
      dayOfWeek: 'Wednesday',
      startHour: 10,
      durationHours: 2,
    ),
    KanbanTask(
      id: '5',
      title: 'Security Vulnerability Assessment',
      description:
          'Q2 security audit and patching of critical system vulnerabilities across...',
      priority: 'HIGH',
      status: KanbanStatus.inProgress,
      department: 'IT Services',
      author: 'Karim',
      authorInitials: 'KT',
      dueDate: 'Jun 22',
      attachmentsCount: 4,
      commentsCount: 7,
      dayOfWeek: 'Thursday',
      startHour: 14,
      durationHours: 2,
    ),
    KanbanTask(
      id: '6',
      title: 'API Integration Review',
      description:
          'Review and optimize third-party API integrations across the student port...',
      priority: 'MEDIUM',
      status: KanbanStatus.complete,
      department: 'CS Dept',
      author: 'Sarah',
      authorInitials: 'SA',
      dueDate: 'Jun 18',
      attachmentsCount: 3,
      commentsCount: 9,
      dayOfWeek: 'Tuesday',
      startHour: 9,
      durationHours: 2,
    ),
    KanbanTask(
      id: '7',
      title: 'Semester Exam Scheduling',
      description:
          'Coordinate with faculty departments to finalize the final examination ti...',
      priority: 'MEDIUM',
      status: KanbanStatus.complete,
      department: 'Math Dept',
      author: 'Dina',
      authorInitials: 'DF',
      dueDate: 'Jun 5',
      attachmentsCount: 1,
      commentsCount: 6,
      dayOfWeek: 'Thursday',
      startHour: 9,
      durationHours: 2,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _boardSearchController.dispose();
    super.dispose();
  }

  void _moveTask(String taskId, KanbanStatus targetStatus) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(status: targetStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      endDrawer: const NotificationDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header (Fixed at top)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.w : 16.w,
                vertical: 16.h,
              ),
              child: _buildHeader(context),
            ),

            // Sub-Header (Fixed below header)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.w : 16.w,
                vertical: 8.h,
              ),
              child: _buildSubHeader(context),
            ),

            // Body Area (Weekly Timetable Grid or Kanban Board)
            Expanded(
              child: _isSchedulerView
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.w : 16.w,
                        vertical: 16.h,
                      ),
                      child: _schedulerScope == 'Day'
                          ? _buildDailyGrid()
                          : (_schedulerScope == 'Week'
                                ? _buildTimetableGrid()
                                : _buildMonthlyGrid()),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.w : 16.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKanbanColumn(
                            context,
                            KanbanStatus.pending,
                            'Pending',
                            const Color(0xFF757575),
                            const Color(0xFFF5F5F5),
                          ),
                          SizedBox(width: 20.w),
                          _buildKanbanColumn(
                            context,
                            KanbanStatus.todo,
                            'To Do',
                            const Color(0xFFF2C94C),
                            const Color(0xFFFFF9E6),
                          ),
                          SizedBox(width: 20.w),
                          _buildKanbanColumn(
                            context,
                            KanbanStatus.inProgress,
                            'In Progress',
                            const Color(0xFF2F80ED),
                            const Color(0xFFEAF2FF),
                          ),
                          SizedBox(width: 20.w),
                          _buildKanbanColumn(
                            context,
                            KanbanStatus.complete,
                            'Complete',
                            const Color(0xFF27AE60),
                            const Color(0xFFE8F8EE),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tasks & Tickets Schedule',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isDesktop ? 22.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Weekly overview of academic tasks and schedules',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isDesktop ? 13.sp : 11.sp,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => _showAddTaskDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 18.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                'Add Task',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? tempStart = _selectedDateRange?.start;
    DateTime? tempEnd = _selectedDateRange?.end;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: 320.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'June 2026',
                    style: TextStyle(
                      color: const Color(0xFF0F4C81),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekdays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      DateTime cellDate;
                      if (index == 0) {
                        cellDate = DateTime(2026, 5, 31);
                      } else if (index >= 1 && index <= 30) {
                        cellDate = DateTime(2026, 6, index);
                      } else {
                        cellDate = DateTime(2026, 7, index - 30);
                      }

                      bool isSelectedStart =
                          tempStart != null &&
                          cellDate.year == tempStart!.year &&
                          cellDate.month == tempStart!.month &&
                          cellDate.day == tempStart!.day;

                      bool isSelectedEnd =
                          tempEnd != null &&
                          cellDate.year == tempEnd!.year &&
                          cellDate.month == tempEnd!.month &&
                          cellDate.day == tempEnd!.day;

                      bool isInRange =
                          tempStart != null &&
                          tempEnd != null &&
                          cellDate.isAfter(tempStart!) &&
                          cellDate.isBefore(tempEnd!);

                      bool isSelectable = cellDate.month == 6;

                      Color cellBgColor = Colors.transparent;
                      Color textColor = isSelectable
                          ? const Color(0xFF334155)
                          : Colors.grey[300]!;

                      if (isSelectedStart || isSelectedEnd) {
                        cellBgColor = const Color(0xFF0F4C81);
                        textColor = Colors.white;
                      } else if (isInRange) {
                        cellBgColor = const Color(0xFFEFF6FF);
                        textColor = const Color(0xFF1E3A8A);
                      }

                      return GestureDetector(
                        onTap: !isSelectable
                            ? null
                            : () {
                                setDialogState(() {
                                  if (tempStart == null ||
                                      (tempStart != null && tempEnd != null)) {
                                    tempStart = cellDate;
                                    tempEnd = null;
                                  } else if (cellDate.isBefore(tempStart!)) {
                                    tempStart = cellDate;
                                  } else {
                                    tempEnd = cellDate;
                                  }
                                });
                              },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cellBgColor,
                            borderRadius: (isSelectedStart || isSelectedEnd)
                                ? BorderRadius.circular(20.r)
                                : (isInRange ? BorderRadius.zero : null),
                          ),
                          child: Text(
                            '${cellDate.day}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: (isSelectedStart || isSelectedEnd)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  if (tempStart != null)
                    Text(
                      tempEnd == null
                          ? 'Selected Start: ${DateFormat('yyyy-MM-dd').format(tempStart!)}'
                          : 'Range: ${DateFormat('yyyy-MM-dd').format(tempStart!)} to ${DateFormat('yyyy-MM-dd').format(tempEnd!)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Clear Filter',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tempStart != null && tempEnd != null) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: tempStart!,
                        end: tempEnd!,
                      );
                    });
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    Widget searchBar = Container(
      width: isDesktop ? 260.w : double.infinity,
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _boardSearchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search tasks or teams...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(
            Icons.search,
            size: 18.sp,
            color: const Color(0xFF0F4C81),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        style: TextStyle(fontSize: 13.sp),
      ),
    );

    Widget viewSelector = Row(
      mainAxisSize: MainAxisSize.min,
      children: ['Day', 'Week', 'Month', 'Kanban'].map((view) {
        final isSelected = _selectedTaskView == view;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTaskView = view;
                if (view == 'Kanban') {
                  _isSchedulerView = false;
                } else {
                  _isSchedulerView = true;
                  _schedulerScope = view;
                }
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F4C81) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F4C81)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Text(
                view,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    Widget actionsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date Filter Button
        OutlinedButton(
          onPressed: () => _selectDateRange(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[300]!, width: 1.2),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            backgroundColor: Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16.sp,
                color: const Color(0xFF0A448C),
              ),
              SizedBox(width: 6.w),
              Text(
                _selectedDateRange == null
                    ? 'Filter by Date'
                    : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // Filter Button
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[300]!, width: 1.2),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            backgroundColor: Colors.white,
          ),
          child: Row(),
        ),
        SizedBox(width: 12.w),
        // Overdue Alert Button
        InkWell(
          onTap: () {
            setState(() {
              _filterOverdueOnly = !_filterOverdueOnly;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _filterOverdueOnly
                  ? const Color(0xFFFFECEB)
                  : Colors.white,
              border: Border.all(
                color: _filterOverdueOnly
                    ? const Color(0xFFEB5757)
                    : Colors.grey[300]!,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16.sp,
                  color: const Color(0xFFEB5757),
                ),
                SizedBox(width: 6.w),
                Text(
                  '1 overdue',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEB5757),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              searchBar,
              SizedBox(width: 16.w),
              viewSelector,
            ],
          ),
          actionsRow,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: searchBar),
              SizedBox(width: 12.w),
              viewSelector,
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: actionsRow,
          ),
        ],
      );
    }
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    KanbanStatus status,
    String columnName,
    Color accentColor,
    Color badgeBgColor,
  ) {
    // Filter tasks based on column status, search query and overdue filter
    final searchQuery = _boardSearchController.text.toLowerCase();
    final columnTasks = _tasks.where((t) {
      if (t.status != status) return false;
      if (_filterOverdueOnly && !t.isOverdue) return false;
      if (searchQuery.isNotEmpty) {
        final matchesTitle = t.title.toLowerCase().contains(searchQuery);
        final matchesDept =
            t.department?.toLowerCase().contains(searchQuery) ?? false;
        return matchesTitle || matchesDept;
      }
      return true;
    }).toList();

    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header Label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  columnName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    columnTasks.length.toString(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards list
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12.w),
              children: [
                // Render "No tasks here yet" dotted box if status is pending and list has elements but we want it shown,
                // or if column is actually empty.
                if (status == KanbanStatus.pending &&
                    columnTasks.any((t) => t.isOverdue) &&
                    !_filterOverdueOnly) ...[
                  _buildNoTasksPlaceholder(),
                  SizedBox(height: 12.h),
                ],
                if (columnTasks.isEmpty)
                  _buildNoTasksPlaceholder()
                else
                  ...columnTasks.map(
                    (task) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildTaskCard(task),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTasksPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
          style:
              BorderStyle.none, // We can draw dashed border or just clean solid
        ),
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 28.sp, color: Colors.grey[400]),
          SizedBox(height: 8.h),
          Text(
            'No tasks here yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(KanbanTask task) {
    Color priorityColor = const Color(0xFFF2C94C); // MEDIUM
    if (task.priority == 'HIGH') {
      priorityColor = const Color(0xFFEB5757);
    } else if (task.priority == 'LOW') {
      priorityColor = const Color(0xFF27AE60);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: priorityColor, width: 4.w),
            ),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority & Overdue Flags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.isOverdue)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            color: const Color(0xFFEB5757),
                            size: 10.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: const Color(0xFFEB5757),
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),

              // Title & Description
              Text(
                task.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11.sp,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),

              // Department & Owner Initials
              Row(
                children: [
                  if (task.department != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        task.department!,
                        style: TextStyle(
                          color: const Color(0xFF2F80ED),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: const Color(0xFFF2C94C),
                    child: Text(
                      task.authorInitials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    task.author,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 10.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      task.dueDate!,
                      style: TextStyle(
                        color: task.isOverdue
                            ? const Color(0xFFEB5757)
                            : Colors.grey[400],
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),

              Divider(color: Colors.grey[100], thickness: 1),
              SizedBox(height: 8.h),

              // Attachment & Comment count, and transitions
              Row(
                children: [
                  Icon(Icons.attachment, size: 12.sp, color: Colors.grey[400]),
                  SizedBox(width: 4.w),
                  Text(
                    task.attachmentsCount.toString(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 12.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    task.commentsCount.toString(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                  ),
                  const Spacer(),

                  // Transition Status actions
                  ..._buildTransitionButtons(task),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTransitionButtons(KanbanTask task) {
    List<Widget> buttons = [];

    if (task.status == KanbanStatus.pending) {
      buttons.add(
        _buildTransitionPill(
          '> To Do',
          const Color(0xFFF2C94C),
          () => _moveTask(task.id, KanbanStatus.todo),
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        _buildTransitionPill(
          '> In',
          const Color(0xFF2F80ED),
          () => _moveTask(task.id, KanbanStatus.inProgress),
        ),
      );
    } else if (task.status == KanbanStatus.todo) {
      buttons.add(
        _buildTransitionPill(
          '> Pending',
          const Color(0xFF757575),
          () => _moveTask(task.id, KanbanStatus.pending),
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        _buildTransitionPill(
          '> In',
          const Color(0xFF2F80ED),
          () => _moveTask(task.id, KanbanStatus.inProgress),
        ),
      );
    } else if (task.status == KanbanStatus.inProgress) {
      buttons.add(
        _buildTransitionPill(
          '> Pending',
          const Color(0xFF757575),
          () => _moveTask(task.id, KanbanStatus.pending),
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        _buildTransitionPill(
          '> To',
          const Color(0xFFF2C94C),
          () => _moveTask(task.id, KanbanStatus.todo),
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        _buildTransitionPill(
          '> Done',
          const Color(0xFF27AE60),
          () => _moveTask(task.id, KanbanStatus.complete),
        ),
      );
    } else if (task.status == KanbanStatus.complete) {
      buttons.add(
        _buildTransitionPill(
          '> Pending',
          const Color(0xFF757575),
          () => _moveTask(task.id, KanbanStatus.pending),
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        _buildTransitionPill(
          '> To',
          const Color(0xFFF2C94C),
          () => _moveTask(task.id, KanbanStatus.todo),
        ),
      );
    }

    return buttons;
  }

  Widget _buildTransitionPill(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final deptController = TextEditingController();
    String selectedPriority = 'HIGH';
    KanbanStatus selectedStatus = KanbanStatus.todo;
    String selectedDay = 'Sunday';
    int selectedHour = 9;
    int selectedDuration = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Add New Task',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 500.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFieldLabel('Task Title'),
                  TextField(
                    controller: titleController,
                    decoration: _buildInputDecoration('Enter task title...'),
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Description'),
                  TextField(
                    controller: descriptionController,
                    decoration: _buildInputDecoration(
                      'Enter task description...',
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Department'),
                  TextField(
                    controller: deptController,
                    decoration: _buildInputDecoration('e.g. CS Dept, Business'),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Day of Week'),
                            DropdownButtonFormField<String>(
                              initialValue: selectedDay,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Sunday',
                                  child: Text('Sunday'),
                                ),
                                DropdownMenuItem(
                                  value: 'Monday',
                                  child: Text('Monday'),
                                ),
                                DropdownMenuItem(
                                  value: 'Tuesday',
                                  child: Text('Tuesday'),
                                ),
                                DropdownMenuItem(
                                  value: 'Wednesday',
                                  child: Text('Wednesday'),
                                ),
                                DropdownMenuItem(
                                  value: 'Thursday',
                                  child: Text('Thursday'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedDay = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Start Hour'),
                            DropdownButtonFormField<int>(
                              initialValue: selectedHour,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(
                                  value: 8,
                                  child: Text('8:00 AM'),
                                ),
                                DropdownMenuItem(
                                  value: 9,
                                  child: Text('9:00 AM'),
                                ),
                                DropdownMenuItem(
                                  value: 10,
                                  child: Text('10:00 AM'),
                                ),
                                DropdownMenuItem(
                                  value: 11,
                                  child: Text('11:00 AM'),
                                ),
                                DropdownMenuItem(
                                  value: 12,
                                  child: Text('12:00 PM'),
                                ),
                                DropdownMenuItem(
                                  value: 13,
                                  child: Text('1:00 PM'),
                                ),
                                DropdownMenuItem(
                                  value: 14,
                                  child: Text('2:00 PM'),
                                ),
                                DropdownMenuItem(
                                  value: 15,
                                  child: Text('3:00 PM'),
                                ),
                                DropdownMenuItem(
                                  value: 16,
                                  child: Text('4:00 PM'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedHour = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Duration (Hours)'),
                            DropdownButtonFormField<int>(
                              initialValue: selectedDuration,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('1 Hour'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('2 Hours'),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text('3 Hours'),
                                ),
                                DropdownMenuItem(
                                  value: 4,
                                  child: Text('4 Hours'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedDuration = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Priority'),
                            DropdownButtonFormField<String>(
                              initialValue: selectedPriority,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(
                                  value: 'HIGH',
                                  child: Text('High'),
                                ),
                                DropdownMenuItem(
                                  value: 'MEDIUM',
                                  child: Text('Medium'),
                                ),
                                DropdownMenuItem(
                                  value: 'LOW',
                                  child: Text('Low'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedPriority = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Phase'),
                  DropdownButtonFormField<KanbanStatus>(
                    initialValue: selectedStatus,
                    decoration: _buildInputDecoration(''),
                    items: const [
                      DropdownMenuItem(
                        value: KanbanStatus.pending,
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: KanbanStatus.todo,
                        child: Text('To Do'),
                      ),
                      DropdownMenuItem(
                        value: KanbanStatus.inProgress,
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: KanbanStatus.complete,
                        child: Text('Complete'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedStatus = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            CustomButton(
              text: 'Save Task',
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _tasks.add(
                      KanbanTask(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        priority: selectedPriority,
                        status: selectedStatus,
                        department: deptController.text.isNotEmpty
                            ? deptController.text
                            : null,
                        author: 'Dr. Ahmed',
                        authorInitials: 'AH',
                        attachmentsCount: 0,
                        commentsCount: 0,
                        dayOfWeek: selectedDay,
                        startHour: selectedHour,
                        durationHours: selectedDuration,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'User Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: AppColors.primary,
              child: Text(
                'AH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Dr. Ahmed',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'ahmed.admin@aitu.edu.eg',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            _buildProfileItem(
              icon: Icons.person_outline,
              label: 'Role',
              value: 'Admin',
            ),
            SizedBox(height: 12.h),
            _buildProfileItem(
              icon: Icons.business_outlined,
              label: 'Department',
              value: 'Administration',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
            ),
          ),
          CustomButton(
            text: 'Logout',
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getWeekRangeString(DateTime date) {
    int daysFromSunday = date.weekday % 7;
    DateTime sunday = date.subtract(Duration(days: daysFromSunday));
    DateTime thursday = sunday.add(const Duration(days: 4));
    return '${DateFormat('MMM d').format(sunday)} - ${DateFormat('MMM d, yyyy').format(thursday)}';
  }

  void _navigateCalendar(int direction) {
    setState(() {
      if (_schedulerScope == 'Day') {
        _focusedDate = _focusedDate.add(Duration(days: direction));
      } else if (_schedulerScope == 'Week') {
        _focusedDate = _focusedDate.add(Duration(days: direction * 7));
      } else if (_schedulerScope == 'Month') {
        int newYear = _focusedDate.year;
        int newMonth = _focusedDate.month + direction;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        } else if (newMonth < 1) {
          newMonth = 12;
          newYear--;
        }
        _focusedDate = DateTime(newYear, newMonth, 1);
      }
    });
  }

  Widget _buildTimetableHeader() {
    String headerText = '';
    if (_schedulerScope == 'Day') {
      headerText = DateFormat('EEEE, MMMM d, yyyy').format(_focusedDate);
    } else if (_schedulerScope == 'Week') {
      headerText = _getWeekRangeString(_focusedDate);
    } else if (_schedulerScope == 'Month') {
      headerText = DateFormat('MMMM yyyy').format(_focusedDate);
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            headerText,
            style: TextStyle(
              color: const Color(0xFF0F4C81),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _navigateCalendar(-1),
                color: Colors.grey[600],
                iconSize: 22.sp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 16.w),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateCalendar(1),
                color: Colors.grey[600],
                iconSize: 22.sp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGrid() {
    final String currentDayName = _getWeekdayName(_focusedDate.weekday);
    final List<int> hours = [8, 9, 10, 11, 12, 13, 14, 15, 16];

    final bool isWeekend =
        (_focusedDate.weekday == 5) || (_focusedDate.weekday == 6);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            _buildTimetableHeader(),
            const Divider(height: 1, thickness: 1.2),
            Expanded(
              child: isWeekend
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hotel_outlined,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Weekend - No scheduled tasks',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 90.w,
                          child: Column(
                            children: hours
                                .map(
                                  (hour) => Container(
                                    height: 90.h,
                                    alignment: Alignment.topCenter,
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      _formatHour(hour),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 90.h * hours.length,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  children: hours
                                      .map(
                                        (hour) => Container(
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade100,
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                ..._buildTasksForSingleDay(
                                  currentDayName,
                                  hours,
                                  90.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTasksForSingleDay(
    String day,
    List<int> hours,
    double cellHeight,
  ) {
    final dayTasks = _tasks.where((t) {
      final matchesSearch =
          _boardSearchController.text.isEmpty ||
          t.title.toLowerCase().contains(
            _boardSearchController.text.toLowerCase(),
          );
      final matchesOverdue = !_filterOverdueOnly || t.isOverdue;
      return t.dayOfWeek.toLowerCase() == day.toLowerCase() &&
          matchesSearch &&
          matchesOverdue;
    }).toList();

    return dayTasks.map((task) {
      final int startHourIndex = hours.indexOf(task.startHour);
      if (startHourIndex == -1) return const SizedBox.shrink();

      final double top = startHourIndex * cellHeight;
      final double height = task.durationHours * cellHeight;

      Color deptBgColor = const Color(0xFFEFF6FF);
      Color deptTextColor = const Color(0xFF1E3A8A);
      Color deptBorderColor = const Color(0xFFBFDBFE);

      if (task.department == 'IT Services') {
        deptBgColor = const Color(0xFFF3E8FF);
        deptTextColor = const Color(0xFF5B21B6);
        deptBorderColor = const Color(0xFFE9D5FF);
      } else if (task.department == 'Business') {
        deptBgColor = const Color(0xFFDCFCE7);
        deptTextColor = const Color(0xFF065F46);
        deptBorderColor = const Color(0xFFBBF7D0);
      } else if (task.department == 'Math Dept') {
        deptBgColor = const Color(0xFFFEF3C7);
        deptTextColor = const Color(0xFF92400E);
        deptBorderColor = const Color(0xFFFDE68A);
      }

      return Positioned(
        top: top + 4.h,
        left: 8.w,
        right: 8.w,
        height: height - 8.h,
        child: Container(
          decoration: BoxDecoration(
            color: deptBgColor,
            border: Border.all(color: deptBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: deptTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      task.priority,
                      style: TextStyle(
                        color: task.priority == 'HIGH'
                            ? Colors.red[700]
                            : Colors.amber[800],
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                task.description,
                style: TextStyle(
                  color: deptTextColor.withOpacity(0.7),
                  fontSize: 11.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                '${_formatHour(task.startHour)} - ${_formatHour(task.startHour + task.durationHours)}',
                style: TextStyle(
                  color: deptTextColor.withOpacity(0.8),
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.r,
                        backgroundColor: deptTextColor.withOpacity(0.2),
                        child: Text(
                          task.authorInitials,
                          style: TextStyle(
                            color: deptTextColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        task.author,
                        style: TextStyle(
                          color: deptTextColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showAddReportDialog(context, task),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F4C81),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_comment_outlined,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTimetableGrid() {
    final List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
    ];
    final List<int> hours = [8, 9, 10, 11, 12, 13, 14, 15, 16];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            _buildTimetableHeader(),
            const Divider(height: 1, thickness: 1.2),
            Container(
              color: const Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    child: Center(
                      child: Text(
                        'Time',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  ...days.map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: const Color(0xFF0F4C81),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1.2),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Column(
                        children: hours
                            .map(
                              (hour) => Container(
                                height: 80.h,
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  _formatHour(hour),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    ...days.map((day) {
                      return Expanded(
                        child: Container(
                          height: 80.h * hours.length,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey.shade100,
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: hours
                                    .map(
                                      (hour) => Container(
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade100,
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              ..._buildTasksForDayAndHour(day, hours),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 12) return '12:00 PM';
    if (hour > 12) return '${hour - 12}:00 PM';
    return '$hour:00 AM';
  }

  List<Widget> _buildTasksForDayAndHour(String day, List<int> hours) {
    // Filter tasks for this day
    final dayTasks = _tasks.where((t) {
      final matchesSearch =
          _boardSearchController.text.isEmpty ||
          t.title.toLowerCase().contains(
            _boardSearchController.text.toLowerCase(),
          );
      final matchesOverdue = !_filterOverdueOnly || t.isOverdue;
      return t.dayOfWeek.toLowerCase() == day.toLowerCase() &&
          matchesSearch &&
          matchesOverdue;
    }).toList();

    return dayTasks.map((task) {
      final int startHourIndex = hours.indexOf(task.startHour);
      if (startHourIndex == -1) return const SizedBox.shrink();

      final double top = startHourIndex * 80.h;
      final double height = task.durationHours * 80.h;

      Color deptBgColor = const Color(0xFFEFF6FF);
      Color deptTextColor = const Color(0xFF1E3A8A);
      Color deptBorderColor = const Color(0xFFBFDBFE);

      if (task.department == 'IT Services') {
        deptBgColor = const Color(0xFFF3E8FF);
        deptTextColor = const Color(0xFF5B21B6);
        deptBorderColor = const Color(0xFFE9D5FF);
      } else if (task.department == 'Business') {
        deptBgColor = const Color(0xFFDCFCE7);
        deptTextColor = const Color(0xFF065F46);
        deptBorderColor = const Color(0xFFBBF7D0);
      } else if (task.department == 'Math Dept') {
        deptBgColor = const Color(0xFFFEF3C7);
        deptTextColor = const Color(0xFF92400E);
        deptBorderColor = const Color(0xFFFDE68A);
      }

      return Positioned(
        top: top + 4.h,
        left: 4.w,
        right: 4.w,
        height: height - 8.h,
        child: Container(
          decoration: BoxDecoration(
            color: deptBgColor,
            border: Border.all(color: deptBorderColor, width: 1.2),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: deptTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      task.priority,
                      style: TextStyle(
                        color: task.priority == 'HIGH'
                            ? Colors.red[700]
                            : Colors.amber[800],
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                '${_formatHour(task.startHour)} - ${_formatHour(task.startHour + task.durationHours)}',
                style: TextStyle(
                  color: deptTextColor.withOpacity(0.8),
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8.r,
                        backgroundColor: deptTextColor.withOpacity(0.2),
                        child: Text(
                          task.authorInitials,
                          style: TextStyle(
                            color: deptTextColor,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        task.author,
                        style: TextStyle(
                          color: deptTextColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Add Report Button
                  GestureDetector(
                    onTap: () => _showAddReportDialog(context, task),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F4C81),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_comment_outlined,
                            size: 9.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showAddReportDialog(BuildContext context, KanbanTask task) {
    final titleController = TextEditingController(
      text: '${task.title} Performance Report',
    );
    final contentController = TextEditingController();
    List<String> tempAttachments = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Submit Task Report',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          content: SizedBox(
            width: 450.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task: ${task.title}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: const Color(0xFF0F4C81),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Department: ${task.department ?? "General"}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldLabel('Report Title'),
                  TextField(
                    controller: titleController,
                    decoration: _buildInputDecoration('Enter report title...'),
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Report Description / Findings'),
                  TextField(
                    controller: contentController,
                    decoration: _buildInputDecoration('Enter findings...'),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldLabel('Attachments'),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            final mockFiles = [
                              'metrics_summary.xlsx',
                              'audit_log.txt',
                              'consolidated_report.pdf',
                              'system_spec.docx',
                            ];
                            final nextFile =
                                mockFiles[tempAttachments.length %
                                    mockFiles.length];
                            tempAttachments.add(
                              '${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}_$nextFile',
                            );
                          });
                        },
                        icon: Icon(
                          Icons.attach_file,
                          size: 14.sp,
                          color: const Color(0xFF0F4C81),
                        ),
                        label: Text(
                          'Attach File',
                          style: TextStyle(
                            color: const Color(0xFF0F4C81),
                            fontSize: 12.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tempAttachments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: tempAttachments
                          .map(
                            (file) => Chip(
                              backgroundColor: const Color(0xFFEDF2F7),
                              label: Text(
                                file,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 12.sp,
                                color: Colors.red[400],
                              ),
                              onDeleted: () {
                                setDialogState(() {
                                  tempAttachments.remove(file);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                side: BorderSide.none,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  ReportsDatabase.reports.add(
                    ReportModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      content: contentController.text,
                      taskName: task.title,
                      department: task.department ?? 'General',
                      teamName: '${task.department ?? "General"} Team',
                      submitter: 'Dr. Ahmed',
                      date: DateFormat('MMM d, yyyy').format(DateTime.now()),
                      attachments: tempAttachments,
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text(
                'Submit Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyGrid() {
    final List<String> weekdays = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];

    final int year = _focusedDate.year;
    final int month = _focusedDate.month;
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int startOffset = firstWeekday == 7 ? 0 : firstWeekday;
    final int totalDaysInMonth = DateUtils.getDaysInMonth(year, month);

    final int prevMonthYear = month == 1 ? year - 1 : year;
    final int prevMonth = month == 1 ? 12 : month - 1;
    final int totalDaysInPrevMonth = DateUtils.getDaysInMonth(
      prevMonthYear,
      prevMonth,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            _buildTimetableHeader(),
            const Divider(height: 1, thickness: 1.2),
            Container(
              color: const Color(0xFFF1F5F9),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: weekdays
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(height: 1, thickness: 1.2),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  int dayNum;
                  bool isCurrentMonth = true;

                  if (index < startOffset) {
                    dayNum = totalDaysInPrevMonth - startOffset + index + 1;
                    isCurrentMonth = false;
                  } else if (index >= startOffset &&
                      index < startOffset + totalDaysInMonth) {
                    dayNum = index - startOffset + 1;
                  } else {
                    dayNum = index - startOffset - totalDaysInMonth + 1;
                    isCurrentMonth = false;
                  }

                  final weekdayMap = [
                    'Sunday',
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                  ];
                  final String currentDayName = weekdayMap[index % 7];

                  final dayTasks = _tasks.where((t) {
                    final matchesSearch =
                        _boardSearchController.text.isEmpty ||
                        t.title.toLowerCase().contains(
                          _boardSearchController.text.toLowerCase(),
                        );
                    final matchesOverdue = !_filterOverdueOnly || t.isOverdue;
                    bool matchesDay =
                        t.dayOfWeek.toLowerCase() ==
                        currentDayName.toLowerCase();
                    bool showThisTask =
                        isCurrentMonth && (dayNum % 7 == 1 || dayNum % 10 == 3);

                    return matchesDay &&
                        showThisTask &&
                        matchesSearch &&
                        matchesOverdue;
                  }).toList();

                  final bool isWeekend = (index % 7 == 5) || (index % 7 == 6);

                  return Container(
                    decoration: BoxDecoration(
                      color: isWeekend ? const Color(0xFFF8FAFC) : Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 0.8,
                      ),
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isCurrentMonth
                                ? (isWeekend
                                      ? Colors.grey[400]
                                      : const Color(0xFF334155))
                                : Colors.grey[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Expanded(
                          child: ListView.builder(
                            itemCount: dayTasks.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, tIndex) {
                              final task = dayTasks[tIndex];
                              Color dotColor = const Color(0xFF3B82F6);
                              if (task.department == 'IT Services') {
                                dotColor = const Color(0xFF8B5CF6);
                              } else if (task.department == 'Business') {
                                dotColor = const Color(0xFF10B981);
                              } else if (task.department == 'Math Dept') {
                                dotColor = const Color(0xFFF59E0B);
                              }
                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: dotColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 4.h,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          color: dotColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textHint, size: 20.sp),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textHint, fontSize: 12.sp),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}
