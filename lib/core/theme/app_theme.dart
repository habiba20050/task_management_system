import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';
import '../styles/app_radius.dart';
import '../styles/app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getTheme(langCode: 'EN', isDark: false);
  static ThemeData get darkTheme => getTheme(langCode: 'EN', isDark: true);

  static ThemeData getTheme({required String langCode, required bool isDark}) {
    final bool isArabic = langCode.toUpperCase() == 'AR';
    
    // Choose base TextTheme using Google Fonts
    final TextTheme baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
        
    final TextTheme fontTextTheme = isArabic
        ? GoogleFonts.cairoTextTheme(baseTextTheme)
        : GoogleFonts.interTextTheme(baseTextTheme);

    // Apply custom colors to TextTheme
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    final TextTheme textTheme = fontTextTheme.copyWith(
      displayLarge: fontTextTheme.displayLarge?.copyWith(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: fontTextTheme.displayMedium?.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: fontTextTheme.displaySmall?.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: fontTextTheme.headlineMedium?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: fontTextTheme.headlineSmall?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: fontTextTheme.titleLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: fontTextTheme.titleMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: fontTextTheme.bodyLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: fontTextTheme.bodyMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: fontTextTheme.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
    );

    final seedColor = AppColors.primary;
    final scaffoldBg = isDark ? const Color(0xFF1E1E1E) : AppColors.background;
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : AppColors.surface;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: seedColor,
        secondary: AppColors.success,
        error: AppColors.error,
        surface: surfaceColor,
        background: scaffoldBg,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          side: BorderSide(color: AppColors.border.withOpacity(isDark ? 0.1 : 0.5)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          textStyle: TextStyle(
            fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          textStyle: TextStyle(
            fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          textStyle: TextStyle(
            fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF242424) : AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: 14.sp,
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: MaterialStateProperty.all(isDark ? const Color(0xFF242424) : AppColors.background),
        dataRowColor: MaterialStateProperty.all(surfaceColor),
        headingTextStyle: TextStyle(
          fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
        dataTextStyle: TextStyle(
          fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.inter().fontFamily,
          color: textColor,
          fontSize: 13.sp,
        ),
        dividerThickness: 1,
        horizontalMargin: 16.w,
        columnSpacing: 24.w,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
        ),
      ),
    );
  }
}
