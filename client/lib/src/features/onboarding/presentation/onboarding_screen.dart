import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/presentation/onboarding_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'onboarding_1.svg',
      'title': 'Elige tu plato, plan de subscripcion o catering',
      'body':
          'Inicia la eligiendo el servicio que prefieres.'
    },
    {
      'image': 'onboarding_2.svg',
      'title': 'Selecciona de Nuestro Menú',
      'body':
          'Elige tus platos favoritos y envíanos tu ubicación y detalles para la entrega.'
    },
    {
      'image': 'onboarding_3.svg',
      'title': 'Confirma tu Pedido y Disfruta',
      'body':
          'Recibe tu cotización, realiza el pago. Selecciona tu día de inicio.\n\n¡Buen Provecho!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        actions: [
          TextButton(
             style: TextButton.styleFrom(
            elevation: 3,
          ),
            onPressed: () {
              _completeOnboarding(ref);
            },
            child: const Text(
              'Saltar',
              style: TextStyle(color: ColorsPaletteRedonda.primary),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPageContent(
                image: _pages[index]['image']!,
                title: _pages[index]['title']!,
                body: _pages[index]['body']!,
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage != _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _completeOnboarding(ref);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(
                _currentPage != _pages.length - 1 ? 'Siguiente' : 'Comenzar',
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({
    required String image,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
          image, // Path to your SVG file
          width: 300,  // Set width and height as needed
          height: 300,
          semanticsLabel: 'Your SVG Image',
        ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color.fromARGB(255, 202, 91, 17),
                ),
            textAlign: TextAlign.center,
            
          ),
        ],
      ),
    );
  }

  void _completeOnboarding(WidgetRef ref) async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (context.mounted) {
      context.goNamed(AppRoute.signIn.name);
    }
  }
}
