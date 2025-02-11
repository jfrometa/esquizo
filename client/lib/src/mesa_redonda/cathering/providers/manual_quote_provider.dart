import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';

final manualQuoteProvider =
    StateNotifierProvider<ManualQuoteNotifier, CateringOrderItem?>((ref) {
  return ManualQuoteNotifier();
});

class ManualQuoteNotifier extends StateNotifier<CateringOrderItem?> {
  ManualQuoteNotifier()
      : super(
          CateringOrderItem(
            title: 'Quote',
            img: '',
            description: '',
            dishes: [],
            hasChef: false,
            alergias: '',
            eventType: '',
            preferencia: '',
            adicionales: '',
            peopleCount: 0,
          ),
        );

  void clearCateringQuote() {
    state = null;
  }

  void addManualItem(CateringDish dish) {
    state = state?.copyWith(dishes: [...state!.dishes, dish]);
  }

  void removeItem(int index) {
    final newDishes = List<CateringDish>.from(state!.dishes);
    newDishes.removeAt(index);
    
    if (newDishes.isEmpty) {
      clearCateringQuote();
    } else {
      state = state?.copyWith(dishes: newDishes);
    }
  }

  void updateQuoteDetails({
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? peopleCount,
  }) {
    state = state?.copyWith(
      hasChef: hasChef ?? state?.hasChef,
      alergias: alergias ?? state?.alergias,
      eventType: eventType ?? state?.eventType,
      preferencia: preferencia ?? state?.preferencia,
      adicionales: adicionales ?? state?.adicionales,
      peopleCount: peopleCount ?? state?.peopleCount,
    );
  }
}