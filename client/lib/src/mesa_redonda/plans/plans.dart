import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mealPlansProvider = Provider<List<MealPlan>>((ref) {
  return [
    MealPlan(
      title: "Básico",
      price: "RD \$8,000.00 / mes",
      features: [
        "8 comidas",
        "Recetas simples",
        "Soporte por correo",
      ],
      description:
          "Disfruta de 8 comidas deliciosas al mes con nuestro Plan Básico.",
      img: 'assets/plan_basico.jpg',
      longDescription:
          "El Plan Básico es perfecto para quienes quieren probar nuestro servicio. Recibe 8 comidas al mes de nuestro menú de recetas simples y deliciosas.",
      howItWorks:
          "Cada semana, elige tus platos favoritos de nuestro menú. Nosotros los preparamos y te los entregamos directamente.",
      totalMeals: 8,
      mealsRemaining: '',
      id: 'basico',
    ),
    MealPlan(
      title: "Estándar",
      price: "RD \$12,000.00 / mes",
      features: [
        "10 comidas",
        "Recetas avanzadas",
        "Soporte prioritario",
      ],
      description: "Obtén 10 comidas gourmet al mes con nuestro Plan Estándar.",
      img: 'assets/plan_estandar.jpg',
      longDescription:
          "El Plan Estándar es ideal para quienes buscan variedad y recetas más elaboradas. Disfruta de 10 comidas al mes con soporte prioritario.",
      howItWorks:
          "Selecciona tus platos favoritos de nuestro menú avanzado cada semana. Nosotros nos encargamos de todo lo demás.",
      totalMeals: 10,
      mealsRemaining: '',
      id: 'estandar',
    ),
    MealPlan(
      title: "Premium",
      price: "RD \$15,000.00 / mes",
      features: [
        "13 comidas",
        "Recetas exclusivas",
        "Coaching personal",
      ],
      description:
          "Disfruta de la experiencia completa con nuestro Plan Premium de 13 comidas al mes.",
      img: 'assets/plan_premium.jpg',
      longDescription:
          "El Plan Premium te ofrece acceso a recetas exclusivas y un servicio de coaching personal. Recibe 13 comidas al mes y disfruta de una experiencia gastronómica única.",
      howItWorks:
          "Cada semana, elige entre nuestras recetas exclusivas. Te ofrecemos asesoramiento personalizado y entregamos tus comidas listas para disfrutar.",
      totalMeals: 13,
      isBestValue: true,
      mealsRemaining: '',
      id: 'premium',
    ),
  ];
});

class MealPlan {
  final String id;
  final String title;
  final String price;
  final List<String> features;
  final bool isBestValue;
  final String description;
  final String img;
  final String longDescription;
  final String howItWorks;
  final int totalMeals;
  final String mealsRemaining;

  MealPlan({
    required this.id,
    required this.longDescription,
    required this.howItWorks,
    required this.totalMeals,
    required this.mealsRemaining,
    required this.img,
    required this.title,
    required this.price,
    required this.features,
    required this.description,
    this.isBestValue = false,
  });
}
