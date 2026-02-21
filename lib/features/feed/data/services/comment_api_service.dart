import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/post_detail_model.dart';

class CommentApiService {
  final Dio dio;

  CommentApiService({required this.dio});

  Future<PostDetailModel> getPostWithComments({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.getPostUrl}/$postId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return PostDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch post details');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch post details',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> createComment({
    required String token,
    required String postId,
    required String comment,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.createCommentUrl,
        data: {'postId': postId, 'comment': comment},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create comment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to create comment',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.deleteCommentUrl}/$commentId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to delete comment',
        );
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
}
