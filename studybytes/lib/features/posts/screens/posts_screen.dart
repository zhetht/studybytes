import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import '../../../core/theme/app_theme.dart';
import 'create_post_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _posts = PostModel.mockPosts();
          _isLoading = false;
        });
      }
    });
  }

  void _deletePost(String id) {
    setState(() => _posts.removeWhere((p) => p.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post eliminado')),
    );
  }

  void _toggleLike(String id) {
    setState(() {
      final i = _posts.indexWhere((p) => p.id == id);
      if (i != -1) {
        final post = _posts[i];
        final likes = List<String>.from(post.likes);
        if (likes.contains('current_user')) {
          likes.remove('current_user');
        } else {
          likes.add('current_user');
        }
        _posts[i] = post.copyWith(likes: likes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _PostCard(
            post: _posts[index],
            index: index,
            onDelete: _deletePost,
            onLike: _toggleLike,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<PostModel>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          if (result != null) {
            setState(() => _posts.insert(0, result));
          }
        },
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  final int index;
  final Function(String) onDelete;
  final Function(String) onLike;

  const _PostCard(
      {required this.post,
      required this.index,
      required this.onDelete,
      required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isAuthor = post.authorId == 'current_user' || post.authorId == 'user_001';
    final isLiked = post.likes.contains('current_user');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  child: Text(
                    post.authorName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAuthor)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz,
                        color: Colors.white.withOpacity(0.4)),
                    onSelected: (v) {
                      if (v == 'delete') onDelete(post.id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              post.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags
                  .map((tag) => Chip(label: Text('#$tag')))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.white.withOpacity(0.06)),
            Row(
              children: [
                _ActionButton(
                  icon:
                      isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.pinkAccent : null,
                  label: '${post.likeCount}',
                  onTap: () => onLike(post.id),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Comentarios próximamente')),
                  ),
                ),
                const Spacer(),
                Icon(Icons.bookmark_border,
                    size: 20, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1);
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: color ?? Colors.white.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white.withOpacity(0.4),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
