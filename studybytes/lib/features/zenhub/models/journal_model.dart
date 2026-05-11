class JournalEntry {
  final String id;
  final String feelings;
  final String academicStress;
  final String mood; // 'great', 'good', 'neutral', 'bad', 'terrible'
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.feelings,
    required this.academicStress,
    required this.mood,
    required this.createdAt,
  });

  factory JournalEntry.fromSupabase(Map<String, dynamic> row) {
    return JournalEntry(
      id: row['id'].toString(),
      feelings: row['feelings'] ?? '',
      academicStress: row['academic_stress'] ?? '',
      mood: row['mood'] ?? 'neutral',
      createdAt: DateTime.parse(row['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'feelings': feelings,
        'academic_stress': academicStress,
        'mood': mood,
      };

  static const moodEmojis = {
    'great': '😄',
    'good': '🙂',
    'neutral': '😐',
    'bad': '😔',
    'terrible': '😣',
  };

  static const moodLabels = {
    'great': 'Genial',
    'good': 'Bien',
    'neutral': 'Regular',
    'bad': 'Mal',
    'terrible': 'Muy mal',
  };

  String get emoji => moodEmojis[mood] ?? '😐';
  String get label => moodLabels[mood] ?? 'Regular';
}
