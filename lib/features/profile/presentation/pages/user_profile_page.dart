import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';
import '../../data/models/profile_stats_model.dart';
import '../../../feed/presentation/pages/comments_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final UserProfileBloc _userProfileBloc;
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _userProfileBloc = GetIt.instance<UserProfileBloc>()
      ..add(LoadUserProfile(widget.userId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userProfileBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      _isLoadingMore = true;
      _userProfileBloc.add(LoadMoreUserProfilePosts(widget.userId));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _userProfileBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.8),
              radius: 1.5,
              colors: [
                const Color(0xFF135bec).withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              if (state.status == UserProfileStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00F2EA),
                    ),
                  ),
                );
              }

              if (state.status == UserProfileStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Something went wrong',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (state.user == null) {
                return const Center(child: Text('No user data'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _userProfileBloc.add(RefreshUserProfile(widget.userId));
                  await Future.delayed(const Duration(seconds: 1));
                },
                color: const Color(0xFF00F2EA),
                backgroundColor: const Color(0xFF14141A),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      title: Text(
                        state.user!.username.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      centerTitle: true,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Profile Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            // Profile Picture with Holographic Border
                            _buildProfilePicture(state.user!.profilePictureUrl),
                            const SizedBox(height: 16),

                            // Name
                            Text(
                              state.user!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bio
                            if (state.user!.bio != null &&
                                state.user!.bio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  state.user!.bio!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                            // Website
                            if (state.user!.website != null &&
                                state.user!.website!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.user!.website!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF00F2EA),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Stats
                            _buildStats(state.stats),

                            const SizedBox(height: 24),

                            // Follow/Unfollow Button
                            _buildFollowButton(context, state),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Tab Indicator
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Icon(
                                    Icons.grid_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 2,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00F2EA),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF00F2EA),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Posts Grid
                    if (state.posts.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 2,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= state.posts.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00F2EA),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final post = state.posts[index];
                              return _buildPostTile(
                                imageUrl: post.imageUrl,
                                postId: post.id,
                              );
                            },
                            childCount:
                                state.posts.length +
                                (state.hasMorePosts ? 1 : 0),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(String? imageUrl) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00F2EA), Color(0xFFFF0050)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x4D00F2EA), blurRadius: 15),
          BoxShadow(color: Color(0x33FF0050), blurRadius: 30),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade800,
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStats(ProfileStatsModel stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem('${stats.postsCount}', 'POSTS'),
        const SizedBox(width: 48),
        _buildStatItem('${stats.followersCount}', 'FOLLOWERS'),
        const SizedBox(width: 48),
        _buildStatItem('${stats.followingCount}', 'FOLLOWING'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context, UserProfileState state) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: state.isFollowing
                ? [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.02),
                  ]
                : [
                    const Color(0xFF00F2EA).withValues(alpha: 0.3),
                    const Color(0xFF00F2EA).withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: state.isFollowing
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF00F2EA).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: state.isFollowing
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF00F2EA).withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state.isFollowLoading
                ? null
                : () {
                    if (state.isFollowing) {
                      _userProfileBloc.add(UnfollowUser(widget.userId));
                    } else {
                      _userProfileBloc.add(FollowUser(widget.userId));
                    }
                  },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: state.isFollowLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      state.isFollowing ? 'Following' : 'Follow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: state.isFollowing
                            ? Colors.white
                            : const Color(0xFF00F2EA),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostTile({required String imageUrl, required String postId}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.broken_image, color: Colors.white54),
              );
            },
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsPage(postId: postId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
