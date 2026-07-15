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
  // Tabs State: 'Tasks' | 'Tickets'
  String _currentTab = 'Tasks';
  
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

  // Fetch Tickets matching user role/team filters
  List<UnifiedItem> _getUnifiedTickets() {
    final db = MockDatabase.instance;
    final List<UnifiedItem> items = [];

    final authState = context.read<AuthCubit>().state;
    String userRole = 'Team Member';
    String userId = '';
    if (authState is AuthSuccess) {
      userRole = authState.user.role;
      userId = authState.user.id;
    }

    // Find the team for Leader / Member to filter
    MockTeam? userTeam;
    if (userRole == 'Team Member' || userRole == 'Team Leader') {
      userTeam = db.teams.firstWhere(
        (t) => t.memberIds.contains(userId) || t.leaderId == userId,
        orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
      );
    }

    for (final ticket in db.tickets) {
      final team = db.teams.firstWhere(
        (t) => t.id == ticket.teamId,
        orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: []),
      );
      
      // Role based visibility checks: only show tickets for the team the leader/member belongs to
      if ((userRole == 'Team Member' || userRole == 'Team Leader') && ticket.teamId != userTeam?.id) {
        continue;
      }

      items.add(
        UnifiedItem(
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          type: 'Ticket',
          priority: ticket.priority,
          status: ticket.status,
          deadline: ticket.deadline,
          teamName: team.name,
          assignedTo: 'Team Deliverable',
          originalObject: ticket,
        ),
      );
    }

    // Apply reactive filters
    return items.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTeam = _selectedTeam == 'All' || item.teamName == _selectedTeam;
      final matchesStatus = _selectedStatus == 'All' || item.status.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesPriority = _selectedPriority == 'All' || item.priority.toUpperCase() == _selectedPriority.toUpperCase();

      return matchesSearch && matchesTeam && matchesStatus && matchesPriority;
    }).toList();
  }

  // Fetch Tasks matching user role/team filters
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

    for (final task in db.tasks) {
      final user = db.users.firstWhere((u) => u.id == task.assignedMemberId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
      final team = db.teams.firstWhere((t) => t.memberIds.contains(task.assignedMemberId), orElse: () => MockTeam(id: '', name: 'General', managerId: '', department: '', leaderId: '', memberIds: []));
      
      // Role based visibility checks
      if (userRole == 'Team Member' && task.assignedMemberId != userId) {
        continue;
      }
      if (userRole == 'Team Leader') {
        final leaderTeam = db.teams.firstWhere((t) => t.leaderId == userId, orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []));
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
    
    final filteredItems = _currentTab == 'Tasks' ? _getUnifiedTasks() : _getUnifiedTickets();

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
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
                        _currentTab == 'Tasks' ? 'Tasks Board' : 'Tickets Board',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _currentTab == 'Tasks'
                            ? 'Monitor, search and filter all assigned task deliverables'
                            : 'Monitor, search and filter high-level team deliverables (Tickets)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                      SizedBox(width: 12.w),
                      if (_currentTab == 'Tasks' && (role == 'Admin' || role == 'Manager' || role == 'Team Leader'))
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
                      if (_currentTab == 'Tickets' && (role == 'Admin' || role == 'Manager' || role == 'Team Leader'))
                        ElevatedButton.icon(
                          onPressed: () => _showAddTicketDialog(context),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 2. Tasks / Tickets Tab Switcher
              Row(
                children: [
                  _buildTabButton('Tasks', _currentTab == 'Tasks'),
                  SizedBox(width: 12.w),
                  _buildTabButton('Tickets', _currentTab == 'Tickets'),
                ],
              ),
              SizedBox(height: 16.h),

              // 3. Filters Row
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
                          hintText: _currentTab == 'Tasks' ? 'Search tasks or assignees...' : 'Search tickets...',
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
                  _buildDropdown('Status', _selectedStatus, _currentTab == 'Tasks'
                      ? ['All', 'Pending', 'Assigned', 'In Progress', 'Submitted', 'Approved', 'Needs Changes', 'Rejected']
                      : ['All', 'Open', 'In Progress', 'Under Review', 'Completed'], (val) {
                    setState(() => _selectedStatus = val!);
                  }),
                  SizedBox(width: 12.w),

                  // Priority Dropdown
                  _buildDropdown('Priority', _selectedPriority, ['All', 'HIGH', 'MEDIUM', 'LOW'], (val) {
                    setState(() => _selectedPriority = val!);
                  }),
                ],
              ),
              SizedBox(height: 24.h),

              // 4. Render Selection View
              Expanded(
                child: _selectedView == 'Table'
                    ? _buildTableView(filteredItems, role)
                    : (_selectedView == 'Kanban' ? _buildKanbanView(filteredItems, role) : _buildCalendarView(filteredItems)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _currentTab = label;
        _selectedStatus = 'All';
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
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
      return Center(child: Text('No ${_currentTab.toLowerCase()} matching criteria.'));
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: const Color(0xFFE2E8F0)),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                  if (_currentTab == 'Tasks')
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
                    if (_currentTab == 'Tasks')
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
                        if (_currentTab == 'Tasks') ...[
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
                          if (item.status == 'Completed' || item.status == 'Approved' || item.status == 'Approved With Suggestions')
                            TextButton.icon(
                              onPressed: () => _showViewTaskSubmissionDialog(context, item.originalObject as MockTask),
                              icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.blue),
                              label: const Text('View', style: TextStyle(color: Colors.blue)),
                            ),
                        ] else ...[
                          if (role == 'Manager')
                            TextButton.icon(
                              onPressed: () => _showUpdateTicketStatusDialog(context, item.id),
                              icon: const Icon(Icons.edit_note, size: 14, color: Colors.orange),
                              label: const Text('Update Status', style: TextStyle(color: Colors.orange)),
                            )
                        ],
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. KANBAN VIEW ---
  Widget _buildKanbanView(List<UnifiedItem> items, String role) {
    final todo = items.where((i) => i.status == 'Todo' || i.status == 'Assigned' || i.status == 'Pending' || i.status == 'Open').toList();
    final inProgress = items.where((i) => i.status == 'In Progress' || i.status == 'Needs Changes').toList();
    final underReview = items.where((i) => i.status == 'Submitted' || i.status == 'Under Review').toList();
    final done = items.where((i) => i.status == 'Approved' || i.status == 'Completed').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKanbanColumn('To Do', todo, Colors.blue, role)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('In Progress', inProgress, Colors.orange, role)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('Under Review', underReview, Colors.purple, role)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('Completed', done, Colors.green, role)),
      ],
    );
  }

  Widget _buildKanbanColumn(String title, List<UnifiedItem> items, Color headerColor, String role) {
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
                return GestureDetector(
                  onTap: () {
                    if (item.type == 'Task' && (item.status == 'Completed' || item.status == 'Approved')) {
                      _showViewTaskSubmissionDialog(context, item.originalObject as MockTask);
                    }
                  },
                  child: Card(
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
                          if (item.type == 'Ticket' && role == 'Manager') ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showUpdateTicketStatusDialog(context, item.id),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                                child: const Text('Update Status', style: TextStyle(fontSize: 11, color: Colors.orange)),
                              ),
                            )
                          ]
                        ],
                      ),
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

  // --- VIEW SUBMISSION DIALOG ---
  void _showViewTaskSubmissionDialog(BuildContext context, MockTask task) {
    showDialog(
      context: context,
      builder: (context) {
        final db = MockDatabase.instance;
        final assignee = db.users.firstWhere((u) => u.id == task.assignedMemberId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('View Task: ${task.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500.w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Assignee:', assignee.fullName),
                  _buildDetailRow('Status:', task.status),
                  _buildDetailRow('Priority:', task.priority),
                  _buildDetailRow('Deadline:', task.deadline),
                  _buildDetailRow('Estimated Hours:', '${task.estimatedHours} hrs'),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(task.description),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Submission Deliverables:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Report Title:', task.submissionReport ?? 'None'),
                  _buildDetailRow('Notes:', task.notes ?? 'None'),
                  _buildLinkRow('GitHub Repository:', task.githubLink),
                  _buildLinkRow('Pull Request:', task.prLink),
                  if (task.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Uploaded Files:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ...task.attachments.map((file) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(file, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: url != null && url.isNotEmpty
                ? Text(url, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
                : const Text('None', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // --- TICKET UPDATE STATUS DIALOG ---
  void _showUpdateTicketStatusDialog(BuildContext context, String ticketId) {
    final db = MockDatabase.instance;
    final ticket = db.tickets.firstWhere((t) => t.id == ticketId);
    String status = ticket.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Update Ticket Status', style: TextStyle(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            value: status,
            items: ['Open', 'In Progress', 'Under Review', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setDialogState(() => status = val!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  MockDatabase.instance.updateTicketStatus(ticketId, status);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ticket status updated to $status')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // --- TICKET ADD DIALOG ---
  void _showAddTicketDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'MEDIUM';
    String teamId = 't1';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Ticket Title')),
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
                  initialValue: teamId,
                  decoration: const InputDecoration(labelText: 'Assign Team'),
                  items: MockDatabase.instance.teams
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => teamId = val!),
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
                    MockDatabase.instance.addTicket(
                      MockTicket(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descController.text,
                        priority: priority,
                        deadline: '2026-07-25',
                        teamId: teamId,
                        status: 'Open',
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

  // --- TASK ADD DIALOG ---
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
