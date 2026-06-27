import 'package:flutter/material.dart';
import '../../model/team_model.dart';
import '../screens/team_details_screen.dart';

class TeamCardWidget extends StatelessWidget {
  final TeamModel team;
  // تم تعريف اسم المدير بشكل ثابت هنا، ويمكنك تمريره من الـ Model مستقبلاً حسب حاجة قاعدة البيانات
  final String createdByManager = "Eng. Mohamed Ali";

  const TeamCardWidget({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetails(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            top: BorderSide(color: Color(0xFF10B981), width: 4), // الخط الأخضر العلوي المميز
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. عنوان الفريق وأزرار التحكم الحالية (تعديل وحذف)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF0F172A),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(Icons.edit_outlined, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.delete_outline, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 2. اسم القسم التابع له الفريق
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                team.department, 
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // 3. المشرفين: تحديد الـ Team Leader والـ Manager الذي أضاف الفريق (تعديل طلب 9)
            Column(
              children: [
                // خانة الـ Team Leader
                _buildSupervisorRow(
                  initials: team.leaderInitials,
                  role: 'TEAM LEADER',
                  name: team.leaderName,
                  avatarBg: const Color(0xFF059669),
                  cardBg: const Color(0xFFFFFBEB),
                  roleColor: Colors.orange,
                ),
                const SizedBox(height: 8),
                // خانة الـ Manager الذي قام بإضافة الفريق
                _buildSupervisorRow(
                  initials: 'MA',
                  role: 'ADDED BY MANAGER',
                  name: createdByManager,
                  avatarBg: const Color(0xFF1E3A8A),
                  cardBg: const Color(0xFFEFF6FF),
                  roleColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. الإحصائيات المصغرة لعدد الأعضاء ونسبة الإنجاز (تعديل طلب 8)
            Row(
              children: [
                Expanded(child: _buildMiniStat('${team.membersCount}', 'Members', const Color(0xFF1E293B))),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniStat('${team.completionPercentage.toInt()}%', 'Completion', const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 20),

            // 5. شريط تقدم المهام الخاصة بالفريق فقط
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Task Progress', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                Text(
                  '${team.completedTasks}/${team.totalTasks} tasks', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: team.progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),

            // 6. الأزرار التفاعلية السفلية للقائمة المنسدلة والتفاصيل
            _buildDropdownButton(
              title: 'View Members (${team.membersCount})', 
              leadingIcon: Icons.people_outline, 
              isPrimary: false,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildDropdownButton(
              title: 'View Details', 
              leadingIcon: Icons.open_in_new, 
              isPrimary: true,
              onTap: () => _navigateToDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود الانتقال لصفحة التفاصيل القوية
  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailsScreen(team: team),
      ),
    );
  }

  // بناء أسطر المسؤولين والمشرفين بشكل منظم
  Widget _buildSupervisorRow({
    required String initials,
    required String role,
    required String name,
    required Color avatarBg,
    required Color cardBg,
    required Color roleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarBg, 
            radius: 14, 
            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(
                  name, 
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // بناء الأزرار الصغيرة للتعديل والحذف
  Widget _buildIconButton(IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 18),
    );
  }

  // بناء المربعات الرمادية للإحصاءات السريعة
  Widget _buildMiniStat(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  // بناء الأزرار السفلية العريضة
  Widget _buildDropdownButton({
    required String title, 
    required IconData leadingIcon, 
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0F4C81) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: isPrimary ? Colors.white : const Color(0xFF64748B), size: 18),
                const SizedBox(width: 10),
                Text(
                  title, 
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF1E293B), 
                    fontWeight: FontWeight.w600, 
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_down, color: isPrimary ? Colors.white : const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}