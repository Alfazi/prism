import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/post_model.dart';

class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLikeToggle;
  final VoidCallback? onComment;
  final VoidCallback? onUserTap;

  const FeedCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    this.onComment,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onUserTap,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: post.user.profilePictureUrl != null &&
                            post.user.profilePictureUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(
                            post.user.profilePictureUrl!,
                          )
                        : null,
                    child: post.user.profilePictureUrl == null ||
                            post.user.profilePictureUrl!.isEmpty
                        ? Text(
                            post.user.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onUserTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeago.format(DateTime.parse(post.createdAt)),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {
                    // TODO: Show post options
                  },
                ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: post.imageUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade900,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 48, color: Colors.grey.shade700),
                            const SizedBox(height: 8),
                            Text(
                              'No image',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00F2EA),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.white54),
                        ),
                      ),
                    ),
            ),
          ),

          // Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLike ? Icons.favorite : Icons.favorite_border,
                    color: post.isLike
                        ? const Color(0xFFFF0050)
                        : Colors.white.withOpacity(0.8),
                  ),
                  onPressed: onLikeToggle,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: onComment,
                ),
              ],
            ),
          ),

          // Likes & Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.totalLikes > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${post.totalLikes} ${post.totalLikes == 1 ? 'like' : 'likes'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (post.caption.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '${post.user.username} ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                if (post.totalComments > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: onComment,
                      child: Text(
                        'View all ${post.totalComments} comments',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
