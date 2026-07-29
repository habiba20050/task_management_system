import '../../../../../core/network/mock_database.dart';
import '../model/team_model.dart';

class TeamsRepository {
  Future<List<TeamModel>> getTeams() async {
    await Future.delayed(const Duration(milliseconds: 100)); // micro delay
    final db = MockDatabase.instance;
    return db.teams.map((t) {
      final leader = db.users.firstWhere(
        (u) => u.id == t.leaderId,
        orElse: () => MockUser(id: '', email: '', fullName: t.leaderId, role: '', department: ''),
      );

      final teamTasks = db.tasks.where((tsk) => t.memberIds.contains(tsk.assignedMemberId)).toList();
      final completed = teamTasks.where((tsk) => tsk.status == 'Completed' || tsk.status == 'Approved' || tsk.status == 'Approved With Suggestions').length;

      return TeamModel(
        id: t.id,
        name: t.name,
        department: t.department,
        leaderName: leader.fullName,
        leaderInitials: leader.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
        membersCount: t.memberIds.length,
        totalTasks: teamTasks.length,
        completedTasks: completed,
      );
    }).toList();
  }
}