class TeamModel {
  final String id;
  final String name;
  final String department;
  final String leaderName;
  final String leaderInitials;
  final int membersCount;
  final int totalTasks;
  final int completedTasks;

  TeamModel({
    required this.id,
    required this.name,
    required this.department,
    required this.leaderName,
    required this.leaderInitials,
    required this.membersCount,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  double get completionPercentage => progress * 100;
}