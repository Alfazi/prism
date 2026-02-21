import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class FetchPostComments extends CommentEvent {
  final String postId;

  const FetchPostComments({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class CreateComment extends CommentEvent {
  final String postId;
  final String comment;

  const CreateComment({required this.postId, required this.comment});

  @override
  List<Object?> get props => [postId, comment];
}

class DeleteComment extends CommentEvent {
  final String commentId;

  const DeleteComment({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ToggleLike extends CommentEvent {
  final bool currentlyLiked;

  const ToggleLike({required this.currentlyLiked});

  @override
  List<Object?> get props => [currentlyLiked];
}
