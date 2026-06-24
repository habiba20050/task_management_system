import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';

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
  });

  KanbanTask copyWith({
    KanbanStatus? status,
  }) {
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



  final List<KanbanTask> _tasks = [
    KanbanTask(
      id: '1',
      title: 'Annual Budget Report',
      description: 'Prepare and submit the annual financial report for academic year 2025-20...',
      priority: 'HIGH',
      status: KanbanStatus.pending,
      department: 'Business',
      author: 'Samira',
      authorInitials: 'SH',
      dueDate: 'Jun 15',
      attachmentsCount: 7,
      commentsCount: 12,
      isOverdue: true,
    ),
    KanbanTask(
      id: '2',
      title: 'Network Infrastructure Audit',
      description: 'Comprehensive review of campus network infrastructure and security proto...',
      priority: 'HIGH',
      status: KanbanStatus.todo,
      department: 'IT Services',
      author: 'Hassan',
      authorInitials: 'HF',
      dueDate: 'Jun 25',
      attachmentsCount: 3,
      commentsCount: 5,
    ),
    KanbanTask(
      id: '3',
      title: 'Website Redesign Proposal',
      description: 'Create wireframes and design proposal for the new AITU public-facing...',
      priority: 'MEDIUM',
      status: KanbanStatus.todo,
      author: 'Karim',
      authorInitials: 'KT',
    ),
    KanbanTask(
      id: '4',
      title: 'Course Management Portal',
      description: 'Development of the new LMS course management and enrollment tracking sys...',
      priority: 'HIGH',
      status: KanbanStatus.inProgress,
      department: 'CS Dept',
      author: 'Sarah',
      authorInitials: 'SA',
      dueDate: 'Jul 15',
      attachmentsCount: 8,
      commentsCount: 15,
    ),
    KanbanTask(
      id: '5',
      title: 'Security Vulnerability Assessment',
      description: 'Q2 security audit and patching of critical system vulnerabilities across...',
      priority: 'HIGH',
      status: KanbanStatus.inProgress,
      department: 'IT Services',
      author: 'Karim',
      authorInitials: 'KT',
      dueDate: 'Jun 22',
      attachmentsCount: 4,
      commentsCount: 7,
    ),
    KanbanTask(
      id: '6',
      title: 'API Integration Review',
      description: 'Review and optimize third-party API integrations across the student port...',
      priority: 'MEDIUM',
      status: KanbanStatus.complete,
      department: 'CS Dept',
      author: 'Sarah',
      authorInitials: 'SA',
      dueDate: 'Jun 18',
      attachmentsCount: 3,
      commentsCount: 9,
    ),
    KanbanTask(
      id: '7',
      title: 'Semester Exam Scheduling',
      description: 'Coordinate with faculty departments to finalize the final examination ti...',
      priority: 'MEDIUM',
      status: KanbanStatus.complete,
      department: 'Math Dept',
      author: 'Dina',
      authorInitials: 'DF',
      dueDate: 'Jun 5',
      attachmentsCount: 1,
      commentsCount: 6,
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
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.w : 16.w, vertical: 16.h),
              child: _buildHeader(context),
            ),
            
            // Sub-Header (Fixed below header)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.w : 16.w, vertical: 8.h),
              child: _buildSubHeader(context),
            ),
            
            // Kanban Board Columns (Scrollable area)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.w : 16.w, vertical: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKanbanColumn(context, KanbanStatus.pending, 'Pending', const Color(0xFF757575), const Color(0xFFF5F5F5)),
                    SizedBox(width: 20.w),
                    _buildKanbanColumn(context, KanbanStatus.todo, 'To Do', const Color(0xFFF2C94C), const Color(0xFFFFF9E6)),
                    SizedBox(width: 20.w),
                    _buildKanbanColumn(context, KanbanStatus.inProgress, 'In Progress', const Color(0xFF2F80ED), const Color(0xFFEAF2FF)),
                    SizedBox(width: 20.w),
                    _buildKanbanColumn(context, KanbanStatus.complete, 'Complete', const Color(0xFF27AE60), const Color(0xFFE8F8EE)),
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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Tasks & Tickets Board',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isDesktop ? 22.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isDesktop) ...[
                    SizedBox(width: 12.w),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Sunday, June 21, 2026',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Overview of work tasks, tickets, and phases',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isDesktop ? 13.sp : 11.sp,
                ),
              ),
            ],
          ),
        ),
        
        if (!ResponsiveLayout.isMobile(context)) ...[
          Container(
            width: isDesktop ? 260.w : 180.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks, teams...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                prefixIcon: Icon(Icons.search, size: 16.sp, color: Colors.grey[400]),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 16.w),
          
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20.sp,
                    color: const Color(0xFF0A448C),
                  ),
                ),
                Positioned(
                  right: -2.w,
                  top: -2.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20.w),
          
          GestureDetector(
            onTap: () => _showUserProfileDialog(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: const Color(0xFF0A448C),
                  child: Text(
                    'AH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Ahmed',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[500],
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    Widget searchBar = Container(
      width: isDesktop ? 300.w : double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
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
          prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey[400]),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 9.h),
        ),
        style: TextStyle(fontSize: 13.sp),
      ),
    );

    Widget actionsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter Button
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[300]!, width: 1.2),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            backgroundColor: Colors.white,
          ),
          child: Row(
            children: [
              Icon(Icons.filter_list, size: 16.sp),
              SizedBox(width: 6.w),
              Text('Filter', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ],
          ),
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
              color: _filterOverdueOnly ? const Color(0xFFFFECEB) : Colors.white,
              border: Border.all(
                color: _filterOverdueOnly ? const Color(0xFFEB5757) : Colors.grey[300]!,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16.sp, color: const Color(0xFFEB5757)),
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
        SizedBox(width: 16.w),
        // Add Task Button
        ElevatedButton(
          onPressed: () => _showAddTaskDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A448C),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 16.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text('Add Task', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchBar,
          actionsRow,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchBar,
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
        final matchesDept = t.department?.toLowerCase().contains(searchQuery) ?? false;
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
                if (status == KanbanStatus.pending && columnTasks.any((t) => t.isOverdue) && !_filterOverdueOnly) ...[
                  _buildNoTasksPlaceholder(),
                  SizedBox(height: 12.h),
                ],
                if (columnTasks.isEmpty)
                  _buildNoTasksPlaceholder()
                else
                  ...columnTasks.map((task) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildTaskCard(task),
                  )),
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
          style: BorderStyle.none, // We can draw dashed border or just clean solid
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
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: const Color(0xFFEB5757), size: 10.sp),
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                    Icon(Icons.calendar_today_outlined, size: 10.sp, color: Colors.grey[400]),
                    SizedBox(width: 4.w),
                    Text(
                      task.dueDate!,
                      style: TextStyle(
                        color: task.isOverdue ? const Color(0xFFEB5757) : Colors.grey[400],
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
                  Icon(Icons.chat_bubble_outline, size: 12.sp, color: Colors.grey[400]),
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
      buttons.add(_buildTransitionPill('> To Do', const Color(0xFFF2C94C), () => _moveTask(task.id, KanbanStatus.todo)));
      buttons.add(SizedBox(width: 4.w));
      buttons.add(_buildTransitionPill('> In', const Color(0xFF2F80ED), () => _moveTask(task.id, KanbanStatus.inProgress)));
    } else if (task.status == KanbanStatus.todo) {
      buttons.add(_buildTransitionPill('> Pending', const Color(0xFF757575), () => _moveTask(task.id, KanbanStatus.pending)));
      buttons.add(SizedBox(width: 4.w));
      buttons.add(_buildTransitionPill('> In', const Color(0xFF2F80ED), () => _moveTask(task.id, KanbanStatus.inProgress)));
    } else if (task.status == KanbanStatus.inProgress) {
      buttons.add(_buildTransitionPill('> Pending', const Color(0xFF757575), () => _moveTask(task.id, KanbanStatus.pending)));
      buttons.add(SizedBox(width: 4.w));
      buttons.add(_buildTransitionPill('> To', const Color(0xFFF2C94C), () => _moveTask(task.id, KanbanStatus.todo)));
      buttons.add(SizedBox(width: 4.w));
      buttons.add(_buildTransitionPill('> Done', const Color(0xFF27AE60), () => _moveTask(task.id, KanbanStatus.complete)));
    } else if (task.status == KanbanStatus.complete) {
      buttons.add(_buildTransitionPill('> Pending', const Color(0xFF757575), () => _moveTask(task.id, KanbanStatus.pending)));
      buttons.add(SizedBox(width: 4.w));
      buttons.add(_buildTransitionPill('> To', const Color(0xFFF2C94C), () => _moveTask(task.id, KanbanStatus.todo)));
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Task',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department (e.g. CS Dept, Business)'),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: const [
                          DropdownMenuItem(value: 'HIGH', child: Text('High')),
                          DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                          DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedPriority = val;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DropdownButtonFormField<KanbanStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Phase'),
                        items: const [
                          DropdownMenuItem(value: KanbanStatus.pending, child: Text('Pending')),
                          DropdownMenuItem(value: KanbanStatus.todo, child: Text('To Do')),
                          DropdownMenuItem(value: KanbanStatus.inProgress, child: Text('In Progress')),
                          DropdownMenuItem(value: KanbanStatus.complete, child: Text('Complete')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedStatus = val;
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Save Task',
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _tasks.add(KanbanTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      description: descriptionController.text,
                      priority: selectedPriority,
                      status: selectedStatus,
                      department: deptController.text.isNotEmpty ? deptController.text : null,
                      author: 'Dr. Ahmed',
                      authorInitials: 'AH',
                      attachmentsCount: 0,
                      commentsCount: 0,
                    ));
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
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
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
              ),
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

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textHint,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12.sp,
              ),
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
