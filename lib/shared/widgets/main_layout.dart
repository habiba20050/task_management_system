import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors/app_colors.dart';
import '../../responsive/responsive_layout.dart';
import '../widgets/sidebar.dart';
import 'notification_drawer.dart';
import '../../features/language/cubit/language_cubit.dart';
import '../../core/localization/translate_extension.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../core/styles/app_spacing.dart';
import '../../core/styles/app_radius.dart';
import '../../core/styles/app_shadow.dart';
import '../../core/network/mock_database.dart';

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

    final String userFullName = authState is AuthSuccess ? (authState.user.fullName as String? ?? 'User') : 'User';
    final String userRole = authState is AuthSuccess ? (authState.user.role as String? ?? 'Team Member') : 'Team Member';
    final String userId = authState is AuthSuccess ? (authState.user.id as String? ?? '4') : '4';
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
      breadcrumbItems.add(Text('  /  ', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400)));
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
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: AppShadow.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumbs
          Row(children: breadcrumbItems),

          // Locale, Notifications & User menu
          Row(
            children: [
              // Language Switch Button
              InkWell(
                onTap: () {
                  final nextLang = lang == 'EN' ? 'AR' : 'EN';
                  context.read<LanguageCubit>().changeLanguage(nextLang);
                },
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                  child: Text(
                    lang == 'EN' ? 'العربية' : 'English',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Role Switcher Dropdown (for demo and switching screens)
              Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ['Admin', 'Manager', 'Team Leader', 'Team Member'].contains(userRole) ? userRole : 'Team Member',
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.notifications_outlined, size: 22.sp, color: AppColors.textSecondary),
                      Positioned(
                        right: -2.w,
                        top: -2.h,
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
                    CircleAvatar(
                      radius: 15.r,
                      backgroundColor: AppColors.aituRed,
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
      return Directionality(
        textDirection: textDir,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              title.tr(context),
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            actions: [
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
