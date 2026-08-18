import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/features/teams/cubit/teams_cubit.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../shared/features/teams/cubit/teams_state.dart';
import '../widgets/create_team_dialog_widget.dart';
import 'team_details_screen.dart';
import 'department_details_screen.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../responsive/responsive_layout.dart';
import '../../../../../shared/features/teams/model/team_model.dart';
import '../../../../../../core/network/mock_database.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../../core/widgets/cards/app_cards.dart';

class TeamsDashboardScreen extends StatefulWidget {
  const TeamsDashboardScreen({super.key});

  @override
  State<TeamsDashboardScreen> createState() => _TeamsDashboardScreenState();
}

class _TeamsDashboardScreenState extends State<TeamsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _teamSearch = '';
  String _deptSearch = '';
  String _selectedDept = 'All';

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
    final currentUserId = authState is AuthSuccess ? authState.user.id : '1';

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
                final match = t.name.toLowerCase().contains(_teamSearch.toLowerCase()) ||
                    t.leaderName.toLowerCase().contains(_teamSearch.toLowerCase());
                final matchDept = _selectedDept == 'All' || t.department == _selectedDept;
                return match && matchDept;
              }).toList();
              if (filtered.isEmpty) return _emptyState('No teams found.'.tr(context), Icons.groups_outlined);
              return isDesktop
                  ? _teamsDesktopTable(context, filtered, context.read<TeamsCubit>())
                  : _teamsMobileCards(context, filtered, context.read<TeamsCubit>());
            }
            return const SizedBox.shrink();
          },
        ),

        // ── Departments Tab ─────────────────────────────────────────
        Builder(builder: (context) {
          final filtered = db.departments.where((d) {
            final q = _deptSearch.toLowerCase();
            return d.name.toLowerCase().contains(q) || d.code.toLowerCase().contains(q);
          }).toList();
          if (filtered.isEmpty) return _emptyState('No departments found.'.tr(context), Icons.business_outlined);
          return isDesktop
              ? _deptsDesktopTable(context, filtered, currentUserId)
              : _deptsMobileCards(context, filtered, currentUserId);
        }),
      ],
    );

    final body = Padding(
      padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
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
                          : 'Department Configuration'.tr(context),
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
                        Flexible(
                          child: Text(
                            _tabController.index == 0
                                ? 'Track university teams & department progress'.tr(context)
                                : 'Manage academic departments and configurations'.tr(context),
                            style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                  label: 'Add Department'.tr(context),
                  icon: Icons.add,
                  onTap: () => _showAddDeptDialog(context, currentUserId),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Tab Bar ───────────────────────────────────────────────
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
                _buildTab(
                  label: 'Teams',
                  icon: Icons.groups_outlined,
                  count: db.teams.length,
                  index: 0,
                ),
                _buildTab(
                  label: 'Departments',
                  icon: Icons.business_outlined,
                  count: db.departments.length,
                  index: 1,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Stats Row ─────────────────────────────────────────────
          if (_tabController.index == 0)
            BlocBuilder<TeamsCubit, TeamsState>(
              builder: (context, state) {
                if (state is TeamsLoaded) {
                  final allTeams = state.teams;
                  final totalMembers = allTeams.fold<int>(0, (s, t) => s + t.membersCount);
                  final avgProgress = allTeams.isEmpty
                      ? 0.0
                      : allTeams.fold<double>(0, (s, t) => s + t.completionPercentage) / allTeams.length;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 600 ? 1 : 3;
                      return GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          mainAxisExtent: 82.h,
                        ),
                        children: [
                          StatCard(
                            title: 'Active Teams'.tr(context),
                            value: allTeams.length.toString(),
                            icon: Icons.groups_outlined,
                            accentColor: Colors.blue,
                          ),
                          StatCard(
                            title: 'Total Members'.tr(context),
                            value: totalMembers.toString(),
                            icon: Icons.person_outline,
                            accentColor: Colors.green,
                          ),
                          StatCard(
                            title: 'Avg Completion'.tr(context),
                            value: '${avgProgress.toInt()}%',
                            icon: Icons.trending_up,
                            accentColor: Colors.purple,
                          ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth < 600 ? 1 : 3;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 82.h,
                  ),
                  children: [
                    StatCard(
                      title: 'Total Departments'.tr(context),
                      value: db.departments.length.toString(),
                      icon: Icons.business_outlined,
                      accentColor: Colors.blue,
                    ),
                    StatCard(
                      title: 'Total Teams'.tr(context),
                      value: db.teams.length.toString(),
                      icon: Icons.groups_outlined,
                      accentColor: Colors.green,
                    ),
                    StatCard(
                      title: 'Total Managers'.tr(context),
                      value: db.users.where((u) => u.role == 'Manager').length.toString(),
                      icon: Icons.supervisor_account_outlined,
                      accentColor: Colors.purple,
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: 16.h),

          // ── Search ────────────────────────────────────────────────
          if (_tabController.index == 0)
            Row(
              children: [
                Expanded(
                  child: _searchBar(
                    hint: 'Search teams by name or leader...'.tr(context),
                    onChanged: (v) => setState(() => _teamSearch = v),
                  ),
                ),
                SizedBox(width: 12.w),
                _deptFilter(
                  selected: _selectedDept,
                  onChanged: (v) => setState(() => _selectedDept = v),
                ),
              ],
            )
          else
            _searchBar(
              hint: 'Search departments by name or code...'.tr(context),
              onChanged: (v) => setState(() => _deptSearch = v),
            ),
          SizedBox(height: 16.h),

          // ── Content ───────────────────────────────────────────────
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
  Widget _buildTab({
    required String label,
    required IconData icon,
    required int count,
    required int index,
  }) {
    final selected = _tabController.index == index;
    final isMobile = ResponsiveLayout.isMobile(context);
    return Tab(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            SizedBox(width: 8),
            Flexible(
              child: Text(label.tr(context), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text('$count',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _deptFilter({required String selected, required ValueChanged<String> onChanged}) {
    final db = MockDatabase.instance;
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          borderRadius: BorderRadius.circular(14.r),
          icon: const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
          items: [
            DropdownMenuItem(
              value: 'All',
              child: Text('All Departments'.tr(context), style: TextStyle(fontSize: 13.sp)),
            ),
            ...db.departments.map(
              (d) => DropdownMenuItem(
                value: d.name,
                child: Text(d.name, style: TextStyle(fontSize: 13.sp)),
              ),
            ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
        ),
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
          Expanded(flex: 2, child: _th('Department')),
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
          _deptBadge(t.department),
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
          _iconBtn(Icons.remove_red_eye_outlined, AppColors.primary, 'View Team Details'.tr(context), () => _openTeamDetails(context, t)),
          _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => CreateTeamDialogWidget.show(context, cubit, teamToEdit: t)),
          _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteTeam(context, t.id, cubit)),
        ])),
      ]),
    );
  }

  Widget _teamsMobileCards(BuildContext context, List<TeamModel> teams, TeamsCubit cubit) {
    return ListView.separated(
      itemCount: teams.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
              _deptBadge(t.department),
              _iconBtn(Icons.remove_red_eye_outlined, AppColors.primary, 'View Team Details'.tr(context), () => _openTeamDetails(context, t)),
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

  Widget _deptBadge(String dept) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(dept.tr(context),
          style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis),
    );
  }

  void _openTeamDetails(BuildContext context, TeamModel team) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TeamDetailsScreen(team: team)),
    );
  }

  void _openDeptDetails(BuildContext context, MockDepartment d) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DepartmentDetailsScreen(department: d)),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // DEPARTMENTS TABLE / CARDS
  // ══════════════════════════════════════════════════════════════════

  String _managerName(MockDatabase db, String managerId) {
    return db.users.firstWhere((u) => u.id == managerId, orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: '')).fullName;
  }

  Widget _deptsDesktopTable(BuildContext context, List<MockDepartment> depts, String currentUserId) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _deptTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: depts.length,
            itemBuilder: (_, i) => _deptTableRow(context, depts[i], currentUserId),
          ),
        ),
      ]),
    );
  }

  Widget _deptTableHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
        child: Row(children: [
          Expanded(flex: 3, child: _th('Department Name')),
          Expanded(flex: 2, child: _th('Code')),
          Expanded(flex: 3, child: _th('Manager')),
          Expanded(flex: 4, child: _th('Description')),
          Expanded(flex: 2, child: _th('Actions', center: true)),
        ]),
      );

  Widget _deptTableRow(BuildContext context, MockDepartment d, String currentUserId) {
    final db = MockDatabase.instance;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          _gradientChip(Icons.business_outlined, AppColors.primary, size: 34),
          SizedBox(width: 10.w),
          Expanded(child: Text(d.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp), overflow: TextOverflow.ellipsis)),
        ])),
        Expanded(flex: 2, child: _deptBadge(d.code)),
        Expanded(flex: 3, child: Row(children: [
          _avatar(_managerName(db, d.managerId), 26, Colors.indigo),
          SizedBox(width: 8.w),
          Expanded(child: Text(_managerName(db, d.managerId), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary))),
        ])),
        Expanded(flex: 4, child: Text(d.description, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary))),
        Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _iconBtn(Icons.remove_red_eye_outlined, AppColors.primary, 'View Department Details'.tr(context), () => _openDeptDetails(context, d)),
          _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => _showEditDeptDialog(context, d, currentUserId)),
          _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteDept(context, d.id)),
        ])),
      ]),
    );
  }

  Widget _deptsMobileCards(BuildContext context, List<MockDepartment> depts, String currentUserId) {
    final db = MockDatabase.instance;
    return ListView.separated(
      itemCount: depts.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final d = depts[i];
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _gradientChip(Icons.business_outlined, AppColors.primary, size: 38),
              SizedBox(width: 12.w),
              Expanded(child: Text(d.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
              _deptBadge(d.code),
            ]),
            SizedBox(height: 10.h),
            Row(children: [
              _avatar(_managerName(db, d.managerId), 24, Colors.indigo),
              SizedBox(width: 8.w),
              Expanded(child: Text(_managerName(db, d.managerId), style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              _iconBtn(Icons.remove_red_eye_outlined, AppColors.primary, 'View Department Details'.tr(context), () => _openDeptDetails(context, d)),
              _iconBtn(Icons.edit_outlined, Colors.orange, 'Edit'.tr(context), () => _showEditDeptDialog(context, d, currentUserId)),
              _iconBtn(Icons.delete_outline, AppColors.error, 'Delete'.tr(context), () => _confirmDeleteDept(context, d.id)),
            ]),
            SizedBox(height: 10.h),
            Text(d.description, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // DIALOGS
  // ══════════════════════════════════════════════════════════════════

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

  void _showAddDeptDialog(BuildContext context, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController();
    final codeCon = TextEditingController();
    final descCon = TextEditingController();
    String? managerId = db.users.isEmpty ? null : db.users.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _dialogHeader('Add Department'.tr(context), 'Create a new academic department configuration.'.tr(context), Icons.business_outlined, AppColors.primary),
                  SizedBox(height: 20.h),

                  _fieldLabel('Department Name'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(nameCon, 'e.g. Computer Science', Icons.school_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Code'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(codeCon, 'e.g. CS', Icons.tag_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Description'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(descCon, 'Enter department description...', Icons.description_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Manager'.tr(context)),
                  SizedBox(height: 6.h),
                  _managerDropdown(value: managerId, onChanged: (v) => setDlg(() => managerId = v)),
                  SizedBox(height: 24.h),

                  _dialogActions(
                    onCancel: () => Navigator.pop(ctx),
                    onConfirm: () {
                      if (nameCon.text.trim().isEmpty || codeCon.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Name and code are required.'.tr(context)),
                          backgroundColor: AppColors.warning,
                          behavior: SnackBarBehavior.floating,
                        ));
                        return;
                      }
                      setState(() {
                        db.addDepartment(
                          MockDepartment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCon.text.trim(),
                            code: codeCon.text.trim(),
                            description: descCon.text.trim(),
                            managerId: managerId ?? '',
                            createdDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          ),
                          adminId,
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Department created successfully.'.tr(context)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    confirmLabel: 'Create'.tr(context),
                    confirmColor: AppColors.primary,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDeptDialog(BuildContext context, MockDepartment dept, String adminId) {
    final db = MockDatabase.instance;
    final nameCon = TextEditingController(text: dept.name);
    final codeCon = TextEditingController(text: dept.code);
    final descCon = TextEditingController(text: dept.description);
    String managerId = dept.managerId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
              padding: EdgeInsets.all(28.w),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _dialogHeader('Edit Department'.tr(context), 'Update the configuration attributes of the department.'.tr(context), Icons.edit_outlined, Colors.orange),
                  SizedBox(height: 20.h),

                  _fieldLabel('Department Name'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(nameCon, '', Icons.school_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Code'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(codeCon, '', Icons.tag_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Description'.tr(context)),
                  SizedBox(height: 6.h),
                  _inputField(descCon, '', Icons.description_outlined),
                  SizedBox(height: 16.h),

                  _fieldLabel('Manager'.tr(context)),
                  SizedBox(height: 6.h),
                  _managerDropdown(value: managerId, onChanged: (v) => setDlg(() => managerId = v ?? '')),
                  SizedBox(height: 24.h),

                  _dialogActions(
                    onCancel: () => Navigator.pop(ctx),
                    onConfirm: () {
                      setState(() {
                        db.editDepartment(
                          MockDepartment(
                            id: dept.id,
                            name: nameCon.text.trim().isEmpty ? dept.name : nameCon.text.trim(),
                            code: codeCon.text.trim().isEmpty ? dept.code : codeCon.text.trim(),
                            description: descCon.text.trim(),
                            managerId: managerId,
                            createdDate: dept.createdDate,
                          ),
                          adminId,
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Department updated successfully.'.tr(context)),
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

  void _confirmDeleteDept(BuildContext context, String deptId) {
    final db = MockDatabase.instance;
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
              _dialogHeader('Delete Department'.tr(context), 'This action cannot be undone.'.tr(context), Icons.delete_outline, AppColors.error),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade100),
              SizedBox(height: 12.h),
              Text('Are you sure you want to delete this department?'.tr(context),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5)),
              SizedBox(height: 24.h),
              _dialogActions(
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  setState(() {
                    db.deleteDepartment(deptId, '1');
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Department deleted successfully.'.tr(context)),
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

  Widget _managerDropdown({required String? value, required ValueChanged<String?> onChanged}) {
    final db = MockDatabase.instance;
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
      items: db.users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)))).toList(),
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
