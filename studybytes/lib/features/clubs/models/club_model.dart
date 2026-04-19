class ClubModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String creatorId;
  final List<String> members;
  final int memberCount;
  final DateTime createdAt;
  final String category;
  final String emoji;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.creatorId,
    required this.members,
    required this.memberCount,
    required this.createdAt,
    required this.category,
    required this.emoji,
  });

  static final _mockData = [
    {'cat': 'Matemáticas', 'emoji': '📐', 'desc': 'Álgebra, cálculo y estadística'},
    {'cat': 'Programación', 'emoji': '💻', 'desc': 'Código, algoritmos y proyectos'},
    {'cat': 'Ciencias', 'emoji': '🔬', 'desc': 'Física, química y biología'},
    {'cat': 'Historia', 'emoji': '📜', 'desc': 'Eventos, civilizaciones y cultura'},
    {'cat': 'Literatura', 'emoji': '📚', 'desc': 'Libros, análisis y escritura'},
    {'cat': 'Idiomas', 'emoji': '🌍', 'desc': 'Inglés, francés y más'},
  ];

  factory ClubModel.mock(int index) {
    final data = _mockData[index % _mockData.length];
    return ClubModel(
      id: 'club_$index',
      name: 'Club de ${data['cat']}',
      description:
          'Un espacio para estudiar y compartir sobre ${data['desc']?.toLowerCase()}',
      creatorId: 'user_001',
      members: ['user_001', 'user_002'],
      memberCount: 24 + index * 13,
      createdAt: DateTime.now().subtract(Duration(days: index * 7)),
      category: data['cat']!,
      emoji: data['emoji']!,
    );
  }
}
