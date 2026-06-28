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
  void addTeam(TeamModel team) {
    _allTeams.add(team);
    emit(TeamsLoaded(List.from(_allTeams)));
  }

  // تعديل بيانات فريق
  void updateTeam(TeamModel team) {
    final index = _allTeams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _allTeams[index] = team;
      emit(TeamsLoaded(List.from(_allTeams)));
    }
  }

  // حذف فريق
  void deleteTeam(String id) {
    _allTeams.removeWhere((t) => t.id == id);
    emit(TeamsLoaded(List.from(_allTeams)));
  }
}