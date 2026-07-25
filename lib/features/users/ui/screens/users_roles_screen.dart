import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/network/mock_database.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../core/localization/translate_extension.dart';
import '../../../../core/styles/app_spacing.dart';
import '../../../../core/styles/app_radius.dart';
import '../../../../core/styles/app_shadow.dart';
import '../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../core/widgets/cards/app_cards.dart';

class UsersRolesScreen extends StatefulWidget {
  const UsersRolesScreen({super.key});

  @override
  State<UsersRolesScreen> createState() => _UsersRolesScreenState();
}

class _UsersRolesScreenState extends State<UsersRolesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Users'.tr(context)),
                  Tab(text: 'Departments'.tr(context)),
                  Tab(text: 'Roles'.tr(context)),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersTab(currentUserId),
                  _buildDepartmentsTab(currentUserId),
                  _buildRolesTab(currentUserId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= USERS TAB =================
  Widget _buildUsersTab(String currentUserId) {
    final db = MockDatabase.instance;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Management'.tr(context), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              PrimaryButton(
                text: 'Add User'.tr(context),
                onPressed: () => _showAddUserDialog(context, currentUserId),
                prefixIcon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name'.tr(context))),
                      DataColumn(label: Text('Email'.tr(context))),
                      DataColumn(label: Text('Phone'.tr(context))),
                      DataColumn(label: Text('Department'.tr(context))),
                      DataColumn(label: Text('Role'.tr(context))),
                      DataColumn(label: Text('Status'.tr(context))),
                      DataColumn(label: Text('Actions'.tr(context))),
                    ],
                    rows: db.users.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.fullName)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.phone)),
                        DataCell(Text(user.department.tr(context))),
                        DataCell(Text(user.role.tr(context))),
                        DataCell(Text(user.status.tr(context))),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 16), onPressed: () => _showEditUserDialog(context, user, currentUserId)),
                            IconButton(icon: const Icon(Icons.delete, color: AppColors.error, size: 16), onPressed: () {
                              setState(() {
                                db.deleteUser(user.id, currentUserId);
                              });
                            }),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final emailCon = TextEditingController();
    final phoneCon = TextEditingController();
    String dept = 'Computer Science';
    String role = 'Team Member';
    String status = 'Active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add User'.tr(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCon, decoration: InputDecoration(labelText: 'Name'.tr(context))),
              TextField(controller: emailCon, decoration: InputDecoration(labelText: 'Email'.tr(context))),
              TextField(controller: phoneCon, decoration: InputDecoration(labelText: 'Phone'.tr(context))),
              DropdownButtonFormField<String>(
                value: dept,
                decoration: InputDecoration(labelText: 'Department'.tr(context)),
                items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context)))).toList(),
                onChanged: (v) => setDialogState(() => dept = v!),
              ),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(labelText: 'Role'.tr(context)),
                items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context)))).toList(),
                onChanged: (v) => setDialogState(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
            ElevatedButton(
              onPressed: () {
                if (nameCon.text.isNotEmpty && emailCon.text.isNotEmpty) {
                  setState(() {
                    db.addUser(
                      MockUser(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        email: emailCon.text,
                        fullName: nameCon.text,
                        role: role,
                        department: dept,
                        phone: phoneCon.text,
                        status: status,
                      ),
                      adminId,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Create'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, MockUser user, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController(text: user.fullName);
    final phoneCon = TextEditingController(text: user.phone);
    String dept = user.department;
    String role = user.role;
    String status = user.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit User'.tr(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCon, decoration: InputDecoration(labelText: 'Name'.tr(context))),
              TextField(controller: phoneCon, decoration: InputDecoration(labelText: 'Phone'.tr(context))),
              DropdownButtonFormField<String>(
                value: dept,
                decoration: InputDecoration(labelText: 'Department'.tr(context)),
                items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context)))).toList(),
                onChanged: (v) => setDialogState(() => dept = v!),
              ),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(labelText: 'Role'.tr(context)),
                items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context)))).toList(),
                onChanged: (v) => setDialogState(() => role = v!),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status'.tr(context)),
                items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context)))).toList(),
                onChanged: (v) => setDialogState(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.editUser(
                    MockUser(
                      id: user.id,
                      email: user.email,
                      fullName: nameCon.text,
                      role: role,
                      department: dept,
                      phone: phoneCon.text,
                      status: status,
                    ),
                    adminId,
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Save'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DEPARTMENTS TAB =================
  Widget _buildDepartmentsTab(String currentUserId) {
    final db = MockDatabase.instance;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Department Configuration'.tr(context), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              PrimaryButton(
                text: 'Add Department'.tr(context),
                onPressed: () => _showAddDeptDialog(context, currentUserId),
                prefixIcon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name'.tr(context))),
                      DataColumn(label: Text('Code'.tr(context))),
                      DataColumn(label: Text('Description'.tr(context))),
                      DataColumn(label: Text('Manager'.tr(context))),
                      DataColumn(label: Text('Created Date'.tr(context))),
                      DataColumn(label: Text('Actions'.tr(context))),
                    ],
                    rows: db.departments.map((dept) {
                      final mgr = db.users.firstWhere((u) => u.id == dept.managerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''));
                      return DataRow(cells: [
                        DataCell(Text(dept.name)),
                        DataCell(Text(dept.code)),
                        DataCell(Text(dept.description)),
                        DataCell(Text(mgr.fullName)),
                        DataCell(Text(dept.createdDate)),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 16), onPressed: () => _showEditDeptDialog(context, dept, currentUserId)),
                            IconButton(icon: const Icon(Icons.delete, color: AppColors.error, size: 16), onPressed: () {
                              setState(() {
                                db.deleteDepartment(dept.id, currentUserId);
                              });
                            }),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAddDeptDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final codeCon = TextEditingController();
    final descCon = TextEditingController();
    String? managerId = db.users.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Department'.tr(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCon, decoration: InputDecoration(labelText: 'Name'.tr(context))),
              TextField(controller: codeCon, decoration: InputDecoration(labelText: 'Code'.tr(context))),
              TextField(controller: descCon, decoration: InputDecoration(labelText: 'Description'.tr(context))),
              DropdownButtonFormField<String>(
                value: managerId,
                decoration: InputDecoration(labelText: 'Manager'.tr(context)),
                items: db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                onChanged: (v) => setDialogState(() => managerId = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
            ElevatedButton(
              onPressed: () {
                if (nameCon.text.isNotEmpty && codeCon.text.isNotEmpty) {
                  setState(() {
                    db.addDepartment(
                      MockDepartment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCon.text,
                        code: codeCon.text,
                        description: descCon.text,
                        managerId: managerId ?? '',
                        createdDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      ),
                      adminId,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Create'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeptDialog(BuildContext context, MockDepartment dept, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController(text: dept.name);
    final codeCon = TextEditingController(text: dept.code);
    final descCon = TextEditingController(text: dept.description);
    String managerId = dept.managerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Department'.tr(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCon, decoration: InputDecoration(labelText: 'Name'.tr(context))),
              TextField(controller: codeCon, decoration: InputDecoration(labelText: 'Code'.tr(context))),
              TextField(controller: descCon, decoration: InputDecoration(labelText: 'Description'.tr(context))),
              DropdownButtonFormField<String>(
                value: managerId,
                decoration: InputDecoration(labelText: 'Manager'.tr(context)),
                items: db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
                onChanged: (v) => setDialogState(() => managerId = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.editDepartment(
                    MockDepartment(
                      id: dept.id,
                      name: nameCon.text,
                      code: codeCon.text,
                      description: descCon.text,
                      managerId: managerId,
                      createdDate: dept.createdDate,
                    ),
                    adminId,
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Save'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ROLES & PERMISSIONS TAB =================
  Widget _buildRolesTab(String currentUserId) {
    final db = MockDatabase.instance;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Role Authorization Policies'.tr(context), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              PrimaryButton(
                text: 'Add Role'.tr(context),
                onPressed: () => _showAddRoleDialog(context, currentUserId),
                prefixIcon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                itemCount: db.roles.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final role = db.roles[index];
                  final isSuperAdmin = role.name == 'Super Admin';
                  return ListTile(
                    title: Text(role.name.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(role.description.tr(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSuperAdmin) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4.r)),
                            child: Text('SYSTEM PROTECTED'.tr(context), style: TextStyle(color: Colors.blue, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                          )
                        ] else ...[
                          IconButton(icon: const Icon(Icons.security, color: Colors.green), onPressed: () => _showPermissionsDialog(context, role, currentUserId)),
                          IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: () {
                            try {
                              setState(() {
                                db.deleteRole(role.id, currentUserId);
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final descCon = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Role'.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCon, decoration: InputDecoration(labelText: 'Name'.tr(context))),
            TextField(controller: descCon, decoration: InputDecoration(labelText: 'Description'.tr(context))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
          ElevatedButton(
            onPressed: () {
              if (nameCon.text.isNotEmpty) {
                setState(() {
                  db.addRole(
                    MockRole(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCon.text,
                      description: descCon.text,
                      permissions: {},
                    ),
                    adminId,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text('Create'.tr(context)),
          ),
        ],
      ),
    );
  }

  // Permissions checkbox editor dialog
  void _showPermissionsDialog(BuildContext context, MockRole role, String adminId) {
    final db = MockDatabase.instance;

    final categories = {
      'Dashboard': ['View Dashboard'],
      'Tasks': ['View Tasks', 'Create Task', 'Edit Task', 'Delete Task', 'Assign Task', 'Reassign Task', 'Complete Task', 'View Task Details', 'View Task History', 'Comment On Task'],
      'Users': ['View Users', 'Add User', 'Edit User', 'Delete User'],
      'Departments': ['View Departments', 'Add Department', 'Edit Department', 'Delete Department'],
      'Teams': ['View Teams', 'Add Team', 'Edit Team', 'Delete Team'],
      'Reports': ['View Reports', 'Export Reports'],
      'Complaints': ['View Complaints', 'Reply', 'Close Complaint'],
      'Evaluations': ['View Evaluations', 'Add Evaluation', 'Edit Evaluation'],
      'Settings': ['Manage Roles', 'Manage Permissions', 'Manage System Settings'],
    };

    if (role.name == 'Super Admin') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Protected Role'.tr(context)),
          content: Text('Super Admin permissions are locked and cannot be modified.'.tr(context)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'.tr(context)))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Manage Permissions: '.tr(context) + role.name),
          content: SizedBox(
            width: 500.w,
            height: 500.h,
            child: ListView(
              children: categories.entries.map((cat) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.key.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.primary)),
                        const Divider(),
                        ...cat.value.map((permission) {
                          final isChecked = role.permissions[permission] ?? false;
                          return CheckboxListTile(
                            dense: true,
                            title: Text(permission.tr(context), style: TextStyle(fontSize: 11.sp)),
                            value: isChecked,
                            onChanged: (bool? val) {
                              setDialogState(() {
                                role.permissions[permission] = val ?? false;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'.tr(context))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.editRole(role, adminId);
                });
                Navigator.pop(context);
              },
              child: Text('Save Permissions'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}
