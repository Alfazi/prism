import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/profile_stats_model.dart';
import '../../../feed/data/models/post_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? user;
  final ProfileStatsModel stats;
  final List<PostModel> posts;
  final int currentPage;
  final bool hasMorePosts;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.stats = const ProfileStatsModel.empty(),
    this.posts = const [],
    this.currentPage = 1,
    this.hasMorePosts = true,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    ProfileStatsModel? stats,
    List<PostModel>? posts,
    int? currentPage,
    bool? hasMorePosts,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
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
    errorMessage,
  ];
}
