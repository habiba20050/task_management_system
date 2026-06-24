import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();
  


  final List<TeamItem> _teams = [
    TeamItem(
      name: 'Engineering Systems',
      department: 'Engineering Dept',
      leaderInitials: 'KM',
      leaderName: 'Prof. Khalid Mansour',
      leaderRole: 'TEAM LEADER',
      membersCount: 3,
      completionPercent: 76,
      tasksString: '38/50 tasks',
      accentColor: const Color(0xFF27AE60),
      members: ['Prof. Khalid Mansour', 'Sarah Ahmed', 'Omar Khalil'],
    ),
    TeamItem(
      name: 'Product Development',
      department: 'R&D Dept',
      leaderInitials: 'PD',
      leaderName: 'Dr. Emily Chen',
      leaderRole: 'PROJECT LEAD',
      membersCount: 4,
      completionPercent: 90,
      tasksString: '45/50 tasks',
      accentColor: const Color(0xFF2F80ED),
      members: ['Dr. Emily Chen', 'Nour Hassan', 'Fatma Ali', 'Ahmed Sayed'],
    ),
    TeamItem(
      name: 'Marketing Strategies',
      department: 'Marketing Dept',
      leaderInitials: 'MK',
      leaderName: 'Ms. Sarah Johnson',
      leaderRole: 'TEAM MANAGER',
      membersCount: 5,
      completionPercent: 82,
      tasksString: '41/50 tasks',
      accentColor: const Color(0xFF27AE60),
      members: ['Ms. Sarah Johnson', 'Laila Mahmoud', 'Youssef Ali', 'Habiba Ahmed', 'Zainab Tarek'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _teamSearchController.dispose();
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
              
              // Search & Add Team Sub-header
              _buildSubHeader(context),
              SizedBox(height: 24.h),
              
              // KPI Cards Grid
              _buildKPIStatsGrid(context),
              SizedBox(height: 24.h),
              
              // Teams Cards Grid
              _buildTeamsGrid(context),
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
                    'Team Management',
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
                'Overview of teams, departments & performance',
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

  Widget _buildSubHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    Widget searchBar = Container(
      width: isDesktop ? 320.w : double.infinity,
      height: 42.h,
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
        controller: _teamSearchController,
        decoration: InputDecoration(
          hintText: 'Search teams or departments...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey[400]),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        style: TextStyle(fontSize: 13.sp),
      ),
    );

    Widget addTeamButton = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A448C),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16.sp, color: Colors.white),
          SizedBox(width: 8.w),
          Text(
            'Add New Team',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchBar,
          Text(
            '6 of 6 teams',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          addTeamButton,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchBar,
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '6 of 6 teams',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              addTeamButton,
            ],
          ),
        ],
      );
    }
  }

  Widget _buildKPIStatsGrid(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final cards = [
      _buildKPICard(
        icon: Icons.group_outlined,
        iconColor: const Color(0xFF2F80ED),
        iconBgColor: const Color(0xFFEAF2FF),
        value: '6',
        label: 'Total Teams',
      ),
      _buildKPICard(
        icon: Icons.person_outline,
        iconColor: const Color(0xFF27AE60),
        iconBgColor: const Color(0xFFE8F8EE),
        value: '21',
        label: 'Total Members',
      ),
      _buildKPICard(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFFF2C94C),
        iconBgColor: const Color(0xFFFFF9E6),
        value: '80%',
        label: 'Avg Completion',
      ),
      _buildKPICard(
        icon: Icons.playlist_add_check,
        iconColor: const Color(0xFF9B51E0),
        iconBgColor: const Color(0xFFF3E6FF),
        value: '276',
        label: 'Active Tasks',
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

  Widget _buildTeamsGrid(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _teams.map((team) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildTeamCard(team),
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
        childAspectRatio: 0.8,
        children: _teams.map((t) => _buildTeamCard(t)).toList(),
      );
    } else {
      return Column(
        children: _teams.map((t) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildTeamCard(t),
        )).toList(),
      );
    }
  }

  Widget _buildTeamCard(TeamItem team) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: team.accentColor, width: 4.h),
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Title, Dept and Edit/Delete Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            team.department,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Edit Button
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
                      // Delete Button
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
                ],
              ),
              SizedBox(height: 20.h),
              
              // Team Leader Details Block
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  border: Border.all(color: const Color(0xFFF2C94C).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: team.accentColor,
                      child: Text(
                        team.leaderInitials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: const Color(0xFFF2C94C), size: 10.sp),
                              SizedBox(width: 4.w),
                              Text(
                                team.leaderRole,
                                style: TextStyle(
                                  color: const Color(0xFF8C731F),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            team.leaderName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.membersCount.toString(),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Members',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${team.completionPercent}%',
                        style: TextStyle(
                          color: team.accentColor,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completion',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Progress',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    team.tasksString,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              LinearProgressIndicator(
                value: team.completionPercent / 100,
                backgroundColor: Colors.grey[100],
                color: team.accentColor,
                minHeight: 6.h,
                borderRadius: BorderRadius.circular(3.r),
              ),
              SizedBox(height: 20.h),
              
              // View Members Dropdown Button
              InkWell(
                onTap: () {
                  setState(() {
                    team.isExpanded = !team.isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_outline, color: Colors.grey[500], size: 14.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'View Members (${team.members.length})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        team.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[500],
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Expandable Members List
              if (team.isExpanded) ...[
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: team.members.map((member) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10.r,
                            backgroundColor: team.accentColor.withOpacity(0.1),
                            child: Text(
                              member.split(' ').map((e) => e[0]).take(2).join(),
                              style: TextStyle(
                                color: team.accentColor,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            member,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
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

class TeamItem {
  final String name;
  final String department;
  final String leaderInitials;
  final String leaderName;
  final String leaderRole;
  final int membersCount;
  final int completionPercent;
  final String tasksString;
  final Color accentColor;
  final List<String> members;
  bool isExpanded;

  TeamItem({
    required this.name,
    required this.department,
    required this.leaderInitials,
    required this.leaderName,
    required this.leaderRole,
    required this.membersCount,
    required this.completionPercent,
    required this.tasksString,
    required this.accentColor,
    required this.members,
    this.isExpanded = false,
  });
}
