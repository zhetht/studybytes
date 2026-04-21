import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/models/user_model.dart';

class UploadDocumentScreen extends StatefulWidget {
  final UserModel user;
  const UploadDocumentScreen({super.key, required this.user});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  final _service = SupabaseService();

  PlatformFile? _pickedFile;
  bool _isPremium = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _uploadError;

  // Tipos de archivo permitidos
  static const _allowedExtensions = ['pdf', 'md', 'txt'];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: kIsWeb, // En web necesitamos los bytes directamente
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _uploadError = null;
        // Auto-rellenar título si está vacío
        if (_titleController.text.isEmpty) {
          _titleController.text = _pickedFile!.name
              .replaceAll(RegExp(r'\.(pdf|md|txt)$', caseSensitive: false), '');
        }
      });
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _uploadError = 'El título es obligatorio');
      return;
    }
    if (_pickedFile == null) {
      setState(() => _uploadError = 'Selecciona un archivo');
      return;
    }

    setState(() { _isUploading = true; _uploadProgress = 0; _uploadError = null; });

    try {
      // Simular progreso de subida
      setState(() => _uploadProgress = 0.3);

      final ext = _pickedFile!.extension?.toLowerCase() ?? 'pdf';
      final mimeType = ext == 'pdf' ? 'application/pdf' : 'text/plain';

      // Subir archivo a Supabase Storage
      String fileUrl;
      if (kIsWeb) {
        fileUrl = await _service.uploadFile(
          fileName: _pickedFile!.name,
          mimeType: mimeType,
          bytes: _pickedFile!.bytes,
        );
      } else {
        fileUrl = await _service.uploadFile(
          fileName: _pickedFile!.name,
          mimeType: mimeType,
          file: File(_pickedFile!.path!),
        );
      }

      setState(() => _uploadProgress = 0.7);

      // Crear registro en la tabla documents
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final doc = await _service.createDocument(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? 'Documento subido por ${widget.user.name}'
            : _descController.text.trim(),
        fileUrl: fileUrl,
        fileType: ext,
        authorId: widget.user.id,
        authorName: widget.user.name,
        tags: tags.isEmpty ? ['documento'] : tags,
        isPremium: _isPremium,
      );

      setState(() => _uploadProgress = 1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) Navigator.pop(context, doc);
    } catch (e) {
      setState(() {
        _uploadError = 'Error al subir: $e\n\nVerifica tu configuración de Supabase.';
        _isUploading = false;
      });
    }
  }

  String _fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: Text('Subir Documento',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _upload,
            child: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryBlue),
                  )
                : const Text('Subir',
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
            // Selector de archivo 
            GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _pickedFile != null
                      ? AppTheme.primaryBlue.withOpacity(0.08)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pickedFile != null
                        ? AppTheme.primaryBlue.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: _pickedFile == null
                    ? Column(
                        children: [
                          Icon(Icons.upload_file_rounded,
                              size: 48, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('Toca para seleccionar archivo',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(
                            'Formatos: PDF, MD, TXT',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _pickedFile!.extension == 'pdf'
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : AppTheme.mint.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _pickedFile!.extension == 'pdf'
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.description_outlined,
                              color: _pickedFile!.extension == 'pdf'
                                  ? Colors.redAccent
                                  : AppTheme.mint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedFile!.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _fileSize(_pickedFile!.size),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.white.withOpacity(0.4), size: 20),
                            onPressed: () => setState(() => _pickedFile = null),
                          ),
                        ],
                      ),
              ),
            ).animate().fadeIn(),

            // Barra de progreso 
            if (_isUploading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  color: AppTheme.primaryBlue,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
'${(_uploadProgress * 100).toInt()}% subido...',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],

            // Error 
            if (_uploadError != null) ...[
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.redAccent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline,
            color: Colors.redAccent, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _uploadError!,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  ),
],

            const SizedBox(height: 24),

            _SectionLabel('Título *'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nombre del documento',
                prefixIcon: Icon(Icons.title, size: 20),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),
            _SectionLabel('Descripción'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe el contenido del documento...',
                alignLabelWithHint: true,
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),
            _SectionLabel('Etiquetas (separadas por comas)'),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              style: TextStyle(color: AppTheme.lavender),
              decoration: InputDecoration(
                hintText: 'matemáticas, cálculo, resumen',
hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                prefixIcon: const Icon(Icons.tag, size: 18, color: AppTheme.lavender),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // Toggle Premium 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isPremium
                    ? const Color(0xFFFFD700).withOpacity(0.08)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPremium
                      ? const Color(0xFFFFD700).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contenido Premium',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text('Solo usuarios premium podrán verlo',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPremium,
                    onChanged: (v) => setState(() => _isPremium = v),
                    activeColor: const Color(0xFFFFD700),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }
}

