class DocumentModel {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;
  final String authorId;
  final String authorName;
  final int downloads;
  final int views;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPremium;

  DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.authorId,
    required this.authorName,
    required this.downloads,
    required this.views,
    required this.createdAt,
    required this.tags,
    this.isPremium = false,
  });

  /// Construye un DocumentModel desde una fila de Supabase
  factory DocumentModel.fromSupabase(Map<String, dynamic> row) {
    return DocumentModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      fileUrl: row['file_url'] ?? '',
      fileType: row['file_type'] ?? 'pdf',
      authorId: row['author_id'] ?? '',
      authorName: row['author_name'] ?? 'Anónimo',
      downloads: row['downloads'] ?? 0,
      views: row['views'] ?? 0,
      createdAt: DateTime.parse(row['created_at']),
      tags: List<String>.from(row['tags'] ?? []),
      isPremium: row['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'file_type': fileType,
        'author_id': authorId,
        'author_name': authorName,
        'downloads': downloads,
        'views': views,
        'created_at': createdAt.toIso8601String(),
        'tags': tags,
        'is_premium': isPremium,
      };

  static final _mockTitles = [
    ('Álgebra Lineal Completa', 'pdf', false),
    ('Cálculo Diferencial e Integral', 'pdf', true),
    ('Introducción a Python', 'md', false),
    ('Física Cuántica Básica', 'pdf', true),
  ];

  factory DocumentModel.mock(int index) {
    final data = _mockTitles[index % _mockTitles.length];
    return DocumentModel(
      id: 'mock_$index',
      title: data.$1,
      description: 'Resumen completo con ejemplos y ejercicios resueltos',
      fileUrl: '',
      fileType: data.$2,
      authorId: 'user_001',
      authorName: 'Ghosty',
      downloads: 80 + index * 45,
      views: 320 + index * 60,
      createdAt: DateTime.now().subtract(Duration(days: index * 5)),
      tags: ['educación', 'resumen'],
      isPremium: data.$3,
    );
  }
}
