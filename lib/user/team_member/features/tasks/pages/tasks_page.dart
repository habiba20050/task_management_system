import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import 'package:task_management_system/auth/model/user_model.dart';
import 'package:task_management_system/language/cubit/language_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../shared/features/tasks/models/unified_item.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedView = 'Table'; // 'Table' | 'Calendar'

  // Filter States
  String _searchQuery = '';
  final String _selectedDept = 'All';
  final String _selectedTeam = 'All';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';
  final String _selectedOwner = 'All';
  DateTimeRange? _selectedDateRange;

  // Sorting States
  String _sortByField = 'Due Date'; // 'Task Title' | 'Priority' | 'Status' | 'Department' | 'Assigned To' | 'Team' | 'Start Date' | 'Due Date' | 'Remaining Time' | 'Progress' | 'Created Date'
  bool _sortAscending = true;

  // Calendar States
  String _calendarMode = 'Week'; // 'Day' | 'Week' | 'Month' | 'Custom'
  final DateTime _calendarActiveDate = DateTime(2026, 7, 24);
  DateTimeRange? _calendarCustomRange;

  // Form controllers
  final TextEditingController _submitTitleController = TextEditingController();
  final TextEditingController _submitDescController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _prController = TextEditingController();

  @override
  void dispose() {
    _submitTitleController.dispose();
    _submitDescController.dispose();
    _githubController.dispose();
    _prController.dispose();
    super.dispose();
  }

  // --- Fetch Tasks matching filters ---
  List<UnifiedItem> _getFilteredAndSortedTasks(String currentUserId, String currentUserRole) {
    final db = MockDatabase.instance;
    final List<UnifiedItem> items = [];

    for (final task in db.tasks) {
      final owner = db.users.firstWhere(
        (u) => u.id == task.currentOwnerId, 
        orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: 'Team Member', department: '')
      );
      final team = db.teams.firstWhere(
        (t) => t.id == task.assignedTeamId,
        orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: [])
      );

      // Role-based visibility
      if (currentUserRole == 'Team Member' && task.currentOwnerId != currentUserId) {
        continue;
      }
      if (currentUserRole == 'Team Leader') {
        final leaderTeam = db.teams.firstWhere(
          (t) => t.leaderId == currentUserId, 
          orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: [])
        );
        final isOwnedByTeamMember = leaderTeam.memberIds.contains(task.currentOwnerId);
        if (task.currentOwnerId != currentUserId && !isOwnedByTeamMember) {
          continue;
        }
      }

      items.add(
        UnifiedItem(
          id: task.id,
          title: task.title,
          description: task.description,
          type: task.taskType,
          priority: task.priority,
          status: task.status,
          deadline: task.deadline,
          teamName: team.name,
          assignedTo: owner.fullName,
          originalObject: task,
        ),
      );
    }

    // Apply filters
    final filtered = items.where((item) {
      final task = item.originalObject as MockTask;

      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesDept = _selectedDept == 'All' || task.taskDepartment == _selectedDept;
      final matchesTeam = _selectedTeam == 'All' || item.teamName == _selectedTeam;
      final matchesPriority = _selectedPriority == 'All' || item.priority.toUpperCase() == _selectedPriority.toUpperCase();
      final matchesStatus = _selectedStatus == 'All' || item.status.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesOwner = _selectedOwner == 'All' || task.currentOwnerId == _selectedOwner;

      bool matchesDateRange = true;
      if (_selectedDateRange != null) {
        final taskDate = DateTime.tryParse(task.deadline);
        if (taskDate != null) {
          matchesDateRange = taskDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }

      return matchesSearch && matchesDept && matchesTeam && matchesPriority && matchesStatus && matchesOwner && matchesDateRange;
    }).toList();

    // Sorting logic on all columns
    filtered.sort((a, b) {
      final taskA = a.originalObject as MockTask;
      final taskB = b.originalObject as MockTask;

      int comparison = 0;
      switch (_sortByField) {
        case 'Task Title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'Priority':
          final pMap = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};
          final pa = pMap[a.priority.toUpperCase()] ?? 0;
          final pb = pMap[b.priority.toUpperCase()] ?? 0;
          comparison = pa.compareTo(pb);
          break;
        case 'Status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'Department':
          comparison = taskA.taskDepartment.compareTo(taskB.taskDepartment);
          break;
        case 'Assigned To':
          comparison = a.assignedTo.compareTo(b.assignedTo);
          break;
        case 'Team':
          comparison = a.teamName.compareTo(b.teamName);
          break;
        case 'Start Date':
          comparison = taskA.startDate.compareTo(taskB.startDate);
          break;
        case 'Due Date':
          final da = DateTime.tryParse(a.deadline) ?? DateTime(9999);
          final dbDate = DateTime.tryParse(b.deadline) ?? DateTime(9999);
          comparison = da.compareTo(dbDate);
          break;
        case 'Remaining Time':
          final da = DateTime.tryParse(a.deadline) ?? DateTime(9999);
          final dbDate = DateTime.tryParse(b.deadline) ?? DateTime(9999);
          comparison = da.compareTo(dbDate);
          break;
        case 'Progress':
          final pa = _calculateProgress(a.status);
          final pb = _calculateProgress(b.status);
          comparison = pa.compareTo(pb);
          break;
        case 'Created Date':
          comparison = a.id.compareTo(b.id);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  double _calculateProgress(String status) {
    switch (status) {
      case 'Completed':
      case 'Approved':
        return 1.0;
      case 'Submitted':
      case 'Under Review':
        return 0.7;
      case 'In Progress':
        return 0.3;
      case 'Needs Changes':
        return 0.2;
      case 'Assigned':
      case 'Pending':
        return 0.0;
      default:
        return 0.1;
    }
  }

  String _calculateRemainingTime(String deadlineStr) {
    final date = DateTime.tryParse(deadlineStr);
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) {
      return 'Overdue'.tr(context);
    } else if (diff.inDays > 0) {
      return context.read<LanguageCubit>().state == 'EN' ? '${diff.inDays}d left' : 'متبقي ${diff.inDays}ي';
    } else {
      return context.read<LanguageCubit>().state == 'EN' ? '${diff.inHours}h left' : 'متبقي ${diff.inHours}س';
    }
  }

  String _getCreatedDate(MockTask task) {
    if (task.startDate.isNotEmpty) return task.startDate;
    return DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(task.id) ?? 1774384000000));
  }

  void _onSort(String field) {
    setState(() {
      if (_sortByField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortByField = field;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(id: '1', email: 'admin@aitu.edu', username: 'admin', fullName: 'Dr. Ahmed Hassan', role: 'Admin');
    final role = user.role.isEmpty ? 'Admin' : user.role;
    final userId = user.id.isEmpty ? '1' : user.id;

    final isMobile = ResponsiveLayout.isMobile(context);
    final filteredItems = _getFilteredAndSortedTasks(userId, role);

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.w : 32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _gradientChip(Icons.checklist_outlined, AppColors.primary, size: 44),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role == 'Team Member' ? 'My Tasks'.tr(context) : 'Tasks'.tr(context),
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            role == 'Team Member'
                                ? 'Track and manage your assigned tasks'.tr(context)
                                : 'Manage and delegate academic workflow tasks'.tr(context),
                            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (role == 'Admin' || role == 'Manager' || role == 'Team Leader') ...[
                      SizedBox(width: 12.w),
                      _headerActionButton(
                        label: 'Add Task'.tr(context),
                        icon: Icons.add,
                        onTap: () => _showAddTaskDialog(context, userId),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.h),

                // Filter Bar
                _buildFilterBar(context),
                SizedBox(height: 12.h),

                // Sorting & View select
                Row(
                  children: [
                    if (_selectedView == 'Table')
                      Expanded(
                        child: Text('Click table headers to sort.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                      )
                    else
                      const Spacer(),
                    _buildViewToggle(),
                  ],
                ),
                SizedBox(height: 12.h),

                // Layout display
                _selectedView == 'Table'
                    ? _buildTableView(filteredItems, role, userId)
                    : _buildCalendarView(filteredItems),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem(
            icon: Icons.table_chart_outlined,
            label: 'Table'.tr(context),
            active: _selectedView == 'Table',
            onTap: () => setState(() => _selectedView = 'Table'),
          ),
          SizedBox(width: 4.w),
          _toggleItem(
            icon: Icons.calendar_month_outlined,
            label: 'Calendar'.tr(context),
            active: _selectedView == 'Calendar',
            onTap: () => setState(() => _selectedView = 'Calendar'),
          ),
        ],
      ),
    );
  }

  Widget _toggleItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [AppColors.primary, _darker(AppColors.primary)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textSecondary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter Bar ---
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '${'Search'.tr(context)}...',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          SizedBox(height: 14.h),
          // Filter fields
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final cols = constraints.maxWidth < 600
                  ? 1
                  : constraints.maxWidth < 1000
                      ? 2
                      : 3;
              final fieldWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: 14.h,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Priority',
                      icon: Icons.flag_outlined,
                      value: _selectedPriority.tr(context),
                      options: ['All', 'HIGH', 'MEDIUM', 'LOW'],
                      labelMap: {'All': 'All'.tr(context), 'HIGH': 'HIGH'.tr(context), 'MEDIUM': 'MEDIUM'.tr(context), 'LOW': 'LOW'.tr(context)},
                      onSelected: (val) => setState(() => _selectedPriority = val),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildFilterField(
                      label: 'Status',
                      icon: Icons.circle_outlined,
                      value: _selectedStatus.tr(context),
                      options: ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'],
                      onSelected: (val) => setState(() => _selectedStatus = val),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildDateRangeField(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    Map<String, String>? labelMap,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        PopupMenuButton<String>(
          initialValue: options.contains(value) ? value : options.first,
          onSelected: onSelected,
          offset: Offset(0, 48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          itemBuilder: (context) => options.map((o) {
            final text = labelMap != null ? (labelMap[o] ?? o) : o.tr(context);
            final isSelected = o == value;
            return PopupMenuItem(
              value: o,
              height: 38.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) Icon(Icons.check, size: 16, color: AppColors.primary) else SizedBox(width: 16.w),
                  SizedBox(width: 8.w),
                  Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
          child: Container(
            width: double.infinity,
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(value, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date Range'.tr(context), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 6.h),
        PopupMenuButton<String>(
          offset: Offset(0, 48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          onSelected: (val) async {
            if (val == 'pick') {
              final range = await showDialog<DateTimeRange>(
                context: context,
                builder: (context) {
                  DateTime? start = _selectedDateRange?.start;
                  DateTime? end = _selectedDateRange?.end;
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)]),
                                          borderRadius: BorderRadius.circular(16.r),
                                          boxShadow: [
                                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: const Icon(Icons.date_range, color: Colors.white, size: 26),
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Select Date Range'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                            SizedBox(height: 2.h),
                                            Text('Choose the start and end dates for your filter.'.tr(context), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h),
                                  _buildDateSelectionCard(
                                    title: 'Start Date'.tr(context),
                                    date: start,
                                    icon: Icons.calendar_today,
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: start ?? DateTime.now(),
                                        firstDate: DateTime(2026),
                                        lastDate: DateTime(2030),
                                        builder: _buildDatePickerTheme,
                                      );
                                      if (d != null) setStateDialog(() => start = d);
                                    },
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildDateSelectionCard(
                                    title: 'End Date'.tr(context),
                                    date: end,
                                    icon: Icons.event,
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: end ?? start ?? DateTime.now(),
                                        firstDate: DateTime(2026),
                                        lastDate: DateTime(2030),
                                        builder: _buildDatePickerTheme,
                                      );
                                      if (d != null) setStateDialog(() => end = d);
                                    },
                                  ),
                                  SizedBox(height: 28.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.textSecondary,
                                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        ),
                                        child: Text('Cancel'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(width: 12.w),
                                      SizedBox(
                                        height: 48.h,
                                        child: ElevatedButton(
                                          onPressed: (start != null && end != null && !end!.isBefore(start!))
                                              ? () => Navigator.pop(context, DateTimeRange(start: start!, end: end!))
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor: const Color(0xFFCBD5E1),
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)]),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                                              alignment: Alignment.center,
                                              child: Text('Apply'.tr(context), style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
                      );
                    },
                  );
                },
              );
              if (range != null) setState(() => _selectedDateRange = range);
            } else if (val == 'clear') {
              setState(() => _selectedDateRange = null);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 38.h,
              value: 'pick',
              child: Row(children: [Icon(Icons.date_range, size: 16, color: AppColors.primary), SizedBox(width: 8.w), Text('Pick Date Range'.tr(context), style: TextStyle(fontSize: 13.sp))]),
            ),
            if (_selectedDateRange != null)
              PopupMenuItem(
                height: 38.h,
                value: 'clear',
                child: Row(children: [Icon(Icons.clear, size: 16, color: AppColors.danger), SizedBox(width: 8.w), Text('Clear'.tr(context), style: TextStyle(fontSize: 13.sp, color: AppColors.danger))]),
              ),
          ],
          child: Container(
            width: double.infinity,
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: _selectedDateRange != null
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _selectedDateRange != null ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 16.sp, color: _selectedDateRange != null ? AppColors.primary : AppColors.textSecondary),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          _selectedDateRange == null
                              ? 'Select'.tr(context)
                              : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: _selectedDateRange != null ? AppColors.primary : AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: Transform.scale(
        scale: 1.15,
        child: child!,
      ),
    );
  }

  Widget _buildDateSelectionCard({required String title, required DateTime? date, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 3.h),
                  Text(date != null ? DateFormat('MMMM d, yyyy').format(date) : 'Select date'.tr(context), style: TextStyle(fontSize: 12.sp, color: date != null ? AppColors.textSecondary : Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- TABLE VIEW ---
  Widget _buildTableView(List<UnifiedItem> items, String role, String currentUserId) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: _modernCardDecoration(),
        child: Column(
          children: [
            _gradientChip(Icons.checklist_outlined, AppColors.textSecondary, size: 52),
            SizedBox(height: 12.h),
            Text(
              'No tasks matching criteria.'.tr(context),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: _modernCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: [
                _buildSortableColumn('Task Title', 'Task Title'),
                _buildSortableColumn('Priority', 'Priority'),
                _buildSortableColumn('Status', 'Status'),
                _buildSortableColumn('Assigned To', 'Assigned To'),
                _buildSortableColumn('Start Date', 'Start Date'),
                _buildSortableColumn('Due Date', 'Due Date'),
                _buildSortableColumn('Remaining Time', 'Remaining Time'),
                _buildSortableColumn('Progress', 'Progress'),
                _buildSortableColumn('Created Date', 'Created Date'),
                DataColumn(
                  label: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12.sp)),
                  columnWidth: const FixedColumnWidth(150),
                ),
              ],
              rows: items.map((item) {
                final task = item.originalObject as MockTask;
                final progress = _calculateProgress(task.status);
                final remaining = _calculateRemainingTime(task.deadline);

                var pBg = const Color(0xFFF1F5F9);
                var pFg = AppColors.textSecondary;
                if (task.priority == 'HIGH') {
                  pBg = const Color(0xFFFFEBEE);
                  pFg = AppColors.danger;
                } else if (task.priority == 'LOW') {
                  pBg = const Color(0xFFE8F5E9);
                  pFg = AppColors.success;
                }

                return DataRow(cells: [
                  DataCell(Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: pBg, borderRadius: BorderRadius.circular(20.r)),
                    child: Text(task.priority.tr(context), style: TextStyle(color: pFg, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                  )),
                  DataCell(Text(task.status.tr(context))),
                  DataCell(Text(item.assignedTo)),
                  DataCell(Text(task.startDate)),
                  DataCell(Text(task.deadline)),
                  DataCell(Text(remaining, style: TextStyle(color: remaining == 'Overdue'.tr(context) ? AppColors.danger : AppColors.textPrimary))),
                  DataCell(SizedBox(
                    width: 80.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        color: progress == 1.0 ? AppColors.success : AppColors.primary,
                        backgroundColor: const Color(0xFFE2E8F0),
                        minHeight: 6,
                      ),
                    ),
                  )),
                  DataCell(Text(_getCreatedDate(task))),
                  DataCell(Row(
                    children: [
                      IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), icon: const Icon(Icons.visibility, color: Colors.blue, size: 16), onPressed: () => _showQuickViewModal(context, task)),
                      IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), icon: const Icon(Icons.edit, color: Colors.orange, size: 16), onPressed: () => _showEditTaskDialog(context, task, currentUserId)),
                      IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), icon: const Icon(Icons.delete, color: AppColors.danger, size: 16), onPressed: () => _confirmDeleteTask(context, task.id)),
                      if (task.status == 'Submitted' || task.status == 'Completed' || task.status == 'Approved')
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.assignment_turned_in, color: Colors.green, size: 16),
                          onPressed: () => _showViewSubmissionDialog(context, task),
                          tooltip: 'View Submission'.tr(context),
                        )
                      else
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.send, color: Colors.purple, size: 16),
                          onPressed: () => _showSubmitTaskDialog(context, task),
                          tooltip: 'Submit Task'.tr(context),
                        ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _buildSortableColumn(String label, String field) {
    final isSelected = _sortByField == field;
    return DataColumn(
      label: InkWell(
        onTap: () => _onSort(field),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 140.w),
              child: Text(label.tr(context), overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12.sp)),
            ),
            if (isSelected) ...[
              SizedBox(width: 4.w),
              Icon(_sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 16, color: AppColors.primary),
            ]
          ],
        ),
      ),
    );
  }

  // --- Calendar View ---
  Widget _buildCalendarView(List<UnifiedItem> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: _modernCardDecoration(),
        child: Column(
          children: [
            _gradientChip(Icons.calendar_month_outlined, AppColors.textSecondary, size: 52),
            SizedBox(height: 12.h),
            Text(
              'No tasks matching criteria.'.tr(context),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: _modernCardDecoration(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(_calendarActiveDate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
              Row(
                children: [
                  _buildCalBtn('Day', 'Day'),
                  _buildCalBtn('Week', 'Week'),
                  _buildCalBtn('Month', 'Month'),
                  _buildCalBtn('Custom', 'Custom'),
                ],
              )
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(child: _buildCalendarBody(items)),
        ],
      ),
    );
  }

  Widget _buildCalBtn(String label, String mode) {
    final isSelected = _calendarMode == mode;
    return TextButton(
      onPressed: () async {
        if (mode == 'Custom') {
          final range = await showDateRangePicker(context: context, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
          if (range != null) {
            setState(() {
              _calendarCustomRange = range;
              _calendarMode = 'Custom';
            });
          }
        } else {
          setState(() => _calendarMode = mode);
        }
      },
      child: Text(label.tr(context), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : Colors.grey)),
    );
  }

  Widget _buildCalendarBody(List<UnifiedItem> items) {
    if (_calendarMode == 'Day') {
      final dayItems = items.where((i) {
        final d = DateTime.tryParse(i.deadline);
        return d != null && d.year == _calendarActiveDate.year && d.month == _calendarActiveDate.month && d.day == _calendarActiveDate.day;
      }).toList();
      return ListView.builder(
        itemCount: dayItems.length,
        itemBuilder: (context, idx) {
          final item = dayItems[idx];
          return ListTile(
            title: Text(item.title),
            trailing: Text(item.priority),
            onTap: () => _showQuickViewModal(context, item.originalObject as MockTask),
          );
        },
      );
    }
    if (_calendarMode == 'Week') {
      final isMobile = ResponsiveLayout.isMobile(context);
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
      if (isMobile) {
        return ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, idx) {
            int offset = idx;
            final dateStr = '2026-07-${20 + offset}';
            final dayItems = items.where((i) => i.deadline == dateStr).toList();
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${days[idx].tr(context)} - $dateStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (dayItems.isEmpty)
                      Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text('No tasks'.tr(context), style: TextStyle(fontSize: 11.sp, color: Colors.grey)))
                    else
                      ...dayItems.map((item) => ListTile(
                            dense: true,
                            title: Text(item.title, style: TextStyle(fontSize: 11.sp)),
                            trailing: Text(item.priority, style: TextStyle(fontSize: 10.sp)),
                          )),
                  ],
                ),
              ),
            );
          },
        );
      }
      return GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        children: days.map((d) {
          int offset = days.indexOf(d);
          final dateStr = '2026-07-${20 + offset}';
          final dayItems = items.where((i) => i.deadline == dateStr).toList();
          return Container(
            color: Colors.grey.shade50,
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateStr, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: dayItems.length,
                    itemBuilder: (context, idx) => Card(child: Padding(padding: EdgeInsets.all(4.w), child: Text(dayItems[idx].title, style: TextStyle(fontSize: 9.sp)))),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      );
    }

    if (_calendarMode == 'Month') {
      final isMobile = ResponsiveLayout.isMobile(context);
      if (isMobile) {
        return ListView.builder(
          itemCount: 30,
          itemBuilder: (context, idx) {
            final dateStr = '2026-07-${idx + 1 < 10 ? '0${idx + 1}' : idx + 1}';
            final dayItems = items.where((i) => i.deadline == dateStr).toList();
            return ListTile(
              leading: CircleAvatar(child: Text('${idx + 1}')),
              title: Text(dayItems.isEmpty ? 'No tasks'.tr(context) : '${dayItems.length} task(s)'.tr(context)),
              subtitle: dayItems.isNotEmpty ? Text(dayItems.first.title) : null,
            );
          },
        );
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
        itemCount: 30,
        itemBuilder: (context, idx) {
          final dateStr = '2026-07-${idx + 1 < 10 ? '0${idx + 1}' : idx + 1}';
          final dayItems = items.where((i) => i.deadline == dateStr).toList();
          return Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (dayItems.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    color: AppColors.primary,
                    child: Text('${dayItems.length}', style: const TextStyle(color: Colors.white, fontSize: 8)),
                  )
              ],
            ),
          );
        },
      );
    }

    if (_calendarMode == 'Custom' && _calendarCustomRange != null) {
      final customItems = items.where((i) {
        final d = DateTime.tryParse(i.deadline);
        return d != null && d.isAfter(_calendarCustomRange!.start) && d.isBefore(_calendarCustomRange!.end);
      }).toList();
      return ListView.builder(
        itemCount: customItems.length,
        itemBuilder: (context, idx) => ListTile(title: Text(customItems[idx].title), onTap: () => _showQuickViewModal(context, customItems[idx].originalObject as MockTask)),
      );
    }
    return const SizedBox();
  }

  // --- Deletion Confirm ---
  void _confirmDeleteTask(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
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
                    _gradientChip(Icons.delete_outline, AppColors.danger, size: 52),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text('Delete Task'.tr(context), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text('Are you sure you want to delete this task? This action cannot be undone.'.tr(context),
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5)),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Cancel'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 140.w,
                      child: _gradientButton(context, 'Delete', () {
                        setState(() {
                          MockDatabase.instance.deleteTask(id);
                        });
                        Navigator.pop(context);
                      }, color: AppColors.danger),
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

  // --- Quick View Modal ---
  void _showQuickViewModal(BuildContext context, MockTask task) {
    final db = MockDatabase.instance;
    final owner = db.users.firstWhere((u) => u.id == task.currentOwnerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
    final creator = db.users.firstWhere((u) => u.id == task.assignedById, orElse: () => MockUser(id: '', email: '', fullName: 'System', role: '', department: ''));
    final remaining = _calculateRemainingTime(task.deadline);
    final submittedStatus = task.status == 'Submitted' || task.status == 'Completed' || task.status == 'Approved';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)]),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.visibility_outlined, color: Colors.white, size: 26),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            SizedBox(height: 2.h),
                            Text('Quick overview of the task'.tr(context), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(task.description, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.6)),
                  ),
                  SizedBox(height: 16.h),
                  _buildQuickViewRow('Assigned By'.tr(context), creator.fullName),
                  _buildQuickViewRow('Current Owner'.tr(context), owner.fullName),
                  _buildQuickViewRow('Team'.tr(context), db.teams.firstWhere((t) => t.id == task.assignedTeamId, orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: [])).name),
                  _buildQuickViewRow('Department'.tr(context), task.taskDepartment.tr(context)),
                  _buildQuickViewRow('Priority'.tr(context), task.priority.tr(context)),
                  _buildQuickViewRow('Status'.tr(context), task.status.tr(context)),
                  _buildQuickViewRow('Progress'.tr(context), '${(_calculateProgress(task.status) * 100).toInt()}%'),
                  _buildQuickViewRow('Start Date'.tr(context), task.startDate),
                  _buildQuickViewRow('Due Date'.tr(context), task.deadline),
                  _buildQuickViewRow('Remaining Time'.tr(context), remaining),
                  _buildQuickViewRow('Created At'.tr(context), _getCreatedDate(task)),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Close'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 10.w),
                      _buildGradientButton(
                        text: submittedStatus ? 'View Submission'.tr(context) : 'Submit Task'.tr(context),
                        icon: submittedStatus ? Icons.assignment_turned_in : Icons.send,
                        onTap: () {
                          Navigator.pop(context);
                          if (submittedStatus) {
                            _showViewSubmissionDialog(context, task);
                          } else {
                            _showSubmitTaskDialog(context, task);
                          }
                        },
                      ),
                      SizedBox(width: 10.w),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/tasks/${task.id}');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Full Details'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
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

  Widget _buildQuickViewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 95.w, child: Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ],
      ),
    );
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

  Widget _gradientButton(BuildContext context, String text, VoidCallback onTap,
      {Color color = AppColors.primary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        height: 50.h,
        alignment: Alignment.center,
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
        child: Text(
          text.tr(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _headerActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
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
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    Color color = AppColors.primary,
  }) {
    return SizedBox(
      height: 46.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14.r),
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
                  Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Add Task Dialog ---
  void _showAddTaskDialog(BuildContext context, String currentUserId) {
    final db = MockDatabase.instance;
    final titleCon = TextEditingController();
    final descCon = TextEditingController();
    final durationCon = TextEditingController(text: '8');

    String priority = 'MEDIUM';
    String status = 'Assigned';
    String taskDept = 'Computer Science';
    DateTime startDate = DateTime(2026, 7, 24);
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    DateTime dueDate = DateTime(2026, 7, 27);
    TimeOfDay dueTime = const TimeOfDay(hour: 17, minute: 0);

    String assignMode = 'Individual'; // 'Individual' | 'Team'
    String selectedRole = 'Team Member';
    String? selectedUserId = '4';
    String? selectedTeamId = 't1';
    bool allowReassignment = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final usersForRole = db.users.where((u) => u.role == selectedRole).toList();

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Task'.tr(context),
                                  style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  'Create and delegate a new task.'.tr(context),
                                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      _buildFieldLabel(context, 'Title', icon: Icons.title),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: titleCon,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration(context, 'Enter task title...', icon: Icons.title),
                      ),
                      SizedBox(height: 22.h),

                      _buildFieldLabel(context, 'Description', icon: Icons.description_outlined),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: descCon,
                        maxLines: 2,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration(context, 'Enter task description...', icon: Icons.description_outlined),
                      ),
                      SizedBox(height: 22.h),

                      _buildFieldLabel(context, 'Priority', icon: Icons.flag_outlined),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        decoration: _buildInputDecoration(context, '', icon: Icons.flag_outlined),
                        items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p.tr(context), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                        onChanged: (v) => setDialogState(() => priority = v!),
                      ),
                      SizedBox(height: 22.h),

                      _buildFieldLabel(context, 'Department', icon: Icons.apartment_outlined),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        initialValue: taskDept,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        decoration: _buildInputDecoration(context, '', icon: Icons.apartment_outlined),
                        items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                        onChanged: (v) => setDialogState(() => taskDept = v!),
                      ),
                      SizedBox(height: 22.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(context, 'Start Date', icon: Icons.calendar_today_outlined),
                                SizedBox(height: 10.h),
                                _datePickerField(context, DateFormat('yyyy-MM-dd').format(startDate), () async {
                                  final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                                  if (picked != null) setDialogState(() => startDate = picked);
                                }, icon: Icons.calendar_today_outlined),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(context, 'Due Date', icon: Icons.event_outlined),
                                SizedBox(height: 10.h),
                                _datePickerField(context, DateFormat('yyyy-MM-dd').format(dueDate), () async {
                                  final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                                  if (picked != null) setDialogState(() => dueDate = picked);
                                }, icon: Icons.event_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 22.h),

                      _buildFieldLabel(context, 'Estimated Duration (Hours)', icon: Icons.timer_outlined),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: durationCon,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration(context, 'e.g. 8', icon: Icons.timer_outlined),
                      ),
                      SizedBox(height: 22.h),

                      _buildFieldLabel(context, 'Assignment Mode', icon: Icons.groups_outlined),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        initialValue: assignMode,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        decoration: _buildInputDecoration(context, '', icon: Icons.groups_outlined),
                        items: ['Individual', 'Team'].map((m) => DropdownMenuItem(value: m, child: Text(m.tr(context), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                        onChanged: (v) => setDialogState(() {
                          assignMode = v!;
                          selectedUserId = null;
                          selectedTeamId = null;
                        }),
                      ),
                      SizedBox(height: 22.h),

                      if (assignMode == 'Individual') ...[
                        _buildFieldLabel(context, 'Role Selection', icon: Icons.badge_outlined),
                        SizedBox(height: 10.h),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          decoration: _buildInputDecoration(context, '', icon: Icons.badge_outlined),
                          items: ['Team Member', 'Team Leader', 'Manager'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                          onChanged: (v) => setDialogState(() {
                            selectedRole = v!;
                            selectedUserId = null;
                          }),
                        ),
                        SizedBox(height: 22.h),

                        _buildFieldLabel(context, 'Select User', icon: Icons.person_outline),
                        SizedBox(height: 10.h),
                        DropdownButtonFormField<String>(
                          initialValue: selectedUserId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          decoration: _buildInputDecoration(context, '', icon: Icons.person_outline),
                          items: usersForRole.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                          onChanged: (v) => setDialogState(() => selectedUserId = v),
                        ),
                        SizedBox(height: 22.h),
                      ] else ...[
                        _buildFieldLabel(context, 'Select Team', icon: Icons.groups_outlined),
                        SizedBox(height: 10.h),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTeamId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          decoration: _buildInputDecoration(context, '', icon: Icons.groups_outlined),
                          items: db.teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
                          onChanged: (v) => setDialogState(() => selectedTeamId = v),
                        ),
                        SizedBox(height: 22.h),
                      ],

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Allow Reassignment'.tr(context),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          value: allowReassignment,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                          activeThumbColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setDialogState(() => allowReassignment = v),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              ),
                              child: Text(
                                'Cancel'.tr(context),
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
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
                                  onTap: () {
                                    if (titleCon.text.isNotEmpty) {
                                      var ownerId = '4';
                                      if (assignMode == 'Individual' && selectedUserId != null) ownerId = selectedUserId!;
                                      if (assignMode == 'Team' && selectedTeamId != null) {
                                        ownerId = db.teams.firstWhere((t) => t.id == selectedTeamId).leaderId;
                                      }
                                      setState(() {
                                        db.addTask(MockTask(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          ticketId: 'tic1',
                                          title: titleCon.text,
                                          description: descCon.text.isNotEmpty ? descCon.text : titleCon.text,
                                          assignedMemberId: ownerId,
                                          deadline: DateFormat('yyyy-MM-dd').format(dueDate),
                                          estimatedHours: int.tryParse(durationCon.text) ?? 8,
                                          priority: priority,
                                          status: status,
                                          assignmentMode: assignMode,
                                          assignedTeamId: selectedTeamId,
                                          assignedRole: selectedRole,
                                          startDate: DateFormat('yyyy-MM-dd').format(startDate),
                                          startTime: '${startTime.hour}:${startTime.minute}',
                                          dueTime: '${dueTime.hour}:${dueTime.minute}',
                                          allowReassignment: allowReassignment,
                                          assignedById: currentUserId,
                                          currentOwnerId: ownerId,
                                          taskDepartment: taskDept,
                                          taskType: assignMode == 'Team' ? 'Team Task' : 'Individual Task',
                                        ));
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Create'.tr(context),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
          );
        },
      ),
    );
  }

  // --- Edit Task Dialog ---
  void _showEditTaskDialog(BuildContext context, MockTask task, String currentUserId) {
    final db = MockDatabase.instance;
    final titleCon = TextEditingController(text: task.title);
    final descCon = TextEditingController(text: task.description);
    String priority = task.priority;
    String status = task.status;
    String taskDept = task.taskDepartment;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientChip(Icons.edit_outlined, Colors.orange, size: 52),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Task'.tr(context),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Modify the selected task attributes.'.tr(context),
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Title'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: titleCon,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'Enter task title...'),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Description'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: descCon,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'Enter task description...'),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Priority'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['HIGH', 'MEDIUM', 'LOW']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.tr(context), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => priority = v!),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Status'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Department'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: taskDept,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['Computer Science', 'Engineering', 'IT Services']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => taskDept = v!),
                    ),
                    SizedBox(height: 28.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Text(
                              'Cancel'.tr(context),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _gradientButton(context, 'Save', () {
                            setState(() {
                              db.updateTaskStatus(task.id, status, db.users.firstWhere((u) => u.id == currentUserId).fullName);
                              // Update title/desc manually in list
                              final idx = db.tasks.indexWhere((t) => t.id == task.id);
                              if (idx != -1) {
                                final oldTask = db.tasks[idx];
                                db.tasks[idx] = MockTask(
                                  id: oldTask.id,
                                  ticketId: oldTask.ticketId,
                                  title: titleCon.text,
                                  description: descCon.text,
                                  assignedMemberId: oldTask.assignedMemberId,
                                  deadline: oldTask.deadline,
                                  estimatedHours: oldTask.estimatedHours,
                                  priority: priority,
                                  status: status,
                                  assignmentMode: oldTask.assignmentMode,
                                  assignedTeamId: oldTask.assignedTeamId,
                                  assignedDepartment: oldTask.assignedDepartment,
                                  assignedRole: oldTask.assignedRole,
                                  startDate: oldTask.startDate,
                                  startTime: oldTask.startTime,
                                  dueTime: oldTask.dueTime,
                                  allowReassignment: oldTask.allowReassignment,
                                  assignedById: oldTask.assignedById,
                                  currentOwnerId: oldTask.currentOwnerId,
                                  taskDepartment: taskDept,
                                  taskType: oldTask.taskType,
                                  checklist: oldTask.checklist,
                                  history: oldTask.history,
                                  activities: oldTask.activities,
                                  comments: oldTask.comments,
                                );
                                db.save();
                              }
                            });
                            Navigator.pop(context);
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _datePickerField(BuildContext context, String value, VoidCallback onTap, {IconData icon = Icons.calendar_today_outlined}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 10.w),
            Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
        ],
        Text(
          label.tr(context),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, size: 19, color: AppColors.textSecondary) : null,
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _showSubmitTaskDialog(BuildContext context, MockTask task) {
    final db = MockDatabase.instance;
    final githubCon = TextEditingController(text: task.githubLink ?? '');
    final prCon = TextEditingController(text: task.prLink ?? '');
    final notesCon = TextEditingController(text: task.notes ?? '');
    final reportCon = TextEditingController(text: task.submissionReport ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
            padding: EdgeInsets.all(28.w),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientChip(Icons.send_outlined, AppColors.primary, size: 52),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Submit Task Deliverables'.tr(context),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Enter submission details for task evaluation.'.tr(context),
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'GitHub Repository Link'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: githubCon,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'https://github.com/username/repo'),
                      validator: (v) => v == null || v.isEmpty ? 'GitHub link is required'.tr(context) : null,
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Pull Request Link'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: prCon,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'https://github.com/username/repo/pull/1'),
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Submission Report Summary'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: reportCon,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'Describe what was accomplished...'),
                      validator: (v) => v == null || v.isEmpty ? 'Report is required'.tr(context) : null,
                    ),
                    SizedBox(height: 18.h),

                    _buildFieldLabel(context, 'Submission Notes / Comments'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: notesCon,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(context, 'Additional notes for reviewer...'),
                    ),
                    SizedBox(height: 28.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Text(
                              'Cancel'.tr(context),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _gradientButton(context, 'Submit Task', () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                db.submitTask(
                                  taskId: task.id,
                                  githubLink: githubCon.text,
                                  prLink: prCon.text,
                                  notes: notesCon.text,
                                  report: reportCon.text,
                                );
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task submitted successfully'.tr(context))),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showViewSubmissionDialog(BuildContext context, MockTask task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
            padding: EdgeInsets.all(28.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _gradientChip(Icons.assignment_turned_in_outlined, AppColors.success, size: 52),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Submission Details'.tr(context),
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Review deliverables submitted by the owner.'.tr(context),
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'GitHub Repository Link'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      task.githubLink ?? 'No GitHub link provided.'.tr(context),
                      style: TextStyle(fontSize: 14.sp, color: task.githubLink != null ? Colors.blue : Colors.black87),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _buildFieldLabel(context, 'Pull Request Link'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      task.prLink ?? 'No PR link provided.'.tr(context),
                      style: TextStyle(fontSize: 14.sp, color: task.prLink != null ? Colors.blue : Colors.black87),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _buildFieldLabel(context, 'Submission Report Summary'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      task.submissionReport ?? 'No report summary provided.'.tr(context),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _buildFieldLabel(context, 'Submission Notes / Comments'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      task.notes ?? 'No notes provided.'.tr(context),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  _gradientButton(context, 'Close', () => Navigator.pop(context),
                      color: const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
