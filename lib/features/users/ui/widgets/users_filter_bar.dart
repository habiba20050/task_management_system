import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management_system/features/users/ui/widgets/invite_user_dialog_widget.dart';
import '../../cubit/users_cubit.dart';

class UsersFilterBar extends StatefulWidget {
  const UsersFilterBar({Key? key}) : super(key: key);

  @override
  State<UsersFilterBar> createState() => _UsersFilterBarState();
}

class _UsersFilterBarState extends State<UsersFilterBar> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Admin', 'Manager', 'Member'];

  @override
  Widget build(BuildContext context) {
    // استخدام Wrap بدلاً من Row لجعل الشريط متجاوباً مع أحجام الشاشات المختلفة
    // وينزل لسطر جديد عند الحاجة لمنع الـ Overflow.
    return Wrap(
      spacing: 16.0, // المسافة الأفقية بين العناصر
      runSpacing: 16.0, // المسافة العمودية بين الأسطر
      crossAxisAlignment: WrapCrossAlignment.center, // محاذاة العناصر في المنتصف عمودياً
      children: [
        // حقل البحث باسم المستخدم أو الإيميل
        SizedBox(
          width: 350, // تحديد عرض مناسب لحقل البحث
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) {
                context.read<UsersCubit>().searchUsers(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search users by name or email...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),

        // أزرار الفلترة (Tabs) لتبديل الأدوار
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicWidth( // يجعل الـ Row يأخذ عرض المحتوى فقط
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = tab);
                    context.read<UsersCubit>().filterByRole(tab);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0F4C81)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // زر إضافة / دعوة مستخدم جديد (+ Invite User)
        ElevatedButton.icon(
          onPressed: () {
            InviteUserDialogWidget.show(context);
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text(
            'Invite User',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // زيادة الـ padding العمودي ليتناسب مع ارتفاع حقل البحث
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
