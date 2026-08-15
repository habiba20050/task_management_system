import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../core/localization/translate_extension.dart';
import '../../../../../core/network/mock_database.dart';
import '../../../../../responsive/responsive_layout.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import 'package:task_management_system/auth/model/user_model.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Evaluation form state
  double _qQuality = 4.0;
  double _qComm = 4.0;
  double _qTeam = 4.0;
  double _qDisc = 4.0;
  double _qProb = 4.0;
  double _qDead = 4.0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _recController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _recController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved' || status == 'Closed') return AppColors.success;
    if (status == 'Open') return AppColors.danger;
    return Colors.orange;
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return Colors.orange;
    return AppColors.danger;
  }

  String _getScoreLabel(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Average';
    return 'Needs Improvement';
  }

  // ─── Modern UI helpers ────────────────────────────────────────────────────
  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _gradientChip(IconData icon, Color color, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, _darker(color)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  Widget _avatar(String name, double size, Color color) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: color,
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _scorePill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _rankBadge(int rank) {
    final isTop = rank <= 3;
    final colors = isTop
        ? [const Color(0xFFFFC107), const Color(0xFFF9A825)]
        : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)];
    return Container(
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: isTop ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    double height = 50,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: EdgeInsets.all(14.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.sp,
        color: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthSuccess
        ? authState.user
        : UserModel(
            id: '1',
            email: '',
            username: '',
            fullName: 'Manager',
            role: 'Manager');
    final currentUserId = user.id;

    // Get manager's mock data
    final managerMock = db.users.cast<MockUser?>().firstWhere(
          (u) => u?.id == currentUserId,
          orElse: () => null,
        );
    final myDept = managerMock?.department ?? 'Computer Science';

    // All users in department
    final deptTeams = db.teams.where((t) => t.department == myDept).toList();
    final deptTeamLeaders =
        db.users.where((u) => u.role == 'Team Leader' && u.department == myDept).toList();
    final deptMembers =
        db.users.where((u) => u.role == 'Team Member' && u.department == myDept).toList();

    // Sort by score for rankings
    final sortedLeaders = List<MockUser>.from(deptTeamLeaders)
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    final sortedMembers = List<MockUser>.from(deptMembers)
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));

    // Best & worst
    final bestLeader = sortedLeaders.isNotEmpty ? sortedLeaders.first : null;
    final worstLeader = sortedLeaders.length > 1 ? sortedLeaders.last : null;
    final bestMember = sortedMembers.isNotEmpty ? sortedMembers.first : null;
    final worstMember = sortedMembers.length > 1 ? sortedMembers.last : null;

    final avgScore = sortedMembers.isEmpty
        ? 0.0
        : sortedMembers.map((u) => u.finalScore).reduce((a, b) => a + b) /
            sortedMembers.length;
    final avgLeaderScore = sortedLeaders.isEmpty
        ? 0.0
        : sortedLeaders.map((u) => u.finalScore).reduce((a, b) => a + b) /
            sortedLeaders.length;

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientChip(Icons.insights_outlined, AppColors.primary, size: 44),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Evaluations'.tr(context),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '$myDept · ${'Department Rankings & Scores'.tr(context)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.all(6.w),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: ResponsiveLayout.isMobile(context),
                  tabAlignment:
                      ResponsiveLayout.isMobile(context) ? TabAlignment.center : TabAlignment.fill,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, _darker(AppColors.primary)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ResponsiveLayout.isMobile(context)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.groups_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Department Overview'.tr(context)),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.groups_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Department Overview'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ResponsiveLayout.isMobile(context)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('My Score'.tr(context)),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('My Score'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Department Overview
                    _buildDepartmentTab(
                      context,
                      db,
                      isDesktop,
                      currentUserId,
                      deptTeams: deptTeams,
                      sortedLeaders: sortedLeaders,
                      sortedMembers: sortedMembers,
                      bestLeader: bestLeader,
                      worstLeader: worstLeader,
                      bestMember: bestMember,
                      worstMember: worstMember,
                      avgScore: avgScore,
                      avgLeaderScore: avgLeaderScore,
                    ),

                    // Tab 2: Manager's own score
                    _buildMyScoreTab(context, managerMock),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 1: Department Overview ──────────────────────────────────────────
  Widget _buildDepartmentTab(
    BuildContext context,
    MockDatabase db,
    bool isDesktop,
    String currentUserId, {
    required List<MockTeam> deptTeams,
    required List<MockUser> sortedLeaders,
    required List<MockUser> sortedMembers,
    required MockUser? bestLeader,
    required MockUser? worstLeader,
    required MockUser? bestMember,
    required MockUser? worstMember,
    required double avgScore,
    required double avgLeaderScore,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI Summary Bar ──
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w < 600 ? 2 : (w < 1000 ? 3 : 5);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 2.0,
              children: [
                _kpiCard(context, 'Teams'.tr(context), deptTeams.length.toString(),
                    Icons.group_work_outlined, AppColors.primary),
                _kpiCard(context, 'Team Leaders'.tr(context), sortedLeaders.length.toString(),
                    Icons.supervisor_account_outlined, Colors.indigo),
                _kpiCard(context, 'Members'.tr(context), sortedMembers.length.toString(),
                    Icons.person_outlined, Colors.blueGrey),
                _kpiCard(context, 'Avg Member Score'.tr(context),
                    '${avgScore.toStringAsFixed(1)}%', Icons.analytics_outlined,
                    _getScoreColor(avgScore)),
                _kpiCard(context, 'Avg Leader Score'.tr(context),
                    '${avgLeaderScore.toStringAsFixed(1)}%', Icons.star_border_outlined,
                    _getScoreColor(avgLeaderScore)),
              ],
            );
          }),
          SizedBox(height: 22.h),

          // ── Best / Worst Rankings ──
          _sectionTitle('Department Rankings'.tr(context)),
          SizedBox(height: 12.h),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth < 600 ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                mainAxisExtent: 100.h,
              ),
              itemCount: 4,
              itemBuilder: (context, i) {
                switch (i) {
                  case 0:
                    return _rankingCard(context, 'Best Team Leader'.tr(context),
                        bestLeader, Icons.emoji_events_outlined, Colors.amber);
                  case 1:
                    return _rankingCard(context, 'Needs Improvement (Leader)'.tr(context),
                        worstLeader, Icons.trending_down, AppColors.danger);
                  case 2:
                    return _rankingCard(context, 'Best Team Member'.tr(context),
                        bestMember, Icons.emoji_events_outlined, AppColors.success);
                  default:
                    return _rankingCard(context, 'Needs Improvement (Member)'.tr(context),
                        worstMember, Icons.trending_down, AppColors.danger);
                }
              },
            );
          }),
          SizedBox(height: 24.h),

          // ── Team Leaders Section ──
          _sectionTitle('Team Leaders'.tr(context)),
          SizedBox(height: 12.h),
          sortedLeaders.isEmpty
              ? _emptyState(context, 'No team leaders in this department'.tr(context))
              : _buildMemberGrid(context, db, sortedLeaders, currentUserId, isDesktop),
          SizedBox(height: 24.h),

          // ── Team Members Section ──
          _sectionTitle('Team Members'.tr(context)),
          SizedBox(height: 12.h),
          sortedMembers.isEmpty
              ? _emptyState(context, 'No team members in this department'.tr(context))
              : _buildMemberGrid(context, db, sortedMembers, currentUserId, isDesktop),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _kpiCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _modernCardDecoration(),
      child: Row(
        children: [
          _gradientChip(icon, color, size: 40),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankingCard(
    BuildContext context,
    String title,
    MockUser? u,
    IconData icon,
    Color accent,
  ) {
    if (u == null) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: _modernCardDecoration(),
        child: Row(
          children: [
            _gradientChip(icon, accent, size: 38),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text('N/A', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _modernCardDecoration(),
      child: Row(
        children: [
          _gradientChip(icon, accent, size: 38),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  u.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${u.finalScore.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: accent),
              ),
              SizedBox(height: 2.h),
              _scorePill(_getScoreLabel(u.finalScore).tr(context), accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberGrid(
    BuildContext context,
    MockDatabase db,
    List<MockUser> users,
    String currentUserId,
    bool isDesktop,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = isDesktop ? 3 : (constraints.maxWidth < 600 ? 1 : 2);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: 162.h,
        ),
        itemCount: users.length,
        itemBuilder: (context, idx) {
          return _memberCard(context, db, users[idx], currentUserId, idx + 1);
        },
      );
    });
  }

  Widget _memberCard(BuildContext context, MockDatabase db, MockUser u, String currentUserId, int rank) {
    final color = _getScoreColor(u.finalScore);
    final completedTasks = db.tasks
        .where((t) => t.currentOwnerId == u.id && (t.status == 'Completed' || t.status == 'Approved'))
        .length;
    final overdueTasks =
        db.tasks.where((t) => t.currentOwnerId == u.id && t.status == 'Overdue').length;

    return InkWell(
      onTap: () => _showEmployee360Modal(context, u, currentUserId),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: _modernCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _rankBadge(rank),
                SizedBox(width: 8.w),
                _avatar(u.fullName, 34, color),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.fullName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        u.role.tr(context),
                        style: TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${u.finalScore.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color),
                    ),
                    SizedBox(height: 3.h),
                    _scorePill(_getScoreLabel(u.finalScore).tr(context), color),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                      context, Icons.check_circle_outline, '$completedTasks',
                      'Done'.tr(context), AppColors.success),
                ),
                Expanded(
                  child: _miniStat(
                      context, Icons.timer_off_outlined, '$overdueTasks',
                      'Overdue'.tr(context), AppColors.danger),
                ),
                Expanded(
                  child: _miniStat(
                      context, Icons.star_outlined, '${u.points}',
                      'Points'.tr(context), Colors.amber),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: u.finalScore / 100.0,
                minHeight: 6.h,
                backgroundColor: const Color(0xFFF1F5F9),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(BuildContext context, IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 26.r,
          height: 26.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, _darker(color, 0.12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 13.sp, color: Colors.white),
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(label, style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, String msg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: _modernCardDecoration(),
      child: Column(
        children: [
          _gradientChip(Icons.people_outline, AppColors.textSecondary, size: 44),
          SizedBox(height: 10.h),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Manager's own score ──────────────────────────────────────────
  Widget _buildMyScoreTab(BuildContext context, MockUser? managerMock) {
    if (managerMock == null) {
      return Center(child: Text('Manager data not found.'.tr(context)));
    }

    final scoreColor = _getScoreColor(managerMock.finalScore);
    final db = MockDatabase.instance;
    final completedTasks = db.tasks
        .where((t) => t.currentOwnerId == managerMock.id && (t.status == 'Completed' || t.status == 'Approved'))
        .length;
    final activeTasks = db.tasks
        .where((t) => t.currentOwnerId == managerMock.id && t.status != 'Completed' && t.status != 'Approved')
        .length;
    final evalHistory =
        db.evaluations.where((e) => e.employeeId == managerMock.id).toList();

    return SingleChildScrollView(
      key: const PageStorageKey('my_score_tab'),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: _modernCardDecoration(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                final scoreRing = Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 108.r,
                      height: 108.r,
                      child: CircularProgressIndicator(
                        value: managerMock.finalScore / 100.0,
                        strokeWidth: 7.r,
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: scoreColor,
                      ),
                    ),
                    _avatar(managerMock.fullName, 78, scoreColor),
                  ],
                );
                final info = Column(
                  crossAxisAlignment:
                      compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      managerMock.fullName,
                      textAlign: compact ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Manager · ${managerMock.department}'.tr(context),
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _getScoreLabel(managerMock.finalScore).tr(context),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                    ),
                  ],
                );
                final scoreBox = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${managerMock.finalScore.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: scoreColor),
                    ),
                    Text(
                      'Final Score'.tr(context),
                      style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                    ),
                  ],
                );

                if (compact) {
                  return Column(
                    children: [
                      scoreRing,
                      SizedBox(height: 16.h),
                      info,
                      SizedBox(height: 14.h),
                      scoreBox,
                    ],
                  );
                }
                return Row(
                  children: [
                    scoreRing,
                    SizedBox(width: 22.w),
                    Expanded(child: info),
                    scoreBox,
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Metrics grid
          _sectionTitle('Performance Breakdown'.tr(context)),
          SizedBox(height: 12.h),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth < 600 ? 2 : 4;
            final metrics = [
              _MetricData('Productivity'.tr(context), managerMock.productivityScore, Icons.speed_outlined, AppColors.primary),
              _MetricData('Deadline Commit.'.tr(context), managerMock.deadlineCommitment, Icons.timer_outlined, Colors.indigo),
              _MetricData('Approval Rate'.tr(context), managerMock.approvalRate, Icons.check_circle_outline, AppColors.success),
              _MetricData('Leader Eval.'.tr(context), managerMock.leaderEvaluation, Icons.star_border_outlined, Colors.amber),
              _MetricData('Rejection Rate'.tr(context), managerMock.rejectionRate, Icons.cancel_outlined, AppColors.danger),
              _MetricData('Tasks Done'.tr(context), completedTasks * 10.0, Icons.task_alt_outlined, Colors.teal),
              _MetricData('Active Tasks'.tr(context), activeTasks * 10.0, Icons.pending_actions_outlined, Colors.orange),
              _MetricData('Points'.tr(context), managerMock.points.toDouble(), Icons.emoji_events_outlined, Colors.amber),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                mainAxisExtent: 132.h,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, i) {
                final m = metrics[i];
                final isTaskMetric = m.label == 'Tasks Done'.tr(context) || m.label == 'Active Tasks'.tr(context);
                final displayVal = m.label == 'Points'.tr(context)
                    ? managerMock.points.toString()
                    : isTaskMetric
                        ? (m.label == 'Tasks Done'.tr(context) ? completedTasks.toString() : activeTasks.toString())
                        : '${m.value.toStringAsFixed(1)}%';
                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: _modernCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _gradientChip(m.icon, m.color, size: 36),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayVal,
                            maxLines: 1,
                            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: m.color),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        m.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          SizedBox(height: 22.h),

          // Evaluation history
          _sectionTitle('Evaluation History'.tr(context)),
          SizedBox(height: 12.h),
          if (evalHistory.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: _modernCardDecoration(),
              child: Column(
                children: [
                  _gradientChip(Icons.assessment_outlined, AppColors.textSecondary, size: 40),
                  SizedBox(height: 8.h),
                  Text(
                    'No evaluations recorded yet.'.tr(context),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                  ),
                ],
              ),
            )
          else
            Column(
              children: evalHistory.reversed.map((ev) {
                final avg = ((ev.taskQuality +
                            ev.communication +
                            ev.teamwork +
                            ev.discipline +
                            ev.problemSolving +
                            ev.deadlineCommitment) /
                        6 *
                        20);
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: _modernCardDecoration(),
                  child: Row(
                    children: [
                      _gradientChip(Icons.assessment_outlined, AppColors.primary, size: 40),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evaluation – ${ev.date}',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Avg Score: ${avg.toStringAsFixed(1)}% · ${ev.managerNotes.isNotEmpty ? ev.managerNotes : 'No notes'.tr(context)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _scorePill('${avg.toStringAsFixed(0)}%', _getScoreColor(avg)),
                    ],
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ─── 360° Employee Dialog ────────────────────────────────────────────────
  void _showEmployee360Modal(BuildContext context, MockUser emp, String currentUserId) {
    final db = MockDatabase.instance;
    final activeTasks = db.tasks
        .where((t) => t.currentOwnerId == emp.id && t.status != 'Completed' && t.status != 'Approved')
        .toList();
    final completedTasks = db.tasks
        .where((t) => t.currentOwnerId == emp.id && (t.status == 'Completed' || t.status == 'Approved'))
        .toList();
    final overdueCount =
        db.tasks.where((t) => t.currentOwnerId == emp.id && t.status == 'Overdue').length;
    final empComplaints = db.complaints.where((c) => c.targetId == emp.id).toList();
    final empEvals = db.evaluations.where((e) => e.employeeId == emp.id).toList();
    final initials = _initials(emp.fullName);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Column(
                children: [
                  // Dialog header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 10.w, 20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, _darker(AppColors.primary)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emp.fullName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${emp.role.tr(context)} · ${emp.department.tr(context)}',
                                style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${emp.finalScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _getScoreLabel(emp.finalScore).tr(context),
                              style: TextStyle(fontSize: 9.sp, color: Colors.white70),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                          tooltip: 'Close'.tr(context),
                        ),
                      ],
                    ),
                  ),
                  // Tab content
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.primary,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                            dividerColor: Colors.transparent,
                            tabs: [
                              Tab(text: 'Profile'.tr(context)),
                              Tab(text: 'Tasks & Quality'.tr(context)),
                              Tab(text: 'Evaluate'.tr(context)),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Tab 1 – Profile
                                ListView(
                                  padding: EdgeInsets.all(20.w),
                                  children: [
                                    _profileRow(context, Icons.email_outlined, 'Email'.tr(context), emp.email),
                                    _profileRow(context, Icons.phone_outlined, 'Phone'.tr(context), emp.phone),
                                    _profileRow(context, Icons.business_outlined, 'Department'.tr(context), emp.department.tr(context)),
                                    Divider(color: const Color(0xFFE2E8F0), height: 24),
                                    _profileRow(context, Icons.speed_outlined, 'Productivity'.tr(context), '${emp.productivityScore.toInt()}%'),
                                    _profileRow(context, Icons.timer_outlined, 'Deadline Commit.'.tr(context), '${emp.deadlineCommitment.toInt()}%'),
                                    _profileRow(context, Icons.check_circle_outline, 'Approval Rate'.tr(context), '${emp.approvalRate.toInt()}%'),
                                    _profileRow(context, Icons.star_border_outlined, 'Leader Evaluation'.tr(context), '${emp.leaderEvaluation.toInt()}%'),
                                    _profileRow(context, Icons.emoji_events_outlined, 'Points'.tr(context), emp.points.toString()),
                                  ],
                                ),

                                // Tab 2 – Tasks & Complaints
                                ListView(
                                  padding: EdgeInsets.all(20.w),
                                  children: [
                                    Text(
                                      'Task Summary'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        _taskChip('${activeTasks.length}', 'Active'.tr(context), AppColors.primary),
                                        SizedBox(width: 10.w),
                                        _taskChip('${completedTasks.length}', 'Done'.tr(context), AppColors.success),
                                        SizedBox(width: 10.w),
                                        _taskChip('$overdueCount', 'Overdue'.tr(context), AppColors.danger),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Text(
                                      'Complaints Log (${empComplaints.length})'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.danger,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Divider(color: const Color(0xFFE2E8F0), height: 20),
                                    if (empComplaints.isEmpty)
                                      Text(
                                        'No complaints on record.'.tr(context),
                                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                                      )
                                    else
                                      ...empComplaints.map((c) => _complaintTile(context, c)),
                                    SizedBox(height: 20.h),
                                    Text(
                                      'Evaluation History (${empEvals.length})'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Divider(color: const Color(0xFFE2E8F0), height: 20),
                                    if (empEvals.isEmpty)
                                      Text(
                                        'No evaluations yet.'.tr(context),
                                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                                      )
                                    else
                                      ...empEvals.map((ev) => _dialogEvalTile(context, ev)),
                                  ],
                                ),

                                // Tab 3 – Evaluation Form
                                ListView(
                                  padding: EdgeInsets.all(20.w),
                                  children: [
                                    Text(
                                      'Submit New Evaluation'.tr(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Rate the employee across six core competencies.'.tr(context),
                                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildRatingSlider(context, 'Task Quality', _qQuality, (v) => setDialogState(() => _qQuality = v)),
                                    _buildRatingSlider(context, 'Communication', _qComm, (v) => setDialogState(() => _qComm = v)),
                                    _buildRatingSlider(context, 'Teamwork', _qTeam, (v) => setDialogState(() => _qTeam = v)),
                                    _buildRatingSlider(context, 'Discipline', _qDisc, (v) => setDialogState(() => _qDisc = v)),
                                    _buildRatingSlider(context, 'Problem Solving', _qProb, (v) => setDialogState(() => _qProb = v)),
                                    _buildRatingSlider(context, 'Deadline Commitment', _qDead, (v) => setDialogState(() => _qDead = v)),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Manager Notes'.tr(context),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    TextField(
                                      controller: _notesController,
                                      maxLines: 3,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                      decoration: _fieldDecoration('Add evaluation notes...'.tr(context)),
                                    ),
                                    SizedBox(height: 14.h),
                                    Text(
                                      'Recommendations'.tr(context),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    TextField(
                                      controller: _recController,
                                      maxLines: 3,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                      decoration: _fieldDecoration('Add recommendations...'.tr(context)),
                                    ),
                                    SizedBox(height: 22.h),
                                    _gradientButton(
                                      label: 'Submit Evaluation'.tr(context),
                                      icon: Icons.send_outlined,
                                      colors: [AppColors.primary, _darker(AppColors.primary)],
                                      onTap: () {
                                        setState(() {
                                          db.addEvaluation(
                                            MockEvaluation(
                                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                                              evaluatorId: currentUserId,
                                              employeeId: emp.id,
                                              taskQuality: _qQuality,
                                              communication: _qComm,
                                              teamwork: _qTeam,
                                              discipline: _qDisc,
                                              problemSolving: _qProb,
                                              deadlineCommitment: _qDead,
                                              managerNotes: _notesController.text,
                                              recommendations: _recController.text,
                                              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                            ),
                                            currentUserId,
                                          );
                                          _notesController.clear();
                                          _recController.clear();
                                          _qQuality = _qComm = _qTeam = _qDisc = _qProb = _qDead = 4.0;
                                        });
                                        Navigator.pop(context);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Evaluation submitted successfully!'.tr(context)),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          _gradientChip(icon, AppColors.primary, size: 34),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(fontSize: 9.sp, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _complaintTile(BuildContext context, MockComplaint c) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.report_outlined, color: _getStatusColor(c.status), size: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${c.category.tr(context)} · ${c.date}',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _scorePill(c.status.tr(context), _getStatusColor(c.status)),
        ],
      ),
    );
  }

  Widget _dialogEvalTile(BuildContext context, MockEvaluation ev) {
    final avg = ((ev.taskQuality +
                ev.communication +
                ev.teamwork +
                ev.discipline +
                ev.problemSolving +
                ev.deadlineCommitment) /
            6 *
            20);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _gradientChip(Icons.assessment_outlined, AppColors.success, size: 36),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${ev.date}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Quality: ${ev.taskQuality}/5 · Notes: ${ev.managerNotes.isEmpty ? 'N/A' : ev.managerNotes}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _scorePill('${avg.toStringAsFixed(0)}%', _getScoreColor(avg)),
        ],
      ),
    );
  }

  Widget _buildRatingSlider(
    BuildContext context,
    String label,
    double val,
    ValueChanged<double> onChanged,
  ) {
    final stars = List.generate(5, (i) => i < val.toInt());
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.tr(context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...stars.map(
                (filled) => Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFFFC107),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${val.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            ),
            child: Slider(value: val, min: 1.0, max: 5.0, divisions: 4, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  const _MetricData(this.label, this.value, this.icon, this.color);
}
