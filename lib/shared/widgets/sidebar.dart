import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors/app_colors.dart';
import '../../responsive/responsive_layout.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveLayout.isMobile(context) ? 260.w : (ResponsiveLayout.isTablet(context) ? 200.w : 260.w),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
              children: [
                // Logo Section
                Container(
                  padding: EdgeInsets.all(ResponsiveLayout.isTablet(context) ? 16.w : 24.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/aitu_logo.png',
                        width: ResponsiveLayout.isTablet(context) ? 32.w : 40.w,
                        height: ResponsiveLayout.isTablet(context) ? 32.h : 40.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: ResponsiveLayout.isTablet(context) ? 8.w : 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AITU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveLayout.isTablet(context) ? 14.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'TASK MANAGEMENT',
                              style: TextStyle(
                                color: const Color(0xFF7D9BB3),
                                fontSize: ResponsiveLayout.isTablet(context) ? 8.sp : 10.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white10,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
                SizedBox(height: 10.h),
                
                // MAIN MENU header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveLayout.isTablet(context) ? 16.w : 24.w,
                    vertical: 8.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'MAIN MENU',
                      style: TextStyle(
                        color: const Color(0xFF6B8B9B),
                        fontSize: ResponsiveLayout.isTablet(context) ? 9.sp : 11.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.isTablet(context) ? 8.w : 12.w),
                    children: [
                      _buildNavItem(
                        context,
                        icon: Icons.bar_chart_outlined,
                        label: 'Dashboard',
                        route: '/dashboard',
                        isSelected: _isRouteSelected(context, '/dashboard'),
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.people_outline,
                        label: 'Teams',
                        route: '/team',
                        isSelected: _isRouteSelected(context, '/team'),
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.grid_view_outlined,
                        label: 'Tasks & Tickets',
                        route: '/tasks',
                        isSelected: _isRouteSelected(context, '/tasks'),
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Reports',
                        route: '/reports',
                        isSelected: _isRouteSelected(context, '/reports'),
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.manage_accounts_outlined,
                        label: 'Users & Roles',
                        route: '/users-roles',
                        isSelected: _isRouteSelected(context, '/users-roles'),
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.settings_outlined,
                        label: 'Profile Settings',
                        route: '/settings',
                        isSelected: _isRouteSelected(context, '/settings'),
                      ),
                    ],
                  ),
                ),
                
                // User Section
                Container(
                  margin: EdgeInsets.all(ResponsiveLayout.isTablet(context) ? 10.w : 16.w),
                  padding: EdgeInsets.all(ResponsiveLayout.isTablet(context) ? 8.w : 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.sidebarProfileBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: ResponsiveLayout.isTablet(context) ? 14.r : 18.r,
                        backgroundColor: const Color(0xFFFF3B30),
                        child: Text(
                          'AH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveLayout.isTablet(context) ? 11.sp : 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveLayout.isTablet(context) ? 6.w : 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dr. Ahmed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveLayout.isTablet(context) ? 11.sp : 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: ResponsiveLayout.isTablet(context) ? 9.sp : 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.logout,
                          color: Colors.white70,
                          size: ResponsiveLayout.isTablet(context) ? 16.sp : 18.sp,
                        ),
                        onPressed: () {
                          context.pushReplacement('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarActiveBg : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 10.h,
                    bottom: 10.h,
                    child: Container(
                      width: 3.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(2.r),
                          bottomRight: Radius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveLayout.isTablet(context) ? 10.w : 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      if (isSelected) SizedBox(width: 6.w),
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: ResponsiveLayout.isTablet(context) ? 18.sp : 20.sp,
                      ),
                      SizedBox(width: ResponsiveLayout.isTablet(context) ? 8.w : 12.w),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: ResponsiveLayout.isTablet(context) ? 12.sp : 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (label == 'Tasks & Tickets')
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '20',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isSelected && label != 'Tasks & Tickets')
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white60,
                          size: ResponsiveLayout.isTablet(context) ? 14.sp : 16.sp,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRouteSelected(BuildContext context, String route) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    return currentRoute == route || currentRoute.startsWith('$route/');
  }
}
