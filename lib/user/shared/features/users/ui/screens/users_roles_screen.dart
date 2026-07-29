import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../core/network/mock_database.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/widgets/cards/app_cards.dart';
import '../../../../../../core/styles/app_shadow.dart';
import '../../../../../../responsive/responsive_layout.dart';

class UsersRolesScreen extends StatefulWidget {
  const UsersRolesScreen({super.key});

  @override
  State<UsersRolesScreen> createState() => _UsersRolesScreenState();
}

class _UsersRolesScreenState extends State<UsersRolesScreen> {
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedRoleFilter = 'All';
  bool _showUsersView = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showUsersView ? 'User Directory'.tr(context) : 'Role & Authorization Portal'.tr(context),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _showUsersView
                            ? 'Configure and manage university personnel access details'.tr(context)
                            : 'Define system authorization rules and security policies'.tr(context),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_showUsersView) {
                        _showAddUserDialog(context, currentUserId);
                      } else {
                        _showAddRoleDialog(context, currentUserId);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: Text(
                      _showUsersView ? 'Add User'.tr(context) : 'Add Role'.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Segmented Toggle Button
              Row(
                children: [
                  _buildSegmentButton(
                    label: 'Users'.tr(context),
                    isSelected: _showUsersView,
                    onTap: () => setState(() => _showUsersView = true),
                  ),
                  SizedBox(width: 12.w),
                  _buildSegmentButton(
                    label: 'Roles'.tr(context),
                    isSelected: !_showUsersView,
                    onTap: () => setState(() => _showUsersView = false),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. Search & Filters Row
              if (_showUsersView) ...[
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
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search users by name or email...'.tr(context),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13.sp,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
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
                          value: _selectedDept,
                          items: [
                            'All',
                            'Computer Science',
                            'Engineering',
                            'IT Services',
                          ].map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(
                                dept.tr(context),
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ),
                          ).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDept = val;
                              });
                            }
                          },
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
                          value: _selectedRoleFilter,
                          items: [
                            'All',
                            'Admin',
                            'Manager',
                            'Team Leader',
                            'Team Member',
                          ].map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.tr(context),
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ),
                          ).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRoleFilter = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ] else ...[
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
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search roles by name...'.tr(context),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13.sp,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],

              // 3. Stat Cards Section
              if (_showUsersView)
                _buildStatsRow(
                  context,
                  [
                    _buildStatWidget(
                      'Total Users',
                      db.users.length.toString(),
                      Icons.people_outline,
                      Colors.blue,
                    ),
                    _buildStatWidget(
                      'Active Profiles',
                      db.users.where((u) => u.status == 'Active').length.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    _buildStatWidget(
                      'Admins & Managers',
                      db.users.where((u) => u.role == 'Admin' || u.role == 'Manager').length.toString(),
                      Icons.admin_panel_settings_outlined,
                      Colors.purple,
                    ),
                  ],
                )
              else
                _buildStatsRow(
                  context,
                  [
                    _buildStatWidget(
                      'Total Roles',
                      db.roles.length.toString(),
                      Icons.security,
                      Colors.blue,
                    ),
                    _buildStatWidget(
                      'System Protected',
                      '1',
                      Icons.lock_outline,
                      Colors.orange,
                    ),
                  ],
                ),
              SizedBox(height: 24.h),

              // 4. Content Area
              Expanded(
                child: _showUsersView
                    ? _buildUsersTable(context, currentUserId)
                    : _buildRolesView(context, currentUserId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
          boxShadow: isSelected ? AppShadow.soft : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildStatWidget(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      height: 76.h,
      child: StatCard(
        title: label.tr(context),
        value: value,
        icon: icon,
        accentColor: color,
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<Widget> cards) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    if (isDesktop || isTablet) {
      return Row(
        children: [
          Expanded(child: cards.isNotEmpty ? cards[0] : const SizedBox.shrink()),
          SizedBox(width: 16.w),
          Expanded(child: cards.length > 1 ? cards[1] : const SizedBox.shrink()),
          SizedBox(width: 16.w),
          Expanded(child: cards.length > 2 ? cards[2] : const SizedBox.shrink()),
        ],
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SizedBox(width: double.infinity, child: c),
        )).toList(),
      );
    }
  }

  Widget _buildUsersTable(BuildContext context, String currentUserId) {
    final db = MockDatabase.instance;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final filtered = db.users.where((u) {
      final matchesSearch = u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDept == 'All' || u.department == _selectedDept;
      final matchesRole = _selectedRoleFilter == 'All' || u.role == _selectedRoleFilter;
      return matchesSearch && matchesDept && matchesRole;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No users found matching search criteria.'.tr(context),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUsersTableHeader(context),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildUsersTableRow(context, filtered[index], currentUserId, db),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, idx) {
          final user = filtered[idx];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            child: ListTile(
              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user.role.tr(context)} | ${user.department.tr(context)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditUserDialog(context, user, currentUserId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        db.deleteUser(user.id, currentUserId);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildUsersTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Name'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 3, child: Text('Email'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Phone'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Department'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Role'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Status'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildUsersTableRow(BuildContext context, MockUser user, String currentUserId, MockDatabase db) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(user.email, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(user.phone, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(user.department.tr(context), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(user.role.tr(context), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: user.status == 'Active' ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  user.status.tr(context),
                  style: TextStyle(
                    color: user.status == 'Active' ? Colors.green : Colors.red,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  onPressed: () => _showEditUserDialog(context, user, currentUserId),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                  onPressed: () {
                    setState(() {
                      db.deleteUser(user.id, currentUserId);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.tr(context),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
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
                            'Add User'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Register a new system user profile.'.tr(context),
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

                  _buildFieldLabel('Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildInputDecoration('Enter full name...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Email'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: emailCon,
                    decoration: _buildInputDecoration('e.g. user@aitu.edu'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Phone'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: phoneCon,
                    decoration: _buildInputDecoration('e.g. +201012345678'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Department'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: dept,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => dept = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Role'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: role,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => role = v!),
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
                            'Edit User'.tr(context),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Update system user profile attributes.'.tr(context),
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

                  _buildFieldLabel('Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildInputDecoration('Enter full name...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Phone'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: phoneCon,
                    decoration: _buildInputDecoration('e.g. +201012345678'),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Department'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: dept,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Computer Science', 'Engineering', 'IT Services'].map((d) => DropdownMenuItem(value: d, child: Text(d.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => dept = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Role'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: role,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r.tr(context)))).toList(),
                    onChanged: (v) => setDialogState(() => role = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildFieldLabel('Status'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: status,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildInputDecoration(''),
                    items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s.tr(context)))).toList(),
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



  Widget _buildRolesView(BuildContext context, String currentUserId) {
    final db = MockDatabase.instance;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    final filtered = db.roles.where((r) {
      final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No roles found matching search criteria.'.tr(context),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRolesTableHeader(context),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildRolesTableRow(context, filtered[index], currentUserId, db),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, idx) {
          final role = filtered[idx];
          final isSuperAdmin = role.name == 'Super Admin';
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            child: ListTile(
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
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showPermissionsDialog(context, role, currentUserId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        try {
                          setState(() {
                            db.deleteRole(role.id, currentUserId);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildRolesTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Role Name'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 6, child: Text('Description'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 3, child: Text('Status'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRolesTableRow(BuildContext context, MockRole role, String currentUserId, MockDatabase db) {
    final isSuperAdmin = role.name == 'Super Admin';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(role.name.tr(context), style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 6, child: Text(role.description.tr(context), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: isSuperAdmin
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4.r)),
                      child: Text('SYSTEM PROTECTED'.tr(context), style: TextStyle(color: Colors.blue, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4.r)),
                      child: Text('ACTIVE'.tr(context), style: TextStyle(color: Colors.green, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isSuperAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                    onPressed: () => _showPermissionsDialog(context, role, currentUserId),
                    tooltip: 'Edit Permissions'.tr(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                    onPressed: () {
                      try {
                        setState(() {
                          db.deleteRole(role.id, currentUserId);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    tooltip: 'Delete Role'.tr(context),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey, size: 18),
                    onPressed: () => _showPermissionsDialog(context, role, currentUserId),
                    tooltip: 'View Permissions'.tr(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final descCon = TextEditingController();
    final Map<String, bool> selectedPermissions = {};

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

    for (var perms in categories.values) {
      for (var p in perms) {
        selectedPermissions[p] = false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 550.w,
            height: 650.h,
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Role'.tr(context),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Create a custom access authorization role with permissions.'.tr(context),
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
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView(
                    children: [
                      _buildFieldLabel('Name'),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: nameCon,
                        decoration: _buildInputDecoration('Enter role name...'),
                      ),
                      SizedBox(height: 20.h),

                      _buildFieldLabel('Description'),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: descCon,
                        decoration: _buildInputDecoration('Enter role description...'),
                      ),
                      SizedBox(height: 24.h),

                      Text(
                        'Select Permissions'.tr(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...categories.entries.map((cat) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6.h),
                          color: const Color(0xFFEDF2F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.key.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.primary)),
                                const Divider(),
                                ...cat.value.map((permission) {
                                  final isChecked = selectedPermissions[permission] ?? false;
                                  return CheckboxListTile(
                                    dense: true,
                                    title: Text(permission.tr(context), style: TextStyle(fontSize: 12.sp)),
                                    value: isChecked,
                                    activeColor: const Color(0xFF0F4C81),
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (bool? val) {
                                      setDialogState(() {
                                        selectedPermissions[permission] = val ?? false;
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
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
                          if (nameCon.text.isNotEmpty) {
                            setState(() {
                              db.addRole(
                                MockRole(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: nameCon.text,
                                  description: descCon.text,
                                  permissions: Map<String, bool>.from(selectedPermissions),
                                ),
                                adminId,
                              );
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
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Protected Role'.tr(context),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
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
                Text(
                  'Super Admin permissions are locked and cannot be modified.'.tr(context),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C81),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Close'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          child: Container(
            width: 550.w,
            height: 600.h,
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Permissions'.tr(context),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${role.name} - ' + 'Authorization Policies'.tr(context),
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
                Expanded(
                  child: ListView(
                    children: categories.entries.map((cat) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        color: const Color(0xFFEDF2F7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat.key.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.primary)),
                              const Divider(),
                              ...cat.value.map((permission) {
                                final isChecked = role.permissions[permission] ?? false;
                                return CheckboxListTile(
                                  dense: true,
                                  title: Text(permission.tr(context), style: TextStyle(fontSize: 12.sp)),
                                  value: isChecked,
                                  activeColor: const Color(0xFF0F4C81),
                                  contentPadding: EdgeInsets.zero,
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
                          setState(() {
                            db.editRole(role, adminId);
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
                          'Save Permissions'.tr(context),
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
    );
  }
}
