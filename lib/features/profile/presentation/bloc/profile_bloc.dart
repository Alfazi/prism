import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/services/profile_api_service.dart';
import '../../data/models/profile_stats_model.dart';
import '../../../auth/data/services/auth_local_service.dart';
import '../../../feed/data/services/feed_api_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileApiService _profileApiService;
  final AuthLocalService _authLocalService;
  final FeedApiService _feedApiService;

  ProfileBloc({
    required ProfileApiService profileApiService,
    required AuthLocalService authLocalService,
    required FeedApiService feedApiService,
  }) : _profileApiService = profileApiService,
       _authLocalService = authLocalService,
       _feedApiService = feedApiService,
       super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadProfileStats>(_onLoadProfileStats);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LoadMoreUserPosts>(_onLoadMoreUserPosts);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final token = await _authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'No authentication token found',
          ),
        );
        return;
      }

      final user = await _profileApiService.getLoggedUser(token);

      // Create stats from user data
      final stats = ProfileStatsModel(
        postsCount: 0, // Will be updated when posts are loaded
        followersCount: user.totalFollowers ?? 0,
        followingCount: user.totalFollowing ?? 0,
      );

      emit(
        state.copyWith(status: ProfileStatus.loaded, user: user, stats: stats),
      );

      // Load posts after user is loaded
      if (user.id != null) {
        add(LoadUserPosts(userId: user.id!));
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadProfileStats(
    LoadProfileStats event,
    Emitter<ProfileState> emit,
  ) async {
    // This is now mainly a fallback - stats are loaded with user data
    // But we can still update from API if needed
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      // If we have user data, use it for follower stats
      if (state.user != null) {
        final stats = ProfileStatsModel(
          postsCount: state.stats.postsCount,
          followersCount: state.user!.totalFollowers ?? 0,
          followingCount: state.user!.totalFollowing ?? 0,
        );
        emit(state.copyWith(stats: stats));
      }
    } catch (e) {
      // Silently fail for stats - the UI will show 0s
    }
  }

  Future<void> _onLoadUserPosts(
    LoadUserPosts event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final response = await _profileApiService.getUserPosts(
        token: token,
        userId: event.userId,
        page: event.page,
      );

      // Filter out posts without images and reverse to show latest first
      final postsWithImages = response.posts
          .where((post) => post.imageUrl.isNotEmpty)
          .toList();
      final reversedPosts = postsWithImages.reversed.toList();

      emit(
        state.copyWith(
          posts: reversedPosts,
          currentPage: event.page,
          hasMorePosts: event.page < response.totalPages,
          stats: state.stats.copyWith(postsCount: response.totalItems),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onLoadMoreUserPosts(
    LoadMoreUserPosts event,
    Emitter<ProfileState> emit,
  ) async {
    if (!state.hasMorePosts) return;

    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final nextPage = state.currentPage + 1;
      final response = await _profileApiService.getUserPosts(
        token: token,
        userId: event.userId,
        page: nextPage,
      );

      // Filter out posts without images and reverse new posts to show latest first
      final postsWithImages = response.posts
          .where((post) => post.imageUrl.isNotEmpty)
          .toList();
      final reversedPosts = postsWithImages.reversed.toList();

      emit(
        state.copyWith(
          posts: [...state.posts, ...reversedPosts],
          currentPage: nextPage,
          hasMorePosts: nextPage < response.totalPages,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      final user = await _profileApiService.getLoggedUser(token);

      // Update stats from user data
      final stats = ProfileStatsModel(
        postsCount: state.stats.postsCount, // Keep current post count
        followersCount: user.totalFollowers ?? 0,
        followingCount: user.totalFollowing ?? 0,
      );

      emit(state.copyWith(user: user, stats: stats));

      if (user.id != null) {
        add(LoadUserPosts(userId: user.id!));
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdatePost(
    UpdatePost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      await _feedApiService.updatePost(
        token: token,
        postId: event.postId,
        imageUrl: event.imageUrl,
        caption: event.caption,
      );

      // Refresh posts after update
      if (state.user?.id != null) {
        add(LoadUserPosts(userId: state.user!.id!));
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final token = await _authLocalService.getToken();
      if (token == null) return;

      await _feedApiService.deletePost(token: token, postId: event.postId);

      // Remove post from list locally and update count
      final updatedPosts = state.posts
          .where((post) => post.id != event.postId)
          .toList();

      emit(
        state.copyWith(
          posts: updatedPosts,
          stats: state.stats.copyWith(postsCount: state.stats.postsCount - 1),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final token = await _authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'No authentication token found',
          ),
        );
        return;
      }

      await _profileApiService.updateProfile(
        token: token,
        name: event.name,
        username: event.username,
        email: event.email,
        profilePictureUrl: event.profilePictureUrl,
        phoneNumber: event.phoneNumber,
        bio: event.bio,
        website: event.website,
      );

      // Reload user profile to get updated data
      final updatedUser = await _profileApiService.getLoggedUser(token);

      // Update stats from user data
      final stats = ProfileStatsModel(
        postsCount: state.stats.postsCount,
        followersCount: updatedUser.totalFollowers ?? 0,
        followingCount: updatedUser.totalFollowing ?? 0,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: updatedUser,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
