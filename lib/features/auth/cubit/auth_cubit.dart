import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual login logic
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login
      final user = UserModel(
        id: '1',
        email: email,
        username: email.split('@')[0],
        role: 'user',
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual forgot password logic
      await Future.delayed(const Duration(seconds: 1));
      emit(OtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual OTP verification logic
      await Future.delayed(const Duration(seconds: 1));
      emit(PasswordResetRequested());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual password reset logic
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}
