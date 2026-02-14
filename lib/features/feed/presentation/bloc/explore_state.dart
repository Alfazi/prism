import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';

enum ExploreStatus { initial, loading, success, error, loadingMore }

class ExploreState extends Equatable {
  final ExploreStatus status;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMorePosts;

  const ExploreState({
    this.status = ExploreStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 0,
    this.hasMorePosts = false,
  });

  ExploreState copyWith({
    ExploreStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMorePosts,
  }) {
    return ExploreState(
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
