import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management_system/user/shared/features/teams/cubit/teams_cubit.dart';
import 'package:task_management_system/user/shared/features/teams/ui/screens/teams_dashboard_screen.dart';
import '../../user/manager/features/teams/ui/screens/teams_dashboard_screen.dart' as manager_teams;
import '../../user/shared/features/auth/pages/login_page.dart';
import '../../user/shared/features/auth/pages/forget_password_page.dart';
import '../../user/shared/features/auth/pages/verify_email_page.dart';
import '../../user/shared/features/auth/pages/create_new_password_page.dart';
import '../../user/shared/features/dashboard/pages/dashboard_page.dart' as shared_dash;
import '../../user/admin/features/dashboard/pages/dashboard_page.dart' as admin_dash;
import '../../user/manager/features/dashboard/pages/dashboard_page.dart' as manager_dash;
import '../../user/team_leader/features/dashboard/pages/dashboard_page.dart' as leader_dash;
import '../../user/team_member/features/dashboard/pages/dashboard_page.dart' as member_dash;
import '../../user/shared/features/tasks/pages/tasks_page.dart';
import '../../user/admin/features/tasks/pages/tasks_page.dart' as admin_tasks;
import '../../user/manager/features/tasks/pages/tasks_page.dart' as manager_tasks;
import '../../user/team_leader/features/tasks/pages/tasks_page.dart' as leader_tasks;
import '../../user/team_member/features/tasks/pages/tasks_page.dart' as member_tasks;
import '../../user/shared/features/tasks/pages/task_details_page.dart';
import '../../user/team_leader/features/tasks/pages/task_details_page.dart' as leader_task_details;
import '../../user/manager/features/tasks/pages/task_details_page.dart' as manager_task_details;
import '../../user/team_member/features/tasks/pages/task_details_page.dart' as member_task_details;
import '../../user/shared/features/users/ui/screens/users_roles_screen.dart';
import '../../user/shared/features/profile/pages/profile_page.dart';
import '../../user/shared/features/profile/cubit/profile_cubit.dart';
import '../../user/shared/features/reports/pages/reports_page.dart';
import '../../user/team_leader/features/reports/pages/reports_page.dart' as leader_reports;
import '../../user/manager/features/reports/pages/reports_page.dart' as manager_reports;
import '../../user/shared/features/audit_log/pages/audit_log_page.dart';
import '../../user/manager/features/audit_log/pages/audit_log_page.dart' as manager_audit;
import '../../user/shared/widgets/main_layout.dart';
import '../dependency_injection/service_locator.dart';
import '../../user/shared/features/auth/cubit/auth_cubit.dart';
import '../../user/shared/features/complaints/pages/complaints_page.dart';
import '../../user/team_member/features/complaints/pages/complaints_page.dart' as member_complaints;
import '../../user/team_leader/features/complaints/pages/complaints_page.dart' as leader_complaints;
import '../../user/manager/features/complaints/pages/complaints_page.dart' as manager_complaints;
import '../../user/shared/features/evaluations/pages/evaluations_page.dart';
import '../../user/team_member/features/evaluations/pages/evaluations_page.dart' as member_evals;
import '../../user/team_leader/features/evaluations/pages/evaluations_page.dart' as leader_evals;
import '../../user/manager/features/evaluations/pages/evaluations_page.dart' as manager_evals;
import '../../user/team_member/features/profile/pages/profile_page.dart' as member_profile;
import '../../user/team_leader/features/profile/pages/profile_page.dart' as leader_profile;
import '../../user/manager/features/profile/pages/profile_page.dart' as manager_profile;
import '../../user/shared/features/tasks/pages/review_center_page.dart';
import '../../user/team_leader/features/tasks/pages/review_center_page.dart' as leader_review;
import '../../user/admin/features/tasks/pages/review_center_page.dart' as admin_review;
import '../../user/manager/features/tasks/pages/review_center_page.dart' as manager_review;

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
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String usersRoles = '/users-roles';
  static const String complaints = '/complaints';
  static const String evaluations = '/evaluations';
  static const String reviewCenter = '/review-center';
  static const String auditLogs = '/audit-logs';

  static final GoRouter router = _buildRouter();

  static GoRouter _buildRouter() {
    return GoRouter(
    initialLocation: dashboard,
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (context, state) {
      final authState = getIt<AuthCubit>().state;
      final isLoggingIn = state.uri.toString() == login ||
          state.uri.toString() == forgetPassword ||
          state.uri.toString() == verifyEmail ||
          state.uri.toString() == createNewPassword;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
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
      // App Shell Routes
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            title: '',
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) {
              final showMyTasks = state.uri.queryParameters['showMyTasks'] == 'true';
              return _DashboardResolver(showMyTasks: showMyTasks);
            },
          ),
          GoRoute(
            path: tasks,
            name: 'tasks',
            builder: (context, state) => const _TasksResolver(),
          ),
          GoRoute(
            path: taskDetails,
            name: 'taskDetails',
            builder: (context, state) {
              final taskId = state.pathParameters['id'] ?? '';
              return _TaskDetailsResolver(taskId: taskId);
            },
          ),
          GoRoute(
            path: team,
            name: 'team',
            builder: (context, state) => BlocProvider(
              create: (context) => getIt<TeamsCubit>()..fetchTeams(),
              child: const _TeamsResolver(),
            ),
          ),
          GoRoute(
            path: reports,
            name: 'reports',
            builder: (context, state) => const _ReportsResolver(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => BlocProvider(
              create: (context) => getIt<ProfileCubit>(),
              child: const _ProfileResolver(),
            ),
          ),
          GoRoute(
            path: usersRoles,
            name: 'usersRoles',
            builder: (context, state) => const UsersRolesScreen(),
          ),
          GoRoute(
            path: complaints,
            name: 'complaints',
            builder: (context, state) => const _ComplaintsResolver(),
          ),
          GoRoute(
            path: evaluations,
            name: 'evaluations',
            builder: (context, state) => const _EvaluationsResolver(),
          ),
          GoRoute(
            path: reviewCenter,
            name: 'reviewCenter',
            builder: (context, state) => const _ReviewCenterResolver(),
          ),
          GoRoute(
            path: auditLogs,
            name: 'auditLogs',
            builder: (context, state) => const _AuditLogsResolver(),
          ),
        ],
      ),
    ],
  );
  }
}

/// Routes to the correct [DashboardPage] based on the current user role.
class _DashboardResolver extends StatelessWidget {
  final bool showMyTasks;
  const _DashboardResolver({this.showMyTasks = false});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Admin':
          return admin_dash.DashboardPage(showMyTasks: showMyTasks);
        case 'Manager':
          return manager_dash.DashboardPage(showMyTasks: showMyTasks);
        case 'Team Leader':
          return leader_dash.DashboardPage(showMyTasks: showMyTasks);
        case 'Team Member':
          return member_dash.DashboardPage(showMyTasks: showMyTasks);
      }
    }
    return shared_dash.DashboardPage(showMyTasks: showMyTasks);
  }
}

/// Routes to the correct [TasksPage] based on the current user role.
class _TasksResolver extends StatelessWidget {
  const _TasksResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Admin':
          return const admin_tasks.TasksPage();
        case 'Manager':
          return const manager_tasks.TasksPage();
        case 'Team Leader':
          return const leader_tasks.TasksPage();
        case 'Team Member':
          return const member_tasks.TasksPage();
      }
    }
    return const TasksPage();
  }
}

/// Routes to the correct [ReportsPage] based on the current user role.
class _ReportsResolver extends StatelessWidget {
  const _ReportsResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      if (authState.user.role == 'Team Leader') {
        return const leader_reports.ReportsPage();
      } else if (authState.user.role == 'Manager') {
        return const manager_reports.ReportsPage();
      }
    }
    return const ReportsPage();
  }
}

/// Routes to the correct [ComplaintsPage] based on the current user role.
class _ComplaintsResolver extends StatelessWidget {
  const _ComplaintsResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Team Member':
          return const member_complaints.ComplaintsPage();
        case 'Team Leader':
          return const leader_complaints.ComplaintsPage();
        case 'Manager':
          return const manager_complaints.ComplaintsPage();
      }
    }
    return const ComplaintsPage();
  }
}

/// Routes to the correct [ProfilePage] based on the current user role.
class _ProfileResolver extends StatelessWidget {
  const _ProfileResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Team Member':
          return const member_profile.ProfilePage();
        case 'Team Leader':
          return const leader_profile.ProfilePage();
        case 'Manager':
          return const manager_profile.ProfilePage();
      }
    }
    return const ProfilePage();
  }
}

/// Routes to the correct [ReviewCenterPage] based on the current user role.
class _ReviewCenterResolver extends StatelessWidget {
  const _ReviewCenterResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Team Leader':
          return const leader_review.ReviewCenterPage();
        case 'Admin':
          return const admin_review.ReviewCenterPage();
        case 'Manager':
          return const manager_review.ReviewCenterPage();

      }
    }
    return const ReviewCenterPage();
  }
}

/// Routes to the correct [TaskDetailsPage] based on the current user role.
class _TaskDetailsResolver extends StatelessWidget {
  final String taskId;
  const _TaskDetailsResolver({required this.taskId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      if (authState.user.role == 'Team Leader') {
        return leader_task_details.TaskDetailsPage(taskId: taskId);
      }
      if (authState.user.role == 'Manager') {
        return manager_task_details.TaskDetailsPage(taskId: taskId);
      }
      if (authState.user.role == 'Team Member') {
        return member_task_details.TaskDetailsPage(taskId: taskId);
      }
    }
    return TaskDetailsPage(taskId: taskId);
  }
}

/// Routes to the correct [EvaluationsPage] based on the current user role.
class _EvaluationsResolver extends StatelessWidget {
  const _EvaluationsResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess) {
      switch (authState.user.role) {
        case 'Team Member':
          return const member_evals.EvaluationsPage();
        case 'Team Leader':
          return const leader_evals.EvaluationsPage();
        case 'Manager':
          return const manager_evals.EvaluationsPage();
      }
    }
    return const EvaluationsPage();
  }
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

/// Routes to the correct [TeamsDashboardScreen] based on the current user role.
class _TeamsResolver extends StatelessWidget {
  const _TeamsResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess && authState.user.role == 'Manager') {
      return const manager_teams.TeamsDashboardScreen();
    }
    return const TeamsDashboardScreen();
  }
}

/// Routes to the correct [AuditLogPage] based on the current user role.
class _AuditLogsResolver extends StatelessWidget {
  const _AuditLogsResolver();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthSuccess && authState.user.role == 'Manager') {
      return const manager_audit.AuditLogPage();
    }
    return const AuditLogPage();
  }
}
