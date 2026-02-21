import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/following_response_model.dart';
import '../models/user_posts_response_model.dart';
import '../models/profile_stats_model.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileApiService {
  final Dio dio;

  ProfileApiService({required this.dio});

  Future<UserModel> getLoggedUser(String token) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getUserUrl}',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load user profile',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String username,
    required String email,
    String? profilePictureUrl,
    String? phoneNumber,
    String? bio,
    String? website,
  }) async {
    try {
      final body = {
        'name': name,
        'username': username,
        'email': email,
        ...profilePictureUrl != null
            ? {'profilePictureUrl': profilePictureUrl}
            : {},
        ...phoneNumber != null ? {'phoneNumber': phoneNumber} : {},
        ...bio != null ? {'bio': bio} : {},
        ...website != null ? {'website': website} : {},
      };

      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.updateProfileUrl}',
        data: body,
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update profile',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<FollowingResponseModel> getMyFollowing({
    required String token,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.myFollowingUrl}',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return FollowingResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load following',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching following: $e');
    }
  }

  Future<FollowingResponseModel> getMyFollowers({
    required String token,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.myFollowersUrl}',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return FollowingResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load followers',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching followers: $e');
    }
  }

  Future<UserPostsResponseModel> getUserPosts({
    required String token,
    required String userId,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.userPostsUrl}/$userId',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return UserPostsResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load user posts',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user posts: $e');
    }
  }

  Future<ProfileStatsModel> getProfileStats({
    required String token,
    required String userId,
  }) async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        getMyFollowing(token: token, size: 1, page: 1),
        getMyFollowers(token: token, size: 1, page: 1),
        getUserPosts(token: token, userId: userId, size: 1, page: 1),
      ]);

      return ProfileStatsModel(
        followingCount: (results[0] as FollowingResponseModel).totalItems,
        followersCount: (results[1] as FollowingResponseModel).totalItems,
        postsCount: (results[2] as UserPostsResponseModel).totalItems,
      );
    } catch (e) {
      throw Exception('Error fetching profile stats: $e');
    }
  }

  Future<UserModel> getUserById({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getUserUrl}/$userId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to load user');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<FollowingResponseModel> getFollowingByUserId({
    required String token,
    required String userId,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.followingByUserIdUrl}/$userId',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return FollowingResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load following',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching following: $e');
    }
  }

  Future<FollowingResponseModel> getFollowersByUserId({
    required String token,
    required String userId,
    int size = 10,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.followersByUserIdUrl}/$userId',
        queryParameters: {'size': size, 'page': page},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return FollowingResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load followers',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching followers: $e');
    }
  }

  Future<Map<String, dynamic>> followUser({
    required String token,
    required String userIdFollow,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.followUrl}',
        data: {'userIdFollow': userIdFollow},
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to follow user');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error following user: $e');
    }
  }

  Future<Map<String, dynamic>> unfollowUser({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.unfollowUrl}/$userId',
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to unfollow user',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error unfollowing user: $e');
    }
  }

  Future<bool> isFollowingUser({
    required String token,
    required String userId,
  }) async {
    try {
      // Fetch following list with a large page size to check
      // We'll check up to 1000 following users for efficiency
      const int pageSize = 100;
      int currentPage = 1;

      while (true) {
        final response = await getMyFollowing(
          token: token,
          size: pageSize,
          page: currentPage,
        );

        // Check if the user is in this page
        final isInPage = response.users.any((user) => user.id == userId);
        if (isInPage) {
          return true;
        }

        // If we've checked all pages, user is not following
        if (currentPage >= response.totalPages) {
          return false;
        }

        // Move to next page
        currentPage++;

        // Safety check: don't check more than 10 pages (1000 users)
        if (currentPage > 10) {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }
}
