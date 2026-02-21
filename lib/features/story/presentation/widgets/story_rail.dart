import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_state.dart';
import '../pages/create_story_page.dart';
import '../pages/story_viewer_page.dart';
import 'story_circle.dart';
import '../../../auth/data/models/user_model.dart';

class StoryRail extends StatelessWidget {
  final UserModel? currentUser;

  const StoryRail({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        // All stories are from following users
        final otherStories = state.stories;

        return Container(
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'STORIES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: state.status == StoryStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00F2EA),
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            otherStories.length + 1, // +1 for current user
                        itemBuilder: (context, index) {
                          // First item is always current user
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: StoryCircle(
                                story: null,
                                isCurrentUser: true,
                                currentUserAvatar:
                                    currentUser?.profilePictureUrl,
                                onTap: () {
                                  // Always create new story
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (buildContext) =>
                                          BlocProvider.value(
                                            value: context.read<StoryBloc>(),
                                            child: const CreateStoryPage(),
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          // Other users' stories
                          final story = otherStories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: StoryCircle(
                              story: story,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (buildContext) =>
                                        BlocProvider.value(
                                          value: context.read<StoryBloc>(),
                                          child: StoryViewerPage(
                                            stories: otherStories,
                                            initialIndex: index - 1,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
