import 'package:equatable/equatable.dart';
import 'post_user_model.dart';

class PostModel extends Equatable {
  final String id;
  final String imageUrl;
  final String caption;
  final PostUserModel user;
  final int totalLikes;
  final int totalComments;
  final bool isLike;
  final String createdAt;
  final String updatedAt;

  const PostModel({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.user,
    required this.totalLikes,
    required this.totalComments,
    required this.isLike,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      user: PostUserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      isLike: json['isLike'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'caption': caption,
      'user': user.toJson(),
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'isLike': isLike,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PostModel copyWith({
    String? id,
    String? imageUrl,
    String? caption,
    PostUserModel? user,
    int? totalLikes,
    int? totalComments,
    bool? isLike,
    String? createdAt,
    String? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      user: user ?? this.user,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      isLike: isLike ?? this.isLike,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    caption,
    user,
    totalLikes,
    totalComments,
    isLike,
    createdAt,
    updatedAt,
  ];
}
