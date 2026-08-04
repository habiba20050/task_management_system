// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'teams_state.dart';
// import '../repository/teams_repository.dart';

// class TeamsCubit extends Cubit<TeamsState> {
//   final TeamsRepository teamsRepository;

//   TeamsCubit(this.teamsRepository) : super(TeamsInitial());

//   void fetchTeams() async {
//     emit(TeamsLoading());
//     try {
//       final teams = await teamsRepository.getTeams();
//       emit(TeamsLoaded(teams));
//     } catch (e) {
//       emit(TeamsError(e.toString()));
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'teams_state.dart';
import '../model/team_model.dart';
import '../repository/teams_repository.dart';
import '../../../../../core/network/mock_database.dart';

class TeamsCubit extends Cubit<TeamsState> {
  final TeamsRepository teamsRepository;
  
  List<TeamModel> _allTeams = []; // لحفظ النسخة الأصلية كاملة

  TeamsCubit(this.teamsRepository) : super(TeamsInitial());

  // جلب البيانات لأول مرة
  void fetchTeams() async {
    emit(TeamsLoading());
    try {
      _allTeams = await teamsRepository.getTeams();
      emit(TeamsLoaded(_allTeams));
    } catch (e) {
      emit(TeamsError(e.toString()));
    }
  }

  // دالة الفلترة والبحث (تستدعى عند الكتابة في السيرش)
  void filterTeams(String query) {
    // نحصل على الحالة الحالية ونتأكد من أنها TeamsLoaded قبل المتابعة
    final currentState = state;
    if (currentState is TeamsLoaded) {
      final filteredTeams = query.isEmpty
          ? _allTeams // لو السيرش فاضي ارجع للقائمة كاملة
          : _allTeams.where((team) {
              final queryLower = query.toLowerCase();
              return team.name.toLowerCase().contains(queryLower) ||
                  team.department.toLowerCase().contains(queryLower);
            }).toList();

      // نقوم ببث الحالة الجديدة بالكروت المفلترة فقط
      // مع الحفاظ على البيانات الأصلية في _allTeams
      emit(TeamsLoaded(filteredTeams));
    }
  }

  // إضافة فريق جديد
  void addTeam(TeamModel teamModel, List<String> memberIds, String managerId, String leaderId) {
    final db = MockDatabase.instance;
    db.addTeam(MockTeam(
      id: teamModel.id,
      name: teamModel.name,
      managerId: managerId,
      department: teamModel.department,
      leaderId: leaderId,
      memberIds: memberIds,
    ));
    fetchTeams();
  }

  // تعديل بيانات فريق
  void updateTeam(TeamModel teamModel, List<String> memberIds, String managerId, String leaderId) {
    final db = MockDatabase.instance;
    final idx = db.teams.indexWhere((t) => t.id == teamModel.id);
    if (idx != -1) {
      db.teams[idx] = MockTeam(
        id: teamModel.id,
        name: teamModel.name,
        managerId: managerId,
        department: teamModel.department,
        leaderId: leaderId,
        memberIds: memberIds,
      );
      db.save();
      fetchTeams();
    }
  }

  // حذف فريق
  void deleteTeam(String id) {
    final db = MockDatabase.instance;
    db.teams.removeWhere((t) => t.id == id);
    db.save();
    fetchTeams();
  }

  // إضافة موظف إلى فريق
  void assignMemberToTeam({
    required String memberId,
    required String teamId,
    required String managerId,
  }) {
    final db = MockDatabase.instance;

    final teamIdx = db.teams.indexWhere((t) => t.id == teamId);
    if (teamIdx != -1) {
      final team = db.teams[teamIdx];
      if (!team.memberIds.contains(memberId)) {
        team.memberIds.add(memberId);
        db.save();
      }
    }

    final userIdx = db.users.indexWhere((u) => u.id == memberId);
    if (userIdx != -1) {
      final u = db.users[userIdx];
      db.editUser(
        MockUser(
          id: u.id,
          email: u.email,
          fullName: u.fullName,
          role: u.role,
          department: u.department,
          phone: u.phone,
          status: u.status,
          teamId: teamId,
          isActive: u.isActive,
          lastActive: u.lastActive,
          points: u.points,
          productivityScore: u.productivityScore,
          deadlineCommitment: u.deadlineCommitment,
          approvalRate: u.approvalRate,
          rejectionRate: u.rejectionRate,
          leaderEvaluation: u.leaderEvaluation,
          finalScore: u.finalScore,
        ),
        managerId,
      );
    }

    fetchTeams();
  }
}