class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://test-deploy.runasp.net';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  static String get fullBaseUrl => baseUrl;

  // Auth endpoints
  static const String loginEndpoint = '/api/Auth/login';
  static const String logoutEndpoint = '/api/Auth/logout';
  static const String forgotPasswordEndpoint = '/api/Auth/forgot-password';
  static const String resetPasswordEndpoint = '/api/Auth/reset-password';

  // Profile endpoints
  static const String profileEndpoint = '/api/Profile';
  static const String changePasswordEndpoint = '/api/Profile/change-password';
}
