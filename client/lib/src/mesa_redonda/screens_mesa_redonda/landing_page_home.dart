import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your theme and SlideItem widget
// import 'path_to_colors_palette_redonda.dart';
// import 'path_to_slide_item.dart';

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

  void _selectRandomDishes() {
    final dishes = ref.read(dishProvider);
    final dishesCopy = List<Map<String, dynamic>>.from(dishes);
    dishesCopy.shuffle();
    setState(() {
      randomDishes = dishesCopy.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to determine screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 450;

    return Scaffold(
      body: isMobile
          ? buildMobileView(context, ref)
          : buildDesktopView(context, ref),
    );
  }

  // Mobile view (450px and below)
  Widget buildMobileView(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildHeroSection(context),
            buildPerksSectionMobile(context),
            buildPlansSectionMobile(context),
            buildDishesSectionMobile(context),
            buildContactSection(context),
            buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Desktop view (451px and above)
  Widget buildDesktopView(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildHeroSection(context),
          buildPerksSectionDesktop(context),
          buildPlansSectionDesktop(context),
          buildDishesSectionDesktop(context),
          buildContactSection(context),
          buildFooter(context),
        ],
      ),
    );
  }

  // Hero Section
  Widget buildHeroSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: const AssetImage('assets/hero_background.jpg'),
      //     fit: BoxFit.cover,
      //     colorFilter: ColorFilter.mode(
      //       ColorsPaletteRedonda.primary.withOpacity(0.6),
      //       BlendMode.darken,
      //     ),
      //   ),
      // ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                onPressed: () {
                  // Navigate to the menu tab
                  GoRouter.of(context).goNamed(AppRoute.home.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
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

  // Mobile Perks Section
  Widget buildPerksSectionMobile(BuildContext context) {
    final perks = [
      {
        'title': 'Ingredientes Frescos',
        'description':
            'Utilizamos solo ingredientes orgánicos y frescos para garantizar el mejor sabor y nutrición.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description':
            'Nuestros platos no solo saben bien, sino que también se ven increíbles.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description':
            'Planes de catering y almuerzo adaptados a tus necesidades.',
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
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: perks.length,
                itemBuilder: (context, index) {
                  final perk = perks[index];
                  final title = perk['title']! as String;
                  final desc = perk['description']! as String;
                  final icon = perk['icon']! as IconData;

                  return buildPerkCard(context, title, desc, icon);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Perks Section
  Widget buildPerksSectionDesktop(BuildContext context) {
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
            children: [
              buildPerkCard(
                context,
                'Ingredientes Frescos',
                'Utilizamos solo ingredientes orgánicos y frescos para garantizar el mejor sabor y nutrición.',
                Icons.eco,
              ),
              buildPerkCard(
                context,
                'Presentación Exquisita',
                'Nuestros platos no solo saben bien, sino que también se ven increíbles.',
                Icons.palette,
              ),
              buildPerkCard(
                context,
                'Servicio Personalizado',
                'Planes de catering y almuerzo adaptados a tus necesidades.',
                Icons.person,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Perk Card
  Widget buildPerkCard(
      BuildContext context, String title, String description, IconData icon) {
    return Container(
      height: 240,
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
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

  Widget buildPlansSectionDesktop(BuildContext context) {
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
              return buildPlanCard(
                context,
                mealPlan.title,
                mealPlan.description,
                mealPlan.price,
                mealPlan.id,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Plan Card
  Widget buildPlansSectionMobile(BuildContext context) {
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
            height: 320, // Adjusted height to accommodate new layout
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mealPlans.length,
                itemBuilder: (context, index) {
                  final mealPlan = mealPlans[index];
                  return buildPlanCard(
                    context,
                    mealPlan.title,
                    mealPlan.description,
                    mealPlan.price,
                    mealPlan.id,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlanCard(
    BuildContext context,
    String planName,
    String description,
    String price,
    String planId,
  ) {
    // Map planId to appropriate icons
    IconData planIcon;
    switch (planId) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage; // Represents basic plan
        break;
      case 'estandar':
        planIcon = Icons.local_cafe; // Represents standard plan
        break;
      case 'premium':
        planIcon = Icons.local_dining; // Represents premium plan
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
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Plan Icon
              Icon(
                planIcon,
                size: 80,
                color: ColorsPaletteRedonda.primary,
              ),
              const SizedBox(height: 20),
              // Plan Name
              Text(
                planName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Plan Description
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Plan Price
              Text(
                price,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ColorsPaletteRedonda.orange,
                    ),
              ),
              // const SizedBox(height: 15),
              const Spacer(),
              // "Seleccionar Plan" Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the plan details screen
                  GoRouter.of(context).goNamed(
                    AppRoute.planDetails.name,
                    pathParameters: {'planId': planId},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  foregroundColor: ColorsPaletteRedonda.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
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

  Widget buildDishesSectionMobile(BuildContext context) {
    if (randomDishes == null) {
      return const Center(child: CircularProgressIndicator());
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
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: randomDishes!.length,
                itemBuilder: (context, index) {
                  final dish = randomDishes![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SlideItem(
                      img: dish['img'],
                      title: dish['title'],
                      description: dish['description'],
                      pricing: dish['pricing'],
                      ingredients: List<String>.from(dish['ingredients']),
                      isSpicy: dish['isSpicy'],
                      foodType: dish['foodType'],
                      index: index,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to the menu tab
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.orange,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
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

// Desktop Dishes Section
  Widget buildDishesSectionDesktop(BuildContext context) {
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
            children: randomDishes!.map((dish) {
              int index = randomDishes!.indexOf(dish);
              return SlideItem(
                img: dish['img'],
                title: dish['title'],
                description: dish['description'],
                pricing: dish['pricing'],
                ingredients: List<String>.from(dish['ingredients']),
                isSpicy: dish['isSpicy'],
                foodType: dish['foodType'],
                index: index,
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to the menu tab
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.orange,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
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

  Future<void> _sendWhatsAppHello() async {
    const String phoneNumber = '+18493590832';
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
        const SnackBar(content: Text('No pude abrir WhatsApp')),
      );
    }
  }

  // Contact Section
  Widget buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the container takes the full width
      color: ColorsPaletteRedonda.deepBrown1.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(
        vertical: 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Contáctanos',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Estamos aquí para ayudarte. Si tienes alguna pregunta o necesitas un servicio personalizado, no dudes en contactarnos.',
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
            onPressed: () async {
              // Navigate to contact form or open email client
              await _sendWhatsAppHello();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPaletteRedonda.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
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

  // Footer
  Widget buildFooter(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the container takes the full width
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
              Text(
                '|',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorsPaletteRedonda.white,
                    ),
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
