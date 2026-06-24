class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  static String get fullBaseUrl => '$baseUrl/$apiVersion';
}
