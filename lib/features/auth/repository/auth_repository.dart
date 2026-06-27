import '../model/login_request.dart';
import '../model/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
}
