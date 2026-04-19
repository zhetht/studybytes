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

  PostModel copyWith({
    List<String>? likes,
    List<PostComment>? comments,
  }) =>
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
          id: '1',
          title: '¿Cómo estudiar para exámenes finales?',
          content:
              'Comparto mis mejores técnicas: la técnica Pomodoro, mapas mentales y el método de repetición espaciada. Con estas herramientas puedes mejorar tu retención en un 60%.',
          authorId: 'user_001',
          authorName: 'Ghosty',
          likes: ['user_002', 'user_003', 'user_004'],
          comments: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          tags: ['estudio', 'exámenes', 'tips'],
        ),
        PostModel(
          id: '2',
          title: 'Recursos gratuitos para aprender Python',
          content:
              'He recopilado los mejores recursos: freeCodeCamp, CS50P de Harvard (gratis), Python.org y el canal de Sentdex. ¡Sin excusas para no aprender!',
          authorId: 'user_002',
          authorName: 'Usuario Test',
          likes: ['user_001'],
          comments: [],
          createdAt:
              DateTime.now().subtract(const Duration(days: 1)),
          tags: ['programación', 'python', 'gratis'],
        ),
        PostModel(
          id: '3',
          title: 'El error más común al aprender matemáticas',
          content:
              'No practicar suficientes ejercicios. La teoría sin práctica no sirve. Les comparto una rutina de 30 minutos diarios que me cambió la vida.',
          authorId: 'user_003',
          authorName: 'MathNerd',
          likes: ['user_001', 'user_002', 'user_005', 'user_006'],
          comments: [],
          createdAt:
              DateTime.now().subtract(const Duration(days: 2)),
          tags: ['matemáticas', 'consejos'],
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
