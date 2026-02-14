class ApiConstants {
  static const String baseUrl =
      'https://photo-sharing-api-bootcamp.do.dibimbing.id/api/v1';
  static const String apiKey = 'API_KEY';

  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';

  // Upload endpoints
  static const String uploadImage = '/upload-image';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json', 'apiKey': apiKey};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Headers for multipart/form-data
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = {'apiKey': apiKey};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
