import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/models/user_model.dart';

class CreateEntryScreen extends StatefulWidget {
  final UserModel user;
  const CreateEntryScreen({super.key, required this.user});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feelingsController = TextEditingController();
  final _stressController = TextEditingController();
  final _service = JournalService();

  String _selectedMood = 'neutral';
  bool _isSaving = false;

  static const _moods = [
    ('great', '😄', 'Genial'),
    ('good', '🙂', 'Bien'),
    ('neutral', '😐', 'Regular'),
    ('bad', '😔', 'Mal'),
    ('terrible', '😣', 'Muy mal'),
  ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final entry = await _service.saveEntry(
      userId: widget.user.id,
      feelings: _feelingsController.text.trim(),
      academicStress: _stressController.text.trim(),
      mood: _selectedMood,
    );

    if (mounted) Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: Text('Nueva entrada',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF7C72E5)),
                  )
                : const Text('Guardar',
                    style: TextStyle(
                        color: Color(0xFF7C72E5), fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Selector de mood ─────────────────────────────────
              Text('¿Cómo te sientes hoy?',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _moods.map((m) {
                  final isSelected = _selectedMood == m.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = m.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7C72E5).withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF7C72E5)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(m.$2,
                              style: TextStyle(
                                  fontSize: isSelected ? 32 : 26)),
                          const SizedBox(height: 4),
                          Text(m.$3,
                              style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF7C72E5)
                                      : Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              // ── Sentimientos ─────────────────────────────────────
              _FieldLabel(
                icon: Icons.favorite_outline,
                color: AppTheme.pink,
                label: '¿Cómo te sientes?',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _feelingsController,
                style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe cómo te sientes en este momento...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.2)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Escribe cómo te sientes' : null,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 20),

              // ── Estrés académico ──────────────────────────────────
              _FieldLabel(
                icon: Icons.school_outlined,
                color: AppTheme.mint,
                label: 'Estrés académico',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stressController,
                style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      '¿Qué situación académica te genera estrés y cómo planeas manejarlo?',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.2)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Describe tu estrés académico' : null,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              // ── Tip de bienestar aleatorio ─────────────────────────
              _WellnessTip(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feelingsController.dispose();
    _stressController.dispose();
    super.dispose();
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _FieldLabel(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3)),
    ]);
  }
}

class _WellnessTip extends StatelessWidget {
  static const _tips = [
    '🌬️ Respira profundo 4 segundos, sostén 4, exhala 4. Repite 3 veces.',
    '🚶 Un paseo de 10 minutos reduce el cortisol significativamente.',
    '📵 Desconéctate de redes 30 minutos antes de dormir.',
    '💧 Beber agua mejora la concentración hasta en un 20%.',
    '🎵 La música instrumental ayuda a mantener el foco al estudiar.',
    '✅ Divide tus tareas en pasos pequeños y celebra cada avance.',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().second % _tips.length];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7C72E5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF7C72E5).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip de bienestar',
                    style: TextStyle(
                        color: const Color(0xFF7C72E5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
                const SizedBox(height: 4),
                Text(tip,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
