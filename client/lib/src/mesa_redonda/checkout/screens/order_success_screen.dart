import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderType;

  const OrderSuccessScreen({
    super.key,
    required this.orderType,
  });

  String _getSuccessMessage() {
    switch (orderType) {
      case 'quote':
        return '¡Cotización enviada con éxito!';
      case 'catering':
        return '¡Orden de catering procesada con éxito!';
      case 'subscriptions':
        return '¡Suscripción procesada con éxito!';
      default:
        return '¡Orden procesada con éxito!';
    }
  }

  String _getDetailMessage() {
    switch (orderType) {
      case 'quote':
        return 'Te contactaremos pronto con los detalles de tu cotización.';
      case 'catering':
        return 'Te contactaremos pronto para confirmar los detalles de tu orden de catering.';
      case 'subscriptions':
        return 'Tu suscripción ha sido activada. ¡Disfruta de tus comidas!';
      default:
        return 'Tu orden está siendo procesada. ¡Gracias por tu compra!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: ColorsPaletteRedonda.primary,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                _getSuccessMessage(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getDetailMessage(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}