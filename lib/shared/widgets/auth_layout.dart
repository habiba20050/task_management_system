import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../responsive/responsive_layout.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final bool isTablet = ResponsiveLayout.isTablet(context);

    // Calculate dimensions based on screen sizes
    final double cardWidth = isMobile
        ? 340.w
        : isTablet
            ? 700.w
            : 950.w;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF031A3A), // Dark blue top-left
                  Color(0xFF063369), // Medium brand blue
                  Color(0xFF0A58B6), // Bright blue bottom-right
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Concentric background circle curves
          const Positioned.fill(
            child: CustomPaint(
              painter: AuthBackgroundCurvesPainter(),
            ),
          ),

          // Translucent decorative shapes
          Positioned(
            top: 100.h,
            left: 80.w,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 120.h,
            right: 100.w,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),

          // Centered Card Layout
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              child: Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: isMobile
                    ? _buildMobileContent(context)
                    : _buildDesktopContent(context, isTablet),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop / Tablet layout: Side-by-side row split
  Widget _buildDesktopContent(BuildContext context, bool isTablet) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Branding
          Expanded(
            flex: isTablet ? 10 : 9,
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with shadow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 270.w,
                      height: 270.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // University Name English
                  Text(
                    'Assiut International Technological University',
                    style: TextStyle(
                      color: const Color(0xFF1565C0), // Button color
                      fontSize: isTablet ? 13.sp : 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  // University Name Arabic
                  Text(
                    'جامعة أسيوط التكنولوجية الدولية',
                    style: TextStyle(
                      color: const Color(0xFF1565C0), // Button color
                      fontSize: isTablet ? 14.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  // Elegant divider line
                  Container(
                    width: 50.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // System Name
                  Text(
                    'Task & Ticket\nManagement System',
                    style: TextStyle(
                      color: const Color(0xFF041831),
                      fontSize: isTablet ? 18.sp : 21.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'نظام إدارة المهام والتذاكر',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: isTablet ? 12.sp : 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Vertical Divider
          VerticalDivider(
            color: Colors.grey.shade200,
            width: 1,
            thickness: 1,
          ),
          // Right side: Form child
          Expanded(
            flex: 11,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.w : 48.w,
                vertical: 40.h,
              ),
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout: Vertical stack split
  Widget _buildMobileContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top side: Branding
        Container(
          color: const Color(0xFFF8FAFC),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 175.w,
                  height: 175.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20.h),
              // University Name English
              Text(
                'Assiut International Technological University',
                style: TextStyle(
                  color: const Color(0xFF1565C0),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              // University Name Arabic
              Text(
                'جامعة أسيوط التكنولوجية الدولية',
                style: TextStyle(
                  color: const Color(0xFF1565C0),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Elegant divider line
              Container(
                width: 40.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
              SizedBox(height: 16.h),
              // System Name
              Text(
                'Task & Ticket Management System',
                style: TextStyle(
                  color: const Color(0xFF041831),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                'نظام إدارة المهام والتذاكر',
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Horizontal Divider
        Divider(
          color: Colors.grey.shade200,
          height: 1,
          thickness: 1,
        ),
        // Bottom side: Form child
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: child,
        ),
      ],
    );
  }
}

class AuthBackgroundCurvesPainter extends CustomPainter {
  const AuthBackgroundCurvesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left concentric circles (centered offscreen top-left)
    final centerLeft = Offset(-size.width * 0.2, size.height * 0.15);
    canvas.drawCircle(centerLeft, size.width * 0.4, paint);
    canvas.drawCircle(centerLeft, size.width * 0.7, paint);
    canvas.drawCircle(centerLeft, size.width * 1.0, paint);
    canvas.drawCircle(centerLeft, size.width * 1.3, paint);

    // Right concentric circles (centered offscreen bottom-right)
    final centerRight = Offset(size.width * 1.2, size.height * 0.85);
    canvas.drawCircle(centerRight, size.width * 0.5, paint);
    canvas.drawCircle(centerRight, size.width * 0.8, paint);
    canvas.drawCircle(centerRight, size.width * 1.1, paint);
    canvas.drawCircle(centerRight, size.width * 1.4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
