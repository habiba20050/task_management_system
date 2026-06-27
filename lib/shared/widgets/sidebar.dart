import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors/app_colors.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../responsive/responsive_layout.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveLayout.isMobile(context)
          ? 260.w
          : (ResponsiveLayout.isTablet(context) ? 200.w : 260.w),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(
              ResponsiveLayout.isTablet(context) ? 16.w : 24.w,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: ResponsiveLayout.isTablet(context) ? 46.w : 58.w,
                  height: ResponsiveLayout.isTablet(context) ? 46.h : 58.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: ResponsiveLayout.isTablet(context) ? 10.w : 14.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AITU',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: ResponsiveLayout.isTablet(context)
                              ? 16.sp
                              : 20.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'جامعة أسيوط التكنولوجية',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: ResponsiveLayout.isTablet(context)
                              ? 10.sp
                              : 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Task & Ticket Management',
                        style: TextStyle(
                          color: const Color(0xFF041831), // Dark navy
                          fontSize: ResponsiveLayout.isTablet(context)
                              ? 8.5.sp
                              : 10.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.divider,
            thickness: 1,
            indent: 16.w,
            endIndent: 16.w,
          ),
          SizedBox(height: 12.h),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.isTablet(context) ? 8.w : 12.w,
              ),
              children: [
                _SidebarNavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Dashboard',
                  route: '/dashboard',
                  isSelected: _isRouteSelected(context, '/dashboard'),
                ),
                _SidebarNavItem(
                  icon: Icons.people_outline,
                  label: 'Teams',
                  route: '/team',
                  isSelected: _isRouteSelected(context, '/team'),
                ),
                _SidebarNavItem(
                  icon: Icons.grid_view_outlined,
                  label: 'Tasks & Tickets',
                  route: '/tasks',
                  isSelected: _isRouteSelected(context, '/tasks'),
                ),
                _SidebarNavItem(
                  icon: Icons.description_outlined,
                  label: 'Reports',
                  route: '/reports',
                  isSelected: _isRouteSelected(context, '/reports'),
                ),
                _SidebarNavItem(
                  icon: Icons.manage_accounts_outlined,
                  label: 'Users & Roles',
                  route: '/users-roles',
                  isSelected: _isRouteSelected(context, '/users-roles'),
                ),
                _SidebarNavItem(
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
            margin: EdgeInsets.all(
              ResponsiveLayout.isTablet(context) ? 10.w : 16.w,
            ),
            padding: EdgeInsets.all(
              ResponsiveLayout.isTablet(context) ? 8.w : 12.w,
            ),
            decoration: BoxDecoration(
              color: AppColors.sidebarProfileBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: ResponsiveLayout.isTablet(context) ? 14.r : 18.r,
                  backgroundColor: AppColors.aituRed,
                  child: Text(
                    'AH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveLayout.isTablet(context)
                          ? 11.sp
                          : 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveLayout.isTablet(context) ? 6.w : 10.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Dr. Ahmed',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: ResponsiveLayout.isTablet(context)
                              ? 11.sp
                              : 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: ResponsiveLayout.isTablet(context)
                              ? 9.sp
                              : 11.sp,
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
                    color: AppColors.textSecondary,
                    size: ResponsiveLayout.isTablet(context) ? 16.sp : 18.sp,
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().logout();
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

  bool _isRouteSelected(BuildContext context, String route) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    return currentRoute == route || currentRoute.startsWith('$route/');
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isSelected || _isHovered;
    final Color contentColor = isActive
        ? AppColors.primary
        : const Color(0xFF4A5568);
    final Color bgColor = widget.isSelected
        ? const Color(0xFFEBF4FF) // Very soft blue for selection
        : (_isHovered ? const Color(0xFFF7FAFC) : Colors.transparent);

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(widget.route),
          onHover: (hovered) {
            setState(() {
              _isHovered = hovered;
            });
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isTablet(context) ? 10.w : 16.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: contentColor,
                  size: ResponsiveLayout.isTablet(context) ? 18.sp : 20.sp,
                ),
                SizedBox(
                  width: ResponsiveLayout.isTablet(context) ? 8.w : 12.w,
                ),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: ResponsiveLayout.isTablet(context)
                          ? 12.sp
                          : 14.sp,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.label == 'Tasks & Tickets')
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.aituRed,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
