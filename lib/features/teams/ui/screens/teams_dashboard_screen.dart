import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/teams_cubit.dart';
import '../../cubit/teams_state.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/team_card_widget.dart';

class TeamsDashboardScreen extends StatelessWidget {
  const TeamsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7), // نفس خلفية التصميم الرمادية الفاتحة
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. شريط البحث العلوي وزر إضافة فريق جديد
              BlocBuilder<TeamsCubit, TeamsState>(
                buildWhen: (previous, current) => current is TeamsLoaded,
                builder: (context, state) {
                  final teamCount = state is TeamsLoaded ? state.teams.length : 0;
                  return TopBarWidget(teamCount: teamCount);
                },
              ),
              const SizedBox(height: 32),

              // 2. كروت الإحصاءات العلوية الخاصة بالفرق فقط (بدون التذاكر - طلب 8)
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  if (state is TeamsLoaded) {
                    // حساب الإحصائيات من البيانات الفعلية
                    final totalTeams = state.teams.length;
                    final totalMembers = state.teams.fold<int>(0, (sum, team) => sum + team.membersCount);
                    final departments = state.teams.map((team) => team.department).toSet().length;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatCardWidget(
                            icon: Icons.groups_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            iconBgColor: const Color(0xFFEFF6FF),
                            value: totalTeams.toString(),
                            title: 'Total Teams',
                          ),
                          const SizedBox(width: 16),
                          StatCardWidget(
                            icon: Icons.person_add_alt_1_outlined,
                            iconColor: const Color(0xFF10B981),
                            iconBgColor: const Color(0xFFE6F4EA),
                            value: totalMembers.toString(),
                            title: 'Total Members',
                          ),
                          const SizedBox(width: 16),
                          StatCardWidget(
                            icon: Icons.domain_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            iconBgColor: const Color(0xFFF5F3FF),
                            value: departments.toString(),
                            title: 'Departments',
                          ),
                        ],
                      ),
                    );
                  }
                  // عرض واجهة تحميل هيكلية (Skeleton) للحفاظ على ثبات الواجهة
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: StatCardWidget(
                          icon: Icons.hourglass_empty,
                          iconColor: Color(0xFFE2E8F0),
                          iconBgColor: Color(0xFFF8FAFC),
                          value: '...',
                          title: 'Loading...',
                        ),
                      )),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 3. مراقبة حالة الـ Cubit وعرض كروت الفرق بناءً على الفلترة والبحث
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
                    // في حالة لم يتم العثور على أي فريق أثناء البحث
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

                    // عرض الكروت المفلترة أفقياً بمحاذاة ممتازة
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.teams.map((team) => Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: TeamCardWidget(team: team),
                        )).toList(),
                      ),
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