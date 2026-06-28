import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/teams_cubit.dart';

class TopBarWidget extends StatelessWidget {
  final int teamCount;

  TopBarWidget({Key? key, required this.teamCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                context.read<TeamsCubit>().filterTeams(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search teams or departments...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Color(0xFF0F4C81), size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text('$teamCount of $teamCount teams', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }
}