import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/localization/translate_extension.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../../../responsive/responsive_layout.dart';

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
            color: Colors.black.withOpacity(0.04),
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
              ResponsiveLayout.isTablet(context) ? 12.w : 18.w,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: ResponsiveLayout.isTablet(context) ? 50.w : 64.w,
                  height: ResponsiveLayout.isTablet(context) ? 50.h : 64.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: ResponsiveLayout.isTablet(context) ? 8.w : 12.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'جامعة أسيوط التكنولوجية',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: ResponsiveLayout.isTablet(context) ? 9.sp : 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Assiut Technological\nUniversity',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: ResponsiveLayout.isTablet(context) ? 7.5.sp : 9.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
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
            child: Builder(
              builder: (context) {
                final authState = context.watch<AuthCubit>().state;
                final role = authState is AuthSuccess ? authState.user.role : 'Team Member';

                final List<Widget> navWidgets = [];
                
                navWidgets.add(_SidebarNavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Dashboard',
                  route: '/dashboard',
                  isSelected: _isRouteSelected(context, '/dashboard'),
                ));

                if (role == 'Admin' || role == 'Manager') {
                  navWidgets.add(_SidebarNavItem(
                    icon: Icons.people_outline,
                    label: 'Teams',
                    route: '/team',
                    isSelected: _isRouteSelected(context, '/team'),
                  ));
                }

                navWidgets.add(_SidebarNavItem(
                  icon: Icons.checklist_outlined,
                  label: role == 'Team Member' ? 'My Tasks' : 'Tasks',
                  route: '/tasks',
                  isSelected: _isRouteSelected(context, '/tasks'),
                ));

                if (role == 'Manager' || role == 'Team Leader') {
                  navWidgets.add(_SidebarNavItem(
                    icon: Icons.rate_review_outlined,
                    label: 'Review Center',
                    route: '/review-center',
                    isSelected: _isRouteSelected(context, '/review-center'),
                  ));
                }

                if (role != 'Team Member') {
                  navWidgets.add(_SidebarNavItem(
                    icon: Icons.description_outlined,
                    label: 'Reports',
                    route: '/reports',
                    isSelected: _isRouteSelected(context, '/reports'),
                  ));
                }

                if (role == 'Admin' || role == 'Manager') {
                  navWidgets.add(_SidebarNavItem(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Users & Roles',
                    route: '/users-roles',
                    isSelected: _isRouteSelected(context, '/users-roles'),
                  ));
                }

                navWidgets.add(_SidebarNavItem(
                  icon: Icons.warning_amber_outlined,
                  label: 'Complaints',
                  route: '/complaints',
                  isSelected: _isRouteSelected(context, '/complaints'),
                ));

                navWidgets.add(_SidebarNavItem(
                  icon: Icons.analytics_outlined,
                  label: role == 'Team Member' ? 'Score & Achievements' : 'Evaluations',
                  route: '/evaluations',
                  isSelected: _isRouteSelected(context, '/evaluations'),
                ));

                if (role == 'Admin' || role == 'Manager') {
                  navWidgets.add(_SidebarNavItem(
                    icon: Icons.history_outlined,
                    label: 'Audit Logs',
                    route: '/audit-logs',
                    isSelected: _isRouteSelected(context, '/audit-logs'),
                  ));
                }

                navWidgets.add(_SidebarNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Profile Settings',
                  route: '/settings',
                  isSelected: _isRouteSelected(context, '/settings'),
                ));

                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveLayout.isTablet(context) ? 8.w : 12.w,
                  ),
                  children: navWidgets,
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  bool _isRouteSelected(BuildContext context, String route) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith(route);
  }
}

class _SidebarNavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
            context.go(route);
          },
          borderRadius: BorderRadius.circular(10.r),
          hoverColor: Colors.grey.shade100,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8.w : 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                SizedBox(width: isTablet ? 8.w : 12.w),
                Expanded(
                  child: Text(
                    label.tr(context),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontSize: isTablet ? 11.sp : 13.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
