import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../widgets/sidebar.dart';
import 'notification_drawer.dart';
import 'package:task_management_system/language/cubit/language_cubit.dart';
import '../../../core/localization/translate_extension.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../core/network/mock_database.dart';

class _MobileNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? route;
  const _MobileNavItem({required this.icon, required this.activeIcon, required this.label, this.route});
}

List<_MobileNavItem> _getMobileNavItems(String role) {
  final items = <_MobileNavItem>[
    _MobileNavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Dashboard', route: '/dashboard'),
  ];
  if (role == 'Admin' || role == 'Manager') {
    items.add(_MobileNavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Teams', route: '/team'));
  }
  items.add(_MobileNavItem(
    icon: Icons.checklist_outlined,
    activeIcon: Icons.checklist,
    label: role == 'Team Member' ? 'My Tasks' : 'Tasks',
    route: '/tasks',
  ));
  if (role == 'Admin' || role == 'Manager' || role == 'Team Leader') {
    items.add(_MobileNavItem(
      icon: Icons.rate_review_outlined,
      activeIcon: Icons.rate_review,
      label: 'Review Center',
      route: '/review-center',
    ));
  }
  if (role != 'Team Member') {
    items.add(_MobileNavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Reports',
      route: '/reports',
    ));
  }
  if (role != 'Manager' && role != 'Team Leader') {
    items.add(_MobileNavItem(icon: Icons.warning_amber_outlined, activeIcon: Icons.warning_amber, label: 'Complaints', route: '/complaints'));
  }
  if (role != 'Manager' && role != 'Team Leader') {
    items.add(_MobileNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: role == 'Team Member' ? 'Score & Achievements' : 'Evaluations',
      route: '/evaluations',
    ));
  }
  if (role != 'Manager' && role != 'Team Leader') {
    items.add(_MobileNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Profile Settings', route: '/settings'));
  }
  return items;
}

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageCubit>().state;
    final isRtl = lang == 'AR';
    final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final authState = context.watch<AuthCubit>().state;
    final db = MockDatabase.instance;

    final String userFullName = authState is AuthSuccess ? (authState.user.fullName ?? 'User') : 'User';
    final String userRole = authState is AuthSuccess ? authState.user.role : 'Team Member';
    final String userId = authState is AuthSuccess ? authState.user.id : '4';
    final initials = userFullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    // 1. Breadcrumb builder
    final location = GoRouterState.of(context).uri.toString();
    final List<String> paths = location.split('/').where((e) => e.isNotEmpty).toList();
    final List<Widget> breadcrumbItems = [];
    
    breadcrumbItems.add(
      GestureDetector(
        onTap: () => context.go('/dashboard'),
        child: Text('Home'.tr(context), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ),
    );

    for (int i = 0; i < paths.length; i++) {
      breadcrumbItems.add(Text('  /  ', style: TextStyle(fontSize: 10.sp, color: const Color(0xFFCBD5E1))));
      final label = paths[i].replaceAll('-', ' ').toUpperCase();
      breadcrumbItems.add(
        Text(
          label.tr(context),
          style: TextStyle(
            fontSize: 11.sp, 
            color: i == paths.length - 1 ? AppColors.primary : AppColors.textSecondary,
            fontWeight: i == paths.length - 1 ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      );
    }

    // 2. Header Layout
    final Widget globalHeader = Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumbs
          Row(children: breadcrumbItems),

          // Centered logo (tablet only)
          if (ResponsiveLayout.isTablet(context))
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/aitu_logo.png',
                        height: 62.h,
                        fit: BoxFit.contain,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جامعة أسيوط التكنولوجية',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Assiut Technological University',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 6.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Locale, Notifications & User menu
          Row(
            children: [
              // Language Switch Button
              InkWell(
                onTap: () {
                  final nextLang = lang == 'EN' ? 'AR' : 'EN';
                  context.read<LanguageCubit>().changeLanguage(nextLang);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 15, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Text(
                        lang == 'EN' ? 'العربية' : 'English',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Role Switcher Dropdown (for demo and switching screens)
              Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ['Admin', 'Manager', 'Team Leader', 'Team Member'].contains(userRole) ? userRole : 'Team Member',
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
                    items: ['Admin', 'Manager', 'Team Leader', 'Team Member']
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.tr(context),
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<AuthCubit>().switchUserRole(val);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Notifications Icon
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    db.markNotificationsRead(userId);
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(
                          child: Icon(Icons.notifications_outlined, size: 20, color: AppColors.textSecondary),
                        ),
                        Positioned(
                          right: 5.w,
                          top: 3.h,
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              db.notifications.where((n) => n.userId == userId && !n.isRead).length.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Profile Dropdown Menu
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'logout') {
                    context.read<AuthCubit>().logout();
                  } else if (val == 'profile') {
                    context.go('/settings');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        SizedBox(width: 8.w),
                        Text('Profile Settings'.tr(context)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 16, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Text('Logout'.tr(context), style: const TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(initials, style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 6.w),
                    if (!ResponsiveLayout.isTablet(context))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(userFullName, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text(userRole.tr(context), style: TextStyle(fontSize: 8.5.sp, color: AppColors.textSecondary)),
                        ],
                      ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );

    // 3. Layout Structuring (Mobile vs Desktop)
    if (ResponsiveLayout.isMobile(context)) {
      final mobileRoutes = _getMobileNavItems(userRole);
      final currentLocation = GoRouterState.of(context).uri.toString();

      int currentIndex = mobileRoutes.indexWhere((r) => r.route != null && currentLocation.startsWith(r.route!));
      if (currentIndex == -1) currentIndex = 0;

      return Directionality(
        textDirection: textDir,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 68.h,
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/aitu_logo.png',
                    height: 68.h,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جامعة أسيوط التكنولوجية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assiut Technological University',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                tooltip: lang == 'EN' ? 'العربية' : 'English',
                onPressed: () {
                  final nextLang = lang == 'EN' ? 'AR' : 'EN';
                  context.read<LanguageCubit>().changeLanguage(nextLang);
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  db.markNotificationsRead(userId);
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: Container(
              color: Colors.white,
              child: const Sidebar(),
            ),
          ),
          endDrawer: const NotificationDrawer(),
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (idx) {
              final route = mobileRoutes[idx].route;
              if (route != null) context.go(route);
            },
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: mobileRoutes
                .map((r) => NavigationDestination(
                      icon: Icon(r.icon),
                      selectedIcon: Icon(r.activeIcon),
                      label: r.label.tr(context),
                    ))
                .toList(),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        endDrawer: const NotificationDrawer(),
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Column(
                children: [
                  globalHeader,
                  Expanded(
                    child: child,
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
