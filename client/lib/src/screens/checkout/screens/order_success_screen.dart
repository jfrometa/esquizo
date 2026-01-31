import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.surface,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessAnimation(colorScheme),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        _getSuccessMessage(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: _showSecondaryContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: _buildActionButtons(context, colorScheme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(ColorScheme colorScheme) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Container(
                  width: 140 + (20 * value),
                  height: 140 + (20 * value),
                  decoration: BoxDecoration(
                    color: colorScheme.primary
                        .withValues(alpha: 0.1 * (1 - value)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
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
                          color: colorScheme.primary,
                          size: 54,
                          key: ValueKey(_getSuccessIcon()),
                        )
                      : CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          strokeWidth: 3,
                          key: const ValueKey("loader"),
                        ),
                ),
              ),
            ),
            if (_showSecondaryContent)
              Positioned(
                right: 15,
                bottom: 15,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        FilledButton(
          onPressed: () => GoRouter.of(context).pop(),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _getActionText(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => GoRouter.of(context).pop(),
          child: Text(
            'Ver Mis Pedidos',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
