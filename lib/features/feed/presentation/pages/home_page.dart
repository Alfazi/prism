import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/feed_card.dart';
import 'comments_page.dart';
import '../../../story/presentation/bloc/story_bloc.dart';
import '../../../story/presentation/bloc/story_event.dart';
import '../../../story/presentation/widgets/story_rail.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late final FeedBloc _feedBloc;
  late final StoryBloc _storyBloc;

  @override
  void initState() {
    super.initState();
    _feedBloc = GetIt.instance<FeedBloc>()..add(const FetchFeed());
    _storyBloc = GetIt.instance<StoryBloc>()..add(const FetchStories());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedBloc.close();
    _storyBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      _isLoadingMore = true;
      _feedBloc.add(const LoadMorePosts());
      // Reset flag after a short delay to prevent rapid-fire
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _feedBloc),
        BlocProvider.value(value: _storyBloc),
      ],
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
          child: SafeArea(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, feedState) {
                if (feedState.status == FeedStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00F2EA),
                      ),
                    ),
                  );
                }

                if (feedState.status == FeedStatus.error) {
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
                          feedState.errorMessage ?? 'Something went wrong',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FeedBloc>().add(const FetchFeed());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF135bec),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (feedState.posts.isEmpty) {
                  return Center(
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
                        const SizedBox(height: 8),
                        Text(
                          'Follow users to see their posts here',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FeedBloc>().add(
                      const FetchFeed(refresh: true),
                    );
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: const Color(0xFF00F2EA),
                  backgroundColor: const Color(0xFF14141A),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Profile Avatar Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, authState) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF00F2EA),
                                            Color(0xFFFF0050),
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                        ),
                                        child: ClipOval(
                                          child:
                                              authState
                                                          .user
                                                          ?.profilePictureUrl !=
                                                      null &&
                                                  authState
                                                      .user!
                                                      .profilePictureUrl!
                                                      .isNotEmpty
                                              ? Image.network(
                                                  authState
                                                      .user!
                                                      .profilePictureUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color: Colors
                                                              .grey
                                                              .shade800,
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 16,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                )
                                              : Container(
                                                  color: Colors.grey.shade800,
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Prism Title (centered)
                              Expanded(
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [Colors.white, Colors.grey],
                                        ).createShader(bounds),
                                    child: const Text(
                                      'Prism',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Spacer to balance the profile avatar on the left
                              const SizedBox(width: 32),
                            ],
                          ),
                        ),
                      ),

                      // Story Rail (collapsible)
                      SliverToBoxAdapter(
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            return StoryRail(currentUser: authState.user);
                          },
                        ),
                      ),

                      // Feed Content
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= feedState.posts.length) {
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

                              final post = feedState.posts[index];
                              return FeedCard(
                                post: post,
                                onLikeToggle: () {
                                  context.read<FeedBloc>().add(
                                    LikePostToggled(
                                      postId: post.id,
                                      currentlyLiked: post.isLike,
                                    ),
                                  );
                                },
                                onComment: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentsPage(postId: post.id),
                                    ),
                                  );
                                },
                                onUserTap: () {
                                  // TODO: Navigate to user profile
                                },
                              );
                            },
                            childCount:
                                feedState.posts.length +
                                (feedState.hasMorePosts ? 1 : 0),
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
      ),
    );
  }
}
