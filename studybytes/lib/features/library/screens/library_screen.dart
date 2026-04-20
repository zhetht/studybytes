import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import 'upload_document_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  final _service = SupabaseService();
  String _filter = 'Todos';
  List<DocumentModel> _docs = [];
  bool _isLoading = true;

  final List<String> _filters = ['Todos', 'PDF', 'Markdown', 'Premium'];

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _isLoading = true);
    try {
      final docs = await _service.fetchDocuments();
      if (mounted) setState(() { _docs = docs; _isLoading = false; });
    } catch (_) {
      // Modo demo sin Supabase
      if (mounted) {
        setState(() {
          _docs = List.generate(4, DocumentModel.mock);
          _isLoading = false;
        });
      }
    }
  }

  List<DocumentModel> get _filtered {
    return _docs.where((doc) {
      final matchSearch = _searchController.text.isEmpty ||
          doc.title.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchFilter = _filter == 'Todos' ||
          (_filter == 'PDF' && doc.fileType == 'pdf') ||
          (_filter == 'Markdown' && doc.fileType == 'md') ||
          (_filter == 'Premium' && doc.isPremium);
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar documentos...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () { _searchController.clear(); setState(() {}); })
                    : null,
              ),
            ),
          ),
          // Filtros
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final f = _filters[i];
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.5),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                        color: selected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.1)),
                    backgroundColor: Colors.transparent,
                  ),
                );
              },
            ),
          ),
          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDocs,
                    child: _filtered.isEmpty
                        ? ListView(children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Text('Sin documentos',
                                  style: TextStyle(color: Colors.white.withOpacity(0.3))),
                            ),
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) =>
                                _DocCard(doc: _filtered[i], index: i, onDeleted: _loadDocs),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión para subir documentos')),
            );
            return;
          }
          final uploaded = await Navigator.push<DocumentModel>(
            context,
            MaterialPageRoute(
              builder: (_) => UploadDocumentScreen(user: authState.user),
            ),
          );
          if (uploaded != null) {
            setState(() => _docs.insert(0, uploaded));
          }
        },
        icon: const Icon(Icons.upload_outlined),
        label: const Text('Subir'),
      ),
    );
  }
}

// ── Document Card ──────────────────────────────────────────────────────────
class _DocCard extends StatelessWidget {
  final DocumentModel doc;
  final int index;
  final VoidCallback onDeleted;

  const _DocCard({required this.doc, required this.index, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (doc.isPremium) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated && authState.user.isPremium) {
              _openDoc(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔒 Requiere cuenta Premium')),
              );
            }
          } else {
            _openDoc(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icono tipo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: doc.fileType == 'pdf'
                      ? Colors.redAccent.withOpacity(0.15)
                      : AppTheme.mint.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  doc.fileType == 'pdf'
                      ? Icons.picture_as_pdf_rounded
                      : Icons.description_outlined,
                  color: doc.fileType == 'pdf' ? Colors.redAccent : AppTheme.mint,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(doc.title,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 14)),
                        ),
                        if (doc.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('✦ PRO',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(doc.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45), fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.download_outlined,
                            size: 13, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 3),
                        Text('${doc.downloads}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3), fontSize: 12)),
                        const SizedBox(width: 12),
                        Icon(Icons.visibility_outlined,
                            size: 13, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 3),
                        Text('${doc.views}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3), fontSize: 12)),
                        const Spacer(),
                        Text(doc.authorName,
                            style: TextStyle(
                                color: AppTheme.lavender.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.08);
  }

  void _openDoc(BuildContext context) {
    if (doc.fileUrl.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Abriendo: ${doc.title}')));
      return;
    }
    // Aquí podrías abrir el PDF viewer o lanzar URL
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Abriendo: ${doc.title}')));
  }
}
