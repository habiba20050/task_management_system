import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../models/unified_item.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Views
  String _selectedView = 'Table'; // 'Table' | 'Kanban' | 'Calendar'
  
  // Filters state
  String _searchQuery = '';
  String _selectedTeam = 'All';
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  // Submissions Controller
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

  // Helper mapping to unified interface for Tasks
  List<UnifiedItem> _getUnifiedTasks() {
    final db = MockDatabase.instance;
    final List<UnifiedItem> items = [];

    final authState = context.read<AuthCubit>().state;
    String userRole = 'Team Member';
    String userId = '';
    if (authState is AuthSuccess) {
      userRole = authState.user.role;
      userId = authState.user.id;
    }

    // Add Tasks
    for (final task in db.tasks) {
      final user = db.users.firstWhere((u) => u.id == task.assignedMemberId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
      final team = db.teams.firstWhere((t) => t.memberIds.contains(task.assignedMemberId), orElse: () => MockTeam(id: '', name: 'General', managerId: '', leaderId: '', memberIds: []));
      
      // Role based visibility checks
      if (userRole == 'Team Member' && task.assignedMemberId != userId) {
        continue;
      }
      if (userRole == 'Team Leader') {
        final leaderTeam = db.teams.firstWhere((t) => t.leaderId == userId, orElse: () => MockTeam(id: '', name: '', managerId: '', leaderId: '', memberIds: []));
        if (!leaderTeam.memberIds.contains(task.assignedMemberId) && task.assignedMemberId != userId) {
          continue;
        }
      }

      items.add(
        UnifiedItem(
          id: task.id,
          title: task.title,
          description: task.description,
          type: 'Task',
          priority: task.priority,
          status: task.status,
          deadline: task.deadline,
          teamName: team.name,
          assignedTo: user.fullName,
          originalObject: task,
        ),
      );
    }

    // Apply reactive filters
    return items.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTeam = _selectedTeam == 'All' || item.teamName == _selectedTeam;
      final matchesStatus = _selectedStatus == 'All' || item.status.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesPriority = _selectedPriority == 'All' || item.priority.toUpperCase() == _selectedPriority.toUpperCase();

      return matchesSearch && matchesTeam && matchesStatus && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final role = authState is AuthSuccess ? authState.user.role : 'Team Member';
    final filteredItems = _getUnifiedTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Header & Creation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks Board',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Monitor, search and filter all assigned task deliverables',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  if (role == 'Admin' || role == 'Manager' || role == 'Team Leader')
                    ElevatedButton.icon(
                      onPressed: () => _showAddTaskDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. Filters & View Switcher Row
              Row(
                children: [
                  // Live Search Field
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search tasks or assignees...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Team Dropdown (Visible only for Admin & Manager)
                  if (role == 'Admin' || role == 'Manager') ...[
                    _buildDropdown('Team', _selectedTeam, ['All', 'Software Engineering Team', 'IT Infrastructure Team', 'Finance Management'], (val) {
                      setState(() => _selectedTeam = val!);
                    }),
                    SizedBox(width: 12.w),
                  ],

                  // Status Dropdown
                  _buildDropdown('Status', _selectedStatus, ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Approved', 'Needs Changes', 'Rejected'], (val) {
                    setState(() => _selectedStatus = val!);
                  }),
                  SizedBox(width: 12.w),

                  // Priority Dropdown
                  _buildDropdown('Priority', _selectedPriority, ['All', 'HIGH', 'MEDIUM', 'LOW'], (val) {
                    setState(() => _selectedPriority = val!);
                  }),
                  SizedBox(width: 16.w),

                  // View Toggle Switcher (Table / Kanban / Calendar)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: ['Table', 'Kanban', 'Calendar'].map((view) {
                        final isSelected = _selectedView == view;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedView = view),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              view,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 3. Render Selection View
              Expanded(
                child: _selectedView == 'Table'
                    ? _buildTableView(filteredItems, role)
                    : (_selectedView == 'Kanban' ? _buildKanbanView(filteredItems) : _buildCalendarView(filteredItems)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 12.sp))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- 1. TABLE VIEW ---
  Widget _buildTableView(List<UnifiedItem> items, String role) {
    if (items.isEmpty) {
      return const Center(child: Text('No tasks matching criteria.'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: const Color(0xFFE2E8F0)),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Assignee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Team / Dept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
              ],
              rows: items.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(item.assignedTo)),
                  DataCell(Text(item.teamName)),
                  DataCell(Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: item.priority == 'HIGH' ? const Color(0xFFFFECEB) : const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.priority,
                      style: TextStyle(
                        color: item.priority == 'HIGH' ? const Color(0xFFEB5757) : const Color(0xFFF2C94C),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  DataCell(Text(item.status, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(item.deadline)),
                  DataCell(Row(
                    children: [
                      if (role == 'Team Member' && item.status != 'Approved' && item.status != 'Completed' && item.status != 'Submitted')
                        TextButton.icon(
                          onPressed: () => _showSubmissionDialog(context, item.id),
                          icon: const Icon(Icons.upload_file, size: 14),
                          label: const Text('Submit Work'),
                        ),
                      if ((role == 'Team Leader' || role == 'Manager') && item.status == 'Submitted')
                        TextButton(
                          onPressed: () => context.go('/review-center'),
                          child: const Text('Review', style: TextStyle(color: Colors.orange)),
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

  // --- 2. KANBAN VIEW ---
  Widget _buildKanbanView(List<UnifiedItem> items) {
    final todo = items.where((i) => i.status == 'Todo' || i.status == 'Assigned' || i.status == 'Pending').toList();
    final inProgress = items.where((i) => i.status == 'In Progress' || i.status == 'Needs Changes').toList();
    final underReview = items.where((i) => i.status == 'Submitted' || i.status == 'Under Review').toList();
    final done = items.where((i) => i.status == 'Approved' || i.status == 'Completed').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKanbanColumn('To Do', todo, Colors.blue)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('In Progress', inProgress, Colors.orange)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('Under Review', underReview, Colors.purple)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('Completed', done, Colors.green)),
      ],
    );
  }

  Widget _buildKanbanColumn(String title, List<UnifiedItem> items, Color headerColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8.w, height: 8.h, decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10.r)),
                child: Text(items.length.toString(), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(item.assignedTo, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.green)),
                            ),
                            Text(item.deadline, style: TextStyle(fontSize: 10.sp, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. CALENDAR VIEW ---
  Widget _buildCalendarView(List<UnifiedItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Schedule View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day) {
                final dayItems = items.where((i) {
                  return i.id.hashCode % 5 == ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].indexOf(day);
                }).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12.sp)),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: dayItems.length,
                          itemBuilder: (context, index) {
                            final item = dayItems[index];
                            return Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Text(item.title, style: TextStyle(fontSize: 11.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS ---
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'MEDIUM';
    String memberId = '4'; // Default member Sarah
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title')),
                SizedBox(height: 12.h),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: memberId,
                  decoration: const InputDecoration(labelText: 'Assign Member'),
                  items: MockDatabase.instance.users
                      .where((u) => u.role == 'Team Member')
                      .map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => memberId = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    MockDatabase.instance.addTask(
                      MockTask(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        ticketId: 'tic1',
                        title: titleController.text,
                        description: descController.text,
                        assignedMemberId: memberId,
                        deadline: '2026-07-20',
                        estimatedHours: 4,
                        priority: priority,
                        status: 'Assigned',
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmissionDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Submit Deliverables', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _submitTitleController, decoration: const InputDecoration(labelText: 'Report Title / Subject')),
              SizedBox(height: 12.h),
              TextField(controller: _submitDescController, decoration: const InputDecoration(labelText: 'Completion Notes'), maxLines: 3),
              SizedBox(height: 12.h),
              TextField(controller: _githubController, decoration: const InputDecoration(labelText: 'GitHub Repository URL')),
              SizedBox(height: 12.h),
              TextField(controller: _prController, decoration: const InputDecoration(labelText: 'Pull Request URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_submitTitleController.text.isNotEmpty) {
                setState(() {
                  MockDatabase.instance.submitTask(
                    taskId: taskId,
                    githubLink: _githubController.text,
                    prLink: _prController.text,
                    notes: _submitDescController.text,
                    report: _submitTitleController.text,
                  );
                });
                _submitTitleController.clear();
                _submitDescController.clear();
                _githubController.clear();
                _prController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deliverables submitted successfully!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
