import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/payment_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedPlanId = 'yearly';
  bool _isProcessing = false;

  Future<void> _purchase() async {
    setState(() => _isProcessing = true);
    final success = await _paymentService.processPremiumPayment(
      userId: 'current_user',
      planId: _selectedPlanId,
      paymentMethod: 'card',
    );
    setState(() => _isProcessing = false);

    if (success && mounted) {
      context.read<AuthBloc>().add(AuthUpgradePremium());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ¡Bienvenido a StudyBytes Premium!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = _paymentService.getPlans();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 42),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'StudyBytes Premium',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Desbloquea todo tu potencial de aprendizaje',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 32),

            // Planes actualizados
            _buildPlanCard(
              id: 'monthly',
              name: 'Premium Mensual',
              price: 99.99,
              period: 'mes',
              features: [
                'Acceso ilimitado a todos los cursos',
                'Asistente IA avanzado',
                'Descarga de materiales',
                'Soporte prioritario 24/7',
              ],
              isPopular: false,
              savings: null,
              index: 0,
            ),
            
            _buildPlanCard(
              id: 'yearly',
              name: 'Premium Anual',
              price: 1199.99,
              period: 'año',
              features: [
                'Todo del plan Mensual',
                ' 2 meses GRATIS ',
                'Acceso a contenido exclusivo',
                'acceso anticipado a funciones',
              ],
              isPopular: true,
              savings: 17,
              index: 1,
            ),
            
            _buildPlanCard(
              id: 'institutional',
              name: 'Plan Institucional',
              price: 49.99,
              period: 'mes/estudiante',
              features: [
                'Todo lo del plan Premium Anual',
                'Panel de control para instituciones',
                'Reportes de progreso',
                'API personalizada',
                'Soporte dedicado',
              ],
              isPopular: false,
              savings: null,
              index: 2,
              isInstitutional: true,
            ),

            const SizedBox(height: 24),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _purchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5),
                      )
                    : Text(
                        'Obtener Premium',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            Text(
              'Cancela cuando quieras • Pago seguro',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String name,
    required double price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required int? savings,
    required int index,
    bool isInstitutional = false,
  }) {
    final isSelected = _selectedPlanId == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.08)
              : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Más popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (isInstitutional) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.mint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Para empresas',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${price.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '/ $period',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (savings != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.mint.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ahorra -${savings}%',
                          style: TextStyle(
                            color: AppTheme.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Features
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 12, color: AppTheme.mint.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        feature,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 80 + 200).ms).slideY(begin: 0.1);
  }
}