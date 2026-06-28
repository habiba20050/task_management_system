import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/notification_drawer.dart';
import '../cubit/profile_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      endDrawer: const NotificationDrawer(),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _populateControllers(state);
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            } else if (state is UpdateProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personal information updated successfully!'),
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
                    Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: 'Retry',
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
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
                  _buildProfileSummaryCard(context),
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
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isDesktop ? 22.sp : 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Update your personal profile, email, and security settings',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isDesktop ? 13.sp : 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.h,
            decoration: const BoxDecoration(
              color: Color(0xFF051B33),
              shape: BoxShape.circle,
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
                  'Admin — ${_deptController.text.isNotEmpty ? _deptController.text : 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27AE60),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Active account',
                      style: TextStyle(
                        color: const Color(0xFF27AE60),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationForm(BuildContext context, ProfileState state) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isUpdateLoading = state is UpdateProfileLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          if (isDesktop) ...[
            Row(
              children: [
                Expanded(child: _buildLockedField('Username (locked)', _username)),
                SizedBox(width: 24.w),
                Expanded(child: _buildLockedField('Email Address (locked)', _email)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildInputField('Full Name', _fullNameController)),
                SizedBox(width: 24.w),
                Expanded(child: _buildInputField('Job Title', _jobTitleController)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildInputField('Department', _deptController)),
                SizedBox(width: 24.w),
                Expanded(child: _buildInputField('Phone Number', _phoneController)),
              ],
            ),
          ] else ...[
            _buildLockedField('Username (locked)', _username),
            SizedBox(height: 16.h),
            _buildLockedField('Email Address (locked)', _email),
            SizedBox(height: 16.h),
            _buildInputField('Full Name', _fullNameController),
            SizedBox(height: 16.h),
            _buildInputField('Job Title', _jobTitleController),
            SizedBox(height: 16.h),
            _buildInputField('Department', _deptController),
            SizedBox(height: 16.h),
            _buildInputField('Phone Number', _phoneController),
          ],
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: isUpdateLoading
                ? null
                : () {
                    context.read<ProfileCubit>().updateProfile(
                      fullName: _fullNameController.text,
                      email: _email,
                      phoneNumber: _phoneController.text,
                      jobTitle: _jobTitleController.text,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A448C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: isUpdateLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: const Color(0xFF0A448C), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Change Password',
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
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFF2C94C).withOpacity(0.2)),
            ),
            child: Text(
              'Password must be at least 8 characters, include at least one uppercase letter, one number, and one special character (@, #, !, etc.).',
              style: TextStyle(
                color: const Color(0xFF8C731F),
                fontSize: 12.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: isPasswordLoading
                ? null
                : () {
                    if (_currentPasswordController.text.isEmpty ||
                        _newPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all password fields.')),
                      );
                      return;
                    }
                    if (_newPasswordController.text !=
                        _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match.')),
                      );
                      return;
                    }
                    context.read<ProfileCubit>().changePassword(
                      currentPassword: _currentPasswordController.text,
                      newPassword: _newPasswordController.text,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A448C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: isPasswordLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 16.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Update Password',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.lock_outline, color: Colors.grey[400], size: 16.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
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
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, String hint) {
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
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
