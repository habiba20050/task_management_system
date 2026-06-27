import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/teams_cubit.dart';
import 'create_team_dialog_widget.dart';

class TopBarWidget extends StatelessWidget {
  final int teamCount;

  TopBarWidget({Key? key, required this.teamCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام Wrap بدلاً من Row لجعل الشريط متجاوباً مع أحجام الشاشات المختلفة
    // وينزل لسطر جديد عند الحاجة لمنع الـ Overflow.
    return Wrap(
      spacing: 20.0, // المسافة الأفقية بين العناصر
      runSpacing: 16.0, // المسافة العمودية بين الأسطر
      crossAxisAlignment: WrapCrossAlignment.center, // محاذاة العناصر في المنتصف عمودياً
      children: [
        // استخدام SizedBox مع عرض محدد بدلاً من Expanded ليتناسب مع Wrap
        SizedBox(
          width: 350,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              // تشغيل البحث تلقائياً عند تغيير النص
              onChanged: (value) {
                context.read<TeamsCubit>().filterTeams(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search teams or departments...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Text('$teamCount of $teamCount teams', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ElevatedButton.icon(
          onPressed: () {
            CreateTeamDialogWidget.show(context);
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Add New Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            // تعديل الـ padding ليتناسب مع ارتفاع حقل البحث
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}