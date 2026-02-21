import 'package:equatable/equatable.dart';
import '../../../feed/data/models/post_model.dart';

class UserPostsResponseModel extends Equatable {
  final int totalItems;
  final List<PostModel> posts;
  final int totalPages;
  final int currentPage;

  const UserPostsResponseModel({
    required this.totalItems,
    required this.posts,
    required this.totalPages,
    required this.currentPage,
  });

  factory UserPostsResponseModel.fromJson(Map<String, dynamic> json) {
    return UserPostsResponseModel(
      totalItems: json['totalItems'] as int,
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'posts': posts.map((e) => e.toJson()).toList(),
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  @override
  List<Object?> get props => [totalItems, posts, totalPages, currentPage];
}
