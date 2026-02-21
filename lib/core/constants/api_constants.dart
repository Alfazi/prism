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

  // Feed endpoints
  static const String followingPostUrl = '/following-post';
  static const String explorePostUrl = '/explore-post';

  // Post endpoints
  static const String createPostUrl = '/create-post';
  static const String updatePostUrl = '/update-post';
  static const String deletePostUrl = '/delete-post';
  static const String getPostUrl = '/post';
  static const String getUserPostsUrl = '/users-post';

  // Like endpoints
  static const String likePostUrl = '/like';
  static const String unlikePostUrl = '/unlike';

  // Comment endpoints
  static const String createCommentUrl = '/create-comment';
  static const String deleteCommentUrl = '/delete-comment';

  // Story endpoints
  static const String followingStoryUrl = '/following-story';
  static const String createStoryUrl = '/create-story';
  static const String deleteStoryUrl = '/delete-story';
  static const String getStoryUrl = '/story';
  static const String storyViewsUrl = '/story-views';

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
