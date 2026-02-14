import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/feed_response_model.dart';
import '../models/post_model.dart';

class FeedApiService {
  final Dio dio;

  FeedApiService({required this.dio});

  Future<FeedResponseModel> getFollowingPosts({
    required String token,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.followingPostUrl,
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return FeedResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch feed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch feed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> likePost({required String token, required String postId}) async {
    try {
      final response = await dio.post(
        ApiConstants.likePostUrl,
        data: {'postId': postId},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to like post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> unlikePost({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.unlikePostUrl,
        data: {'postId': postId},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unlike post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to unlike post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<FeedResponseModel> getExplorePosts({
    required String token,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.explorePostUrl,
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return FeedResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch explore posts');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch explore posts',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<PostModel> getPostById({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.getPostUrl}/$postId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<FeedResponseModel> getUserPosts({
    required String token,
    required String userId,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.getUserPostsUrl}/$userId',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return FeedResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user posts');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch user posts',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<PostModel> createPost({
    required String token,
    required String imageUrl,
    required String caption,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.createPostUrl,
        data: {'imageUrl': imageUrl, 'caption': caption},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<PostModel> updatePost({
    required String token,
    required String postId,
    required String imageUrl,
    required String caption,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.updatePostUrl}/$postId',
        data: {'imageUrl': imageUrl, 'caption': caption},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> deletePost({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.deletePostUrl}/$postId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete post');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
