import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../model/change_password_request.dart';
import '../model/profile_response.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  Future<ProfileResponse> getProfile(String token) async {
    final response = await _dio.get(
      ApiConstants.profileEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to load profile with status code: ${response.statusCode}',
    );
  }

  Future<void> changePassword(
      String token, ChangePasswordRequest request) async {
    await _dio.put(
      ApiConstants.changePasswordEndpoint,
      data: request.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<ProfileResponse> updateProfile({
    required String token,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String jobTitle,
  }) async {
    final formData = FormData.fromMap({
      'FullName': fullName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'JobTitle': jobTitle,
      'Signature': '',
    });

    final response = await _dio.put(
      ApiConstants.profileEndpoint,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to update profile with status code: ${response.statusCode}',
    );
  }
}
