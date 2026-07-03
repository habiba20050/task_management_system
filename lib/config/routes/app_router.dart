import 'dart:async';
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
import '../../features/users/ui/screens/users_roles_screen.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/reports/pages/reports_page.dart';
import '../../shared/widgets/main_layout.dart';
import '../dependency_injection/service_locator.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/complaints/pages/complaints_page.dart';
import '../../features/evaluations/pages/evaluations_page.dart';
import '../../features/tasks/pages/review_center_page.dart';
import '../../features/projects/pages/project_management_page.dart';
import '../../features/tasks/pages/tickets_page.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String verifyEmail = '/verify-email';
  static const String createNewPassword = '/create-new-password';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String tickets = '/tickets';
  static const String taskDetails = '/tasks/:id';
  static const String team = '/team';
  static const String projects = '/projects';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String usersRoles = '/users-roles';
  static const String complaints = '/complaints';
  static const String evaluations = '/evaluations';
  static const String reviewCenter = '/review-center';

  static GoRouter get router => GoRouter(
    initialLocation: dashboard,
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (context, state) {
      final authState = getIt<AuthCubit>().state;
      final isLoggingIn = state.uri.toString() == login ||
          state.uri.toString() == forgetPassword ||
          state.uri.toString() == verifyEmail ||
          state.uri.toString() == createNewPassword;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null; // Let the initialization page run
      }

      if (authState is! AuthSuccess) {
        return isLoggingIn ? null : login;
      }

      if (isLoggingIn) {
        return dashboard;
      }

      return null;
    },
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
          final args = state.extra as Map<String, dynamic>? ?? {};
          final email = args['email'] as String? ?? '';
          final otp = args['otp'] as String? ?? '';
          return CreateNewPasswordPage(email: email, otp: otp);
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
        path: tickets,
        name: 'tickets',
        builder: (context, state) =>
            const MainLayout(title: 'Tickets', child: TicketsPage()),
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
                  ..fetchTeams(),
            child: TeamsDashboardScreen(),
          ),
        ),
      ),
      GoRoute(
        path: projects,
        name: 'projects',
        builder: (context, state) => const MainLayout(
          title: 'Projects',
          child: ProjectManagementPage(),
        ),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const MainLayout(
          title: 'Reports',
          child: ReportsPage(),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => MainLayout(
          title: 'Profile Settings',
          child: BlocProvider(
            create: (context) => getIt<ProfileCubit>(),
            child: const ProfilePage(),
          ),
        ),
      ),
      GoRoute(
        path: usersRoles,
        name: 'usersRoles',
        builder: (context, state) => const MainLayout(
            title: 'Users & Roles', child: UsersRolesScreen()),
      ),
      GoRoute(
        path: complaints,
        name: 'complaints',
        builder: (context, state) => const MainLayout(
            title: 'Complaints', child: ComplaintsPage()),
      ),
      GoRoute(
        path: evaluations,
        name: 'evaluations',
        builder: (context, state) => const MainLayout(
            title: 'Evaluations', child: EvaluationsPage()),
      ),
      GoRoute(
        path: reviewCenter,
        name: 'reviewCenter',
        builder: (context, state) => const MainLayout(
            title: 'Review Center', child: ReviewCenterPage()),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
