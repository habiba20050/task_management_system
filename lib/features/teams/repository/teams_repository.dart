import '../model/team_model.dart';

class TeamsRepository {
  // هنا يمكنك حقن الـ API Client الخاص بك مستقبلاً لجلب البيانات الفعلية
  Future<List<TeamModel>> getTeams() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة وقت الطلب من السيرفر
    return [
      TeamModel(
        id: '1',
        name: 'Engineering Systems',
        department: 'Engineering Dept',
        leaderName: 'Prof. Khalid Mansour',
        leaderInitials: 'KM',
        membersCount: 3,
        totalTasks: 50,
        completedTasks: 38,
      ),
    ];
  }
}