import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/profile_response.dart';
import '../repository/profile_repository.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileResponse profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class PasswordChangeLoading extends ProfileState {
  const PasswordChangeLoading();
}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

class UpdateProfileLoading extends ProfileState {
  const UpdateProfileLoading();
}

class UpdateProfileSuccess extends ProfileState {
  const UpdateProfileSuccess();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await _profileRepository.getProfile();
      emit(ProfileLoaded(profile));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(ProfileError(message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const PasswordChangeLoading());
    try {
      await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(const PasswordChangeSuccess());
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(ProfileError(message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobTitle,
  }) async {
    emit(const UpdateProfileLoading());
    try {
      await _profileRepository.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        jobTitle: jobTitle,
      );
      emit(const UpdateProfileSuccess());
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(ProfileError(message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
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
