import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../../core/widgets/cards/app_cards.dart';
import 'package:task_management_system/widgets/custom_button.dart';
import 'package:task_management_system/widgets/notification_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  
  String _selectedRoleFilter = 'All'; // 'All' | 'Admin' | 'Manager' | 'Member'

  List<MockUser> get _users => MockDatabase.instance.users;

  @override
  void dispose() {
    _searchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      endDrawer: const NotificationDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.w : 16.w,
            vertical: 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              SizedBox(height: 24.h),
              
              // KPI Metrics Row
              _buildKPIStatsGrid(context),
              SizedBox(height: 24.h),
              
              // Sub Header (Search and Filter Tabs)
              _buildSubHeader(context),
              SizedBox(height: 16.h),
              
              // Table Container
              _buildUsersTable(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Profile Setting', // Mockup shows "Profile Setting" as the page title in Screenshot 2
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
                'Manage workspace users, roles, and status',
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
                  color: Colors.black.withValues(alpha: 0.02),
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
                          color: Colors.black.withValues(alpha: 0.02),
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
        SizedBox(width: 16.w),
        ElevatedButton(
          onPressed: () => _showAddUserDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A448C),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text('Invite User', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPIStatsGrid(BuildContext context) {
    final db = MockDatabase.instance;

    final totalUsers = db.users.length;
    final admins = db.users.where((u) => u.role == 'Admin').length;
    final managers = db.users.where((u) => u.role == 'Manager').length;
    final members = db.users.where((u) => u.role == 'Team Member').length;

    final cards = [
      StatCard(title: 'Total Users', value: totalUsers.toString(), icon: Icons.people_outline, accentColor: AppColors.primary),
      StatCard(title: 'Admins', value: admins.toString(), icon: Icons.shield_outlined, accentColor: AppColors.danger),
      StatCard(title: 'Managers', value: managers.toString(), icon: Icons.workspace_premium_outlined, accentColor: const Color(0xFFF59E0B)),
      StatCard(title: 'Members', value: members.toString(), icon: Icons.person_add_alt_outlined, accentColor: AppColors.success),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 1100 ? 3 : 4);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 76.h,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    Widget searchBar = Container(
      width: isDesktop ? 300.w : double.infinity,
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _userSearchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, size: 18.sp, color: const Color(0xFF0F4C81)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        style: TextStyle(fontSize: 13.sp),
      ),
    );

    Widget roleTabs = Row(
      mainAxisSize: MainAxisSize.min,
      children: ['All', 'Admin', 'Manager', 'Member'].map((role) {
        final isSelected = _selectedRoleFilter == role;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedRoleFilter = role;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F4C81) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchBar,
          roleTabs,
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
            child: roleTabs,
          ),
        ],
      );
    }
  }

  Widget _buildUsersTable(BuildContext context) {
    // Filter logic
    final searchQuery = _userSearchController.text.toLowerCase();
    final filteredUsers = _users.where((u) {
      if (_selectedRoleFilter != 'All' && u.role != _selectedRoleFilter) return false;
      if (searchQuery.isNotEmpty) {
        final matchesName = u.fullName.toLowerCase().contains(searchQuery);
        final matchesEmail = u.email.toLowerCase().contains(searchQuery);
        return matchesName || matchesEmail;
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56.h,
          dataRowMaxHeight: 64.h,
          dataRowMinHeight: 64.h,
          horizontalMargin: 24.w,
          columns: [
            DataColumn(label: _headerText('USER')),
            DataColumn(label: _headerText('USERNAME')),
            DataColumn(label: _headerText('ROLE')),
            DataColumn(label: _headerText('DEPARTMENT')),
            DataColumn(label: _headerText('STATUS')),
            DataColumn(label: _headerText('LAST ACTIVE')),
            DataColumn(label: _headerText('ACTIONS')),
          ],
          rows: filteredUsers.map((user) {
            final initials = user.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
            Color badgeText = const Color(0xFF2F80ED);
            Color badgeBg = const Color(0xFFEAF2FF);
            Color avatarColor = const Color(0xFF2F80ED);
            
            if (user.role == 'Admin') {
              badgeText = const Color(0xFFEB5757);
              badgeBg = const Color(0xFFFFECEB);
              avatarColor = const Color(0xFFEB5757);
            } else if (user.role == 'Manager') {
              badgeText = const Color(0xFFF2C94C);
              badgeBg = const Color(0xFFFFF9E6);
              avatarColor = const Color(0xFFF2C94C);
            } else if (user.role == 'Team Leader') {
              badgeText = const Color(0xFF9C27B0);
              badgeBg = const Color(0xFFE1BEE7);
              avatarColor = const Color(0xFF9C27B0);
            }

            return DataRow(
              cells: [
                // User Column
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: avatarColor,
                        child: Text(
                          initials,
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Username Column
                DataCell(
                  Text(
                    '@${user.fullName.toLowerCase().replaceAll(' ', '.')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                ),
                // Role Column
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6.r)),
                    child: Text(
                      user.role,
                      style: TextStyle(color: badgeText, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Department Column
                DataCell(
                  Text(
                    user.department,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                ),
                // Status Column
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: user.isActive ? const Color(0xFF27AE60) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Last Active Column
                DataCell(
                  Text(
                    user.lastActive,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                  ),
                ),
                // Actions Column
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.edit_outlined, color: const Color(0xFF2F80ED), size: 14.sp),
                          onPressed: () => _showEditUserDialog(context, user),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFECEB),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete_outline, color: const Color(0xFFEB5757), size: 14.sp),
                          onPressed: () => _showDeleteUserDialog(context, user),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _headerText(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final emailCon = TextEditingController();
    final phoneCon = TextEditingController();
    String dept = db.departments.isNotEmpty ? db.departments.first.name : 'Computer Science';
    String role = 'Team Member';

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
                            'Add User',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Register a new system user profile.',
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

                  _buildDialogFieldLabel('Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildDialogInputDecoration('Enter full name...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Email'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: emailCon,
                    decoration: _buildDialogInputDecoration('e.g. user@aitu.edu'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Phone'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: phoneCon,
                    decoration: _buildDialogInputDecoration('e.g. +201012345678'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Department'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    initialValue: dept,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildDialogInputDecoration(''),
                    items: db.departments.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: (v) => setDialogState(() => dept = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Role'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildDialogInputDecoration(''),
                    items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
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
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
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
                              try {
                                db.addUser(
                                  MockUser(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    email: emailCon.text.trim(),
                                    fullName: nameCon.text.trim(),
                                    role: role,
                                    department: dept,
                                    phone: phoneCon.text.trim(),
                                  ),
                                  currentAdminId,
                                );
                                setState(() {});
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
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
                          child: const Text(
                            'Create',
                            style: TextStyle(
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

  void _showEditUserDialog(BuildContext context, MockUser user) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController(text: user.fullName);
    final emailCon = TextEditingController(text: user.email);
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
                            'Edit User',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Update system user profile attributes.',
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

                  _buildDialogFieldLabel('Name'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: nameCon,
                    decoration: _buildDialogInputDecoration('Enter full name...'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Email'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: emailCon,
                    decoration: _buildDialogInputDecoration('e.g. user@aitu.edu'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Phone'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: phoneCon,
                    decoration: _buildDialogInputDecoration('e.g. +201012345678'),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Department'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    initialValue: dept,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildDialogInputDecoration(''),
                    items: db.departments.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: (v) => setDialogState(() => dept = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Role'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildDialogInputDecoration(''),
                    items: ['Admin', 'Manager', 'Team Leader', 'Team Member'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setDialogState(() => role = v!),
                  ),
                  SizedBox(height: 20.h),

                  _buildDialogFieldLabel('Status'),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: _buildDialogInputDecoration(''),
                    items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
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
                              db.editUser(
                                MockUser(
                                  id: user.id,
                                  email: emailCon.text.trim(),
                                  fullName: nameCon.text.trim(),
                                  role: role,
                                  department: dept,
                                  phone: phoneCon.text.trim(),
                                  status: status,
                                ),
                                currentAdminId,
                              );
                              setState(() {});
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
                          child: const Text(
                            'Save',
                            style: TextStyle(
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

  void _showDeleteUserDialog(BuildContext context, MockUser user) {
    final db = MockDatabase.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        backgroundColor: Colors.white,
        title: const Text(
          'Delete User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "${user.fullName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              db.deleteUser(user.id, currentAdminId);
              setState(() {});
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String get currentAdminId {
    final admin = MockDatabase.instance.users
        .where((u) => u.role == 'Admin')
        .toList();
    return admin.isNotEmpty ? admin.first.id : '1';
  }

  Widget _buildDialogFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _buildDialogInputDecoration(String hint) {
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
