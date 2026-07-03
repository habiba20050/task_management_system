import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../models/unified_item.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  // Views
  String _selectedView = 'Table'; // 'Table' | 'Kanban' | 'Calendar'
  
  // Filters state
  String _searchQuery = '';
  String _selectedTeam = 'All';
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  // Helper mapping to unified interface for Tickets
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
        orElse: () => MockTeam(id: '', name: '', managerId: '', leaderId: '', memberIds: []),
      );
    }

    // Add Tickets
    for (final ticket in db.tickets) {
      final team = db.teams.firstWhere((t) => t.id == ticket.teamId, orElse: () => MockTeam(id: '', name: 'General', managerId: '', leaderId: '', memberIds: []));
      
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final role = authState is AuthSuccess ? authState.user.role : 'Team Member';
    final filteredItems = _getUnifiedTickets();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tickets Board',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Monitor, search and filter all active high-level tickets',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  if (role == 'Admin' || role == 'Manager' || role == 'Team Leader')
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
                          hintText: 'Search tickets...',
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
                  _buildDropdown('Status', _selectedStatus, ['All', 'Pending', 'In Progress', 'Completed'], (val) {
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
      return const Center(child: Text('No tickets matching criteria.'));
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
                DataColumn(label: Text('Team Associated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
              ],
              rows: items.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600))),
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
                      if (role == 'Manager' || role == 'Team Leader')
                        TextButton(
                          onPressed: () => _showUpdateStatusDialog(context, item.id),
                          child: const Text('Update Status'),
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
    final todo = items.where((i) => i.status == 'Pending' || i.status == 'NotAssigned').toList();
    final inProgress = items.where((i) => i.status == 'In Progress' || i.status == 'OnProgress').toList();
    final done = items.where((i) => i.status == 'Completed').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKanbanColumn('Pending / Todo', todo, Colors.blue)),
        SizedBox(width: 16.w),
        Expanded(child: _buildKanbanColumn('On Progress', inProgress, Colors.orange)),
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
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(item.teamName, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
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
          const Text('Weekly Ticket Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  void _showAddTicketDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'MEDIUM';
    String teamId = 't1'; // Software Engineering
    
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
                        status: 'Pending',
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

  void _showUpdateStatusDialog(BuildContext context, String ticketId) {
    String status = 'In Progress';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Update Ticket Status', style: TextStyle(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            initialValue: status,
            items: ['Pending', 'In Progress', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
