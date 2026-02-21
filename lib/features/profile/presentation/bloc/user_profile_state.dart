import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/profile_stats_model.dart';
import '../../../feed/data/models/post_model.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserModel? user;
  final ProfileStatsModel stats;
  final List<PostModel> posts;
  final int currentPage;
  final bool hasMorePosts;
  final bool isFollowing;
  final bool isFollowLoading;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.stats = const ProfileStatsModel.empty(),
    this.posts = const [],
    this.currentPage = 1,
    this.hasMorePosts = true,
    this.isFollowing = false,
    this.isFollowLoading = false,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserModel? user,
    ProfileStatsModel? stats,
    List<PostModel>? posts,
    int? currentPage,
    bool? hasMorePosts,
    bool? isFollowing,
    bool? isFollowLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    stats,
    posts,
    currentPage,
    hasMorePosts,
    isFollowing,
    isFollowLoading,
    errorMessage,
  ];
}
