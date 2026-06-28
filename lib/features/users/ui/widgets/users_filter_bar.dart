import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Row(
      children: [
        // حقل البحث باسم المستخدم أو الإيميل
        SizedBox(
          width: 350,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
        const SizedBox(width: 16),

        // أزرار الفلترة (Tabs) لتبديل الأدوار
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _tabs.map((tab) {
            final isSelected = _selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = tab);
                  context.read<UsersCubit>().filterByRole(tab);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F4C81)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F4C81)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
