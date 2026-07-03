import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
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

    final projects = MockDatabase.instance.projects.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesPriority = _selectedPriorityFilter == 'All' || p.priority == _selectedPriorityFilter;
      return matchesSearch && matchesPriority;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
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
                      label: const Text('New Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
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
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF0F4C81)),
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
                            .map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(fontSize: 13.sp))))
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
                          childAspectRatio: 1.4,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          final leaderName = MockDatabase.instance.users
                              .firstWhere((u) => u.id == project.assignedLeaderId,
                                  orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''))
                              .fullName;

                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: project.priority == 'HIGH'
                                              ? const Color(0xFFFFECEB)
                                              : const Color(0xFFFFF9E6),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          project.priority,
                                          style: TextStyle(
                                            color: project.priority == 'HIGH'
                                                ? const Color(0xFFEB5757)
                                                : const Color(0xFFF2C94C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        project.status,
                                        style: TextStyle(
                                          color: project.status == 'Completed' ? Colors.green : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    project.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Expanded(
                                    child: Text(
                                      project.description,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12.sp, height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Leader: $leaderName',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                                      ),
                                      if (role == 'Manager')
                                        TextButton(
                                          onPressed: () => _showAssignLeaderDialog(context, project.id),
                                          child: const Text('Assign Leader'),
                                        ),
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
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'MEDIUM';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Project Name'),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: ['HIGH', 'MEDIUM', 'LOW']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => priority = val);
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    MockDatabase.instance.addProject(
                      MockProject(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        description: descCtrl.text,
                        startDate: '2026-07-03',
                        endDate: '2026-10-30',
                        priority: priority,
                        status: 'Pending',
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

  void _showAssignLeaderDialog(BuildContext context, String projectId) {
    final leaders = MockDatabase.instance.users.where((u) => u.role == 'Team Leader').toList();
    if (leaders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Team Leaders registered yet. Invite them in Users & Roles page.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Assign Team Leader', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300.w,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: leaders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return ListTile(
                title: Text(leader.fullName),
                subtitle: Text(leader.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() {
                    MockDatabase.instance.assignProject(projectId, leader.id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully assigned ${leader.fullName}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
