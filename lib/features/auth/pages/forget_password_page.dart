import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/validation/validators.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/auth_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().forgotPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(child: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveLayout.isMobile(context) ? 20.h : 40.h),
          Text(
            'Forget Password',
            style: TextStyle(
              fontSize: ResponsiveLayout.isMobile(context) ? 24.sp : 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your registered email address. You will receive a 6-digit OTP code to reset your password.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),

          // Email Field
          CustomTextField(
            label: 'Username or Email Address',
            hint: 'Enter Your Email',
            controller: _emailController,
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSendOtp(),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.textHint,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 30.h),

          // Confirm Button
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is OtpSent) {
                context.push(
                  '/verify-email',
                  extra: _emailController.text.trim(),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomButton(
                text: 'Confirm',
                onPressed: _handleSendOtp,
                isLoading: state is AuthLoading,
              );
            },
          ),
          SizedBox(height: 24.h),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
