import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/team_model.dart';
import '../../cubit/teams_cubit.dart';
import '../screens/team_details_screen.dart';
import 'create_team_dialog_widget.dart';
import '../../../../../../core/colors/app_colors.dart';
import '../../../../../../core/localization/translate_extension.dart';
import '../../../../../../core/styles/app_radius.dart';
import '../../../../../../core/styles/app_shadow.dart';

class TeamCardWidget extends StatelessWidget {
  final TeamModel team;

  const TeamCardWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetails(context),
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: AppShadow.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Accent Bar matching app cards
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 4.h),

            // Header: Team Name & Department Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    team.department.tr(context),
                    style: TextStyle(color: AppColors.primary, fontSize: 8.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Supervisor & Members Row
            Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    team.leaderInitials,
                    style: TextStyle(fontSize: 8.5.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.leaderName,
                        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Team Leader'.tr(context),
                        style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${team.membersCount} ${'Members'.tr(context)}',
                    style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: team.progress,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.primary,
                      minHeight: 4.h,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${team.completionPercentage.toInt()}%',
                  style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const Divider(height: 1),

            // Actions Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _navigateToDetails(context),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 12.sp, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text('View Team Details'.tr(context), style: TextStyle(fontSize: 8.5.sp, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        CreateTeamDialogWidget.show(
                          context,
                          context.read<TeamsCubit>(),
                          teamToEdit: team,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Icon(Icons.edit_outlined, color: Colors.orange, size: 14.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () {
                        context.read<TeamsCubit>().deleteTeam(team.id);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Icon(Icons.delete_outline, color: AppColors.danger, size: 14.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TeamDetailsScreen(team: team),
    );
  }
}
