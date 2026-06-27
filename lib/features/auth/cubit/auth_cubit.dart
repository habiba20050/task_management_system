import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/login_request.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;
  final String accessToken;

  const AuthSuccess(this.user, this.accessToken);

  @override
  List<Object?> get props => [user, accessToken];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class OtpSent extends AuthState {
  const OtpSent();
}

class PasswordResetRequested extends AuthState {
  const PasswordResetRequested();
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final request = LoginRequest(identifier: email, password: password);
      final response = await _authRepository.login(request);

      emit(AuthSuccess(
        response.user ??
            UserModel(
              id: '',
              email: email,
              username: email.split('@')[0],
              role: 'user',
            ),
        response.accessToken,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const OtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    emit(const AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const PasswordResetRequested());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(const AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() {
    emit(const AuthUnauthenticated());
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      return data['message'] as String? ??
          data['title'] as String? ??
          e.message ??
          'An unexpected error occurred';
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
