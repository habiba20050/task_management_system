import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';

class UserItem {
  final String name;
  final String email;
  final String username;
  final String role; // 'Admin' | 'Manager' | 'Member'
  final String department;
  final bool isActive;
  final String lastActive;
  final String initials;
  final Color avatarColor;

  UserItem({
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.department,
    required this.isActive,
    required this.lastActive,
    required this.initials,
    required this.avatarColor,
  });
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  
  String _selectedRoleFilter = 'All'; // 'All' | 'Admin' | 'Manager' | 'Member'



  final List<UserItem> _users = [
    UserItem(
      name: 'Dr. Ahmed Hassan',
      email: 'ahmed.hassan@aitu.edu.eg',
      username: '@ahmed.hassan',
      role: 'Admin',
      department: 'Computer Science',
      isActive: true,
      lastActive: 'Just now',
      initials: 'AH',
      avatarColor: const Color(0xFF0A448C),
    ),
    UserItem(
      name: 'Prof. Khalid Mansour',
      email: 'k.mansour@aitu.edu.eg',
      username: '@k.mansour',
      role: 'Manager',
      department: 'Engineering',
      isActive: true,
      lastActive: '2 hours ago',
      initials: 'KM',
      avatarColor: const Color(0xFF27AE60),
    ),
    UserItem(
      name: 'Sarah Ahmed',
      email: 'sarah.ahmed@aitu.edu.eg',
      username: '@sarah.ahmed',
      role: 'Member',
      department: 'Computer Science',
      isActive: true,
      lastActive: '5 min ago',
      initials: 'SA',
      avatarColor: const Color(0xFF2F80ED),
    ),
    UserItem(
      name: 'Prof. Khalid Mansour',
      email: 'k.mansour@aitu.edu.eg',
      username: '@k.mansour',
      role: 'Manager',
      department: 'Engineering',
      isActive: false,
      lastActive: '2 hours ago',
      initials: 'KM',
      avatarColor: const Color(0xFF27AE60),
    ),
    UserItem(
      name: 'Sarah Ahmed',
      email: 'sarah.ahmed@aitu.edu.eg',
      username: '@sarah.ahmed',
      role: 'Member',
      department: 'Computer Science',
      isActive: true,
      lastActive: '5 min ago',
      initials: 'SA',
      avatarColor: const Color(0xFF2F80ED),
    ),
    UserItem(
      name: 'Nour Hassan',
      email: 'nour.hassan@aitu.edu.eg',
      username: '@nour.hassan',
      role: 'Manager',
      department: 'IT Services',
      isActive: true,
      lastActive: '1 hour ago',
      initials: 'NH',
      avatarColor: const Color(0xFFF2C94C),
    ),
    UserItem(
      name: 'Ahmed Sayed',
      email: 'ahmed.sayed@aitu.edu.eg',
      username: '@ahmed.sayed',
      role: 'Member',
      department: 'Business',
      isActive: true,
      lastActive: '2 hours ago',
      initials: 'AS',
      avatarColor: const Color(0xFFEB5757),
    ),
    UserItem(
      name: 'Fatma Ali',
      email: 'fatma.ali@aitu.edu.eg',
      username: '@fatma.ali',
      role: 'Member',
      department: 'Mathematics',
      isActive: true,
      lastActive: '3 hours ago',
      initials: 'FA',
      avatarColor: Colors.grey,
    ),
    UserItem(
      name: 'Samira Harb',
      email: 'samira.harb@aitu.edu.eg',
      username: '@samira.harb',
      role: 'Member',
      department: 'Business',
      isActive: true,
      lastActive: '4 hours ago',
      initials: 'SH',
      avatarColor: const Color(0xFF0A448C),
    ),
  ];

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
                  color: Colors.black.withOpacity(0.02),
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
                          color: Colors.black.withOpacity(0.02),
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
      ],
    );
  }

  Widget _buildKPIStatsGrid(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final cards = [
      _buildKPICard(
        icon: Icons.people_outline,
        iconColor: const Color(0xFF2F80ED),
        iconBgColor: const Color(0xFFEAF2FF),
        value: '9',
        label: 'Total Users',
      ),
      _buildKPICard(
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFFEB5757),
        iconBgColor: const Color(0xFFFFECEB),
        value: '1',
        label: 'Admins',
      ),
      _buildKPICard(
        icon: Icons.workspace_premium_outlined,
        iconColor: const Color(0xFFF2C94C),
        iconBgColor: const Color(0xFFFFF9E6),
        value: '3',
        label: 'Managers',
      ),
      _buildKPICard(
        icon: Icons.person_add_alt_outlined,
        iconColor: const Color(0xFF27AE60),
        iconBgColor: const Color(0xFFE8F8EE),
        value: '5',
        label: 'Members',
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: c,
          ),
        )).toList(),
      );
    } else if (isTablet) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.8,
        children: cards,
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: c,
        )).toList(),
      );
    }
  }

  Widget _buildKPICard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    Widget searchBar = Container(
      width: isDesktop ? 300.w : double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
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
          prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey[400]),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 9.h),
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
                color: isSelected ? const Color(0xFF0A448C) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0A448C) : Colors.grey[200]!,
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

    Widget inviteButton = ElevatedButton(
      onPressed: () {},
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
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchBar,
          roleTabs,
          inviteButton,
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
          SizedBox(height: 12.h),
          inviteButton,
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
        final matchesName = u.name.toLowerCase().contains(searchQuery);
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
            color: Colors.black.withOpacity(0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56.h,
          dataRowHeight: 64.h,
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
            Color badgeText = const Color(0xFF2F80ED);
            Color badgeBg = const Color(0xFFEAF2FF);
            if (user.role == 'Admin') {
              badgeText = const Color(0xFFEB5757);
              badgeBg = const Color(0xFFFFECEB);
            } else if (user.role == 'Manager') {
              badgeText = const Color(0xFFF2C94C);
              badgeBg = const Color(0xFFFFF9E6);
            }

            return DataRow(
              cells: [
                // User Column
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: user.avatarColor,
                        child: Text(
                          user.initials,
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
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
                    user.username,
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
                          onPressed: () {},
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
                          onPressed: () {},
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

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}
