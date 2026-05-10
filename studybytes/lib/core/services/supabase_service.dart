
import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/posts/models/post_model.dart';
import '../../features/library/models/document_model.dart';
import '../../features/auth/services/supabase_auth_service.dart';
import '../../features/auth/models/user_model.dart';


class SupabaseService {
  final SupabaseAuthService _authService;
  final _client = Supabase.instance.client;

  SupabaseService({required SupabaseAuthService authService}) : _authService = authService;


  // ── GETTER PARA USUARIO ACTUAL ────────────────────────────────────────────
  
  /// Obtener el usuario autenticado actual
  Future<UserModel?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }
  
  /// Obtener ID del usuario actual (sincrónico)
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  // ── POSTS (modificados para usar usuario actual) ─────────────────────────
  
  Future<List<PostModel>> fetchPosts() async {
    final res = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((e) => PostModel.fromSupabase(e)).toList();
  }

  Future<PostModel> createPost({
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    final res = await _client.from('posts').insert({
      'title': title,
      'content': content,
      'author_id': currentUser.id,
      'author_name': currentUser.name,
      'tags': tags,
      'likes': [],
    }).select().single();
    return PostModel.fromSupabase(res);
  }

  Future<void> deletePost(String postId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) throw Exception('Usuario no autenticado');
    await _client.from('posts').delete().eq('id', postId);
  }

  Future<PostModel> toggleLike(String postId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) throw Exception('Usuario no autenticado');
    final userId = currentUser.id;
    
    final res = await _client
        .from('posts')
        .select('likes')
        .eq('id', postId)
        .single();
    final likes = List<String>.from(res['likes'] ?? []);
    likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
    final updated = await _client
        .from('posts')
        .update({'likes': likes})
        .eq('id', postId)
        .select()
        .single();
    return PostModel.fromSupabase(updated);
  }

  // ── DOCUMENTOS (modificados para usar usuario actual) ────────────────────
  
  Future<List<DocumentModel>> fetchDocuments() async {
    final res = await _client
        .from('documents')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((e) => DocumentModel.fromSupabase(e)).toList();
  }

  Future<String> uploadFile({
    required String fileName,
    required String mimeType,
    File? file,
    Uint8List? bytes,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    if (kIsWeb && bytes != null) {
      await _client.storage.from('documents').uploadBinary(
        path, bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );
    } else if (file != null) {
      await _client.storage.from('documents').upload(
        path, file,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );
    } else {
      throw Exception('Se requiere file (móvil) o bytes (web)');
    }
    return _client.storage.from('documents').getPublicUrl(path);
  }

  Future<DocumentModel> createDocument({
    required String title,
    required String description,
    required String fileUrl,
    required String fileType,
    required List<String> tags,
    bool isPremium = false,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    final res = await _client.from('documents').insert({
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'author_id': currentUser.id,
      'author_name': currentUser.name,
      'tags': tags,
      'is_premium': isPremium,
      'downloads': 0,
      'views': 0,
    }).select().single();
    return DocumentModel.fromSupabase(res);
  }

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

  Future<void> incrementViews(String docId) async {
    await _client.rpc('increment_views', params: {'doc_id': docId});
  }
}