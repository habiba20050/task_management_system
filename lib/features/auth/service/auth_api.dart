import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.loginEndpoint,
      data: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Login failed with status code: ${response.statusCode}',
    );
  }

  Future<void> logout(String token) async {
    await _dio.post(
      ApiConstants.logoutEndpoint,
      data: {},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiConstants.forgotPasswordEndpoint,
      data: {
        "email": email,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post(
      ApiConstants.resetPasswordEndpoint,
      data: {
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      },
    );
  }
}
