import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../premium/screens/premium_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user =
            state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar & Info
                Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              AppTheme.primaryBlue.withOpacity(0.2),
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        if (user?.isPremium == true)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Usuario',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (user?.isPremium == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: Colors.black, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Miembro Premium',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.1),
                const SizedBox(height: 32),

                // Stats row
                Row(
                  children: [
                    _StatCard(label: 'Posts', value: '12'),
                    const SizedBox(width: 10),
                    _StatCard(label: 'Clubs', value: '4'),
                    const SizedBox(width: 10),
                    _StatCard(label: 'Docs', value: '8'),
                  ],
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // Premium card (if not premium)
                if (user?.isPremium == false)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PremiumScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withOpacity(0.15),
                            const Color(0xFFFFA500).withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: Color(0xFFFFD700), size: 32),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mejora a Premium',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Accede a todo el contenido exclusivo',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFFFFD700)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                if (user?.isPremium == false) const SizedBox(height: 16),

                // Menu items
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Editar perfil',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente')),
                  ),
                  index: 0,
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () {},
                  index: 1,
                ),
                _MenuItem(
                  icon: Icons.security_outlined,
                  label: 'Privacidad y seguridad',
                  onTap: () {},
                  index: 2,
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  onTap: () {},
                  index: 3,
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  color: Colors.redAccent,
                  onTap: () => context
                      .read<AuthBloc>()
                      .add(AuthLogoutRequested()),
                  index: 4,
                ),
                const SizedBox(height: 20),
                Text(
                  'StudyBytes v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final int index;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.index,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: c.withOpacity(0.8), size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: c,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: Colors.white.withOpacity(0.2), size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ).animate().fadeIn(delay: (index * 60 + 300).ms).slideX(begin: 0.1);
  }
}
