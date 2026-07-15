import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriorityFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final role = authState is AuthSuccess ? authState.user.role : 'Team Member';
    final currentUserId = authState is AuthSuccess ? authState.user.id : '';

    final db = MockDatabase.instance;

    // Find the team for Leader / Member to filter
    MockTeam? currentUserTeam;
    if (role == 'Team Member' || role == 'Team Leader') {
      currentUserTeam = db.teams.firstWhere(
        (t) => t.memberIds.contains(currentUserId) || t.leaderId == currentUserId,
        orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
      );
    }

    final projects = db.projects.where((p) {
      // 1. Role-based visibility
      if (role == 'Manager' && p.managerId != currentUserId) {
        return false;
      }
      if ((role == 'Team Member' || role == 'Team Leader') &&
          (currentUserTeam == null || !p.assignedTeamIds.contains(currentUserTeam.id))) {
        return false;
      }

      // 2. Filter search and priority
      final matchesSearch =
          p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesPriority =
          _selectedPriorityFilter == 'All' || p.priority == _selectedPriorityFilter;

      return matchesSearch && matchesPriority;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projects Portfolio',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Create and monitor university project developments',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  if (role == 'Admin' || role == 'Manager')
                    ElevatedButton.icon(
                      onPressed: () => _showCreateProjectDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'New Project',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),

              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search projects by name, description...',
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
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPriorityFilter,
                        items: ['All', 'HIGH', 'MEDIUM', 'LOW']
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p, style: TextStyle(fontSize: 13.sp)),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPriorityFilter = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Projects Grid
              Expanded(
                child: projects.isEmpty
                    ? const Center(child: Text('No projects found.'))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 1,
                          crossAxisSpacing: 24.w,
                          mainAxisSpacing: 24.h,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          
                          // Fetch Manager Name
                          final managerName = db.users.firstWhere(
                            (u) => u.id == project.managerId,
                            orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned Manager', role: '', department: ''),
                          ).fullName;

                          // Fetch assigned teams objects
                          final teams = db.teams.where((t) => project.assignedTeamIds.contains(t.id)).toList();

                          return GestureDetector(
                            onTap: () => _showProjectDetailsDialog(context, project, role),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Stack(
                                  children: [
                                    // Colored accent line indicating priority
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 5.w,
                                        color: project.priority == 'HIGH'
                                            ? const Color(0xFFEB5757)
                                            : (project.priority == 'MEDIUM' ? const Color(0xFFF2C94C) : const Color(0xFF27AE60)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 16.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                                radius: 20.r,
                                                child: Icon(Icons.folder_open_rounded, color: AppColors.primary, size: 20.sp),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      project.name,
                                                      style: TextStyle(
                                                        color: AppColors.textPrimary,
                                                        fontSize: 15.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.person_outline, size: 12.sp, color: Colors.grey[500]),
                                                        SizedBox(width: 4.w),
                                                        Text(
                                                          'Mgr: $managerName',
                                                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),
                                          Expanded(
                                            child: Text(
                                              project.description,
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp, height: 1.4),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today_outlined, size: 11.sp, color: Colors.grey[500]),
                                              SizedBox(width: 4.w),
                                              Text(
                                                '${project.startDate} to ${project.endDate}',
                                                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: teams.map((t) {
                                                      return Container(
                                                        margin: EdgeInsets.only(right: 6.w),
                                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFEFF6FF),
                                                          borderRadius: BorderRadius.circular(6.r),
                                                        ),
                                                        child: Text(
                                                          t.name,
                                                          style: TextStyle(
                                                            color: const Color(0xFF0F4C81),
                                                            fontSize: 9.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: project.status == 'Completed' ? const Color(0xFFE6F9EE) : const Color(0xFFE8F0FE),
                                                  borderRadius: BorderRadius.circular(6.r),
                                                ),
                                                child: Text(
                                                  project.status,
                                                  style: TextStyle(
                                                    color: project.status == 'Completed' ? Colors.green : Colors.blue,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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
        ),
      ),
    );
  }

  void _showMockFilePickerDialog(BuildContext context, Function(List<String>) onPicked) {
    final List<String> mockFiles = [
      'aitu_portal_specifications.pdf',
      'system_architecture_diagram.png',
      'database_schema_v2.sql',
      'ui_ux_prototype_links.fig',
      'graduation_project_draft.docx',
      'sensor_calibration_script.py',
    ];
    List<String> tempPicked = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Select Mock Upload Attachments', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 350.w,
            child: ListView(
              shrinkWrap: true,
              children: mockFiles.map((file) {
                final isChecked = tempPicked.contains(file);
                return CheckboxListTile(
                  title: Text(file, style: const TextStyle(fontSize: 13)),
                  value: isChecked,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setDialogState(() {
                      if (val == true) {
                        tempPicked.add(file);
                      } else {
                        tempPicked.remove(file);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                onPicked(tempPicked);
                Navigator.pop(context);
              },
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final linksCtrl = TextEditingController();
    String priority = 'MEDIUM';
    
    final db = MockDatabase.instance;
    final managers = db.users.where((u) => u.role == 'Manager').toList();
    final teams = db.teams;

    String? selectedManagerId = managers.isNotEmpty ? managers.first.id : null;
    List<String> selectedTeamIds = [];
    List<String> selectedFiles = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Project Name')),
                  SizedBox(height: 12.h),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  SizedBox(height: 16.h),
                  
                  // Manager Selector
                  const Text('Assign Project Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  DropdownButtonFormField<String>(
                    value: selectedManagerId,
                    items: managers
                        .map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedManagerId = val),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
                  ),
                  SizedBox(height: 16.h),

                  // Teams Selector
                  const Text('Select Working Teams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    height: 130,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: teams.map((team) {
                        final isChecked = selectedTeamIds.contains(team.id);
                        return CheckboxListTile(
                          title: Text(team.name, style: const TextStyle(fontSize: 13)),
                          value: isChecked,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedTeamIds.add(team.id);
                              } else {
                                selectedTeamIds.remove(team.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setDialogState(() => priority = val!),
                  ),
                  SizedBox(height: 16.h),
                  
                  TextField(controller: linksCtrl, decoration: const InputDecoration(labelText: 'Links (Optional, comma-separated)')),
                  SizedBox(height: 16.h),
                  
                  // Interactive Visual Mock File Picker
                  const Text('Attach Project Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () {
                      _showMockFilePickerDialog(context, (picked) {
                        setDialogState(() {
                          selectedFiles.addAll(picked);
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 36.sp, color: AppColors.primary),
                          SizedBox(height: 8.h),
                          Text(
                            'Click to browse mock files',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.primary),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Supports PDF, PNG, SQL, DOCX up to 50MB',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedFiles.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: selectedFiles.map((file) {
                        return Chip(
                          label: Text(file, style: TextStyle(fontSize: 10.sp)),
                          deleteIcon: Icon(Icons.close, size: 12.sp),
                          onDeleted: () {
                            setDialogState(() {
                              selectedFiles.remove(file);
                            });
                          },
                          backgroundColor: const Color(0xFFF1F5F9),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && selectedManagerId != null) {
                  if (selectedTeamIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one team.')));
                    return;
                  }
                  
                  final links = linksCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                  setState(() {
                    MockDatabase.instance.addProject(
                      MockProject(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        description: descCtrl.text,
                        startDate: '2026-07-15',
                        endDate: '2026-11-30',
                        priority: priority,
                        status: 'Pending',
                        managerId: selectedManagerId,
                        assignedTeamIds: selectedTeamIds,
                        projectLinks: links,
                        projectFiles: selectedFiles,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetailsDialog(BuildContext context, MockProject project, String role) {
    final db = MockDatabase.instance;
    
    // Fetch manager details
    final manager = db.users.firstWhere((u) => u.id == project.managerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
    
    // Fetch assigned teams
    final teams = db.teams.where((t) => project.assignedTeamIds.contains(t.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 550.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('Manager:', manager.fullName),
                _buildInfoRow('Priority:', project.priority),
                _buildInfoRow('Status:', project.status),
                _buildInfoRow('Duration:', '${project.startDate} to ${project.endDate}'),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(project.description),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Assigned Teams:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ...teams.map((t) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('- ${t.name} (Leader: ${db.users.firstWhere((u) => u.id == t.leaderId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: '')).fullName})'),
                )),
                if (project.projectLinks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Links:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ...project.projectLinks.map((link) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(link, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  )),
                ],
                if (project.projectFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Attached Files:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ...project.projectFiles.map((file) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(file, style: const TextStyle(color: Colors.blue)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (role == 'Manager')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDivideTasksDialog(context, project, teams);
              },
              child: const Text('Divide Tasks (Create Tickets)'),
            ),
          if (role == 'Team Leader')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDivideTicketsIntoTasksDialog(context, project);
              },
              child: const Text('Divide Tickets into Tasks'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(val, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  // MANAGER DIVISION: Create tickets for Team Leaders of chosen teams
  void _showDivideTasksDialog(BuildContext context, MockProject project, List<MockTeam> teams) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'MEDIUM';
    String selectedTeamId = teams.isNotEmpty ? teams.first.id : 't1';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Create Deliverable (Ticket) for: ${project.name}'),
          content: SizedBox(
            width: 400.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTeamId,
                  decoration: const InputDecoration(labelText: 'Assign to Team'),
                  items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setDialogState(() => selectedTeamId = val!),
                ),
                SizedBox(height: 12.h),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Ticket Title')),
                SizedBox(height: 12.h),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Requirement'), maxLines: 3),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  MockDatabase.instance.addTicket(
                    MockTicket(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      priority: priority,
                      deadline: project.endDate,
                      teamId: selectedTeamId,
                      status: 'Open',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket created and assigned successfully.')),
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  // LEADER DIVISION: View assigned tickets and split them into member tasks
  void _showDivideTicketsIntoTasksDialog(BuildContext context, MockProject project) {
    final db = MockDatabase.instance;
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '';

    // Find leader's team
    final team = db.teams.firstWhere(
      (t) => t.leaderId == currentUserId,
      orElse: () => MockTeam(id: '', name: '', managerId: '', department: '', leaderId: '', memberIds: []),
    );

    if (team.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are not currently leading a team.')));
      return;
    }

    // Find open/active tickets for this team
    final tickets = db.tickets.where((t) => t.teamId == team.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Split Team Tickets: ${team.name}'),
        content: SizedBox(
          width: 450.w,
          child: tickets.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No active tickets assigned to your team yet.'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return ListTile(
                      title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreateSubTaskDialog(context, ticket, team);
                        },
                        child: const Text('Split & Assign'),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showCreateSubTaskDialog(BuildContext context, MockTicket ticket, MockTeam team) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'MEDIUM';
    
    final db = MockDatabase.instance;
    final teamMembers = db.users.where((u) => team.memberIds.contains(u.id)).toList();
    
    if (teamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No team members found to assign tasks to.')));
      return;
    }

    String selectedMemberId = teamMembers.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Assign Sub-Task for: ${ticket.title}'),
          content: SizedBox(
            width: 400.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMemberId,
                  decoration: const InputDecoration(labelText: 'Assign to Member'),
                  items: teamMembers.map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))).toList(),
                  onChanged: (val) => setDialogState(() => selectedMemberId = val!),
                ),
                SizedBox(height: 12.h),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Sub-Task Title')),
                SizedBox(height: 12.h),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Task Details'), maxLines: 3),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['HIGH', 'MEDIUM', 'LOW'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  db.addTask(
                    MockTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      ticketId: ticket.id,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      assignedMemberId: selectedMemberId,
                      deadline: ticket.deadline,
                      estimatedHours: 8,
                      priority: priority,
                      status: 'Assigned',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task assigned to member successfully.')),
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}
