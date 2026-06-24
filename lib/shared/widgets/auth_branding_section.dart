import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../responsive/responsive_layout.dart';

class AuthBrandingSection extends StatelessWidget {
  const AuthBrandingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveLayout.isDesktop(context) ? 500.w : 400.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031A3A), // Dark blue top-left
            Color(0xFF063369), // Medium brand blue
            Color(0xFF0A58B6), // Bright blue bottom-right
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ResponsiveLayout.isDesktop(context)
            ? null
            : BorderRadius.only(
                topLeft: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
      ),
      child: Stack(
        children: [
          // Background thin concentric circles overlay
          const Positioned.fill(
            child: CustomPaint(
              painter: BackgroundCurvesPainter(),
            ),
          ),

          // Floating semi-transparent circle (top right)
          Positioned(
            top: 60.h,
            right: 80.w,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Floating rotated translucent square (middle right)
          Positioned(
            bottom: 260.h,
            right: 60.w,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),

          // Core content layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 48.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Logo & Brand Text
                Row(
                  children: [
                    Image.asset(
                      'assets/images/aitu_logo.png',
                      width: 64.w,
                      height: 64.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AITU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'TASK MANAGEMENT',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 48.h),

                // Capsule Badge: Task & Ticket Management System
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF27AE60), // Green dot
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Task & Ticket Management System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 70.h),

                // Main Heading
                Text(
                  'Manage Academic\nTasks with\nPrecision.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 24.h),

                // Sub-description
                Text(
                  'Streamline workflows, track progress, and collaborate seamlessly across all AITU departments and teams.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.sp,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 48.h),

                // Feature capsule tags Wrap
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    _buildFeatureTag('Kanban Boards'),
                    _buildFeatureTag('Team Management'),
                    _buildFeatureTag('Auto Reports'),
                    _buildFeatureTag('Role-Based Access'),
                  ],
                ),
                const Spacer(),

                // Bottom Copyright
                Center(
                  child: Text(
                    '© 2026 Assiut International Technological University',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// CustomPainter to paint clean math/tech background circular paths
class BackgroundCurvesPainter extends CustomPainter {
  const BackgroundCurvesPainter();

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
