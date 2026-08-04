import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/features/teams/cubit/teams_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../shared/features/teams/cubit/teams_state.dart';
import '../widgets/create_team_dialog_widget.dart';
import '../widgets/assign_member_to_team_dialog_widget.dart';
import 'team_details_screen.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../responsive/responsive_layout.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import '../../../../../shared/features/auth/cubit/auth_cubit.dart';

class TeamsDashboardScreen extends StatefulWidget {
  const TeamsDashboardScreen({super.key});

  @override
  State<TeamsDashboardScreen> createState() => _TeamsDashboardScreenState();
}

class _TeamsDashboardScreenState extends State<TeamsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _teamSearch = '';
  String _empSearch  = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    // ── المدير الحالي ───────────────────────────────────────────────
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : '';
    final mockManager = db.users.firstWhere(
      (u) => u.id == currentUserId,
      orElse: () => db.users.firstWhere((u) => u.role == 'Manager', orElse: () => db.users.first),
    );
    final managerDept = mockManager.department;

    // ── بيانات الفرق والموظفين الخاصة بالمدير ─────────────────────
    final myRawTeamIds = db.teams.where((t) => t.managerId == currentUserId).map((t) => t.id).toSet();
    final myMemberIds  = db.teams.where((t) => t.managerId == currentUserId).expand((t) => t.memberIds).toSet();
    final myLeaderIds  = db.teams.where((t) => t.managerId == currentUserId).map((t) => t.leaderId).toSet();
    final allSubIds    = {...myMemberIds, ...myLeaderIds};

    // الموظفون (Team Leaders + Team Members) تحت إشراف المدير
    final myEmployees = db.users.where((u) => allSubIds.contains(u.id)).toList();

    final mobileTabHeight = MediaQuery.of(context).size.height * 0.5;

    final tabBarView = TabBarView(
      controller: _tabController,
      children: [
        // ── Teams Tab ───────────────────────────────────────────────
        BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            if (state is TeamsLoading) return const Center(child: CircularProgressIndicator());
            if (state is TeamsLoaded) {
              final filtered = state.teams.where((t) {
                final mine = myRawTeamIds.contains(t.id);
                final match = t.name.toLowerCase().contains(_teamSearch.toLowerCase()) ||
                    t.leaderName.toLowerCase().contains(_teamSearch.toLowerCase());
                return mine && match;
              }).toList();
              if (filtered.isEmpty) return _emptyState('No teams found.'.tr(context), Icons.groups_outlined);
              return isDesktop
                  ? _teamsDesktopTable(context, filtered, context.read<TeamsCubit>())
                  : _teamsMobileCards(context, filtered, context.read<TeamsCubit>());
            }
            return const SizedBox.shrink();
          },
        ),

        // ── Employees Tab ───────────────────────────────────────────
        Builder(builder: (context) {
          final filtered = myEmployees.where((u) {
            final q = _empSearch.toLowerCase();
            return u.fullName.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q) ||
                u.role.toLowerCase().contains(q);
          }).toList();
          if (filtered.isEmpty) return _emptyState('No employees found.'.tr(context), Icons.people_outline);
          return isDesktop
              ? _empDesktopTable(context, filtered, currentUserId, db)
              : _empMobileCards(context, filtered, currentUserId, db);
        }),
      ],
    );

    final body = Padding(
      padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // ── Header ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tabController.index == 0
                              ? 'Team Management'.tr(context)
                              : 'Employee Management'.tr(context),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.corporate_fare, size: 13.sp, color: AppColors.primary),
                            SizedBox(width: 4.w),
                            Text(managerDept,
                                style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_tabController.index == 0)
                    _headerActionButton(
                      label: 'Add Team'.tr(context),
                      icon: Icons.add,
                      onTap: () => CreateTeamDialogWidget.show(context, context.read<TeamsCubit>()),
                    )
                  else if (_tabController.index == 1)
                    _headerActionButton(
                      label: 'Assign to Team'.tr(context),
                      icon: Icons.person_add_alt_1_rounded,
                      onTap: () => AssignMemberToTeamDialogWidget.show(context, context.read<TeamsCubit>()),
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              // ── Tab Bar ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: ResponsiveLayout.isMobile(context),
                  tabAlignment:
                      ResponsiveLayout.isMobile(context) ? TabAlignment.center : TabAlignment.fill,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
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
                                  Text('Teams'.tr(context)),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: _tabController.index == 0 ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text('${myRawTeamIds.length}',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold,
                                            color: _tabController.index == 0 ? Colors.white : AppColors.primary)),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.groups_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Teams'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: _tabController.index == 0 ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text('${myRawTeamIds.length}',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold,
                                            color: _tabController.index == 0 ? Colors.white : AppColors.primary)),
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
                                  const Icon(Icons.people_outline, size: 16),
                                  SizedBox(width: 8),
                                  Text('Employees'.tr(context)),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: _tabController.index == 1 ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text('${myEmployees.length}',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold,
                                            color: _tabController.index == 1 ? Colors.white : AppColors.primary)),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.people_outline, size: 16),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Employees'.tr(context),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: _tabController.index == 1 ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text('${myEmployees.length}',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold,
                                            color: _tabController.index == 1 ? Colors.white : AppColors.primary)),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── Stats Row ─────────────────────────────────────────
              if (_tabController.index == 0)
                BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, state) {
                    if (state is TeamsLoaded) {
                      final myTeams = state.teams.where((t) => myRawTeamIds.contains(t.id)).toList();
                      final totalMembers = myTeams.fold<int>(0, (s, t) => s + t.membersCount);
                      final avgProgress  = myTeams.isEmpty ? 0.0 : myTeams.fold<double>(0, (s, t) => s + t.completionPercentage) / myTeams.length;
                      return _statsRow([
                        _statCard('My Teams'.tr(context),      '${myTeams.length}', Icons.groups_outlined, Colors.blue),
                        _statCard('Total Members'.tr(context), '$totalMembers',     Icons.person_outline,   Colors.green),
                        _statCard('Avg Completion'.tr(context),'${avgProgress.toInt()}%', Icons.trending_up, Colors.purple),
                      ]);
                    }
                    return const SizedBox.shrink();
                  },
                )
              else
                _statsRow([
                  _statCard('Team Leaders'.tr(context), '${myLeaderIds.length}', Icons.supervisor_account_outlined, Colors.indigo),
                  _statCard('Team Members'.tr(context), '${myMemberIds.length}', Icons.person_outline, Colors.teal),
                  _statCard('Total'.tr(context),        '${myEmployees.length}', Icons.people, Colors.blue),
                ]),
              SizedBox(height: 16.h),

              // ── Search ────────────────────────────────────────────
              _searchBar(
                hint: _tabController.index == 0
                    ? 'Search teams...'.tr(context)
                    : 'Search employees...'.tr(context),
                onChanged: (v) => setState(() {
                  if (_tabController.index == 0) _teamSearch = v; else _empSearch = v;
                }),
              ),
              SizedBox(height: 16.h),

              // ── Content ───────────────────────────────────────────
              if (isDesktop)
                Expanded(child: tabBarView)
              else
                SizedBox(height: mobileTabHeight, child: tabBarView),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop ? body : SingleChildScrollView(child: body),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
        height: 86.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
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
        ),
        child: Row(
          children: [
            _gradientChip(icon, color, size: 44),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _statsRow(List<Widget> cards) {
    final isWide = ResponsiveLayout.isDesktop(context) || ResponsiveLayout.isTablet(context);
    if (isWide) {
      return Row(children: [
        Expanded(child: cards[0]), SizedBox(width: 12.w),
        Expanded(child: cards[1]), SizedBox(width: 12.w),
        Expanded(child: cards[2]),
      ]);
    }
    return Column(children: cards.map((c) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: SizedBox(width: double.infinity, child: c))).toList());
  }

  Widget _searchBar({required String hint, required ValueChanged<String> onChanged}) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.sp),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
        ),
        style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _headerActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6FC4), Color(0xFF0F4C81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(msg, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
          ],
        ),
      );

  Color _progressColor(double p) => p >= 0.75 ? AppColors.success : (p >= 0.4 ? Colors.orange : AppColors.danger);

  // ══════════════════════════════════════════════════════════════════
  // TEAMS TABLE / CARDS
  // ══════════════════════════════════════════════════════════════════

  Widget _teamsDesktopTable(BuildContext context, List<TeamModel> teams, TeamsCubit cubit) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _teamTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: teams.length,
              itemBuilder: (_, i) => _teamTableRow(context, teams[i], cubit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamTableHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
        child: Row(children: [
          Expanded(flex: 3, child: _th('Team Name')),
          Expanded(flex: 2, child: _th('Team Leader')),
          Expanded(flex: 1, child: _th('Members')),
          Expanded(flex: 2, child: _th('Completion')),
          Expanded(flex: 2, child: _th('Actions', center: true)),
        ]),
      );

  Widget _teamTableRow(BuildContext context, TeamModel t, TeamsCubit cubit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          _teamIcon(),
          SizedBox(width: 10.w),
          Expanded(child: Text(t.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp), overflow: TextOverflow.ellipsis)),
        ])),
        Expanded(flex: 2, child: Row(children: [
          _avatar(t.leaderName, 26, AppColors.aituRed),
          SizedBox(width: 8.w),
          Expanded(child: Text(t.leaderName, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary))),
        ])),
        Expanded(flex: 1, child: Row(children: [
          Icon(Icons.people_outline, size: 13.sp, color: Colors.grey),
          SizedBox(width: 3.w),
          Text('${t.membersCount}', style: TextStyle(fontSize: 12.sp)),
        ])),
        Expanded(flex: 2, child: Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(value: t.progress, backgroundColor: Colors.grey[200], color: _progressColor(t.progress), minHeight: 6.h))),
          SizedBox(width: 8.w),
          Text('${t.completionPercentage.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: _progressColor(t.progress))),
        ])),
        Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _iconBtn(Icons.info_outline, AppColors.primary, 'Details'.tr(context), () => showDialog(context: context, builder: (_) => TeamDetailsScreen(team: t))),
          _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => CreateTeamDialogWidget.show(context, cubit, teamToEdit: t)),
          _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteTeam(context, t.id, cubit)),
        ])),
      ]),
    );
  }

  Widget _teamsMobileCards(BuildContext context, List<TeamModel> teams, TeamsCubit cubit) {
    return ListView.separated(
      itemCount: teams.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final t = teams[i];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
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
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _teamIcon(),
              SizedBox(width: 12.w),
              Expanded(child: Text(t.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
              _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => CreateTeamDialogWidget.show(context, cubit, teamToEdit: t)),
              _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteTeam(context, t.id, cubit)),
            ]),
            SizedBox(height: 12.h),
            Row(children: [
              _avatar(t.leaderName, 28, AppColors.aituRed),
              SizedBox(width: 8.w),
              Expanded(child: Text(t.leaderName, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              Icon(Icons.people_outline, size: 15.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text('${t.membersCount}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ]),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(value: t.progress, backgroundColor: Colors.grey.shade100, color: _progressColor(t.progress), minHeight: 8.h))),
              SizedBox(width: 10.w),
              Text('${t.completionPercentage.toInt()}%', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: _progressColor(t.progress))),
            ]),
          ]),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // EMPLOYEES TABLE / CARDS
  // ══════════════════════════════════════════════════════════════════

  Widget _empDesktopTable(BuildContext context, List<MockUser> emps, String currentUserId, MockDatabase db) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _empTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: emps.length,
            itemBuilder: (_, i) => _empTableRow(context, emps[i], currentUserId, db),
          ),
        ),
      ]),
    );
  }

  Widget _empTableHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
        child: Row(children: [
          Expanded(flex: 3, child: _th('Employee')),
          Expanded(flex: 3, child: _th('Email')),
          Expanded(flex: 2, child: _th('Role')),
          Expanded(flex: 2, child: _th('Performance')),
          Expanded(flex: 1, child: _th('Status')),
          Expanded(flex: 2, child: _th('Actions', center: true)),
        ]),
      );

  Widget _empTableRow(BuildContext context, MockUser u, String currentUserId, MockDatabase db) {
    final scoreColor = u.finalScore >= 80 ? AppColors.success : (u.finalScore >= 60 ? Colors.orange : AppColors.danger);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          _avatar(u.fullName, 32, AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(child: Text(u.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp), overflow: TextOverflow.ellipsis)),
        ])),
        Expanded(flex: 3, child: Text(u.email, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: _roleBadge(u.role)),
        Expanded(flex: 2, child: Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(value: u.finalScore / 100, backgroundColor: Colors.grey[200], color: scoreColor, minHeight: 6.h))),
          SizedBox(width: 6.w),
          Text('${u.finalScore.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: scoreColor)),
        ])),
        Expanded(flex: 1, child: _statusDot(u.isActive)),
        Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => _showEditEmployeeDialog(context, u, currentUserId, db)),
          _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteEmployee(context, u, currentUserId, db)),
        ])),
      ]),
    );
  }

  Widget _empMobileCards(BuildContext context, List<MockUser> emps, String currentUserId, MockDatabase db) {
    return ListView.separated(
      itemCount: emps.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final u = emps[i];
        final scoreColor = u.finalScore >= 80 ? AppColors.success : (u.finalScore >= 60 ? Colors.orange : AppColors.danger);
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
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
          ),
          child: Row(children: [
            _avatar(u.fullName, 40, AppColors.primary),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary)),
              Text(u.email, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              SizedBox(height: 4.h),
              Row(children: [
                _roleBadge(u.role),
                SizedBox(width: 8.w),
                Text('${u.finalScore.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: scoreColor)),
              ]),
            ])),
            Column(children: [
              _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => _showEditEmployeeDialog(context, u, currentUserId, db)),
              _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteEmployee(context, u, currentUserId, db)),
            ]),
          ]),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ADD / EDIT EMPLOYEE DIALOGS
  // ══════════════════════════════════════════════════════════════════

  void _showEditEmployeeDialog(BuildContext context, MockUser user, String currentUserId, MockDatabase db) {
    final nameCon  = TextEditingController(text: user.fullName);
    final phoneCon = TextEditingController(text: user.phone);
    String selectedRole = user.role;
    bool   isActive     = user.isActive;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _dialogHeader('Edit Employee'.tr(context), user.email, Icons.edit_outlined, Colors.orange),
                SizedBox(height: 20.h),

                _fieldLabel('Full Name'.tr(context)),
                SizedBox(height: 6.h),
                _inputField(nameCon, '', Icons.person_outline),
                SizedBox(height: 16.h),

                _fieldLabel('Phone'.tr(context)),
                SizedBox(height: 6.h),
                _inputField(phoneCon, '', Icons.phone_outlined, keyboardType: TextInputType.phone),
                SizedBox(height: 16.h),

                _fieldLabel('Role'.tr(context)),
                SizedBox(height: 6.h),
                _roleDropdown(
                  value: selectedRole,
                  items: const ['Team Leader', 'Team Member'],
                  onChanged: (v) => setDlg(() => selectedRole = v!),
                ),
                SizedBox(height: 16.h),

                // Status toggle
                Row(children: [
                  Text('Active'.tr(context), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                  const Spacer(),
                  Switch(
                    value: isActive,
                    onChanged: (v) => setDlg(() => isActive = v),
                    activeColor: AppColors.success,
                  ),
                ]),
                SizedBox(height: 24.h),

                _dialogActions(
                  onCancel: () => Navigator.pop(ctx),
                  onConfirm: () {
                    setState(() {
                      db.editUser(MockUser(
                        id: user.id,
                        email: user.email,
                        fullName: nameCon.text.trim().isEmpty ? user.fullName : nameCon.text.trim(),
                        role: selectedRole,
                        department: user.department,
                        phone: phoneCon.text.trim().isEmpty ? user.phone : phoneCon.text.trim(),
                        status: isActive ? 'Active' : 'Inactive',
                        teamId: user.teamId,
                        isActive: isActive,
                        lastActive: user.lastActive,
                        points: user.points,
                        productivityScore: user.productivityScore,
                        deadlineCommitment: user.deadlineCommitment,
                        approvalRate: user.approvalRate,
                        rejectionRate: user.rejectionRate,
                        leaderEvaluation: user.leaderEvaluation,
                        finalScore: user.finalScore,
                      ), currentUserId);
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Employee updated successfully.'.tr(context)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  confirmLabel: 'Save Changes'.tr(context),
                  confirmColor: Colors.orange,
                ),
              ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteEmployee(BuildContext context, MockUser user, String currentUserId, MockDatabase db) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
            padding: EdgeInsets.all(28.w),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dialogHeader('Remove Employee'.tr(context), user.fullName, Icons.person_remove_outlined, AppColors.error),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade100),
              SizedBox(height: 12.h),
              Text('Are you sure you want to remove "${user.fullName}" from your department?'.tr(context),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5)),
              SizedBox(height: 24.h),
              _dialogActions(
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  setState(() { db.deleteUser(user.id, currentUserId); });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Employee removed successfully.'.tr(context)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                confirmLabel: 'Remove'.tr(context),
                confirmColor: AppColors.error,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTeam(BuildContext context, String teamId, TeamsCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
            padding: EdgeInsets.all(28.w),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dialogHeader('Delete Team'.tr(context), 'This action cannot be undone.'.tr(context), Icons.delete_outline, AppColors.error),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade100),
              SizedBox(height: 12.h),
              Text('Are you sure you want to delete this team?'.tr(context),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5)),
              SizedBox(height: 24.h),
              _dialogActions(
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  cubit.deleteTeam(teamId);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Team deleted successfully.'.tr(context)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                confirmLabel: 'Delete'.tr(context),
                confirmColor: AppColors.error,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SHARED UI HELPERS
  // ══════════════════════════════════════════════════════════════════

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  Widget _gradientChip(IconData icon, Color color, {double size = 40}) => Container(
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

  Widget _th(String label, {bool center = false}) => Text(label.tr(context),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppColors.textSecondary),
      textAlign: center ? TextAlign.center : TextAlign.start);

  Widget _teamIcon() => _gradientChip(Icons.group_work_outlined, AppColors.primary, size: 34);

  Widget _iconBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(padding: EdgeInsets.all(5.w), child: Icon(icon, color: color, size: 18.sp)),
        ),
      );

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

  Widget _roleBadge(String role) {
    final colors = {
      'Team Leader': [Colors.indigo.shade50, Colors.indigo],
      'Team Member': [Colors.teal.shade50, Colors.teal],
    };
    final c = colors[role] ?? [Colors.grey.shade100, Colors.grey];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: c[0] as Color, borderRadius: BorderRadius.circular(20.r)),
      child: Text(role.tr(context), style: TextStyle(color: c[1] as Color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusDot(bool active) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8.w, height: 8.h,
            decoration: BoxDecoration(color: active ? AppColors.success : Colors.grey, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(active ? 'Active'.tr(context) : 'Inactive'.tr(context),
            style: TextStyle(fontSize: 10.sp, color: active ? AppColors.success : Colors.grey)),
      ]);

  Widget _dialogHeader(String title, String subtitle, IconData icon, Color color) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _gradientChip(icon, color, size: 50),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 3.h),
            Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
          ])),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textSecondary)),
        ],
      );

  Widget _fieldLabel(String label) => Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      );

  Widget _inputField(TextEditingController con, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: con,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, size: 19, color: AppColors.textSecondary),
        fillColor: const Color(0xFFF1F5F9),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    );
  }

  Widget _roleDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
      decoration: InputDecoration(
        fillColor: const Color(0xFFF1F5F9),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      items: items.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dialogActions({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return Row(children: [
      Expanded(child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text('Cancel'.tr(context), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      )),
      SizedBox(width: 12.w),
      Expanded(child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [confirmColor, _darker(confirmColor)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: confirmColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: onConfirm,
            child: Center(
              child: Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      )),
    ]);
  }
}
