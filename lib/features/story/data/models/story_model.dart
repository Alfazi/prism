import 'package:equatable/equatable.dart';
import 'story_user_model.dart';

class StoryModel extends Equatable {
  final String id;
  final String imageUrl;
  final String caption;
  final StoryUserModel user;
  final int totalViews;
  final String createdAt;
  final String updatedAt;
  final bool isViewed;

  const StoryModel({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.user,
    required this.totalViews,
    required this.createdAt,
    required this.updatedAt,
    this.isViewed = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      user: StoryUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
      totalViews: json['totalViews'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      isViewed: json['isViewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'caption': caption,
      'user': user.toJson(),
      'totalViews': totalViews,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isViewed': isViewed,
    };
  }

  StoryModel copyWith({
    String? id,
    String? imageUrl,
    String? caption,
    StoryUserModel? user,
    int? totalViews,
    String? createdAt,
    String? updatedAt,
    bool? isViewed,
  }) {
    return StoryModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      user: user ?? this.user,
      totalViews: totalViews ?? this.totalViews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    caption,
    user,
    totalViews,
    createdAt,
    updatedAt,
    isViewed,
  ];
}
