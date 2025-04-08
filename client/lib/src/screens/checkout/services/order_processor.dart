import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order_storage_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderProcessor {
  final WidgetRef ref;
  final BuildContext context;
  final String phoneNumber;

  // OrderProcessor(this.ref, this.context, {this.phoneNumber = '+18493590832'});
    OrderProcessor(this.ref, this.context, {this.phoneNumber = '+18099880275'});

  Future<void> processRegularOrder(
    List<CartItem> items,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
    String orderDetails,
  ) async {
    try {
    await _sendWhatsAppMessage(orderDetails, () => _clearRegularCart());

    await ref.read(orderStorageProvider).saveRegularOrder(
              items,
              contactInfo,
              paymentMethod,
              location,
              delivery,
            );

    } catch (error) {
      _showError(error);
    }
  }

  Future<void> processSubscriptionOrder(
    List<CartItem> items,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
    String orderDetails,
  ) async {
    try {
      await _sendWhatsAppMessage(orderDetails, () => _clearSubscriptionCart());
      await ref.read(orderStorageProvider).saveSubscription(
            items,
            contactInfo,
            paymentMethod,
            location,
            delivery,
          );
     
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> processCateringOrder(
    CateringOrderItem order,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
    String orderDetails,
  ) async {
    try {
      await _sendWhatsAppMessage(orderDetails, () => _clearCateringCart());
      await ref.read(orderStorageProvider).saveCateringOrder(
            order,
            contactInfo,
            paymentMethod,
            location,
            delivery,
          ); 
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> processQuoteOrder(
    CateringOrderItem quote,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
    String orderDetails,
  ) async {
    try {
      await _sendWhatsAppMessage(orderDetails, () => _clearCateringQuoteCart());
      await ref.read(orderStorageProvider).saveCateringOrder(
            quote,
            contactInfo,
            paymentMethod,
            location,
            delivery,
          );
      
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _sendWhatsAppMessage(
    String message,
    VoidCallback onSuccess,
  ) async {
    const String phoneNumber = '+18099880275';
    final String whatsappUrlMobile =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
    final String whatsappUrlWeb =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
// log('WhatsApp Web URL: $whatsappUrlWeb ');
    if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
      await launchUrl(Uri.parse(whatsappUrlMobile));
      // log('LAUCH mopbile: $whatsappUrlWeb \nMessage: $message');
      onSuccess();
    } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
      // log('LAUCH Web URL: $whatsappUrlWeb\nMessage: $message');
      await launchUrl(Uri.parse(whatsappUrlWeb));
      onSuccess();
    } else {
      // log('WhatsApp Web URL: $whatsappUrlWeb\nMessage: $message');
      _showError('No pude abrir WhatsApp');
    }
  }



  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearRegularCart() {
     ref.read(cartProvider.notifier).clearCart();
  }

  void _clearSubscriptionCart() {
    ref.read(mealOrderProvider.notifier).clearCart();
  }

  void _clearCateringCart() {
     ref.read(cateringOrderProvider.notifier).clearCateringOrder();
  }

    void _clearCateringQuoteCart() {
     ref.read(manualQuoteProvider.notifier).clearManualQuote();
  }

    void _pop() {
    // Check if the current route can be popped (i.e., there's a previous screen in the stack)
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context)
          .pop(); // Pop the checkout screen to return to the previous screen
    } else {
      // If there's no previous screen, directly navigate to the home screen
      GoRouter.of(context).goNamed(AppRoute.home.name);
    }
  }

 

}