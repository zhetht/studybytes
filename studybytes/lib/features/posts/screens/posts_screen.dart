import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import 'create_post_screen.dart';
import '../../../../features/library/screens/upload_document_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _service = SupabaseService();
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final posts = await _service.fetchPosts();
      if (mounted) setState(() { _posts = posts; _isLoading = false; });
    } catch (e) {
      // Si Supabase no está configurado, carga datos mock
      if (mounted) {
        setState(() {
          _posts = PostModel.mockPosts();
          _isLoading = false;
          _error = null; // silencioso en modo demo
        });
      }
    }
  }

  Future<void> _deletePost(String id) async {
    try {
      await _service.deletePost(id);
      setState(() => _posts.removeWhere((p) => p.id == id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post eliminado')),
        );
      }
    } catch (e) {
      // fallback local
      setState(() => _posts.removeWhere((p) => p.id == id));
    }
  }

  Future<void> _toggleLike(String postId) async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : 'guest';

    try {
      final updated = await _service.toggleLike(postId, userId);
      setState(() {
        final i = _posts.indexWhere((p) => p.id == postId);
        if (i != -1) _posts[i] = updated;
      });
    } catch (_) {
      // fallback local
      setState(() {
        final i = _posts.indexWhere((p) => p.id == postId);
        if (i != -1) {
          final post = _posts[i];
          final likes = List<String>.from(post.likes);
          likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
          _posts[i] = post.copyWith(likes: likes);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadPosts, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _posts.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.article_outlined,
                            size: 48, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text('Sin posts todavía. ¡Sé el primero!',
                            style: TextStyle(color: Colors.white.withOpacity(0.4))),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final authState = context.read<AuthBloc>().state;
                  final currentUserId = authState is AuthAuthenticated
                      ? authState.user.id
                      : 'guest';
                  return _PostCard(
                    post: _posts[index],
                    index: index,
                    currentUserId: currentUserId,
                    onDelete: _deletePost,
                    onLike: _toggleLike,
                  );
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión para crear contenido')),
            );
            return;
          }
          final result = await Navigator.push<PostModel>(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(user: authState.user),
            ),
          );
          if (result != null) {
            setState(() => _posts.insert(0, result));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Post publicado! 🎉')),
            );
          }
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Crear Post'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.cardDark,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 28),
                tooltip: 'Subir Documento',
                onPressed: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes iniciar sesión para subir documentos')),
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadDocumentScreen(user: authState.user),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Documento subido exitosamente! 📚')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Post Card ──────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final PostModel post;
  final int index;
  final String currentUserId;
  final Function(String) onDelete;
  final Function(String) onLike;

  const _PostCard({
    required this.post,
    required this.index,
    required this.currentUserId,
    required this.onDelete,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthor = post.authorId == currentUserId;
    final isLiked = post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autor
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppTheme.primaryBlue, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                      Text(_formatDate(post.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                if (isAuthor)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.4)),
                    onSelected: (v) { if (v == 'delete') onDelete(post.id); },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                        ]),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Contenido
            Text(post.title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text(post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 14, height: 1.5)),
            const SizedBox(height: 12),
            // Tags
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
              ),
            Divider(color: Colors.white.withOpacity(0.06), height: 20),
            // Acciones
            Row(
              children: [
                _ActionBtn(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.pinkAccent : null,
                  label: '${post.likeCount}',
                  onTap: () => onLike(post.id),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.08);
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.white.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color ?? Colors.white.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
