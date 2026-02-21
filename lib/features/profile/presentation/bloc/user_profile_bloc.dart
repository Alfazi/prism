import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';
import '../../data/services/profile_api_service.dart';
import '../../data/models/profile_stats_model.dart';
import '../../../auth/data/services/auth_local_service.dart';
import '../../../feed/data/services/feed_api_service.dart';
import '../../../feed/data/models/post_model.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final ProfileApiService _profileApiService;
  final AuthLocalService _authLocalService;

  UserProfileBloc({
    required ProfileApiService profileApiService,
    required AuthLocalService authLocalService,
    FeedApiService?
    feedApiService, // Kept for compatibility with GetIt registration
  }) : _profileApiService = profileApiService,
       _authLocalService = authLocalService,
       super(const UserProfileState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<LoadUserProfilePosts>(_onLoadUserProfilePosts);
    on<LoadMoreUserProfilePosts>(_onLoadMoreUserProfilePosts);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(status: UserProfileStatus.loading));

    try {
      final token = await _authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: UserProfileStatus.error,
            errorMessage: 'No authentication token found',
          ),
        );
        return;
      }

      final user = await _profileApiService.getUserById(
        token: token,
        userId: event.userId,
      );

      // Create stats from user data
      final stats = ProfileStatsModel(
        postsCount: 0, // Will be updated when posts are loaded
        followersCount: user.totalFollowers ?? 0,
        followingCount: user.totalFollowing ?? 0,
      );

      // Check if currently following this user
      final isFollowing = await _profileApiService.isFollowingUser(
        token: token,
        userId: event.userId,
      );

      emit(
        state.copyWith(
          status: UserProfileStatus.loaded,
          user: user,
          stats: stats,
          isFollowing: isFollowing,
        ),
      );

      // Load posts after user is loaded
      add(LoadUserProfilePosts(userId: event.userId));
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadUserProfilePosts(
    LoadUserProfilePosts event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final response = await _profileApiService.getUserPosts(
        token: token,
        userId: event.userId,
        size: 10,
        page: event.page,
      );

      // Filter out posts without images
      final postsWithImages = response.posts
          .where((post) => post.imageUrl.isNotEmpty)
          .toList();

      final updatedStats = state.stats.copyWith(
        postsCount: response.totalItems,
      );

      emit(
        state.copyWith(
          posts: postsWithImages,
          stats: updatedStats,
          currentPage: 1,
          hasMorePosts: response.totalPages > 1,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onLoadMoreUserProfilePosts(
    LoadMoreUserProfilePosts event,
    Emitter<UserProfileState> emit,
  ) async {
    if (!state.hasMorePosts) return;

    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final nextPage = state.currentPage + 1;
      final response = await _profileApiService.getUserPosts(
        token: token,
        userId: event.userId,
        size: 10,
        page: nextPage,
      );

      // Filter out posts without images
      final postsWithImages = response.posts
          .where((post) => post.imageUrl.isNotEmpty)
          .toList();

      final updatedPosts = List<PostModel>.from(state.posts)
        ..addAll(postsWithImages);

      emit(
        state.copyWith(
          posts: updatedPosts,
          currentPage: nextPage,
          hasMorePosts: nextPage < response.totalPages,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final user = await _profileApiService.getUserById(
        token: token,
        userId: event.userId,
      );

      final response = await _profileApiService.getUserPosts(
        token: token,
        userId: event.userId,
        size: 10,
        page: 1,
      );

      // Filter out posts without images
      final postsWithImages = response.posts
          .where((post) => post.imageUrl.isNotEmpty)
          .toList();

      final stats = ProfileStatsModel(
        postsCount: response.totalItems,
        followersCount: user.totalFollowers ?? 0,
        followingCount: user.totalFollowing ?? 0,
      );

      // Check if currently following this user
      final isFollowing = await _profileApiService.isFollowingUser(
        token: token,
        userId: event.userId,
      );

      emit(
        state.copyWith(
          user: user,
          posts: postsWithImages,
          stats: stats,
          currentPage: 1,
          hasMorePosts: response.totalPages > 1,
          isFollowing: isFollowing,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isFollowLoading: true));

    try {
      final token = await _authLocalService.getToken();
      if (token == null) {
        emit(state.copyWith(isFollowLoading: false));
        return;
      }

      await _profileApiService.followUser(
        token: token,
        userIdFollow: event.userId,
      );

      // Update the stats to reflect the new follower count
      final updatedStats = state.stats.copyWith(
        followersCount: state.stats.followersCount + 1,
      );

      emit(
        state.copyWith(
          isFollowing: true,
          isFollowLoading: false,
          stats: updatedStats,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isFollowLoading: false));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUser event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isFollowLoading: true));

    try {
      final token = await _authLocalService.getToken();
      if (token == null) {
        emit(state.copyWith(isFollowLoading: false));
        return;
      }

      await _profileApiService.unfollowUser(token: token, userId: event.userId);

      // Update the stats to reflect the new follower count
      final updatedStats = state.stats.copyWith(
        followersCount: state.stats.followersCount - 1,
      );

      emit(
        state.copyWith(
          isFollowing: false,
          isFollowLoading: false,
          stats: updatedStats,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isFollowLoading: false));
    }
  }
}
