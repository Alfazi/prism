import 'package:equatable/equatable.dart';

class ProfileStatsModel extends Equatable {
  final int postsCount;
  final int followersCount;
  final int followingCount;

  const ProfileStatsModel({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  const ProfileStatsModel.empty()
    : postsCount = 0,
      followersCount = 0,
      followingCount = 0;

  ProfileStatsModel copyWith({
    int? postsCount,
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileStatsModel(
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  List<Object?> get props => [postsCount, followersCount, followingCount];
}
