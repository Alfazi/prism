import 'package:equatable/equatable.dart';
import 'post_model.dart';

class FeedResponseModel extends Equatable {
  final int totalItems;
  final List<PostModel> posts;
  final int totalPages;
  final int currentPage;

  const FeedResponseModel({
    required this.totalItems,
    required this.posts,
    required this.totalPages,
    required this.currentPage,
  });

  factory FeedResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return FeedResponseModel(
      totalItems: data['totalItems'] as int? ?? 0,
      posts:
          (data['posts'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      totalPages: data['totalPages'] as int? ?? 0,
      currentPage: data['currentPage'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [totalItems, posts, totalPages, currentPage];
}
