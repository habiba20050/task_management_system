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
}
