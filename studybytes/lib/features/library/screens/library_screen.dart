import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_model.dart';
import '../../../core/theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  String _filter = 'Todos';
  List<DocumentModel> _docs = [];
  bool _isLoading = true;

  final List<String> _filters = ['Todos', 'PDF', 'Markdown', 'Premium'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _docs = List.generate(6, DocumentModel.mock);
          _isLoading = false;
        });
      }
    });
  }

  List<DocumentModel> get _filteredDocs {
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
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _filter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = filter),
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.white.withOpacity(0.5),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.white.withOpacity(0.1),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDocs.isEmpty
                    ? Center(
                        child: Text(
                          'Sin resultados',
                          style: TextStyle(color: Colors.white.withOpacity(0.3)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDocs.length,
                        itemBuilder: (context, index) {
                          return _DocumentCard(
                            doc: _filteredDocs[index],
                            index: index,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Próximamente: Subir documento')),
        ),
        icon: const Icon(Icons.upload_outlined),
        label: const Text('Subir'),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final int index;

  const _DocumentCard({required this.doc, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (doc.isPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('🔒 Requiere cuenta Premium')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Abriendo: ${doc.title}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
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
                  color: doc.fileType == 'pdf'
                      ? Colors.redAccent
                      : AppTheme.mint,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doc.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (doc.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                              ]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '✦ PRO',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.download_outlined,
                            size: 13,
                            color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 3),
                        Text(
                          '${doc.downloads}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.visibility_outlined,
                            size: 13,
                            color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 3),
                        Text(
                          '${doc.views}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          doc.authorName,
                          style: TextStyle(
                            color: AppTheme.lavender.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1);
  }
}
