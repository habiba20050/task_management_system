import 'package:flutter/material.dart';
import '../../model/user_role_model.dart';
import 'edit_user_dialog_widget.dart';
import 'delete_confirm_dialog_widget.dart';

class UserDataTable extends StatelessWidget {
  final List<UserRoleModel> users;

  const UserDataTable({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: const Color(0xFFF1F5F9)),
        child: DataTable(
          horizontalMargin: 24,
          headingRowHeight: 56,
          dataRowHeight: 72,
          columns: const [
            DataColumn(label: Text('USER', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('USERNAME', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ROLE', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('DEPARTMENT', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('STATUS', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('LAST ACTIVE', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
          ],
          rows: users.map((user) => _buildDataRow(context, user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, UserRoleModel user) {
    // تحديد ألوان وأيقونات الـ Badges بناءً على الصلاحية (Role)
    Color roleColor = Colors.blue;
    Color roleBg = const Color(0xFFEFF6FF);
    IconData roleIcon = Icons.person_outline;

    if (user.role == 'Admin') {
      roleColor = const Color(0xFFEF4444);
      roleBg = const Color(0xFFFEF2F2);
      roleIcon = Icons.shield_outlined;
    } else if (user.role == 'Manager') {
      roleColor = const Color(0xFFF59E0B);
      roleBg = const Color(0xFFFFFBEB);
      roleIcon = Icons.workspace_premium_outlined;
    } else {
      roleColor = const Color(0xFF3B82F6);
      roleBg = const Color(0xFFEFF6FF);
      roleIcon = Icons.badge_outlined;
    }

    return DataRow(
      cells: [
        // 1. عمود الـ User (الأفاتار، الاسم الكامل، والإيميل الجامعي)
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: user.role == 'Admin' 
                    ? const Color(0xFF0F4C81) 
                    : (user.role == 'Manager' ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
                child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
                  Text(user.email, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        
        // 2. عمود الـ Username
        DataCell(Text(user.username, style: const TextStyle(color: Color(0xFF475569), fontSize: 14))),
        
        // 3. عمود الـ Role (الـ Badge الملونة التفاعلية)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, size: 12, color: roleColor),
                const SizedBox(width: 4),
                Text(user.role, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
        ),
        
        // 4. عمود القسم (Department)
        DataCell(Text(user.department, style: const TextStyle(color: Color(0xFF475569), fontSize: 14))),
        
        // 5. عمود حالة الحساب (Active / Inactive)
        DataCell(
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: user.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: user.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8), 
                  fontWeight: FontWeight.w600, 
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        
        // 6. عمود آخر نشاط أو ظهور (Last Active)
        DataCell(Text(user.lastActive, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        
        // 7. عمود التحكم العملياتي والـ Context الآمن للـ Edit والـ Delete
        DataCell(
          Row(
            children: [
              // زر فتح التعديل (Edit) ممرراً له الـ context التاريخي والمستخدم الحالي
              _buildActionButton(
                icon: Icons.edit_outlined, 
                color: const Color(0xFF3B82F6), 
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => EditUserDialogWidget.show(context, user),
              ),
              const SizedBox(width: 8),
              // زر فتح تأكيد الحذف (Delete) لحماية البيانات من النقرات الخاطئة
              _buildActionButton(
                icon: Icons.delete_outline, 
                color: const Color(0xFFEF4444), 
                bgColor: const Color(0xFFFEF2F2),
                onTap: () => DeleteConfirmDialogWidget.show(context, user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ويجت مساعدة لبناء الأزرار التفاعلية بتأثير حركي عند الضغط (InkWell) وبحواف دائرية متناسقة
  Widget _buildActionButton({
    required IconData icon, 
    required Color color, 
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}