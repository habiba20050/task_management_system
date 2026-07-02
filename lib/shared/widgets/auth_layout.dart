import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../responsive/responsive_layout.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final bool isTablet = ResponsiveLayout.isTablet(context);

    // Calculate dimensions based on screen sizes
    final double cardWidth = isMobile
        ? 340.w
        : isTablet
        ? 450.w
        : 480.w;

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
            child: CustomPaint(painter: AuthBackgroundCurvesPainter()),
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
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.w : 36.w,
                    vertical: isMobile ? 32.h : 40.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Circular Logo with glow shadow
                      Center(
                        child: Container(
                          width: isMobile ? 130.w : 170.w,
                          height: isMobile ? 130.w : 170.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(8.r),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // University Short Name / Acronym
                      Text(
                        'AITU',
                        style: TextStyle(
                          color: const Color(0xFF1565C0),
                          fontSize: isMobile ? 28.sp : 32.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),

                      // System Name
                      Text(
                        'Task Management System',
                        style: TextStyle(
                          color: const Color(0xFF1565C0),
                          fontSize: isMobile ? 13.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),

                      // University Name in Arabic
                      Text(
                        'جامعة أسيوط التكنولوجية الدولية',
                        style: TextStyle(
                          color: const Color(0xFF757575),
                          fontSize: isMobile ? 14.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Small separator
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 16.h),
                          width: 40.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                      ),

                      // Form child
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
