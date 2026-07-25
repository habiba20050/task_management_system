import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../colors/app_colors.dart';
import '../../styles/app_radius.dart';
import '../../styles/app_spacing.dart';

class _BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide? side;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const _BaseButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    required this.backgroundColor,
    required this.foregroundColor,
    this.side,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonWidget = ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: AppColors.disabledBackground,
        disabledForegroundColor: AppColors.disabled,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: side,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 18.h,
              width: 18.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  SizedBox(width: AppSpacing.sm.w),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (suffixIcon != null) ...[
                  SizedBox(width: AppSpacing.sm.w),
                  suffixIcon!,
                ],
              ],
            ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        height: height ?? 44.h,
        child: buttonWidget,
      );
    } else {
      return SizedBox(
        height: height ?? 44.h,
        child: buttonWidget,
      );
    }
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      width: width,
      height: height,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      width: width,
      height: height,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      width: width,
      height: height,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
      width: width,
      height: height,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
