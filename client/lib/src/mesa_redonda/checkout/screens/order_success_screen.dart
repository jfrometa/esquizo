import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class OrderSuccessScreen extends StatefulWidget {
  final String orderType;

  const OrderSuccessScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showSecondaryContent = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation and show secondary content after a delay
    _animationController.forward();
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showSecondaryContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getSuccessMessage() {
    switch (widget.orderType) {
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
    switch (widget.orderType) {
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

  String _getActionText() {
    switch (widget.orderType) {
      case 'quote':
        return 'Volver al Inicio';
      case 'subscriptions':
        return 'Explorar Más Planes';
      default:
        return 'Seguir Comprando';
    }
  }

  IconData _getSuccessIcon() {
    switch (widget.orderType) {
      case 'quote':
        return Icons.request_quote_outlined;
      case 'catering':
        return Icons.dining_outlined;
      case 'subscriptions':
        return Icons.calendar_month_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorsPaletteRedonda.primary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessAnimation(),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        _getSuccessMessage(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorsPaletteRedonda.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _showSecondaryContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _getDetailMessage(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: _showSecondaryContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: _buildActionButtons(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: ColorsPaletteRedonda.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background pulse animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Container(
                  width: 140 + (20 * value),
                  height: 140 + (20 * value),
                  decoration: BoxDecoration(
                    color: ColorsPaletteRedonda.primary.withOpacity(0.1 * (1 - value)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            
            // Main icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorsPaletteRedonda.primary.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _showSecondaryContent
                      ? Icon(
                          _getSuccessIcon(),
                          color: ColorsPaletteRedonda.primary,
                          size: 54,
                          key: ValueKey(_getSuccessIcon()),
                        )
                      : const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsPaletteRedonda.primary),
                          strokeWidth: 3,
                          key: ValueKey("loader"),
                        ),
                ),
              ),
            ),
            
            // Success checkmark overlay
            if (_showSecondaryContent)
              Positioned(
                right: 15,
                bottom: 15,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorsPaletteRedonda.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => GoRouter.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsPaletteRedonda.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            _getActionText(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Navigate to order tracking or account page
            // For now, just pop back
            GoRouter.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: ColorsPaletteRedonda.primary,
          ),
          child: const Text(
            'Ver Mis Pedidos',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}