

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _service = ServiceLocator().supabaseService;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final _tagsController = TextEditingController();


  bool _isPosting = false;
  String? _error;

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      setState(() => _error = 'El título es obligatorio');
      return;
    }
    if (content.isEmpty) {
      setState(() => _error = 'El contenido es obligatorio');
      return;
    }

    setState(() {
      _isPosting = true;
      _error = null;
    });

    try {
      const authorName = 'Anónimo';

      final created = await _service.createPost(
        title: title,
        content: content,
        authorName: authorName,
        tags: tags.isEmpty ? ['post'] : tags,
      );


      if (mounted) Navigator.pop(context, created);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al publicar: $e';
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: Text(
          'Crear Post',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Contenido',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              maxLines: 6,
            ).animate().fadeIn(delay: 140.ms),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Etiquetas (separadas por comas)',
                prefixIcon: const Icon(Icons.tag_outlined, color: AppTheme.lavender),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
              ),
            ).animate().fadeIn(delay: 200.ms),


            const SizedBox(height: 20),

            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPosting ? null : _submit,
                icon: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _isPosting ? 'Publicando...' : 'Publicar',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

