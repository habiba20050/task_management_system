import 'package:flutter/material.dart';
import '../../model/user_role_model.dart';

class DeleteConfirmDialogWidget extends StatelessWidget {
  final UserRoleModel user;

  const DeleteConfirmDialogWidget({Key? key, required this.user}) : super(key: key);

  static void show(BuildContext context, UserRoleModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeleteConfirmDialogWidget(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة تحذير حمراء متناسقة مع التصميم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_outlined, color: Color(0xFFEF4444), size: 36),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Delete User Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(text: user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const TextSpan(text: '? This action cannot be undone and portal access will be revoked immediately.'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      // استدعاء دالة الحذف في الـ Cubit مستقبلاً هنا
                      navigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444), // اللون الأحمر للحذف التحذيري
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Delete Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}