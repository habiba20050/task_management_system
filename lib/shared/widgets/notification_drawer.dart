import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors/app_colors.dart';
import '../../responsive/responsive_layout.dart';

class NotificationDrawer extends StatelessWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final drawerWidth = isMobile ? 320.w : 380.w;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Bell Icon Container
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.aituBlue.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: 22.sp,
                          color: AppColors.aituBlue,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Notifications title and unread count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '3 unread',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Mark all read & Clear all Row
                  Row(
                    children: [
                      // Mark all read button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAF2FF),
                            side: const BorderSide(color: Color(0xFF2F80ED), width: 1.2),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 14.sp, color: const Color(0xFF2F80ED)),
                              SizedBox(width: 6.w),
                              Text(
                                'Mark all read',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Clear all button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFECEB),
                            side: const BorderSide(color: Color(0xFFEB5757), width: 1.2),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, size: 14.sp, color: const Color(0xFFEB5757)),
                              SizedBox(width: 6.w),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEB5757),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1.5, height: 1),

            // Scrollable Notifications List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Task Overdue! (Unread - Red Highlight)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: const Color(0xFFEB5757),
                    backgroundColor: const Color(0xFFFFECEB),
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFEB5757),
                    iconBgColor: Colors.white,
                    title: 'Task Overdue!',
                    description:
                        'Faculty Performance Review Q2 is past its deadline by 4 days.',
                    time: 'Just now',
                  ),
                  // 2. New Task Assigned (Unread - Blue Highlight)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: const Color(0xFF2F80ED),
                    backgroundColor: const Color(0xFFEAF2FF),
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF2F80ED),
                    iconBgColor: Colors.white,
                    title: 'New Task Assigned',
                    description:
                        'You have been assigned Department Budget Planning 2027.',
                    time: '2 hrs ago',
                  ),
                  // 3. Mentioned in Comment (Unread - Purple Highlight)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: const Color(0xFF9B51E0),
                    backgroundColor: const Color(0xFFF2EAFE),
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF9B51E0),
                    iconBgColor: Colors.white,
                    title: 'Mentioned in Comment',
                    description:
                        'Sarah Ahmed mentioned you in the Course Management Portal discussion.',
                    time: 'Yesterday',
                  ),
                  // 4. New Task Assigned (Read - White Bg, Blue icon)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF2F80ED),
                    iconBgColor: const Color(0xFFEAF2FF),
                    title: 'New Task Assigned',
                    description:
                        'AI Research Proposal Review has been added to your task list.',
                    time: '2 days ago',
                  ),
                  // 5. New Task Assigned (Read - White Bg, Blue icon)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF2F80ED),
                    iconBgColor: const Color(0xFFEAF2FF),
                    title: 'New Task Assigned',
                    description:
                        'AI Research Proposal Review has been added to your task list.',
                    time: '2 days ago',
                  ),
                  // 6. New Task Assigned (Read - White Bg, Blue icon)
                  _buildNotificationCard(
                    context: context,
                    leftBorderColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF2F80ED),
                    iconBgColor: const Color(0xFFEAF2FF),
                    title: 'New Task Assigned',
                    description:
                        'AI Research Proposal Review has been added to your task list.',
                    time: '2 days ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required Color leftBorderColor,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String time,
  }) {
    return InkWell(
      onTap: () {
        // Close the drawer first
        Navigator.pop(context);
        // Navigate to dashboard with query param to show "My Tasks"
        context.go('/dashboard?showMyTasks=true');
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: BorderSide(color: leftBorderColor, width: 4.w),
            bottom: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Icon Container
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
