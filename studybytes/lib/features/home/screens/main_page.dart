import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../clubs/screens/clubs_screen.dart';
import '../../posts/screens/posts_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../zenhub/screens/zenhub_screen.dart';
import '../../../widgets/ai_bubble/ai_bubble_widget.dart';
import '../../../core/theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final _screens = const [
    PostsScreen(),
    ClubsScreen(),
    LibraryScreen(),
    ZenHubScreen(),   // ← nuevo
    ProfileScreen(),
  ];

  final _titles = const [
    'StudyBytes',
    'Clubs de Estudio',
    'Mi Biblioteca',
    'ZenHub',         // ← nuevo
    'Mi Perfil',
  ];

  final _navItems = const [
    (Icons.article_outlined,      Icons.article_rounded,           'Posts'),
    (Icons.group_outlined,        Icons.group_rounded,             'Clubs'),
    (Icons.library_books_outlined,Icons.library_books_rounded,     'Biblioteca'),
    (Icons.self_improvement,      Icons.self_improvement,          'ZenHub'),  // ← nuevo
    (Icons.person_outline_rounded,Icons.person_rounded,            'Perfil'),
  ];

  // Color de acento por sección
  Color get _accentColor {
    if (_selectedIndex == 3) return const Color(0xFF7C72E5); // ZenHub violeta
    return AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return isWide ? _buildWideLayout() : _buildNarrowLayout();
  }

  // ── Layout tablet / escritorio ───────────────────────────────────────────
  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: AppTheme.cardDark,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_accentColor, AppTheme.lavender],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('StudyBytes',
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Nav items
                ..._navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == i;
                  final accent =
                      i == 3 ? const Color(0xFF7C72E5) : AppTheme.primaryBlue;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedIndex = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? item.$2 : item.$1,
                                color: isSelected
                                    ? accent
                                    : Colors.white.withOpacity(0.4),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(item.$3,
                                  style: TextStyle(
                                      color: isSelected
                                          ? accent
                                          : Colors.white.withOpacity(0.4),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.white.withOpacity(0.06)),
          Expanded(
            child: Scaffold(
              backgroundColor: AppTheme.darkBg,
              appBar: AppBar(
                title: Text(_titles[_selectedIndex]),
                backgroundColor: AppTheme.darkBg,
              ),
              body: _screens[_selectedIndex],
              floatingActionButton:
                  _selectedIndex != 4 ? const AiBubbleWidget() : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Layout móvil ─────────────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, AppTheme.lavender],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(_titles[_selectedIndex]),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      floatingActionButton:
          _selectedIndex != 4 ? const AiBubbleWidget() : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.cardDark,
        indicatorColor: _selectedIndex == 3
            ? const Color(0xFF7C72E5).withOpacity(0.15)
            : AppTheme.primaryBlue.withOpacity(0.15),
        destinations: _navItems
            .asMap()
            .entries
            .map((e) {
              final accent = e.key == 3
                  ? const Color(0xFF7C72E5)
                  : AppTheme.primaryBlue;
              return NavigationDestination(
                icon: Icon(e.value.$1),
                selectedIcon: Icon(e.value.$2, color: accent),
                label: e.value.$3,
              );
            })
            .toList(),
      ),
    );
  }
}
