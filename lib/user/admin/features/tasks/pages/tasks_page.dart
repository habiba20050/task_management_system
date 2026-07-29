import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../shared/features/auth/cubit/auth_cubit.dart';
import '../../../../shared/features/auth/model/user_model.dart';
import '../../../../shared/features/language/cubit/language_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../shared/features/tasks/models/unified_item.dart';
import '../../../../../core/styles/app_spacing.dart';
import '../../../../../core/styles/app_radius.dart';
import '../../../../../core/styles/app_shadow.dart';
import '../../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../../core/widgets/cards/app_cards.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedView = 'Table'; // 'Table' | 'Kanban' | 'Calendar'

  // Filter States
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedTeam = 'All';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';
  String _selectedOwner = 'All';
  DateTimeRange? _selectedDateRange;

  // Sorting States
  String _sortByField = 'Due Date'; // 'Task Title' | 'Priority' | 'Status' | 'Department' | 'Assigned To' | 'Team' | 'Start Date' | 'Due Date' | 'Remaining Time' | 'Progress' | 'Created Date'
  bool _sortAscending = true;

  // Calendar States
  String _calendarMode = 'Week'; // 'Day' | 'Week' | 'Month' | 'Custom'
  DateTime _calendarActiveDate = DateTime(2026, 7, 24);
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
      final owner = db.users.firstWhere((u) => u.id == task.currentOwnerId, orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''));

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

    final filteredItems = _getFilteredAndSortedTasks(userId, role);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == 'Team Member' ? 'My Tasks'.tr(context) : 'Tasks'.tr(context),
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Manage and delegate academic workflow tasks'.tr(context),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (role == 'Admin' || role == 'Manager' || role == 'Team Leader')
                    PrimaryButton(
                      text: 'Add Task'.tr(context),
                      onPressed: () => _showAddTaskDialog(context, userId),
                      prefixIcon: const Icon(Icons.add, color: Colors.white),
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              // Filter Bar
              _buildFilterBar(context),
              SizedBox(height: 12.h),

              // Sorting & View select
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Click table headers to sort.'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    selectedColor: Colors.white,
                    fillColor: AppColors.primary,
                    color: AppColors.textSecondary,
                    constraints: BoxConstraints(minWidth: 60.w, minHeight: 32.h),
                    isSelected: [_selectedView == 'Table', _selectedView == 'Kanban', _selectedView == 'Calendar'],
                    onPressed: (index) {
                      setState(() {
                        if (index == 0) _selectedView = 'Table';
                        if (index == 1) _selectedView = 'Kanban';
                        if (index == 2) _selectedView = 'Calendar';
                      });
                    },
                    children: [
                      Text('Table'.tr(context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      Text('Kanban'.tr(context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      Text('Calendar'.tr(context), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Layout display
              Expanded(
                child: _selectedView == 'Table'
                    ? _buildTableView(filteredItems, role, userId)
                    : (_selectedView == 'Kanban' ? _buildKanbanView(filteredItems, role, userId) : _buildCalendarView(filteredItems)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Filter Bar ---
  Widget _buildFilterBar(BuildContext context) {
    final db = MockDatabase.instance;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search'.tr(context) + '...',
                      border: InputBorder.none,
                      icon: const Icon(Icons.search, color: Colors.grey),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _buildDropdown('Department'.tr(context), _selectedDept, ['All', 'Computer Science', 'Engineering', 'IT Services'], (val) => setState(() => _selectedDept = val!)),
              SizedBox(width: 10.w),
              _buildDropdown('Team'.tr(context), _selectedTeam, ['All', ...db.teams.map((t) => t.name)], (val) => setState(() => _selectedTeam = val!)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildDropdown('Priority'.tr(context), _selectedPriority, ['All', 'HIGH', 'MEDIUM', 'LOW'], (val) => setState(() => _selectedPriority = val!)),
              SizedBox(width: 10.w),
              _buildDropdown('Status'.tr(context), _selectedStatus, ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'], (val) => setState(() => _selectedStatus = val!)),
              SizedBox(width: 10.w),
              _buildDropdown('Assigned To'.tr(context), _selectedOwner, ['All', ...db.users.map((u) => u.id)], (val) => setState(() => _selectedOwner = val!), labelMap: {'All': 'All'.tr(context), ...{for (var u in db.users) u.id: u.fullName}}),
              SizedBox(width: 10.w),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(context: context, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                    if (range != null) setState(() => _selectedDateRange = range);
                  },
                  icon: const Icon(Icons.date_range, size: 14),
                  label: Text(_selectedDateRange == null ? 'Date Range'.tr(context) : 'Selected', style: TextStyle(fontSize: 10.sp)),
                  style: TextButton.styleFrom(side: const BorderSide(color: AppColors.border)),
                ),
              ),
              if (_selectedDateRange != null) ...[
                IconButton(icon: const Icon(Icons.clear, color: AppColors.danger), onPressed: () => setState(() => _selectedDateRange = null))
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged, {Map<String, String>? labelMap}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md.r), border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(label, style: TextStyle(fontSize: 11.sp)),
            items: options.map((o) {
              final text = labelMap != null ? (labelMap[o] ?? o) : o.tr(context);
              return DropdownMenuItem(value: o, child: Text(text, style: TextStyle(fontSize: 11.sp)));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // --- TABLE VIEW ---
  Widget _buildTableView(List<UnifiedItem> items, String role, String currentUserId) {
    if (items.isEmpty) {
      return Center(child: Text('No tasks matching criteria.'.tr(context)));
    }

    final db = MockDatabase.instance;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              columns: [
                _buildSortableColumn('Task Title', 'Task Title'),
                _buildSortableColumn('Priority', 'Priority'),
                _buildSortableColumn('Status', 'Status'),
                _buildSortableColumn('Department', 'Department'),
                _buildSortableColumn('Assigned To', 'Assigned To'),
                _buildSortableColumn('Team', 'Team'),
                _buildSortableColumn('Start Date', 'Start Date'),
                _buildSortableColumn('Due Date', 'Due Date'),
                _buildSortableColumn('Remaining Time', 'Remaining Time'),
                _buildSortableColumn('Progress', 'Progress'),
                _buildSortableColumn('Created Date', 'Created Date'),
                DataColumn(label: Text('Actions'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: items.map((item) {
                final task = item.originalObject as MockTask;
                final creator = db.users.firstWhere((u) => u.id == task.assignedById, orElse: () => MockUser(id: '', email: '', fullName: 'System', role: '', department: ''));
                final progress = _calculateProgress(task.status);
                final remaining = _calculateRemainingTime(task.deadline);

                var pBg = Colors.grey.shade100;
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: pBg, borderRadius: BorderRadius.circular(6.r)),
                    child: Text(task.priority.tr(context), style: TextStyle(color: pFg, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                  )),
                  DataCell(Text(task.status.tr(context))),
                  DataCell(Text(task.taskDepartment.tr(context))),
                  DataCell(Text(item.assignedTo)),
                  DataCell(Text(item.teamName)),
                  DataCell(Text(task.startDate)),
                  DataCell(Text(task.deadline)),
                  DataCell(Text(remaining, style: TextStyle(color: remaining == 'Overdue'.tr(context) ? AppColors.danger : AppColors.textPrimary))),
                  DataCell(SizedBox(width: 80.w, child: LinearProgressIndicator(value: progress, color: progress == 1.0 ? AppColors.success : AppColors.primary))),
                  DataCell(Text(_getCreatedDate(task))),
                  DataCell(Row(
                    children: [
                      IconButton(icon: const Icon(Icons.visibility, color: Colors.blue, size: 16), onPressed: () => _showQuickViewModal(context, task)),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 16), onPressed: () => _showEditTaskDialog(context, task, currentUserId)),
                      IconButton(icon: const Icon(Icons.delete, color: AppColors.danger, size: 16), onPressed: () => _confirmDeleteTask(context, task.id)),
                      if (task.status == 'Submitted' || task.status == 'Completed' || task.status == 'Approved')
                        IconButton(
                          icon: const Icon(Icons.assignment_turned_in, color: Colors.green, size: 16),
                          onPressed: () => _showViewSubmissionDialog(context, task),
                          tooltip: 'View Submission'.tr(context),
                        )
                      else
                        IconButton(
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
            Text(label.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isSelected) ...[
              SizedBox(width: 4.w),
              Icon(_sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 16),
            ]
          ],
        ),
      ),
    );
  }

  // --- Kanban Column Widget ---
  Widget _buildKanbanView(List<UnifiedItem> items, String role, String currentUserId) {
    final todo = items.where((i) => i.status == 'Todo' || i.status == 'Assigned' || i.status == 'Pending').toList();
    final inProgress = items.where((i) => i.status == 'In Progress' || i.status == 'Needs Changes').toList();
    final review = items.where((i) => i.status == 'Submitted' || i.status == 'Under Review').toList();
    final done = items.where((i) => i.status == 'Completed' || i.status == 'Approved').toList();

    return Row(
      children: [
        Expanded(child: _buildKanbanCol('Todo'.tr(context), todo)),
        SizedBox(width: 10.w),
        Expanded(child: _buildKanbanCol('In Progress'.tr(context), inProgress)),
        SizedBox(width: 10.w),
        Expanded(child: _buildKanbanCol('Under Review'.tr(context), review)),
        SizedBox(width: 10.w),
        Expanded(child: _buildKanbanCol('Completed'.tr(context), done)),
      ],
    );
  }

  Widget _buildKanbanCol(String label, List<UnifiedItem> list) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(AppRadius.lg.r), border: Border.all(color: AppColors.border)),
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label (${list.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final item = list[idx];
                final task = item.originalObject as MockTask;
                return Card(
                  child: ListTile(
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.assignedTo),
                    onTap: () => _showQuickViewModal(context, task),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Calendar View ---
  Widget _buildCalendarView(List<UnifiedItem> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg.r), border: Border.all(color: AppColors.border)),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${DateFormat('MMMM yyyy').format(_calendarActiveDate)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
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
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
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
      builder: (context) => AlertDialog(
        title: Text('Delete Task'.tr(context)),
        content: Text('Are you sure you want to delete this task?'.tr(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
          TextButton(
            onPressed: () {
              setState(() {
                MockDatabase.instance.deleteTask(id);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'.tr(context), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // --- Quick View Modal ---
  void _showQuickViewModal(BuildContext context, MockTask task) {
    final db = MockDatabase.instance;
    final owner = db.users.firstWhere((u) => u.id == task.currentOwnerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
    final creator = db.users.firstWhere((u) => u.id == task.assignedById, orElse: () => MockUser(id: '', email: '', fullName: 'System', role: '', department: ''));
    final remaining = _calculateRemainingTime(task.deadline);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 420.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                const Divider(),
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
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context))),
          if (task.status == 'Submitted' || task.status == 'Completed' || task.status == 'Approved')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showViewSubmissionDialog(context, task);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('View Submission'.tr(context)),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSubmitTaskDialog(context, task);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Submit Task'.tr(context)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/tasks/${task.id}');
            },
            child: Text('View Full Details'.tr(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickViewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 95.w, child: Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600))),
        ],
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            backgroundColor: Colors.white,
            child: Container(
              width: 500.w,
              padding: EdgeInsets.all(32.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Task'.tr(context),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Create and delegate a new task.'.tr(context),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Title'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: titleCon,
                      decoration: _buildInputDecoration(context, 'Enter task title...'),
                    ),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Description'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: descCon,
                      maxLines: 2,
                      decoration: _buildInputDecoration(context, 'Enter task description...'),
                    ),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Priority'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: priority,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p.tr(context)))).toList(),
                      onChanged: (v) => setDialogState(() => priority = v!),
                    ),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Department'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: taskDept,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context)))).toList(),
                      onChanged: (v) => setDialogState(() => taskDept = v!),
                    ),
                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(context, 'Start Date'),
                              SizedBox(height: 8.h),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                                  if (picked != null) setDialogState(() => startDate = picked);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF2F7),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('yyyy-MM-dd').format(startDate), style: TextStyle(fontSize: 13.sp)),
                                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(context, 'Due Date'),
                              SizedBox(height: 8.h),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
                                  if (picked != null) setDialogState(() => dueDate = picked);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF2F7),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('yyyy-MM-dd').format(dueDate), style: TextStyle(fontSize: 13.sp)),
                                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Estimated Duration (Hours)'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: durationCon,
                      decoration: _buildInputDecoration(context, 'e.g. 8'),
                    ),
                    SizedBox(height: 20.h),

                    _buildFieldLabel(context, 'Assignment Mode'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: assignMode,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      decoration: _buildInputDecoration(context, ''),
                      items: ['Individual', 'Team'].map((m) => DropdownMenuItem(value: m, child: Text(m.tr(context)))).toList(),
                      onChanged: (v) => setDialogState(() {
                        assignMode = v!;
                        selectedUserId = null;
                        selectedTeamId = null;
                      }),
                    ),
                    SizedBox(height: 20.h),

                    if (assignMode == 'Individual') ...[
                      _buildFieldLabel(context, 'Role Selection'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        decoration: _buildInputDecoration(context, ''),
                        items: ['Team Member', 'Team Leader', 'Manager'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context)))).toList(),
                        onChanged: (v) => setDialogState(() {
                          selectedRole = v!;
                          selectedUserId = null;
                        }),
                      ),
                      SizedBox(height: 20.h),

                      _buildFieldLabel(context, 'Select User'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: selectedUserId,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        decoration: _buildInputDecoration(context, ''),
                        items: usersForRole.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                        onChanged: (v) => setDialogState(() => selectedUserId = v),
                      ),
                      SizedBox(height: 20.h),
                    ] else ...[
                      _buildFieldLabel(context, 'Select Team'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: selectedTeamId,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        decoration: _buildInputDecoration(context, ''),
                        items: db.teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                        onChanged: (v) => setDialogState(() => selectedTeamId = v),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    SwitchListTile(
                      title: Text('Allow Reassignment'.tr(context), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                      value: allowReassignment,
                      activeColor: const Color(0xFF0F4C81),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setDialogState(() => allowReassignment = v),
                    ),
                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
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
                          child: ElevatedButton(
                            onPressed: () {
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
                                    description: titleCon.text,
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F4C81),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Create'.tr(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 500.w,
            padding: EdgeInsets.all(32.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Task'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Modify the selected task attributes.'.tr(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Title'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: titleCon,
                    decoration: _buildInputDecoration(context, 'Enter task title...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Description'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: descCon,
                    maxLines: 2,
                    decoration: _buildInputDecoration(context, 'Enter task description...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Priority'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: priority,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(context, ''),
                    items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => priority = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Status'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: status,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(context, ''),
                    items: ['Pending', 'Assigned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Completed', 'Needs Changes', 'Rejected', 'Overdue'].map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
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
                        child: ElevatedButton(
                          onPressed: () {
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(32.w),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submit Task Deliverables'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Enter submission details for task evaluation.'.tr(context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'GitHub Repository Link'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: githubCon,
                    decoration: _buildInputDecoration(context, 'https://github.com/username/repo'),
                    validator: (v) => v == null || v.isEmpty ? 'GitHub link is required'.tr(context) : null,
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Pull Request Link'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: prCon,
                    decoration: _buildInputDecoration(context, 'https://github.com/username/repo/pull/1'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Submission Report Summary'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: reportCon,
                    maxLines: 3,
                    decoration: _buildInputDecoration(context, 'Describe what was accomplished...'),
                    validator: (v) => v == null || v.isEmpty ? 'Report is required'.tr(context) : null,
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel(context, 'Submission Notes / Comments'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: notesCon,
                    maxLines: 2,
                    decoration: _buildInputDecoration(context, 'Additional notes for reviewer...'),
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
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
                        child: ElevatedButton(
                          onPressed: () {
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Submit Task'.tr(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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

  void _showViewSubmissionDialog(BuildContext context, MockTask task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(32.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Submission Details'.tr(context),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Review deliverables submitted by the owner.'.tr(context),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                SizedBox(height: 20.h),

                _buildFieldLabel(context, 'GitHub Repository Link'),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    task.githubLink ?? 'No GitHub link provided.',
                    style: TextStyle(fontSize: 14.sp, color: task.githubLink != null ? Colors.blue : Colors.black87),
                  ),
                ),
                SizedBox(height: 20.h),

                _buildFieldLabel(context, 'Pull Request Link'),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    task.prLink ?? 'No PR link provided.',
                    style: TextStyle(fontSize: 14.sp, color: task.prLink != null ? Colors.blue : Colors.black87),
                  ),
                ),
                SizedBox(height: 20.h),

                _buildFieldLabel(context, 'Submission Report Summary'),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    task.submissionReport ?? 'No report summary provided.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 20.h),

                _buildFieldLabel(context, 'Submission Notes / Comments'),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    task.notes ?? 'No notes provided.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C81),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close'.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
}
