import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/teams_cubit.dart';
import '../../../../core/localization/translate_extension.dart';
import '../../cubit/teams_state.dart';
import '../widgets/create_team_dialog_widget.dart';
import 'team_details_screen.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../responsive/responsive_layout.dart';

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

                    return Row(
                      children: [
                        _buildStatWidget(
                          'Active Teams',
                          totalTeams.toString(),
                          Icons.groups_outlined,
                          Colors.blue,
                        ),
                        SizedBox(width: 16.w),
                        _buildStatWidget(
                          'Assigned Members',
                          totalMembers.toString(),
                          Icons.person_outline,
                          Colors.green,
                        ),
                        SizedBox(width: 16.w),
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

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: const Color(0xFFE2E8F0)),
                                child: DataTable(
                                  columnSpacing: isDesktop ? 40.w : 20.w,
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'Team Name'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Department'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Team Leader'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Members'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Completion Rate'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions'.tr(context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filtered.map((t) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.group_work_outlined,
                                                color: AppColors.primary,
                                                size: 18.sp,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                t.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEAF2FF),
                                              borderRadius: BorderRadius.circular(
                                                6.r,
                                              ),
                                            ),
                                            child: Text(
                                              t.department.tr(context),
                                              style: TextStyle(
                                                color: const Color(0xFF0A448C),
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12.r,
                                                backgroundColor: AppColors.aituRed
                                                    .withOpacity(0.1),
                                                child: Text(
                                                  t.leaderInitials,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: AppColors.aituRed,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(t.leaderName),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text('${t.membersCount} ' + 'Members'.tr(context)),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 80.w,
                                                child: LinearProgressIndicator(
                                                  value: t.progress,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                '${t.completionPercentage.toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => TeamDetailsScreen(team: t),
                                              );
                                            },
                                            child: Text(
                                              'More'.tr(context),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
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
    return Expanded(
      child: Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
