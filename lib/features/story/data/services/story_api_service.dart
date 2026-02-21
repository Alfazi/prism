import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/story_response_model.dart';
import '../models/story_model.dart';

class StoryApiService {
  final Dio dio;

  StoryApiService({required this.dio});

  /// Get following users stories
  Future<StoryResponseModel> getFollowingStories({
    required String token,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.followingStoryUrl,
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return StoryResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch stories');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch stories',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get story by ID
  Future<StoryModel> getStoryById({
    required String token,
    required String storyId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.getStoryUrl}/$storyId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return StoryModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch story');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch story');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Create a new story
  Future<StoryModel> createStory({
    required String token,
    required String imageUrl,
    required String caption,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.createStoryUrl,
        data: {'imageUrl': imageUrl, 'caption': caption},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return StoryModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create story');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to create story',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Delete a story
  Future<void> deleteStory({
    required String token,
    required String storyId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.deleteStoryUrl}/$storyId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete story');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to delete story',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get story views by story ID
  Future<List<Map<String, dynamic>>> getStoryViews({
    required String token,
    required String storyId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.storyViewsUrl}/$storyId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        return data?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      } else {
        throw Exception('Failed to fetch story views');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch story views',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
