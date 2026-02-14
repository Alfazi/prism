import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';

enum FeedStatus { initial, loading, success, error, loadingMore }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMorePosts;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 0,
    this.hasMorePosts = false,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMorePosts,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    errorMessage,
    currentPage,
    totalPages,
    hasMorePosts,
  ];
}
