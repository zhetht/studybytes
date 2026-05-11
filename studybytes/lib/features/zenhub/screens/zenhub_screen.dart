import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import 'create_entry_screen.dart';

class ZenHubScreen extends StatefulWidget {
  const ZenHubScreen({super.key});

  @override
  State<ZenHubScreen> createState() => _ZenHubScreenState();
}

class _ZenHubScreenState extends State<ZenHubScreen> {
  final _service = JournalService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthAuthenticated ? authState.user.id : 'guest';
    final entries = await _service.fetchEntries(userId);
    if (mounted) setState(() { _entries = entries; _isLoading = false; });
  }

  Future<void> _delete(String id) async {
    await _service.deleteEntry(id);
    setState(() => _entries.removeWhere((e) => e.id == id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada eliminada')),
      );
    }
  }

  // Mood promedio de los últimos 7 días para el resumen
  String get _weekSummaryEmoji {
    if (_entries.isEmpty) return '😐';
    const order = ['terrible', 'bad', 'neutral', 'good', 'great'];
    final recent = _entries.take(7).toList();
    final avg = recent
            .map((e) => order.indexOf(e.mood))
            .reduce((a, b) => a + b) /
        recent.length;
    return JournalEntry.moodEmojis[order[avg.round()]] ?? '😐';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // ── Banner de bienvenida ──────────────────────────
                  SliverToBoxAdapter(
                    child: _WelcomeBanner(
                      emoji: _weekSummaryEmoji,
                      entryCount: _entries.length,
                    ),
                  ),
                  // ── Lista de entradas ─────────────────────────────
                  _entries.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🌱',
                                    style: const TextStyle(fontSize: 56)),
                                const SizedBox(height: 14),
                                Text('Tu diario emocional está vacío',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 15)),
                                const SizedBox(height: 6),
                                Text('Toca ✦ para escribir tu primera entrada',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.25),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _EntryCard(
                                entry: _entries[i],
                                index: i,
                                onDelete: _delete,
                              ),
                              childCount: _entries.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Inicia sesión para usar el diario')),
            );
            return;
          }
          final entry = await Navigator.push<JournalEntry>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEntryScreen(user: authState.user),
            ),
          );
          if (entry != null) setState(() => _entries.insert(0, entry));
        },
        backgroundColor: const Color(0xFF7C72E5), // violeta ZenHub
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Nueva entrada'),
      ),
    );
  }
}

// ── Banner ─────────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String emoji;
  final int entryCount;
  const _WelcomeBanner({required this.emoji, required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C72E5), Color(0xFF5B4FCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C72E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZenHub',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu diario emocional académico',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$entryCount ${entryCount == 1 ? 'entrada' : 'entradas'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

// ── Entry Card ─────────────────────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final int index;
  final Function(String) onDelete;

  const _EntryCard(
      {required this.entry, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                Text(entry.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.label,
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      Text(
                        _formatDate(entry.createdAt),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz,
                      color: Colors.white.withOpacity(0.3)),
                  onSelected: (v) {
                    if (v == 'delete') onDelete(entry.id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar',
                            style: TextStyle(color: Colors.redAccent)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sentimientos
            _Section(
              icon: Icons.favorite_outline,
              color: AppTheme.pink,
              label: '¿Cómo me siento?',
              text: entry.feelings,
            ),
            const SizedBox(height: 10),
            // Estrés académico
            _Section(
              icon: Icons.school_outlined,
              color: AppTheme.mint,
              label: 'Estrés académico',
              text: entry.academicStress,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.08);
  }

  String _formatDate(DateTime d) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${d.day} ${months[d.month - 1]} · '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;

  const _Section(
      {required this.icon,
      required this.color,
      required this.label,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
          ]),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }
}
