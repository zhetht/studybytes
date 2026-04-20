class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final List<String> likes;
  final List<PostComment> comments;
  final DateTime createdAt;
  final List<String> tags;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.tags,
  });

  int get likeCount => likes.length;
  int get commentCount => comments.length;

  /// Construye un PostModel desde una fila de Supabase
  factory PostModel.fromSupabase(Map<String, dynamic> row) {
    return PostModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      authorId: row['author_id'] ?? '',
      authorName: row['author_name'] ?? 'Anónimo',
      likes: List<String>.from(row['likes'] ?? []),
      comments: [],
      createdAt: DateTime.parse(row['created_at']),
      tags: List<String>.from(row['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author_id': authorId,
        'author_name': authorName,
        'likes': likes,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  PostModel copyWith({List<String>? likes, List<PostComment>? comments}) =>
      PostModel(
        id: id,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        createdAt: createdAt,
        tags: tags,
      );

  static List<PostModel> mockPosts() => [
        PostModel(
          id: 'mock_1',
          title: '¿Cómo estudiar para exámenes finales?',
          content:
              'Comparto mis mejores técnicas: Pomodoro, mapas mentales y repetición espaciada.',
          authorId: 'user_001',
          authorName: 'Ghosty',
          likes: ['user_002', 'user_003'],
          comments: [],
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
          likes: ['user_001'],
          comments: [],
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
