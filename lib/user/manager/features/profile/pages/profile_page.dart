import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/colors/app_colors.dart';
import '../../../../../responsive/responsive_layout.dart';
import '../../../../../user/shared/features/profile/cubit/profile_cubit.dart';
import 'package:task_management_system/auth/cubit/auth_cubit.dart';
import '../../../../../core/localization/translate_extension.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Form 1 Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form 2 Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Locked fields
  String _username = '';
  String _email = '';
  String _initials = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _deptController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateControllers(ProfileLoaded state) {
    final profile = state.profile;
    _fullNameController.text = profile.fullName ?? '';
    _jobTitleController.text = profile.jobTitle ?? '';
    _deptController.text = profile.department ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _username = profile.username;
    _email = profile.email;
    _initials = _getInitials(profile.fullName ?? profile.username);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _darker(Color c, [double f = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - f).clamp(0.0, 1.0)).toColor();
  }

  BoxDecoration _modernCardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _gradientChip(IconData icon, Color color, {double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, _darker(color)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }

  InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 48.h,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: onTap == null ? [Colors.grey, Colors.grey.shade600] : colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: onTap == null
                  ? null
                  : [
                      BoxShadow(
                        color: colors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                else ...[
                  Icon(icon, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final userRole = authState is AuthSuccess ? authState.user.role : 'Manager';

    return Container(
      color: AppColors.dashboardBg,
      child: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _populateControllers(state);
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password updated successfully!'.tr(context)),
                  backgroundColor: AppColors.success,
                ),
              );
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            } else if (state is UpdateProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Personal information updated successfully!'.tr(context)),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<ProfileCubit>().loadProfile();
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      child: Text('Retry'.tr(context)),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.w : 16.w,
                vertical: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildProfileSummaryCard(context, userRole),
                  SizedBox(height: 24.h),
                  _buildPersonalInformationForm(context, state),
                  SizedBox(height: 24.h),
                  _buildChangePasswordForm(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientChip(Icons.person_outline, AppColors.primary, size: 44),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Settings'.tr(context),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Update your personal profile, email, and security settings'.tr(context),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context, String userRole) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: _modernCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, _darker(AppColors.primary)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials.isNotEmpty ? _initials : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullNameController.text.isNotEmpty
                      ? _fullNameController.text
                      : _username,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${userRole.tr(context)} — ${_deptController.text.isNotEmpty ? _deptController.text : 'N/A'.tr(context)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Active account'.tr(context),
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationForm(
    BuildContext context,
    ProfileState state,
  ) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isUpdateLoading = state is UpdateProfileLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(Icons.badge_outlined, Colors.indigo, size: 36),
              SizedBox(width: 12.w),
              Text(
                'Personal Information'.tr(context),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (isDesktop) ...[
            Row(
              children: [
                Expanded(child: _buildLockedField('Username (locked)', _username, Icons.account_circle_outlined)),
                SizedBox(width: 24.w),
                Expanded(child: _buildLockedField('Email Address (locked)', _email, Icons.email_outlined)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildInputField('Full Name', _fullNameController, Icons.person_outline)),
                SizedBox(width: 24.w),
                Expanded(child: _buildInputField('Job Title', _jobTitleController, Icons.work_outline)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildInputField('Department', _deptController, Icons.business_outlined)),
                SizedBox(width: 24.w),
                Expanded(child: _buildInputField('Phone Number', _phoneController, Icons.phone_outlined)),
              ],
            ),
          ] else ...[
            _buildLockedField('Username (locked)', _username, Icons.account_circle_outlined),
            SizedBox(height: 16.h),
            _buildLockedField('Email Address (locked)', _email, Icons.email_outlined),
            SizedBox(height: 16.h),
            _buildInputField('Full Name', _fullNameController, Icons.person_outline),
            SizedBox(height: 16.h),
            _buildInputField('Job Title', _jobTitleController, Icons.work_outline),
            SizedBox(height: 16.h),
            _buildInputField('Department', _deptController, Icons.business_outlined),
            SizedBox(height: 16.h),
            _buildInputField('Phone Number', _phoneController, Icons.phone_outlined),
          ],
          SizedBox(height: 24.h),
          _gradientButton(
            label: 'Save Changes'.tr(context),
            icon: Icons.save_outlined,
            colors: [AppColors.primary, _darker(AppColors.primary)],
            isLoading: isUpdateLoading,
            onTap: isUpdateLoading
                ? null
                : () {
                    context.read<ProfileCubit>().updateProfile(
                      fullName: _fullNameController.text,
                      email: _email,
                      phoneNumber: _phoneController.text,
                      jobTitle: _jobTitleController.text,
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordForm(BuildContext context, ProfileState state) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isPasswordLoading = state is PasswordChangeLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: _modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _gradientChip(Icons.lock_outline, Colors.teal, size: 36),
              SizedBox(width: 12.w),
              Text(
                'Security Settings'.tr(context),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildPasswordField('Current Password', _currentPasswordController, 'Enter your current password'),
          SizedBox(height: 16.h),
          if (isDesktop) ...[
            Row(
              children: [
                Expanded(child: _buildPasswordField('New Password', _newPasswordController, 'New password')),
                SizedBox(width: 24.w),
                Expanded(child: _buildPasswordField('Confirm New Password', _confirmPasswordController, 'Confirm new password')),
              ],
            ),
          ] else ...[
            _buildPasswordField('New Password', _newPasswordController, 'New password'),
            SizedBox(height: 16.h),
            _buildPasswordField('Confirm New Password', _confirmPasswordController, 'Confirm new password'),
          ],
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Password must be at least 8 characters, include at least one uppercase letter, one number, and one special character (@, #, !, etc.).'.tr(context),
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 12.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _gradientButton(
            label: 'Update Password'.tr(context),
            icon: Icons.key_outlined,
            colors: [Colors.teal, _darker(Colors.teal)],
            isLoading: isPasswordLoading,
            onTap: isPasswordLoading
                ? null
                : () {
                    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all password fields.'.tr(context))));
                      return;
                    }
                    if (_newPasswordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match.'.tr(context))));
                      return;
                    }
                    context.read<ProfileCubit>().changePassword(
                      currentPassword: _currentPasswordController.text,
                      newPassword: _newPasswordController.text,
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildLockedField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textHint, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.lock_outline, color: AppColors.textHint, size: 16.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          decoration: _fieldDecoration(label, prefixIcon: Icon(icon, color: AppColors.textHint, size: 18.sp)),
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: _fieldDecoration(hint, prefixIcon: Icon(Icons.password_outlined, color: AppColors.textHint, size: 18.sp)),
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
