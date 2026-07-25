import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand & UI Colors (Unified Design System)
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF041831);
  static const Color accent = Color(0xFFFA1819);

  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF041831);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9E9E9E);

  static const Color border = Color(0xFFD9E2EC);
  static const Color divider = Color(0xFFE0E0E0);

  // Status & Utility Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFA1819);
  static const Color danger = error;
  static const Color info = Color(0xFF2196F3);
  static const Color inProgress = Color(0xFF26A69A); // Teal/Turquoise for Progress

  // Backward Compatibility Aliases for Brand Identity
  static const Color aituBlue = primary;
  static const Color aituBlueDark = primaryDark;
  static const Color aituBlueLight = primary;
  static const Color aituRed = accent;
  
  static const Color card = surface;
  static const Color authBackground = background;
  static const Color dashboardBg = background;
  static const Color sidebarBg = surface;
  static const Color sidebarActiveBg = primary;
  static const Color sidebarProfileBg = background;
  
  static const Color secondary = success;
  static const Color secondaryDark = success;
  static const Color secondaryLight = success;

  // KPI Visuals
  static const Color kpiTotalTasks = primary;
  static const Color kpiCompleted = success;
  static const Color kpiInProgress = inProgress;
  static const Color kpiOverdue = error;

  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFE0E0E0);
}
