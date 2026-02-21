import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchStories extends StoryEvent {
  final bool refresh;

  const FetchStories({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class CreateStory extends StoryEvent {
  final String imageUrl;
  final String caption;

  const CreateStory({required this.imageUrl, required this.caption});

  @override
  List<Object?> get props => [imageUrl, caption];
}

class DeleteStory extends StoryEvent {
  final String storyId;

  const DeleteStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

class MarkStoryAsViewed extends StoryEvent {
  final String storyId;

  const MarkStoryAsViewed({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}
