import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) {
    return ScreenUtil().screenWidth < 600;
  }

  static bool isTablet(BuildContext context) {
    return ScreenUtil().screenWidth >= 600 && ScreenUtil().screenWidth < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return ScreenUtil().screenWidth >= 1200;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ResponsiveLayout.isMobile(context),
      ResponsiveLayout.isTablet(context),
      ResponsiveLayout.isDesktop(context),
    );
  }
}
