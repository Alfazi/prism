import 'package:flutter/material.dart';
import '../../data/models/story_model.dart';

class StoryCircle extends Widget {
  final StoryModel? story;
  final bool isCurrentUser;
  final String? currentUserAvatar;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    this.story,
    this.isCurrentUser = false,
    this.currentUserAvatar,
    required this.onTap,
  });

  @override
  Element createElement() => _StoryCircleElement(this);
}

class _StoryCircleElement extends ComponentElement {
  _StoryCircleElement(StoryCircle super.widget);

  @override
  StoryCircle get widget => super.widget as StoryCircle;

  @override
  Widget build() {
    final isViewed = widget.story?.isViewed ?? false;
    final hasStory = widget.story != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Story Ring
            Container(
              width: 72,
              height: 72,
              padding: EdgeInsets.all(hasStory && !isViewed ? 2 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasStory && !isViewed
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00C2FF), Color(0xFFFF0055)],
                      )
                    : null,
                border: hasStory && isViewed
                    ? Border.all(color: Colors.grey.shade700, width: 2)
                    : widget.isCurrentUser && !hasStory
                    ? Border.all(
                        color: Colors.grey.shade700,
                        width: 2,
                        style: BorderStyle.solid,
                      )
                    : null,
              ),
              child: Container(
                padding: hasStory && !isViewed
                    ? const EdgeInsets.all(2)
                    : EdgeInsets.zero,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF050505),
                ),
                child: Stack(
                  children: [
                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.isCurrentUser
                                ? (widget.currentUserAvatar ?? '')
                                : (widget.story?.user.profilePictureUrl ?? ''),
                          ),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        ),
                        color: Colors.grey.shade800,
                      ),
                      child: widget.isCurrentUser && !hasStory
                          ? Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade600,
                                size: 32,
                              ),
                            )
                          : null,
                    ),
                    // Add button for current user without story
                    if (widget.isCurrentUser && !hasStory)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF135bec),
                            border: Border.all(
                              color: const Color(0xFF050505),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Username
            Text(
              widget.isCurrentUser
                  ? 'Your Story'
                  : (widget.story?.user.username ?? 'Unknown'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isViewed
                    ? Colors.grey.shade500
                    : Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
