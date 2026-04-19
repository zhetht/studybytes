import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../clubs/screens/clubs_screen.dart';
import '../../posts/screens/posts_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../profile/screens/profile_screen.dart';
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
    ProfileScreen(),
  ];

  final _titles = const [
    'StudyBytes',
    'Clubs de Estudio',
    'Mi Biblioteca',
    'Mi Perfil',
  ];

  final _navItems = const [
    (Icons.article_outlined, Icons.article_rounded, 'Posts'),
    (Icons.group_outlined, Icons.group_rounded, 'Clubs'),
    (Icons.library_books_outlined, Icons.library_books_rounded, 'Biblioteca'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return _buildWideLayout();
    }
    return _buildNarrowLayout();
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Side nav
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
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.lavender,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'StudyBytes',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Nav items
                ..._navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
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
                                ? AppTheme.primaryBlue.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? item.$2 : item.$1,
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.white.withOpacity(0.4),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.$3,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : Colors.white.withOpacity(0.4),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
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
            color: Colors.white.withOpacity(0.06),
          ),
          // Content
          Expanded(
            child: Scaffold(
              backgroundColor: AppTheme.darkBg,
              appBar: AppBar(
                title: Text(_titles[_selectedIndex]),
                backgroundColor: AppTheme.darkBg,
              ),
              body: _screens[_selectedIndex],
              floatingActionButton: const AiBubbleWidget(),
            ),
          ),
        ],
      ),
    );
  }

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
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.lavender],
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
      floatingActionButton: _selectedIndex != 3
          ? const AiBubbleWidget()
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.cardDark,
        indicatorColor: AppTheme.primaryBlue.withOpacity(0.15),
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.$1),
                selectedIcon: Icon(item.$2,
                    color: AppTheme.primaryBlue),
                label: item.$3,
              ),
            )
            .toList(),
      ),
    );
  }
}
