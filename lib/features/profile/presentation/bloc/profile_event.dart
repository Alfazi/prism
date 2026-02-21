import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadProfileStats extends ProfileEvent {
  final String userId;

  const LoadProfileStats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUserPosts extends ProfileEvent {
  final String userId;
  final int page;

  const LoadUserPosts({required this.userId, this.page = 1});

  @override
  List<Object?> get props => [userId, page];
}

class LoadMoreUserPosts extends ProfileEvent {
  final String userId;

  const LoadMoreUserPosts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

class UpdatePost extends ProfileEvent {
  final String postId;
  final String imageUrl;
  final String caption;

  const UpdatePost({
    required this.postId,
    required this.imageUrl,
    required this.caption,
  });

  @override
  List<Object?> get props => [postId, imageUrl, caption];
}

class DeletePost extends ProfileEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? bio;
  final String? website;

  const UpdateProfile({
    required this.name,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    this.phoneNumber,
    this.bio,
    this.website,
  });

  @override
  List<Object?> get props => [
    name,
    username,
    email,
    profilePictureUrl,
    phoneNumber,
    bio,
    website,
  ];
}
