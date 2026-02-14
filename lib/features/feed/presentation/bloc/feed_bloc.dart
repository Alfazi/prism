import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/feed_api_service.dart';
import '../../../auth/data/services/auth_local_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedApiService feedApiService;
  final AuthLocalService authLocalService;

  FeedBloc({required this.feedApiService, required this.authLocalService})
    : super(const FeedState()) {
    on<FetchFeed>(_onFetchFeed);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<LikePostToggled>(_onLikePostToggled);
  }

  Future<void> _onFetchFeed(FetchFeed event, Emitter<FeedState> emit) async {
    try {
      if (!event.refresh) {
        emit(state.copyWith(status: FeedStatus.loading));
      }

      final token = await authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: FeedStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      final response = await feedApiService.getFollowingPosts(
        token: token,
        size: 10,
        page: 1,
      );

      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: response.posts,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasMorePosts:
              response.totalPages > 0 &&
              response.currentPage < response.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<FeedState> emit,
  ) async {
    if (!state.hasMorePosts || state.status == FeedStatus.loadingMore) {
      return;
    }

    try {
      emit(state.copyWith(status: FeedStatus.loadingMore));

      final token = await authLocalService.getToken();
      if (token == null) return;

      final nextPage = state.currentPage + 1;
      final response = await feedApiService.getFollowingPosts(
        token: token,
        size: 10,
        page: nextPage,
      );

      final updatedPosts = [...state.posts, ...response.posts];

      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: updatedPosts,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasMorePosts:
              response.posts.isNotEmpty &&
              response.currentPage < response.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLikePostToggled(
    LikePostToggled event,
    Emitter<FeedState> emit,
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
