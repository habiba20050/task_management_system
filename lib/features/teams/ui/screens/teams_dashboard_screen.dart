import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/teams_cubit.dart';
import '../../cubit/teams_state.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/team_card_widget.dart';
import '../widgets/create_team_dialog_widget.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../responsive/responsive_layout.dart';

class TeamsDashboardScreen extends StatefulWidget {
  const TeamsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeamsDashboardScreen> createState() => _TeamsDashboardScreenState();
}

class _TeamsDashboardScreenState extends State<TeamsDashboardScreen> {


  Widget _buildHeader(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Management',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isDesktop ? 22.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Overview of teams, departments & performance',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isDesktop ? 13.sp : 11.sp,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            CreateTeamDialogWidget.show(context, context.read<TeamsCubit>());
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Add New Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unified Header
              _buildHeader(context),
              const SizedBox(height: 24),
              
              // 1. Search Bar and Add Team
              BlocBuilder<TeamsCubit, TeamsState>(
                buildWhen: (previous, current) => current is TeamsLoaded,
                builder: (context, state) {
                  final teamCount = state is TeamsLoaded ? state.teams.length : 0;
                  return TopBarWidget(teamCount: teamCount);
                },
              ),
              const SizedBox(height: 32),

              // 2. Stats
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  if (state is TeamsLoaded) {
                    final totalTeams = state.teams.length;
                    final totalMembers = state.teams.fold<int>(0, (sum, team) => sum + team.membersCount);
                    final departments = state.teams.map((team) => team.department).toSet().length;

                    return Row(
                      children: [
                        Expanded(
                          child: StatCardWidget(
                            icon: Icons.groups_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            iconBgColor: const Color(0xFFEFF6FF),
                            value: totalTeams.toString(),
                            title: 'Total Teams',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCardWidget(
                            icon: Icons.person_add_alt_1_outlined,
                            iconColor: const Color(0xFF10B981),
                            iconBgColor: const Color(0xFFE6F4EA),
                            value: totalMembers.toString(),
                            title: 'Total Members',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCardWidget(
                            icon: Icons.domain_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            iconBgColor: const Color(0xFFF5F3FF),
                            value: departments.toString(),
                            title: 'Departments',
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: List.generate(3, (index) => const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: StatCardWidget(
                          icon: Icons.hourglass_empty,
                          iconColor: Color(0xFFE2E8F0),
                          iconBgColor: Color(0xFFF8FAFC),
                          value: '...',
                          title: 'Loading...',
                        ),
                      ),
                    )),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 3. Teams List
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  if (state is TeamsLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                        ),
                      ),
                    );
                  } else if (state is TeamsLoaded) {
                    if (state.teams.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 64.0),
                        child: Center(
                          child: Text(
                            'No teams found matching your search query.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    final isDesktop = ResponsiveLayout.isDesktop(context);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 24.w,
                        mainAxisSpacing: 24.h,
                        childAspectRatio: isDesktop ? 0.78 : (ResponsiveLayout.isTablet(context) ? 0.9 : 1.0),
                      ),
                      itemCount: state.teams.length,
                      itemBuilder: (context, index) {
                        final team = state.teams[index];
                        return TeamCardWidget(team: team);
                      },
                    );
                  } else if (state is TeamsError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64.0),
                      child: Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}