import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/following_response_model.dart';
import '../models/user_posts_response_model.dart';
import '../models/profile_stats_model.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileApiService {
  Future<UserModel> getLoggedUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserUrl}'),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return UserModel.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to load user profile');
      }
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
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (bio != null) 'bio': bio,
        if (website != null) 'website': website,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateProfileUrl}'),
        headers: ApiConstants.getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.myFollowingUrl}?size=$size&page=$page',
        ),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FollowingResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load following');
      }
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.myFollowersUrl}?size=$size&page=$page',
        ),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FollowingResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load followers');
      }
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.userPostsUrl}/$userId?size=$size&page=$page',
        ),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserPostsResponseModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load user posts');
      }
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
}
