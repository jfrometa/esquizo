import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

// Print Service
class PrintService {
  Future<void> printOrder(Order order) async {
    // This would integrate with a printing service
    await Future.delayed(const Duration(seconds: 1));
    // print('Order ${order.id} sent to printer');
  }
}

final printServiceProvider = Provider<PrintService>((ref) {
  return PrintService();
});
