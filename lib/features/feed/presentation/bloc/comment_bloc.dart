import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/comment_api_service.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentApiService commentApiService;
  final FlutterSecureStorage secureStorage;

  CommentBloc({required this.commentApiService, required this.secureStorage})
    : super(const CommentState()) {
    on<FetchPostComments>(_onFetchPostComments);
    on<CreateComment>(_onCreateComment);
    on<DeleteComment>(_onDeleteComment);
    on<ToggleLike>(_onToggleLike);
  }

  Future<void> _onFetchPostComments(
    FetchPostComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.loading));

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        emit(
          state.copyWith(
            status: CommentStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      final postDetail = await commentApiService.getPostWithComments(
        token: token,
        postId: event.postId,
      );

      emit(state.copyWith(status: CommentStatus.success, post: postDetail));
    } catch (e) {
      emit(
        state.copyWith(status: CommentStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        emit(
          state.copyWith(
            status: CommentStatus.error,
            errorMessage: 'Not authenticated',
            isSubmitting: false,
          ),
        );
        return;
      }

      await commentApiService.createComment(
        token: token,
        postId: event.postId,
        comment: event.comment,
      );

      // Refresh comments after creation
      final postDetail = await commentApiService.getPostWithComments(
        token: token,
        postId: event.postId,
      );

      emit(
        state.copyWith(
          status: CommentStatus.success,
          post: postDetail,
          isSubmitting: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentStatus.error,
          errorMessage: e.toString(),
          isSubmitting: false,
        ),
      );
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    if (state.post == null) return;

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        emit(
          state.copyWith(
            status: CommentStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      await commentApiService.deleteComment(
        token: token,
        commentId: event.commentId,
      );

      // Refresh comments after deletion
      final postDetail = await commentApiService.getPostWithComments(
        token: token,
        postId: state.post!.id,
      );

      emit(state.copyWith(status: CommentStatus.success, post: postDetail));
    } catch (e) {
      emit(
        state.copyWith(status: CommentStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<CommentState> emit,
  ) async {
    if (state.post == null) return;

    // Optimistically update UI
    final updatedPost = state.post!.copyWith(
      isLike: !event.currentlyLiked,
      totalLikes: event.currentlyLiked
          ? state.post!.totalLikes - 1
          : state.post!.totalLikes + 1,
    );
    emit(state.copyWith(post: updatedPost));

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        // Revert on error
        emit(state.copyWith(post: state.post));
        return;
      }

      if (event.currentlyLiked) {
        await commentApiService.unlikePost(
          token: token,
          postId: state.post!.id,
        );
      } else {
        await commentApiService.likePost(token: token, postId: state.post!.id);
      }
    } catch (e) {
      // Revert on error
      emit(state.copyWith(post: state.post));
    }
  }
}
