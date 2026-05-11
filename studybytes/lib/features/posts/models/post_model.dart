class PostModel {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final int likes;
  final DateTime createdAt;
  final List<String> tags;

  // UI helpers (para mantener el layout actual)
  final String title;
  final List<PostComment> comments;

  PostModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.likes,
    required this.createdAt,
    required this.tags,
    required this.title,
    required this.comments,
  });

  int get likeCount => likes;
  int get commentCount => comments.length;

  factory PostModel.fromSupabase(Map<String, dynamic> row) {
    return PostModel(
      id: row['id'].toString(),
      // Schema actual: posts.content, posts.username
      content: row['content'] ?? '',
      authorId: row['user_id']?.toString() ?? '',
      authorName: row['username'] ?? 'Anónimo',
      likes: (row['likes'] is int)
          ? row['likes'] as int
          : int.tryParse(row['likes']?.toString() ?? '') ?? 0,
      createdAt: DateTime.parse(row['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(row['tags'] ?? []),
      // Mantener compatibilidad con UI (tu UI usa post.title)
      title: (row['content'] ?? '').toString(),
      comments: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'user_id': authorId,
        'username': authorName,
        'likes': likes,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  PostModel copyWith({int? likes, String? content, List<String>? tags}) =>
      PostModel(
        id: id,
        content: content ?? this.content,
        authorId: authorId,
        authorName: authorName,
        likes: likes ?? this.likes,
        createdAt: createdAt,
        tags: tags ?? this.tags,
        title: title,
        comments: comments,
      );


  static List<PostModel> mockPosts() => [
        PostModel(
          id: 'mock_1',
          title: '¿Cómo estudiar para exámenes finales?',
          content:
              'Comparto mis mejores técnicas: Pomodoro, mapas mentales y repetición espaciada.',
          authorId: 'user_001',
          authorName: 'Ghosty',
          likes: 2,
          comments: const [],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          tags: ['estudio', 'exámenes'],
        ),
        PostModel(
          id: 'mock_2',
          title: 'Recursos gratuitos para aprender Python',
          content:
              'freeCodeCamp, CS50P de Harvard, Python.org y Sentdex. ¡Sin excusas!',
          authorId: 'user_002',
          authorName: 'Usuario Test',
          likes: 1,
          comments: const [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['programación', 'python'],
        ),
      ];
}

class PostComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });
}
