import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/teams_cubit.dart';
import '../../../../core/localization/translate_extension.dart';
import '../../cubit/teams_state.dart';
import '../widgets/create_team_dialog_widget.dart';
import '../widgets/team_card_widget.dart';
import 'team_details_screen.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../responsive/responsive_layout.dart';
import '../../model/team_model.dart';

class TeamsDashboardScreen extends StatefulWidget {
  const TeamsDashboardScreen({super.key});

  @override
  State<TeamsDashboardScreen> createState() => _TeamsDashboardScreenState();
}

class _TeamsDashboardScreenState extends State<TeamsDashboardScreen> {
  String _searchQuery = '';
  String _selectedDept = 'All';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Management Portal'.tr(context),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Track and filter university team operations & department progress'.tr(context),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      CreateTeamDialogWidget.show(
                        context,
                        context.read<TeamsCubit>(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: Text(
                      'Add New Team'.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. Search & Reactive Filters Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search teams by name or leader...'.tr(context),
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13.sp,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDept,
                        items:
                            [
                                  'All',
                                  'IT Services',
                                  'CS Dept',
                                  'Business',
                                  'Math Dept',
                                ]
                                .map(
                                  (dept) => DropdownMenuItem(
                                    value: dept,
                                    child: Text(
                                      dept,
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDept = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 3. Stat Cards Section
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  if (state is TeamsLoaded) {
                    final totalTeams = state.teams.length;
                    final totalMembers = state.teams.fold<int>(
                      0,
                      (sum, team) => sum + team.membersCount,
                    );
                    final avgProgress = totalTeams == 0
                        ? 0.0
                        : state.teams.fold<double>(
                                0,
                                (sum, team) => sum + team.completionPercentage,
                              ) /
                              totalTeams;

                    return Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        _buildStatWidget(
                          'Active Teams',
                          totalTeams.toString(),
                          Icons.groups_outlined,
                          Colors.blue,
                        ),
                        _buildStatWidget(
                          'Assigned Members',
                          totalMembers.toString(),
                          Icons.person_outline,
                          Colors.green,
                        ),
                        _buildStatWidget(
                          'Avg Completion',
                          '${avgProgress.toInt()}%',
                          Icons.trending_up,
                          Colors.purple,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: 24.h),

              // 4. Clean Data Table for Teams
              Expanded(
                child: BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, state) {
                    if (state is TeamsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TeamsLoaded) {
                      final filtered = state.teams.where((t) {
                        final matchesSearch =
                            t.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            t.leaderName.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        final matchesDept =
                            _selectedDept == 'All' ||
                            t.department == _selectedDept;
                        return matchesSearch && matchesDept;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'No teams found matching search criteria.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return isDesktop
                          ? _buildDesktopTable(context, filtered, context.read<TeamsCubit>())
                          : _buildMobileCards(context, filtered, context.read<TeamsCubit>());
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatWidget(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: ResponsiveLayout.isMobile(context) ? 140.w : 220.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label.tr(context),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<TeamModel> filtered, TeamsCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(context),
          ...filtered.map((t) => _buildTableRow(context, t, cubit)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Team Name'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Department'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Team Leader'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 1, child: Text('Members'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Completion Rate'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('Actions'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, TeamModel t, TeamsCubit cubit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.group_work_outlined, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    t.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  t.department.tr(context),
                  style: TextStyle(color: const Color(0xFF0A448C), fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.aituRed.withOpacity(0.1),
                  child: Text(t.leaderInitials, style: TextStyle(fontSize: 9.sp, color: AppColors.aituRed, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(t.leaderName, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${t.membersCount}'),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: t.progress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('${t.completionPercentage.toInt()}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => TeamDetailsScreen(team: t),
                    );
                  },
                  tooltip: 'More Details'.tr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  onPressed: () => _showEditTeamDialog(context, t, cubit),
                  tooltip: 'Edit Team'.tr(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                  onPressed: () => _showDeleteTeamConfirm(context, t.id, cubit),
                  tooltip: 'Delete Team'.tr(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCards(
    BuildContext context,
    List<TeamModel> filtered,
    TeamsCubit cubit,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 135.h,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, idx) {
            return TeamCardWidget(team: filtered[idx]);
          },
        );
      },
    );
  }

  void _showEditTeamDialog(BuildContext context, TeamModel team, TeamsCubit cubit) {
    CreateTeamDialogWidget.show(context, cubit, teamToEdit: team);
  }

  void _showDeleteTeamConfirm(BuildContext context, String teamId, TeamsCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team'.tr(context)),
        content: Text('Are you sure you want to delete this team?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              cubit.deleteTeam(teamId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Team deleted successfully'.tr(context))),
              );
            },
            child: Text('Delete'.tr(context), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
