import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/story_api_service.dart';
import '../../../auth/data/services/auth_local_service.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryApiService storyApiService;
  final AuthLocalService authLocalService;

  StoryBloc({required this.storyApiService, required this.authLocalService})
    : super(const StoryState()) {
    on<FetchStories>(_onFetchStories);
    on<CreateStory>(_onCreateStory);
    on<DeleteStory>(_onDeleteStory);
    on<MarkStoryAsViewed>(_onMarkStoryAsViewed);
  }

  Future<void> _onFetchStories(
    FetchStories event,
    Emitter<StoryState> emit,
  ) async {
    try {
      if (!event.refresh) {
        emit(state.copyWith(status: StoryStatus.loading));
      }

      final token = await authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: StoryStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      final response = await storyApiService.getFollowingStories(
        token: token,
        size: 20,
        page: 1,
      );

      emit(
        state.copyWith(
          status: StoryStatus.success,
          stories: response.stories,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StoryStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onCreateStory(
    CreateStory event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(state.copyWith(status: StoryStatus.creating));

      final token = await authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: StoryStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      await storyApiService.createStory(
        token: token,
        imageUrl: event.imageUrl,
        caption: event.caption,
      );

      // Story created successfully
      emit(state.copyWith(status: StoryStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: StoryStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteStory(
    DeleteStory event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(state.copyWith(status: StoryStatus.deleting));

      final token = await authLocalService.getToken();
      if (token == null) {
        emit(
          state.copyWith(
            status: StoryStatus.error,
            errorMessage: 'Not authenticated',
          ),
        );
        return;
      }

      await storyApiService.deleteStory(token: token, storyId: event.storyId);

      // Remove deleted story from the list
      final updatedStories = state.stories
          .where((story) => story.id != event.storyId)
          .toList();

      emit(
        state.copyWith(status: StoryStatus.success, stories: updatedStories),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StoryStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onMarkStoryAsViewed(
    MarkStoryAsViewed event,
    Emitter<StoryState> emit,
  ) async {
    final updatedStories = state.stories.map((story) {
      if (story.id == event.storyId) {
        return story.copyWith(isViewed: true);
      }
      return story;
    }).toList();

    emit(state.copyWith(stories: updatedStories));
  }
}
