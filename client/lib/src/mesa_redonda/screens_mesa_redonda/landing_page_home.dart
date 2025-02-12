import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart'; 
import 'package:url_launcher/url_launcher.dart';

class ResponsiveLandingPage extends ConsumerStatefulWidget {
  const ResponsiveLandingPage({super.key});

  @override
  ConsumerState<ResponsiveLandingPage> createState() =>
      _ResponsiveLandingPageState();
}

class _ResponsiveLandingPageState extends ConsumerState<ResponsiveLandingPage> {
  List<Map<String, dynamic>>? randomDishes;

  @override
  void initState() {
    super.initState();
    _selectRandomDishes();
  }

  // Select random dishes once in initState.
  void _selectRandomDishes() {
    final dishes = ref.read(dishProvider);
    // final dishesCopy = List<Map<String, dynamic>>.from(dishes);
    // dishesCopy.shuffle();
    // Cache the random dishes only once.
    randomDishes =dishes; // dishesCopy.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine device type by screen width.
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 450;

    return Scaffold(
      body: isMobile
          ? buildMobileView(context)
          : buildDesktopView(context),
    );
  }

  // Mobile view with vertical scrolling.
  Widget buildMobileView(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard.
      child: SingleChildScrollView(
        child: Column(
          children:  [
           const HeroSection(),
           const PerksSectionMobile(),
           const PlansSectionMobile(),
           DishesSectionMobile(randomDishes: randomDishes,),
           const ContactSection(),
           const FooterSection(),
          ],
        ),
      ),
    );
  }

  // Desktop view with more generous spacing.
  Widget buildDesktopView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:  [
        const  HeroSection(),
         const PerksSectionDesktop(),
        const  PlansSectionDesktop(),
          DishesSectionDesktop(randomDishes: randomDishes,),
         const ContactSection(),
         const FooterSection(),
        ],
      ),
    );
  }
}

/// ------------------------
/// Hero Section (static, so marked const)
/// ------------------------
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      // If using network images, consider caching them.
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/hero_background.jpg'),
          fit: BoxFit.cover,
        ),
        color: ColorsPaletteRedonda.primary.withOpacity(0.6),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Experiencia Gastronómica Saludable!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ColorsPaletteRedonda.primary,
                      fontSize: 32,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ColorsPaletteRedonda.primary,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    GoRouter.of(context).goNamed(AppRoute.home.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Explorar Menú',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorsPaletteRedonda.white,
                        fontWeight: FontWeight.bold,
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

/// ------------------------
/// Perks Section (Mobile)
/// ------------------------
class PerksSectionMobile extends StatelessWidget {
  const PerksSectionMobile({super.key});
  @override
  Widget build(BuildContext context) {
    // Use a constant list of perks.
    const perks = [
      {
        'title': 'Ingredientes Frescos',
        'description':
            'Ingredientes orgánicos y frescos garantizan el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description':
            'Platos que se ven tan bien como saben.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description':
            'Planes adaptados a tus necesidades.',
        'icon': Icons.person,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: perks.length,
              itemBuilder: (context, index) {
                final perk = perks[index];
                return PerkCard(
                  title: perk['title'] as String,
                  description: perk['description'] as String,
                  icon: perk['icon'] as IconData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Perks Section (Desktop)
/// ------------------------
class PerksSectionDesktop extends StatelessWidget {
  const PerksSectionDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              PerkCard(
                title: 'Ingredientes Frescos',
                description:
                    'Ingredientes orgánicos y frescos garantizan el mejor sabor.',
                icon: Icons.eco,
              ),
              PerkCard(
                title: 'Presentación Exquisita',
                description:
                    'Platos que se ven tan bien como saben.',
                icon: Icons.palette,
              ),
              PerkCard(
                title: 'Servicio Personalizado',
                description:
                    'Planes adaptados a tus necesidades.',
                icon: Icons.person,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Perk Card widget.
class PerkCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  const PerkCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(icon, size: 50, color: ColorsPaletteRedonda.primary),
              const SizedBox(height: 15),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------
/// Plans Section (Mobile)
/// ------------------------
class PlansSectionMobile extends ConsumerWidget {
  const PlansSectionMobile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Text(
            'Nuestros Planes',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mealPlans.length,
              itemBuilder: (context, index) {
                final mealPlan = mealPlans[index];
                return PlanCard(
                  planName: mealPlan.title,
                  description: mealPlan.description,
                  price: mealPlan.price,
                  planId: mealPlan.id,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Plans Section (Desktop)
/// ------------------------
class PlansSectionDesktop extends ConsumerWidget {
  const PlansSectionDesktop({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Text(
            'Nuestros Planes',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: mealPlans.map((mealPlan) {
              return PlanCard(
                planName: mealPlan.title,
                description: mealPlan.description,
                price: mealPlan.price,
                planId: mealPlan.id,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A reusable Plan Card widget.
class PlanCard extends StatelessWidget {
  final String planName;
  final String description;
  final String price;
  final String planId;
  const PlanCard({
    super.key,
    required this.planName,
    required this.description,
    required this.price,
    required this.planId,
  });

  @override
  Widget build(BuildContext context) {
    IconData planIcon;
    switch (planId) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage;
        break;
      case 'estandar':
        planIcon = Icons.local_cafe;
        break;
      case 'premium':
        planIcon = Icons.local_dining;
        break;
      default:
        planIcon = Icons.fastfood;
    }
    return Container(
      width: 300,
      height: 340,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(planIcon, size: 80, color: ColorsPaletteRedonda.primary),
              const SizedBox(height: 20),
              Text(
                planName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                price,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ColorsPaletteRedonda.orange,
                    ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).goNamed(
                    AppRoute.planDetails.name,
                    pathParameters: {'planId': planId},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  foregroundColor: ColorsPaletteRedonda.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Ver Detalles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorsPaletteRedonda.white,
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

/// ------------------------
/// Dishes Section (Mobile)
/// ------------------------
class DishesSectionMobile extends StatelessWidget {
  final List<Map<String, dynamic>>? randomDishes;
  const DishesSectionMobile({super.key, this.randomDishes});

  @override
  Widget build(BuildContext context) {
    if (randomDishes == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Text(
            'Nuestros Platos',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: randomDishes!.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final dish = randomDishes![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SlideItem(
                    key: Key('dish_$index'),
                    index: index,
                    img: dish['img'],
                    title: dish['title'],
                    description: dish['description'],
                    pricing: dish['pricing'],
                    ingredients: List<String>.from(dish['ingredients']),
                    isSpicy: dish['isSpicy'],
                    foodType: dish['foodType'],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.orange,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Todos nuestros platos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorsPaletteRedonda.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Dishes Section (Desktop)
/// ------------------------
class DishesSectionDesktop extends StatelessWidget {
  final List<Map<String, dynamic>>? randomDishes;
  const DishesSectionDesktop({super.key, this.randomDishes});

  @override
  Widget build(BuildContext context) {
    if (randomDishes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Text(
            'Nuestros Platos',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: randomDishes!.asMap().entries.map((entry) {
              final index = entry.key;
              final dish = entry.value;
              return SlideItem(
                key: Key('dish_$index'),
                index: index,
                img: dish['img'],
                title: dish['title'],
                description: dish['description'],
                pricing: dish['pricing'],
                ingredients: List<String>.from(dish['ingredients']),
                isSpicy: dish['isSpicy'],
                foodType: dish['foodType'],
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.orange,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Ver Menú Completo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorsPaletteRedonda.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Contact Section
/// ------------------------
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<void> _sendWhatsAppHello(BuildContext context) async {
    const String phoneNumber = '+18099880275';
    final String whatsappUrlMobile =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent('Hola')}';
    final String whatsappUrlWeb =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent('Hola!')}';

    if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
      await launchUrl(Uri.parse(whatsappUrlMobile));
    } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
      await launchUrl(Uri.parse(whatsappUrlWeb));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pude abrir WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ColorsPaletteRedonda.deepBrown1.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Contáctanos',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Si tienes preguntas o necesitas un servicio personalizado, contáctanos.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Email: mesaredonda.rd@gmail.com',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Teléfono: +1 849 359 0832',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _sendWhatsAppHello(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Envíanos un Mensaje',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorsPaletteRedonda.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Footer Section
/// ------------------------
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ColorsPaletteRedonda.deepBrown1,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '© 2024 Tu Cocina Digital',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorsPaletteRedonda.white,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Política de Privacidad',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ColorsPaletteRedonda.white,
                      ),
                ),
              ),
              const Text(
                '|',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Términos del Servicio',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ColorsPaletteRedonda.white,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}