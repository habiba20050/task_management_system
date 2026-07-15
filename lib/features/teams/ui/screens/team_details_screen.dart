import 'package:flutter/material.dart';
import '../../model/team_model.dart';
import '../../../../core/network/mock_database.dart';
import '../../../../core/localization/translate_extension.dart';

class TeamDetailsScreen extends StatelessWidget {
  final TeamModel team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase.instance;

    // Fetch live data from MockDatabase using the team's id
    final mockTeam = db.teams.firstWhere(
      (t) => t.id == team.id,
      orElse: () => MockTeam(
        id: team.id,
        name: team.name,
        managerId: '2', // default manager Prof. Khalid
        department: team.department,
        leaderId: '3',  // default leader Eng. Nour
        memberIds: ['4', '5'],
      ),
    );

    // Fetch Manager
    final manager = db.users.firstWhere(
      (u) => u.id == mockTeam.managerId,
      orElse: () => MockUser(
        id: '2',
        email: 'manager@aitu.edu',
        fullName: 'Prof. Khalid Mansour',
        role: 'Manager',
        department: team.department,
      ),
    );

    // Fetch Team Leader
    final leader = db.users.firstWhere(
      (u) => u.id == mockTeam.leaderId,
      orElse: () => MockUser(
        id: '3',
        email: 'leader@aitu.edu',
        fullName: team.leaderName,
        role: 'Team Leader',
        department: team.department,
      ),
    );

    // Fetch members
    final members = db.users.where((u) => mockTeam.memberIds.contains(u.id)).toList();

    // Fetch team tasks (tasks assigned to members in the team)
    final memberIdsSet = mockTeam.memberIds.toSet();
    final tasks = db.tasks.where((t) => memberIdsSet.contains(t.assignedMemberId)).toList();
    final completedTasks = tasks.where((t) => t.status == 'Completed' || t.status == 'Approved' || t.status == 'Approved With Suggestions').toList();
    final totalTasksCount = tasks.length;
    final completedTasksCount = completedTasks.length;
    final remainingTasksCount = totalTasksCount - completedTasksCount;
    final double completionRate = totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: const Color(0xFFEDF2F7),
      child: Container(
        width: 1000,
        height: 680,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Back to Teams'.tr(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Management & Progress)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildManagementCard(context, manager, leader),
                          const SizedBox(height: 20),
                          _buildProgressCard(context, completedTasksCount, remainingTasksCount, totalTasksCount, completionRate),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Column (Members & Tasks details)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildMembersList(context, members, tasks),
                          const SizedBox(height: 20),
                          _buildTeamTasksList(context, tasks, members),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, MockUser manager, MockUser leader) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Supervision'.tr(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildUserTile(
            leader.fullName,
            leader.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
            'TEAM LEADER'.tr(context),
            const Color(0xFFFFFBEB),
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildUserTile(
            manager.fullName,
            manager.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
            'PROJECT MANAGER'.tr(context),
            const Color(0xFFEFF6FF),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(
    String name,
    String initials,
    String role,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: textColor,
            radius: 18,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int completed, int remaining, int total, double rate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Score & Completion'.tr(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
                Text(
                  '${(rate * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Completed'.tr(context), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('$completed', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                children: [
                  Text('Remaining'.tr(context), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('$remaining', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                children: [
                  Text('Total Tasks'.tr(context), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('$total', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<MockUser> members, List<MockTask> tasks) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members'.tr(context) + ' (${members.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No members assigned to this team.'.tr(context), style: const TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (_, _) => const Divider(color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final member = members[index];
                final initials = member.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                final memberTasks = tasks.where((t) => t.assignedMemberId == member.id).toList();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF64748B),
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    member.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${memberTasks.length} ' + 'tasks taken'.tr(context)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${member.points} ' + 'Points'.tr(context),
                      style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTeamTasksList(BuildContext context, List<MockTask> tasks, List<MockUser> members) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Team Tasks Details'.tr(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No active tasks found.'.tr(context),
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const Divider(color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final assignee = members.firstWhere(
                  (u) => u.id == task.assignedMemberId,
                  orElse: () => MockUser(id: '', email: '', fullName: 'Unassigned', role: '', department: ''),
                );

                return ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Assigned to'.tr(context) + ': ${assignee.fullName} | ' + 'Deadline'.tr(context) + ': ${task.deadline}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.status == 'Completed' || task.status == 'Approved'
                          ? const Color(0xFFE8F8EE)
                          : const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.status.tr(context),
                      style: TextStyle(
                        color: task.status == 'Completed' || task.status == 'Approved'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
