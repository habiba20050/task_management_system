import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management_system/features/teams/cubit/teams_cubit.dart';
import 'package:task_management_system/features/teams/ui/screens/teams_dashboard_screen.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/forget_password_page.dart';
import '../../features/auth/pages/verify_email_page.dart';
import '../../features/auth/pages/create_new_password_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/tasks/pages/tasks_page.dart';
import '../../features/users/pages/users_page.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../shared/widgets/main_layout.dart';
import '../dependency_injection/service_locator.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String verifyEmail = '/verify-email';
  static const String createNewPassword = '/create-new-password';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String taskDetails = '/tasks/:id';
  static const String team = '/team';
  static const String projects = '/projects';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String usersRoles = '/users-roles';

  static GoRouter get router => GoRouter(
    initialLocation: dashboard, // تغيير الصفحة الابتدائية إلى لوحة التحكم بعد تسجيل الدخول
    routes: [
      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: forgetPassword,
        name: 'forgetPassword',
        builder: (context, state) => const ForgetPasswordPage(),
      ),
      GoRoute(
        path: verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailPage(email: email);
        },
      ),
      GoRoute(
        path: createNewPassword,
        name: 'createNewPassword',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return CreateNewPasswordPage(email: email);
        },
      ),
      // App Routes
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) {
          final showMyTasks =
              state.uri.queryParameters['showMyTasks'] == 'true';
          return MainLayout(
            title: 'Dashboard',
            child: DashboardPage(showMyTasks: showMyTasks),
          );
        },
      ),
      GoRoute(
        path: tasks,
        name: 'tasks',
        builder: (context, state) =>
            const MainLayout(title: 'Tasks', child: TasksPage()),
      ),
      GoRoute(
        path: taskDetails,
        name: 'taskDetails',
        builder: (context, state) {
          final taskId = state.pathParameters['id'] ?? '';
          return MainLayout(
            title: 'Task Details',
            child: Scaffold(body: Center(child: Text('Task: $taskId'))),
          );
        },
      ),
      GoRoute(
        path: team,
        name: 'team',
        builder: (context, state) => MainLayout(
          title: 'Team',
          child: BlocProvider(
            create: (context) =>
                getIt<TeamsCubit>()
                  ..fetchTeams(), // استدعاء البيانات تلقائياً عند فتح الشاشة
            child: TeamsDashboardScreen(),
          ),
        ),
      ),
      GoRoute(
        path: projects,
        name: 'projects',
        builder: (context, state) => const MainLayout(
          title: 'Projects',
          child: Scaffold(body: Center(child: Text('Projects Page'))),
        ),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const MainLayout(
          title: 'Reports',
          child: Scaffold(body: Center(child: Text('Reports Page'))),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ProfileCubit>(),
          child: const MainLayout(
            title: 'Profile Settings',
            child: ProfilePage(),
          ),
        ),
      ),
      GoRoute(
        path: usersRoles,
        name: 'usersRoles',
        builder: (context, state) =>
            const MainLayout(title: 'Users & Roles', child: UsersPage()),
      ),
    ],
  );
}
