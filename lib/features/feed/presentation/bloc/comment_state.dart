import 'package:equatable/equatable.dart';
import '../../data/models/post_detail_model.dart';

enum CommentStatus { initial, loading, success, error }

class CommentState extends Equatable {
  final CommentStatus status;
  final PostDetailModel? post;
  final String? errorMessage;
  final bool isSubmitting;

  const CommentState({
    this.status = CommentStatus.initial,
    this.post,
    this.errorMessage,
    this.isSubmitting = false,
  });

  CommentState copyWith({
    CommentStatus? status,
    PostDetailModel? post,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return CommentState(
      status: status ?? this.status,
      post: post ?? this.post,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, post, errorMessage, isSubmitting];
}
