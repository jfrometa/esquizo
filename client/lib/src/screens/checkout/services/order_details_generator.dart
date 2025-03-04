import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

class OrderDetailsGenerator {
  final double taxRate;
  final int deliveryFee;
  final List<String> paymentMethods;
  final int selectedPaymentMethod;

  OrderDetailsGenerator({
    required this.taxRate,
    required this.deliveryFee,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
  });

  String _generateContactInfo(Map<String, String>? contactInfo) {
    if (contactInfo == null || contactInfo.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('*Información de Contacto*:');
    if (contactInfo['name']?.isNotEmpty ?? false) {
      buffer.writeln('Nombre: ${contactInfo['name']}');
    }
    if (contactInfo['phone']?.isNotEmpty ?? false) {
      buffer.writeln('Teléfono: ${contactInfo['phone']}');
    }
    if (contactInfo['email']?.isNotEmpty ?? false) {
      buffer.writeln('Email: ${contactInfo['email']}');
    }
    return buffer.toString();
  }

  String _generateTotals(double total) {
    final tax = total * taxRate;
    final grandTotal = total + tax + deliveryFee;

    return '''
*Método de Pago*: ${paymentMethods[selectedPaymentMethod]}
*Totales*:
Envío: RD \$$deliveryFee
Impuestos: RD \$${tax.toStringAsFixed(2)}
Total: RD \$${grandTotal.toStringAsFixed(2)}
''';
  }

  String _generateGoogleMapsLink(String latitude, String longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  String generateRegularOrder({
    required List<CartItem> items,
    required Map<String, String>? contactInfo,
    required String address,
    required String latitude,
    required String longitude,
    required String date,
    required String time,
  }) {
    final buffer = StringBuffer();
    double total = 0.0;
    String itemsBuffer = '';

    buffer.writeln('*Detalles de la Orden*:');
    buffer.writeln(_generateContactInfo(contactInfo));

    for (var item in items) {
      final price = double.tryParse(item.pricing) ?? 0.0;
      total += price * item.quantity;
      itemsBuffer += '${item.quantity} x ${item.title} @ RD \$$price each\n';
    }

    if (itemsBuffer.isNotEmpty) {
      buffer.writeln('''
*Platos Regulares*:
Ubicación: ${address}
Google Maps: ${_generateGoogleMapsLink(latitude, longitude)}
Fecha y Hora de Entrega: $date - $time
$itemsBuffer
''');
    }

    buffer.writeln(_generateTotals(total));
    return buffer.toString();
  }

  String generateSubscriptionOrder({
    required List<CartItem> items,
    required Map<String, String>? contactInfo,
    required String address,
    required String latitude,
    required String longitude,
    required String date,
    required String time,
  }) {
    final buffer = StringBuffer();
    double total = 0.0;
    String itemsBuffer = '';

    buffer.writeln('*Detalles de la Orden de Suscripción*:');
    buffer.writeln(_generateContactInfo(contactInfo));

    for (var item in items) {
      final price = double.tryParse(item.pricing) ?? 0.0;
      total += price * item.quantity;
      itemsBuffer += '${item.quantity} x ${item.title} @ RD \$$price each\n';
    }

    if (itemsBuffer.isNotEmpty) {
      buffer.writeln('''
*Suscripciones de Comidas*:
Ubicación: $address
Google Maps: ${_generateGoogleMapsLink(latitude, longitude)}
Fecha: $date
Hora: $time
$itemsBuffer
''');
    }

    buffer.writeln(_generateTotals(total));
    return buffer.toString();
  }

  String generateCateringOrder({
    required CateringOrderItem order,
    required Map<String, String>? contactInfo,
    required String address,
    required String latitude,
    required String longitude,
    required String date,
    required String time,
    bool isQuote = false,
  }) {
    final buffer = StringBuffer();
    String itemsBuffer = '';
    double total = 0.0;

    buffer.writeln(isQuote 
      ? '*Detalles de la Cotización de Catering*:'
      : '*Detalles de la Orden de Catering*:');
    buffer.writeln(_generateContactInfo(contactInfo));

    for (var dish in order.dishes) {
      final title = dish.title ?? 'Unknown Dish';
      final quantity = dish.quantity ?? 0;
      final price = dish.pricing ?? 0.0;
      total += price * quantity;
      itemsBuffer += '$quantity x $title @ RD \$$price each\n';
    }

    if (itemsBuffer.isNotEmpty) {
      buffer.writeln('''
*${isQuote ? 'Cotización' : 'Catering'}*:
Ubicación: $address
Google Maps: ${_generateGoogleMapsLink(latitude, longitude)}
Fecha: $date
Hora: $time
$itemsBuffer
''');
    }

    buffer.writeln(_generateTotals(total));
    return buffer.toString();
  }
}