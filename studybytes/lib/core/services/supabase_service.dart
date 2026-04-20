import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/posts/models/post_model.dart';
import '../../features/library/models/document_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

final _client = Supabase.instance.client;

  // ── POSTS ─────────────────────────────────────────────────────────────────

  /// Carga todos los posts ordenados por fecha descendente
  Future<List<PostModel>> fetchPosts() async {
    final res = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => PostModel.fromSupabase(e)).toList();
  }

  /// Crea un nuevo post
  Future<PostModel> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    required List<String> tags,
  }) async {
    final res = await _client.from('posts').insert({
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'tags': tags,
      'likes': [],
    }).select().single();

    return PostModel.fromSupabase(res);
  }

  /// Elimina un post (solo el autor puede hacerlo — RLS en Supabase)
  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  /// Alterna like en un post
  Future<PostModel> toggleLike(String postId, String userId) async {
    // Leer likes actuales
    final res = await _client
        .from('posts')
        .select('likes')
        .eq('id', postId)
        .single();

    final likes = List<String>.from(res['likes'] ?? []);
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    final updated = await _client
        .from('posts')
        .update({'likes': likes})
        .eq('id', postId)
        .select()
        .single();

    return PostModel.fromSupabase(updated);
  }

  // ── DOCUMENTOS ────────────────────────────────────────────────────────────

  /// Carga todos los documentos
  Future<List<DocumentModel>> fetchDocuments() async {
    final res = await _client
        .from('documents')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => DocumentModel.fromSupabase(e)).toList();
  }

  /// Sube un archivo al bucket "documents" de Supabase Storage
  /// Devuelve la URL pública del archivo subido
  Future<String> uploadFile({
    required String fileName,
    required String mimeType,
    File? file,           // móvil
    Uint8List? bytes,     // web
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    if (kIsWeb && bytes != null) {
      await _client.storage.from('documents').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );
    } else if (file != null) {
      await _client.storage.from('documents').upload(
        path,
        file,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );
    } else {
      throw Exception('Se requiere file (móvil) o bytes (web)');
    }

    return _client.storage.from('documents').getPublicUrl(path);
  }

  /// Crea el registro del documento en la tabla "documents"
  Future<DocumentModel> createDocument({
    required String title,
    required String description,
    required String fileUrl,
    required String fileType,
    required String authorId,
    required String authorName,
    required List<String> tags,
    bool isPremium = false,
  }) async {
    final res = await _client.from('documents').insert({
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'author_id': authorId,
      'author_name': authorName,
      'tags': tags,
      'is_premium': isPremium,
      'downloads': 0,
      'views': 0,
    }).select().single();

    return DocumentModel.fromSupabase(res);
  }

  /// Elimina un documento y su archivo en Storage
  Future<void> deleteDocument(String docId, String fileUrl) async {
    final uri = Uri.parse(fileUrl);
    final pathSegments = uri.pathSegments;
    final filePathIndex = pathSegments.indexOf('documents');
    if (filePathIndex != -1 && filePathIndex + 1 < pathSegments.length) {
      final filePath = pathSegments.sublist(filePathIndex + 1).join('/');
      await _client.storage.from('documents').remove([filePath]);
    }
    await _client.from('documents').delete().eq('id', docId);
  }

  /// + contador de vistas
  Future<void> incrementViews(String docId) async {
    await _client.rpc('increment_views', params: {'doc_id': docId});
  }
}
