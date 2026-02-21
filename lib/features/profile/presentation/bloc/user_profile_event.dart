import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUserProfilePosts extends UserProfileEvent {
  final String userId;
  final int page;

  const LoadUserProfilePosts({required this.userId, this.page = 1});

  @override
  List<Object?> get props => [userId, page];
}

class LoadMoreUserProfilePosts extends UserProfileEvent {
  final String userId;

  const LoadMoreUserProfilePosts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshUserProfile extends UserProfileEvent {
  final String userId;

  const RefreshUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FollowUser extends UserProfileEvent {
  final String userId;

  const FollowUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnfollowUser extends UserProfileEvent {
  final String userId;

  const UnfollowUser(this.userId);

  @override
  List<Object?> get props => [userId];
}
