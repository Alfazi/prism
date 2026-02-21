import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/feed_api_service.dart';
import '../../data/models/post_model.dart';
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

      // Fetch pages until we get posts with images or run out of pages
      List<PostModel> allPostsWithImages = [];
      int currentPage = 1;
      int totalPages = 1;
      const int maxPagesToFetch = 10; // Safety limit

      while (allPostsWithImages.isEmpty &&
          currentPage <= totalPages &&
          currentPage <= maxPagesToFetch) {
        final response = await feedApiService.getExplorePosts(
          token: token,
          size: 10,
          page: currentPage,
        );

        totalPages = response.totalPages;

        // Filter out posts without images
        final postsWithImages = response.posts
            .where((post) => post.imageUrl.isNotEmpty)
            .toList();

        if (postsWithImages.isNotEmpty) {
          allPostsWithImages = postsWithImages;
          break;
        }

        currentPage++;
      }

      final hasMore = currentPage < totalPages;

      emit(
        state.copyWith(
          status: ExploreStatus.success,
          posts: allPostsWithImages,
          currentPage: currentPage,
          totalPages: totalPages,
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
    if (!state.hasMorePosts || state.status == ExploreStatus.loadingMore) {
      return;
    }

    try {
      emit(state.copyWith(status: ExploreStatus.loadingMore));

      final token = await authLocalService.getToken();
      if (token == null) {
        return;
      }

      // Fetch pages until we get posts with images or run out of pages
      List<PostModel> newPostsWithImages = [];
      int currentPage = state.currentPage + 1;
      const int maxPagesToFetch = 10; // Safety limit

      while (newPostsWithImages.isEmpty &&
          currentPage <= state.totalPages &&
          currentPage <= state.currentPage + maxPagesToFetch) {
        final response = await feedApiService.getExplorePosts(
          token: token,
          size: 10,
          page: currentPage,
        );

        // Filter out posts without images
        final postsWithImages = response.posts
            .where((post) => post.imageUrl.isNotEmpty)
            .toList();

        if (postsWithImages.isNotEmpty) {
          newPostsWithImages = postsWithImages;
          break;
        }

        currentPage++;
      }

      final updatedPosts = [...state.posts, ...newPostsWithImages];

      emit(
        state.copyWith(
          status: ExploreStatus.success,
          posts: updatedPosts,
          currentPage: currentPage,
          totalPages: state.totalPages,
          hasMorePosts: currentPage < state.totalPages,
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
