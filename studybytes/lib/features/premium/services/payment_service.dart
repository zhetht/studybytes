class PaymentService {
  Future<bool> processPremiumPayment({
    required String userId,
    required String planId,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // Mock: siempre exitoso
  }

  Future<bool> restorePurchase(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  List<PremiumPlan> getPlans() => [
        PremiumPlan(
          id: 'monthly',
          name: 'Mensual',
          price: 9.99,
          period: 'mes',
          features: [
            'Acceso a todos los resúmenes premium',
            'IA avanzada sin límites',
            'Crear clubs privados',
            'Sin publicidad',
          ],
        ),
        PremiumPlan(
          id: 'yearly',
          name: 'Anual',
          price: 89.99,
          period: 'año',
          features: [
            'Todo lo del plan mensual',
            '2 meses gratis',
            'Soporte prioritario',
            'Certificados de finalización',
          ],
          isPopular: true,
          savings: 25,
        ),
        PremiumPlan(
          id: 'lifetime',
          name: 'De por vida',
          price: 299.99,
          period: 'único',
          features: [
            'Todo lo anterior',
            'Acceso vitalicio',
            'Actualizaciones gratuitas',
            'Membresía VIP',
          ],
        ),
      ];
}

class PremiumPlan {
  final String id;
  final String name;
  final double price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final int? savings;

  PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.savings,
  });
}
