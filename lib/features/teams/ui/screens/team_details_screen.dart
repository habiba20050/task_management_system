import 'package:flutter/material.dart';
import '../../model/team_model.dart';

class TeamDetailsScreen extends StatelessWidget {
  final TeamModel team;
  // أضفنا مدير الفريق هنا لمحاكاة الطلب رقم 9
  final String createdByManager = "Eng. Mohamed Ali"; 

  const TeamDetailsScreen({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: const Color(0xFFEDF2F7),
      child: Container(
        width: 1000,
        height: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                  label: const Text('Back to Teams', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildManagementCard(),
                          const SizedBox(height: 20),
                          _buildProgressCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildMembersList(),
                          const SizedBox(height: 20),
                          _buildTeamTasksList(),
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

  Widget _buildManagementCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team Supervision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          _buildUserTile(team.leaderName, team.leaderInitials, 'TEAM LEADER', const Color(0xFFFFFBEB), Colors.orange),
          const SizedBox(height: 16),
          _buildUserTile(createdByManager, 'MA', 'ADDED BY MANAGER', const Color(0xFFEFF6FF), Colors.blue),
        ],
      ),
    );
  }

  Widget _buildUserTile(String name, String initials, String role, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: textColor, radius: 18, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Task Completion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: team.progress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
                Text('${team.completionPercentage.toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Completed: ${team.completedTasks}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              Text('Total Tasks: ${team.totalTasks}', style: const TextStyle(color: Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members (${team.membersCount})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: team.membersCount,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF64748B), child: Icon(Icons.person, color: Colors.white)),
              title: Text('Team Member ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Member Role / Track'),
              trailing: OutlinedButton(onPressed: () {}, child: const Text('View Profile')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTasksList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Active Team Tickets / Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          SizedBox(height: 16),
          Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Tasks list query filter goes here...', style: TextStyle(color: Color(0xFF94A3B8))))),
        ],
      ),
    );
  }
}