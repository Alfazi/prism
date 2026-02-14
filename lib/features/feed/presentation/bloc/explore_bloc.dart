import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/feed_api_service.dart';
import '../../../auth/data/services/auth_local_service.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final FeedApiService feedApiService;
  final AuthLocalService authLocalService;

  ExploreBloc({required this.feedApiService, required this.authLocalService})
    : super(const ExploreState()) {
    on<FetchExplorePosts>(_onFetchExplorePosts);
    on<LoadMoreExplorePosts>(_onLoadMoreExplorePosts);
    on<ExplorePostLikeToggled>(_onExplorePostLikeToggled);
  }

  Future<void> _onFetchExplorePosts(
    FetchExplorePosts event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      if (!event.refresh) {
        emit(state.copyWith(status: ExploreStatus.loading));
      }

      final token = await authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: ExploreStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      print('📱 Initial fetch explore posts...');
      final response = await feedApiService.getExplorePosts(
        token: token,
        size: 10,
        page: 1,
      );

      print('✅ Initial fetch received:');
      print('   Posts: ${response.posts.length}');
      print('   currentPage: ${response.currentPage}');
      print('   totalPages: ${response.totalPages}');
      print('   totalItems: ${response.totalItems}');

      final hasMore =
          response.totalPages > 0 && response.currentPage < response.totalPages;

      print('   hasMorePosts: $hasMore');

      emit(
        state.copyWith(
          status: ExploreStatus.success,
          posts: response.posts,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasMorePosts: hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExploreStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMoreExplorePosts(
    LoadMoreExplorePosts event,
    Emitter<ExploreState> emit,
  ) async {
    // Debug: Check why load more might not be working
    print('🔄 LoadMoreExplorePosts triggered');
    print('   hasMorePosts: ${state.hasMorePosts}');
    print('   currentPage: ${state.currentPage}');
    print('   totalPages: ${state.totalPages}');
    print('   status: ${state.status}');

    if (!state.hasMorePosts || state.status == ExploreStatus.loadingMore) {
      print(
        '   ❌ Blocked: hasMorePosts=${state.hasMorePosts}, status=${state.status}',
      );
      return;
    }

    try {
      emit(state.copyWith(status: ExploreStatus.loadingMore));

      final token = await authLocalService.getToken();
      if (token == null) {
        print('   ❌ No token');
        return;
      }

      final nextPage = state.currentPage + 1;
      print('   📡 Fetching page $nextPage...');

      final response = await feedApiService.getExplorePosts(
        token: token,
        size: 10,
        page: nextPage,
      );

      print('   ✅ Received ${response.posts.length} posts');
      print('   Response currentPage: ${response.currentPage}');
      print('   Response totalPages: ${response.totalPages}');

      final updatedPosts = [...state.posts, ...response.posts];

      emit(
        state.copyWith(
          status: ExploreStatus.success,
          posts: updatedPosts,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasMorePosts:
              response.posts.isNotEmpty &&
              response.currentPage < response.totalPages,
        ),
      );

      print(
        '   ✅ Updated: ${updatedPosts.length} total posts, hasMorePosts: ${response.posts.isNotEmpty && response.currentPage < response.totalPages}',
      );
    } catch (e) {
      print('   ❌ Error: $e');
      emit(
        state.copyWith(
          status: ExploreStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onExplorePostLikeToggled(
    ExplorePostLikeToggled event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      final token = await authLocalService.getToken();
      if (token == null) return;

      // Optimistically update UI
      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLike: !event.currentlyLiked,
            totalLikes: event.currentlyLiked
                ? post.totalLikes - 1
                : post.totalLikes + 1,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts));

      // Make API call
      if (event.currentlyLiked) {
        await feedApiService.unlikePost(token: token, postId: event.postId);
      } else {
        await feedApiService.likePost(token: token, postId: event.postId);
      }
    } catch (e) {
      // Revert optimistic update on error
      final revertedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLike: event.currentlyLiked,
            totalLikes: event.currentlyLiked
                ? post.totalLikes + 1
                : post.totalLikes - 1,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: revertedPosts));
    }
  }
}
