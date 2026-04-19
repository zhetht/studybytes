import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AiBubbleWidget extends StatefulWidget {
  const AiBubbleWidget({super.key});

  @override
  State<AiBubbleWidget> createState() => _AiBubbleWidgetState();
}

class _AiBubbleWidgetState extends State<AiBubbleWidget> {
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen)
          Container(
            width: 340,
            height: 480,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const _ChatPanel(),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppTheme.primaryBlue,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isOpen
                ? const Icon(Icons.close, key: ValueKey('close'))
                : const Icon(Icons.auto_awesome, key: ValueKey('open')),
          ),
        ),
      ],
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel();

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;


  bool get _keyIsConfigured {
    final key = ApiConfig.geminiApiKey.trim();
    return key.isNotEmpty &&
        !key.startsWith('REEMPLAZA') &&
        !key.startsWith('tu_api') &&
        key.length > 20; 
  }

  @override
  void initState() {
    super.initState();
    _initModel();
    _addWelcome();
  }

  void _initModel() {
    if (!_keyIsConfigured) return;
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: ApiConfig.geminiApiKey.trim(),
      );
    } catch (e) {
      debugPrint('[Gemini] initModel error: $e');
      _model = null;
    }
  }

  void _addWelcome() {
    _messages.add(_ChatMessage(
      text: _keyIsConfigured
          ? '¡Hola! Soy tu asistente de estudio con IA ✨\n\n'
              'Puedo ayudarte con dudas académicas, explicar conceptos, '
              'resolver problemas o hacer resúmenes. ¿En qué puedo ayudarte?'
          : '¡Hola! Estoy en modo demo 🤖\n\n'
              'Para activar la IA real, pon tu clave en:\n'
              '`lib/config/api_config.dart`\n\n'
              'Obtén una gratis en aistudio.google.com',
      isUser: false,
    ));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Sin key → respuesta demo local, sin llamada a red
    if (!_keyIsConfigured) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: _demoResponse(text), isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
      return;
    }

    // Con key → llamar a Gemini
    try {
      _model ??= GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConfig.geminiApiKey.trim(),
      );

      final result = await _model!.generateContent([Content.text(text)]);
      final reply = result.text?.trim() ?? '';

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: reply.isNotEmpty ? reply : 'Sin respuesta. Intenta de nuevo.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } on GenerativeAIException catch (e) {
      _showError('Error de Gemini API: ${e.message}');
    } catch (e) {
      _showError('Error de conexión.\nDetalle: $e');
    }
  }

  void _showError(String detail) {
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: '⚠️ $detail', isUser: false, isError: true));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  String _demoResponse(String input) {
    final q = input.toLowerCase();
    if (q.contains('matemáticas') || q.contains('algebra') || q.contains('cálculo')) {
      return 'Las matemáticas se dominan con práctica constante. '
          'Te recomiendo la técnica de repetición espaciada y ejercicios progresivos. '
          '¿Sobre qué tema específico necesitas ayuda?';
    }
    if (q.contains('programación') || q.contains('código') || q.contains('python')) {
      return 'La clave para aprender programación es construir proyectos reales desde el primer día. '
          'Empieza pequeño y ve incrementando la complejidad. ¿Qué lenguaje estás aprendiendo?';
    }
    if (q.contains('historia') || q.contains('guerra') || q.contains('revolución')) {
      return 'Para memorizar historia crea líneas de tiempo visuales y relaciona '
          'eventos con causas y consecuencias. ¿Sobre qué período necesitas ayuda?';
    }
    return '(Modo demo) Configura tu API key en `lib/config/api_config.dart` '
        'para respuestas reales de Gemini. '
        'Por ahora pregúntame sobre matemáticas, programación o historia.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildMessages()),
        _buildInput(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.lavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistente IA',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                _keyIsConfigured ? 'Gemini 2.0 Flash' : 'Modo demo',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          // Verde = key configurada  |  Amarillo = modo demo
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _keyIsConfigured ? AppTheme.mint : const Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _TypingIndicator();
        return _MessageBubble(message: _messages[index]);
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: null,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Pregúntame algo...',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  _ChatMessage({required this.text, required this.isUser, this.isError = false});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.redAccent.withOpacity(0.15)
              : message.isUser
                  ? AppTheme.primaryBlue
                  : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.isUser ? 14 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 14),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isError
                ? Colors.redAccent
                : Colors.white.withOpacity(0.9),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppTheme.lavender.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(delay: (i * 150).ms)
                .then()
                .fadeOut(delay: 200.ms),
          ),
        ),
      ),
    );
  }
}
