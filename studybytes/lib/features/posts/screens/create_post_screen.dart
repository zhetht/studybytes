import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/models/user_model.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel user;
  const CreatePostScreen({super.key, required this.user});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _service = SupabaseService();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título y contenido son obligatorios')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      final post = await _service.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: widget.user.id,
        authorName: widget.user.name,
        tags: tags.isEmpty ? ['general'] : tags,
      );
      if (mounted) Navigator.pop(context, post);
    } catch (e) {
      // Fallback: crear post local si Supabase no está configurado
      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: widget.user.id,
        authorName: widget.user.name,
        likes: [],
        comments: [],
        createdAt: DateTime.now(),
        tags: tags.isEmpty ? ['general'] : tags,
      );
      if (mounted) Navigator.pop(context, post);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: Text('Nuevo Post',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryBlue),
                  )
                : const Text('Publicar',
                    style: TextStyle(
                        color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autor
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  child: Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(widget.user.name,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            // Título
            TextField(
              controller: _titleController,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Título del post...',
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
                border: InputBorder.none,
                filled: false,
              ),
            ).animate().fadeIn(delay: 100.ms),
            Divider(color: Colors.white.withOpacity(0.06), height: 24),
            // Contenido
            TextField(
              controller: _contentController,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.6),
              maxLines: null,
              minLines: 6,
              decoration: InputDecoration(
                hintText: 'Escribe tu contenido aquí...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 15),
                border: InputBorder.none,
                filled: false,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),
            // Tags
            Text('Etiquetas (separadas por comas)',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              style: TextStyle(color: AppTheme.lavender, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'estudio, matemáticas, consejos',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                prefixIcon: const Icon(Icons.tag, size: 18, color: AppTheme.lavender),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
