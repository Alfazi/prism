import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeed extends FeedEvent {
  final bool refresh;

  const FetchFeed({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMorePosts extends FeedEvent {
  const LoadMorePosts();
}

class LikePostToggled extends FeedEvent {
  final String postId;
  final bool currentlyLiked;

  const LikePostToggled({required this.postId, required this.currentlyLiked});

  @override
  List<Object?> get props => [postId, currentlyLiked];
}
