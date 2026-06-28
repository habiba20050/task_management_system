import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';

class DashboardPage extends StatefulWidget {
  final bool showMyTasks;
  const DashboardPage({super.key, this.showMyTasks = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showMyTasks = false;
  bool _card1Complete = false;
  bool _card2Complete = false;
  bool _card3Complete = false;
  bool _card4Complete = true;
  


  @override
  void initState() {
    super.initState();
    _showMyTasks = widget.showMyTasks;
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showMyTasks != widget.showMyTasks) {
      setState(() {
        _showMyTasks = widget.showMyTasks;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _currentLanguage = 'EN';

  Widget _buildLanguageSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _currentLanguage = 'EN';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _currentLanguage == 'EN'
                    ? const Color(0xFF1565C0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                'English',
                style: TextStyle(
                  color: _currentLanguage == 'EN' ? Colors.white : Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentLanguage = 'AR';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _currentLanguage == 'AR'
                    ? const Color(0xFF1565C0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                'العربية',
                style: TextStyle(
                  color: _currentLanguage == 'AR' ? Colors.white : Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              // Top Header
              _buildHeader(context),
              SizedBox(height: 24.h),
              
              if (!_showMyTasks) ...[
                // KPI Stats Grid
                _buildKPIStatsGrid(context),
                SizedBox(height: 24.h),
                
                // Charts Section 2 (Bar Chart & Recent Activity)
                _buildChartsSection2(context),
              ] else ...[
                // My Tasks Section
                _buildMyTasksSection(context),
              ],
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
        // Title & Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isDesktop ? 22.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Overview of tasks, teams & performance',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isDesktop ? 13.sp : 11.sp,
                ),
              ),
            ],
          ),
        ),
        
        // Search & Profile Actions (Only shown on Desktop/Tablet)
        if (!ResponsiveLayout.isMobile(context)) ...[

          
          // Notifications Bell
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
          
          // Language selector
          _buildLanguageSelector(context),
        ],
      ],
    );
  }

  Widget _buildKPIStatsGrid(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final cards = [
      _buildKPICard(
        icon: Icons.adjust,
        iconColor: const Color(0xFF2F80ED),
        iconBgColor: const Color(0xFFEAF2FF),
        value: '248',
        label: 'Total Tasks',
      ),
      _buildKPICard(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF27AE60),
        iconBgColor: const Color(0xFFE8F8EE),
        value: '186',
        label: 'Completed',
      ),
      _buildKPICard(
        icon: Icons.access_time,
        iconColor: const Color(0xFFF2C94C),
        iconBgColor: const Color(0xFFFFF9E6),
        value: '42',
        label: 'In Progress',
      ),
      _buildKPICard(
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEB5757),
        iconBgColor: const Color(0xFFFFECEB),
        value: '20',
        label: 'Overdue',
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
                  color: Colors.grey[500],
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

  Widget _buildChartsSection2(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildBarChartCard(),
          ),
          SizedBox(width: 24.w),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 334.h,
              child: _buildRecentActivityCard(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildBarChartCard(),
          SizedBox(height: 24.h),
          SizedBox(
            height: 360.h,
            child: _buildRecentActivityCard(),
          ),
        ],
      );
    }
  }



  Widget _buildBarChartCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    'Department Performance',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Completed vs. pending tasks by department',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendDot(color: const Color(0xFF0A448C), label: 'Completed'),
                  SizedBox(width: 16.w),
                  _buildLegendDot(color: const Color(0xFF9CCAFF), label: 'Pending'),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 210.h,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4.h,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}%',
                        TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.sp,
                        ),
                      );
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 15,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28.w,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const depts = ['CS Dept', 'Engineering', 'Business', 'IT Services', 'Mathematics'];
                        if (value.toInt() >= 0 && value.toInt() < depts.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              depts[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 28.h,
                    ),
                  ),
                ),
                barGroups: [
                  _buildBarGroup(0, 47, 15),
                  _buildBarGroup(1, 37, 18),
                  _buildBarGroup(2, 29, 12),
                  _buildBarGroup(3, 52, 8),
                  _buildBarGroup(4, 20, 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double completed, double pending) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: completed,
          color: const Color(0xFF0A448C),
          width: 10.w,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(3.r),
            topRight: Radius.circular(3.r),
          ),
        ),
        BarChartRodData(
          toY: pending,
          color: const Color(0xFF9CCAFF),
          width: 10.w,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(3.r),
            topRight: Radius.circular(3.r),
          ),
        ),
      ],
      showingTooltipIndicators: const [0, 1],
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    final List<ActivityItem> activities = [
      ActivityItem(
        initials: 'SA',
        name: 'Sarah Ahmed',
        action: 'completed',
        target: 'API Integration Review',
        time: '5 min ago',
        color: const Color(0xFF27AE60),
      ),
      ActivityItem(
        initials: 'OK',
        name: 'Omar Khalil',
        action: 'created ticket',
        target: 'Network Infrastructure Audit',
        time: '23 min ago',
        color: const Color(0xFF2F80ED),
      ),
      ActivityItem(
        initials: 'NH',
        name: 'Nour Hassan',
        action: 'updated status of',
        target: 'Course Management Portal',
        time: '1 hr ago',
        color: const Color(0xFFF2C94C),
      ),
      ActivityItem(
        initials: 'AS',
        name: 'Ahmed Sayed',
        action: 'missed deadline for',
        target: 'Annual Report Submission',
        time: '2 hr ago',
        color: const Color(0xFFEB5757),
      ),
      ActivityItem(
        initials: 'FA',
        name: 'Fatma Ali',
        action: 'commented on',
        target: 'Student Portal Redesign',
        time: '3 hr ago',
        color: Colors.grey[500]!,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: const Color(0xFF2F80ED),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[100],
                thickness: 1,
                height: 14.h,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14.r,
                      backgroundColor: activity.color.withOpacity(0.1),
                      child: Text(
                        activity.initials,
                        style: TextStyle(
                          color: activity.color,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: '${activity.name} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                TextSpan(text: '${activity.action} '),
                                TextSpan(
                                  text: activity.target,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A448C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            activity.time,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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

  Widget _buildMyTasksSection(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final activeCount = 3 - (_card1Complete ? 1 : 0) - (_card2Complete ? 1 : 0) - (_card3Complete ? 1 : 0);
    final completedCount = 1 + (_card1Complete ? 1 : 0) + (_card2Complete ? 1 : 0) + (_card3Complete ? 1 : 0);
    final overdueCount = 1 - (_card1Complete ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dark Blue Tasks Banner / Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.aituBlue,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.white38),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Description Columns
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                        children: [
                          TextSpan(text: '$activeCount active · $completedCount completed · '),
                          TextSpan(
                            text: '$overdueCount overdue!',
                            style: TextStyle(
                              color: overdueCount > 0 ? const Color(0xFFFF8A80) : Colors.white.withOpacity(0.8),
                              fontWeight: overdueCount > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // View All Tasks Button
              OutlinedButton(
                onPressed: () {
                  context.go('/tasks');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54, width: 1.2),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Tasks',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Responsive Cards Grid / Column
        if (!isMobile)
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetailedTaskCard(
                      leftBorderColor: const Color(0xFFEB5757),
                      priority: 'HIGH',
                      priorityColor: const Color(0xFFEB5757),
                      priorityBg: const Color(0xFFFFECEB),
                      status: 'To Do',
                      statusColor: const Color(0xFFF2C94C),
                      statusBg: const Color(0xFFFFF9E6),
                      isOverdue: true,
                      title: 'Faculty Performance Review Q2',
                      description:
                          'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                      department: 'CS Dept',
                      dueDate: 'Jun 30',
                      isComplete: _card1Complete,
                      onActionTap: () {
                        setState(() {
                          _card1Complete = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildDetailedTaskCard(
                      leftBorderColor: const Color(0xFFF2C94C),
                      priority: 'HIGH',
                      priorityColor: const Color(0xFFEB5757),
                      priorityBg: const Color(0xFFFFECEB),
                      status: 'To Do',
                      statusColor: const Color(0xFFF2C94C),
                      statusBg: const Color(0xFFFFF9E6),
                      isOverdue: true,
                      title: 'Faculty Performance Review Q2',
                      description:
                          'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                      department: 'CS Dept',
                      dueDate: 'Jun 30',
                      isComplete: _card2Complete,
                      onActionTap: () {
                        setState(() {
                          _card2Complete = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetailedTaskCard(
                      leftBorderColor: const Color(0xFF27AE60),
                      priority: 'HIGH',
                      priorityColor: const Color(0xFFEB5757),
                      priorityBg: const Color(0xFFFFECEB),
                      status: 'To Do',
                      statusColor: const Color(0xFFF2C94C),
                      statusBg: const Color(0xFFFFF9E6),
                      isOverdue: true,
                      title: 'Faculty Performance Review Q2',
                      description:
                          'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                      department: 'CS Dept',
                      dueDate: 'Jun 30',
                      isComplete: _card3Complete,
                      onActionTap: () {
                        setState(() {
                          _card3Complete = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildDetailedTaskCard(
                      leftBorderColor: const Color(0xFF2F80ED),
                      priority: 'HIGH',
                      priorityColor: const Color(0xFFEB5757),
                      priorityBg: const Color(0xFFFFECEB),
                      status: 'Complete',
                      statusColor: const Color(0xFF2F80ED),
                      statusBg: const Color(0xFFEAF2FF),
                      isOverdue: false,
                      title: 'Faculty Performance Review Q2',
                      description:
                          'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                      department: 'CS Dept',
                      dueDate: 'Jun 30',
                      isComplete: _card4Complete,
                      onActionTap: () {
                        setState(() {
                          _card4Complete = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              _buildDetailedTaskCard(
                leftBorderColor: const Color(0xFFEB5757),
                priority: 'HIGH',
                priorityColor: const Color(0xFFEB5757),
                priorityBg: const Color(0xFFFFECEB),
                status: 'To Do',
                statusColor: const Color(0xFFF2C94C),
                statusBg: const Color(0xFFFFF9E6),
                isOverdue: true,
                title: 'Faculty Performance Review Q2',
                description:
                    'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                department: 'CS Dept',
                dueDate: 'Jun 30',
                isComplete: _card1Complete,
                onActionTap: () {
                  setState(() {
                    _card1Complete = true;
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildDetailedTaskCard(
                leftBorderColor: const Color(0xFFF2C94C),
                priority: 'HIGH',
                priorityColor: const Color(0xFFEB5757),
                priorityBg: const Color(0xFFFFECEB),
                status: 'To Do',
                statusColor: const Color(0xFFF2C94C),
                statusBg: const Color(0xFFFFF9E6),
                isOverdue: true,
                title: 'Faculty Performance Review Q2',
                description:
                    'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                department: 'CS Dept',
                dueDate: 'Jun 30',
                isComplete: _card2Complete,
                onActionTap: () {
                  setState(() {
                    _card2Complete = true;
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildDetailedTaskCard(
                leftBorderColor: const Color(0xFF27AE60),
                priority: 'HIGH',
                priorityColor: const Color(0xFFEB5757),
                priorityBg: const Color(0xFFFFECEB),
                status: 'To Do',
                statusColor: const Color(0xFFF2C94C),
                statusBg: const Color(0xFFFFF9E6),
                isOverdue: true,
                title: 'Faculty Performance Review Q2',
                description:
                    'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                department: 'CS Dept',
                dueDate: 'Jun 30',
                isComplete: _card3Complete,
                onActionTap: () {
                  setState(() {
                    _card3Complete = true;
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildDetailedTaskCard(
                leftBorderColor: const Color(0xFF2F80ED),
                priority: 'HIGH',
                priorityColor: const Color(0xFFEB5757),
                priorityBg: const Color(0xFFFFECEB),
                status: 'Complete',
                statusColor: const Color(0xFF2F80ED),
                statusBg: const Color(0xFFEAF2FF),
                isOverdue: false,
                title: 'Faculty Performance Review Q2',
                description:
                    'Conduct comprehensive performance evaluations for all CS department faculty members, reviewing research publications, teaching feedback, and service metrics.',
                department: 'CS Dept',
                dueDate: 'Jun 30',
                isComplete: _card4Complete,
                onActionTap: () {
                  setState(() {
                    _card4Complete = true;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDetailedTaskCard({
    required Color leftBorderColor,
    required String priority,
    required Color priorityColor,
    required Color priorityBg,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required bool isOverdue,
    required String title,
    required String description,
    required String department,
    required String dueDate,
    required bool isComplete,
    required VoidCallback onActionTap,
  }) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: leftBorderColor, width: 4.w),
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags Row
              Row(
                children: [
                  // Priority Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: priorityBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Status Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isOverdue && !isComplete) ...[
                    SizedBox(width: 8.w),
                    // Overdue Tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFEB5757),
                            size: 11.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: const Color(0xFFEB5757),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16.h),
              // Title
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              // Description
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.sp,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              // Bottom Row (Department, Due Date, Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Department Tag
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          department,
                          style: TextStyle(
                            color: const Color(0xFF0A448C),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Due Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[400],
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            dueDate,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Action Button or Done status
                  if (isComplete)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: const Color(0xFF27AE60),
                            size: 13.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: const Color(0xFF27AE60),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: onActionTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF27AE60),
                        side: const BorderSide(color: Color(0xFF27AE60), width: 1.2),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        backgroundColor: const Color(0xFFE8F8EE),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            color: const Color(0xFF27AE60),
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Mark Complete',
                            style: TextStyle(
                              color: const Color(0xFF27AE60),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class ActivityItem {
  final String initials;
  final String name;
  final String action;
  final String target;
  final String time;
  final Color color;

  ActivityItem({
    required this.initials,
    required this.name,
    required this.action,
    required this.target,
    required this.time,
    required this.color,
  });
}
