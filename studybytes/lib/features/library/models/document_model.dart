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

  static final _mockTitles = [
    ('Álgebra Lineal Completa', 'pdf', false),
    ('Cálculo Diferencial e Integral', 'pdf', true),
    ('Introducción a Python', 'md', false),
    ('Física Cuántica Básica', 'pdf', true),
    ('Estructuras de Datos', 'pdf', false),
    ('Historia de la Revolución Industrial', 'md', false),
  ];

  factory DocumentModel.mock(int index) {
    final data = _mockTitles[index % _mockTitles.length];
    return DocumentModel(
      id: 'doc_$index',
      title: data.$1,
      description: 'Resumen completo con ejemplos prácticos y ejercicios resueltos',
      fileUrl: 'https://example.com/doc_$index.${data.$2}',
      fileType: data.$2,
      authorId: 'user_00${(index % 3) + 1}',
      authorName: ['Ghosty', 'Usuario Test', 'MathNerd'][index % 3],
      downloads: 80 + index * 45,
      views: 320 + index * 60,
      createdAt: DateTime.now().subtract(Duration(days: index * 5)),
      tags: ['educación', 'resumen'],
      isPremium: data.$3,
    );
  }
}
