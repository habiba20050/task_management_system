import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/teams_cubit.dart';
import 'create_team_dialog_widget.dart';

class TopBarWidget extends StatelessWidget {
  final int teamCount;

  TopBarWidget({Key? key, required this.teamCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
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
        const SizedBox(width: 20),
        Text('$teamCount of $teamCount teams', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () {
            CreateTeamDialogWidget.show(context);
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Add New Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}