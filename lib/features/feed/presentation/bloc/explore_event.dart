import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class FetchExplorePosts extends ExploreEvent {
  final bool refresh;

  const FetchExplorePosts({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreExplorePosts extends ExploreEvent {
  const LoadMoreExplorePosts();
}

class ExplorePostLikeToggled extends ExploreEvent {
  final String postId;
  final bool currentlyLiked;

  const ExplorePostLikeToggled({
    required this.postId,
    required this.currentlyLiked,
  });

  @override
  List<Object?> get props => [postId, currentlyLiked];
}
