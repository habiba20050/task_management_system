import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../colors/app_colors.dart';
import '../../styles/app_radius.dart';
import '../../styles/app_spacing.dart';
import '../buttons/app_buttons.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDanger;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDanger ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  text: cancelLabel,
                  width: 90.w,
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: AppSpacing.md.w),
                isDanger
                    ? DangerButton(
                        text: confirmLabel,
                        width: 90.w,
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                      )
                    : PrimaryButton(
                        text: confirmLabel,
                        width: 90.w,
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
