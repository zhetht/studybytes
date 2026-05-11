import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_model.dart';

class JournalService {
  static final JournalService _i = JournalService._();
  factory JournalService() => _i;
  JournalService._();

  final _client = Supabase.instance.client;

  // Caché local para cuando Supabase no está configurado
  final List<JournalEntry> _local = [];

  Future<List<JournalEntry>> fetchEntries(String userId) async {
    try {
      final res = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (res as List).map((e) => JournalEntry.fromSupabase(e)).toList();
    } catch (_) {
      return List.from(_local.reversed);
    }
  }

  Future<JournalEntry> saveEntry({
    required String userId,
    required String feelings,
    required String academicStress,
    required String mood,
  }) async {
    try {
      final res = await _client.from('journal_entries').insert({
        'user_id': userId,
        'feelings': feelings,
        'academic_stress': academicStress,
        'mood': mood,
      }).select().single();
      return JournalEntry.fromSupabase(res);
    } catch (_) {
      // Fallback local si Supabase no está listo
      final entry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        feelings: feelings,
        academicStress: academicStress,
        mood: mood,
        createdAt: DateTime.now(),
      );
      _local.add(entry);
      return entry;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _client.from('journal_entries').delete().eq('id', entryId);
    } catch (_) {
      _local.removeWhere((e) => e.id == entryId);
    }
  }
}
