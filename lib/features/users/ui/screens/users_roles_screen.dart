import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/dependency_injection/service_locator.dart';
import '../../cubit/users_cubit.dart';
import '../../cubit/users_state.dart';
import '../widgets/users_filter_bar.dart';
import '../widgets/user_data_table.dart';
import '../widgets/invite_user_dialog_widget.dart';
import '../../../teams/ui/widgets/stat_card_widget.dart'; // إعادة استخدام كروت الإحصاءات السابقة

class UsersRolesScreen extends StatelessWidget {
  const UsersRolesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UsersCubit>()..fetchUsers(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF2F7),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // هيدر الشاشة العلوي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Users & Roles', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. كروت الإحصاءات الأربعة العلوية تماماً كالتصميم
                Row(
                  children: const [
                    Expanded(child: StatCardWidget(icon: Icons.people_outline, iconColor: Color(0xFF3B82F6), iconBgColor: Color(0xFFEFF6FF), value: '9', title: 'Total Users')),
                    SizedBox(width: 16),
                    Expanded(child: StatCardWidget(icon: Icons.shield_outlined, iconColor: Color(0xFFEF4444), iconBgColor: Color(0xFFFEF2F2), value: '1', title: 'Admins')),
                    SizedBox(width: 16),
                    Expanded(child: StatCardWidget(icon: Icons.workspace_premium_outlined, iconColor: Color(0xFFF59E0B), iconBgColor: Color(0xFFFFFBEB), value: '3', title: 'Managers')),
                    SizedBox(width: 16),
                    Expanded(child: StatCardWidget(icon: Icons.badge_outlined, iconColor: Color(0xFF10B981), iconBgColor: Color(0xFFE6F4EA), value: '5', title: 'Members')),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. شريط السيرش وفلترة التابس التفاعلي
                const UsersFilterBar(),
                const SizedBox(height: 24),

                // 3. جدول عرض البيانات المتجاوب مع الـ Cubit وحالة الفلترة
                BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersLoading) {
                      return const Center(child: Padding(padding: EdgeInsets.all(64.0), child: CircularProgressIndicator()));
                    } else if (state is UsersLoaded) {
                      if (state.filteredUsers.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No users found.', style: TextStyle(color: Color(0xFF94A3B8)))));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: UserDataTable(users: state.filteredUsers),
                      );
                    } else if (state is UsersError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}