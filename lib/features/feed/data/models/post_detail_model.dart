import 'package:equatable/equatable.dart';
import 'comment_model.dart';
import 'post_user_model.dart';

class PostDetailModel extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final bool isLike;
  final int totalLikes;
  final PostUserModel user;
  final List<CommentModel> comments;
  final String createdAt;
  final String updatedAt;

  const PostDetailModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.isLike,
    required this.totalLikes,
    required this.user,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List<dynamic>? ?? [];
    return PostDetailModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      isLike: json['isLike'] as bool? ?? false,
      totalLikes: json['totalLikes'] as int? ?? 0,
      user: PostUserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      comments: commentsList
          .map(
            (comment) => CommentModel.fromJson(comment as Map<String, dynamic>),
          )
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  PostDetailModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    bool? isLike,
    int? totalLikes,
    PostUserModel? user,
    List<CommentModel>? comments,
    String? createdAt,
    String? updatedAt,
  }) {
    return PostDetailModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      isLike: isLike ?? this.isLike,
      totalLikes: totalLikes ?? this.totalLikes,
      user: user ?? this.user,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    caption,
    isLike,
    totalLikes,
    user,
    comments,
    createdAt,
    updatedAt,
  ];
}
