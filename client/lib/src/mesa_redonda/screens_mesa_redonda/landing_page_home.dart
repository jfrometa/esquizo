import 'package:flutter/material.dart';

class ResponsiveLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return buildMobileView(context);
          } else {
            return buildDesktopView(context);
          }
        },
      ),
    );
  }

  // Mobile view (450px and below)
  Widget buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildHeroSection(context),
          buildPerksSectionMobile(),
          buildPlansSectionMobile(),
          buildContactSection(),
          buildFooter(),
        ],
      ),
    );
  }

  // Desktop view (451px and above)
  Widget buildDesktopView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildHeroSection(context),
          buildPerksSectionDesktop(),
          buildPlansSectionDesktop(),
          buildContactSection(),
          buildFooter(),
        ],
      ),
    );
  }

  // Hero Section (same for both mobile and desktop)
  Widget buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/hero_background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡Bienvenido a Tu Cocina Favorita!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Deliciosas comidas entregadas en tu puerta. ¡Servicio de catering y almuerzo disponible!',
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Iniciar Servicio', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // Mobile Perks Section with Horizontal Scrolling and Consistent Card Sizes
  Widget buildPerksSectionMobile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Text(
            '¿Por qué Elegirnos?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildPerkCard('Ingredientes Frescos', 'Solo utilizamos ingredientes frescos y orgánicos.'),
                buildPerkCard('Entrega Rápida', 'Recibe tus comidas en menos de 30 minutos.'),
                buildPerkCard('Planes Personalizados', 'Planes de catering y almuerzo a medida.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Perks Section with Consistent Card Sizes
  Widget buildPerksSectionDesktop() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          const Text(
            '¿Por qué Elegirnos?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildPerkCard('Ingredientes Frescos', 'Solo utilizamos ingredientes frescos y orgánicos.'),
              buildPerkCard('Entrega Rápida', 'Recibe tus comidas en menos de 30 minutos.'),
              buildPerkCard('Planes Personalizados', 'Planes de catering y almuerzo a medida.'),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile Plans Section with Horizontal Scrolling and Consistent Card Sizes
  Widget buildPlansSectionMobile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Text(
            'Nuestros Planes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildPlanCard('Plan Básico', 'Entregas semanales de comidas.', '\$49/semana'),
                buildPlanCard('Plan de Catering', 'Catering a medida para eventos.', '\$299/evento'),
                buildPlanCard('Plan Premium', 'Comidas exclusivas y entrega prioritaria.', '\$99/semana'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Plans Section with Consistent Card Sizes
  Widget buildPlansSectionDesktop() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          const Text(
            'Nuestros Planes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildPlanCard('Plan Básico', 'Entregas semanales de comidas.', '\$49/semana'),
              buildPlanCard('Plan de Catering', 'Catering a medida para eventos.', '\$299/evento'),
              buildPlanCard('Plan Premium', 'Comidas exclusivas y entrega prioritaria.', '\$99/semana'),
            ],
          ),
        ],
      ),
    );
  }

  // Perks and Plans card reusable method with consistent sizes
  Widget buildPerkCard(String title, String description) {
    return Container(
      width: 300, // Fixed width for consistency
      height: 220, // Fixed height for consistency
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // iOS guidelines for rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Icon(Icons.check_circle, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlanCard(String planName, String description, String price) {
    return Container(
      width: 300, // Fixed width for consistency
      height: 260, // Fixed height for consistency
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // iOS guidelines for rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(planName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description),
              const SizedBox(height: 10),
              Text(price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Seleccionar Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Contact Section (same for both views)
  Widget buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Contáctanos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Email: contacto@tucocina.com'),
          const Text('Teléfono: +1 234 567 890'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Envíanos un Mensaje'),
          ),
        ],
      ),
    );
  }

  // Footer (same for both views)
  Widget buildFooter() {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('© 2024 Tu Cocina Digital', style: TextStyle(color: Colors.white)),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Política de Privacidad', style: TextStyle(color: Colors.white))),
              TextButton(onPressed: () {}, child: const Text('Términos del Servicio', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}