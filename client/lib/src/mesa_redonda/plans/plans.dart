import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mealPlansProvider = Provider<List<MealPlan>>((ref) {
  return [
    MealPlan(
      title: "Básico",
      price: "\$9.99 / mes",
      features: [
        "1 usuario",
        "8 comidas", // Updated meal count
        "Recetas simples",
        "Soporte por correo",
      ],
    ),
    MealPlan(
      title: "Estándar",
      price: "\$19.99 / mes",
      features: [
        "2 usuarios",
        "10 comidas", // Updated meal count
        "Recetas avanzadas",
        "Soporte prioritario",
      ],
    ),
    MealPlan(
      title: "Premium",
      price: "\$29.99 / mes",
      features: [
        "5 usuarios",
        "13 comidas", // Updated meal count
        "Recetas exclusivas",
        "Coaching personal",
      ],
      isBestValue: true, // Marked as best value
    ),
  ];
});

class MealPlan {
  final String title;
  final String price;
  final List<String> features;
  final bool isBestValue;

  MealPlan({
    required this.title,
    required this.price,
    required this.features,
    this.isBestValue = false,
  });
}

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanCard({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 450,
        maxHeight: 550,
      ),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: mealPlan.isBestValue ? Colors.green : Colors.grey.shade300,
            width: mealPlan.isBestValue ? 3 : 1.5,
          ),
        ),
        color: mealPlan.isBestValue ? Colors.green.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mealPlan.isBestValue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mejor Valor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color:
                        mealPlan.isBestValue ? Colors.green : Colors.blueAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      mealPlan.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.blueAccent,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    mealPlan.price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.featured_play_list,
                    color: Colors.blueAccent,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Características:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mealPlan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    'Gastos de envío se aplicarán',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle add to cart
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mealPlan.isBestValue
                        ? Colors.green.shade700
                        : Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Agregar al carrito',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
