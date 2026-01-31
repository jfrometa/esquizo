import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkout_state_provider.g.dart';

class CheckoutState {
  final int currentStep;
  final int selectedPaymentMethod;
  final bool isProcessingOrder;

  // Location data
  final String? cateringAddress;
  final String? regularAddress;
  final String? mealSubscriptionAddress;

  final String? cateringLatitude;
  final String? cateringLongitude;
  final String? mealSubscriptionLatitude;
  final String? mealSubscriptionLongitude;
  final String? regularDishesLatitude;
  final String? regularDishesLongitude;

  // User data
  final String? name;
  final String? phone;
  final String? email;

  CheckoutState({
    this.currentStep = 0,
    this.selectedPaymentMethod = 0,
    this.isProcessingOrder = false,
    this.cateringAddress,
    this.regularAddress,
    this.mealSubscriptionAddress,
    this.cateringLatitude,
    this.cateringLongitude,
    this.mealSubscriptionLatitude,
    this.mealSubscriptionLongitude,
    this.regularDishesLatitude,
    this.regularDishesLongitude,
    this.name,
    this.phone,
    this.email,
  });

  CheckoutState copyWith({
    int? currentStep,
    int? selectedPaymentMethod,
    bool? isProcessingOrder,
    String? cateringAddress,
    String? regularAddress,
    String? mealSubscriptionAddress,
    String? cateringLatitude,
    String? cateringLongitude,
    String? mealSubscriptionLatitude,
    String? mealSubscriptionLongitude,
    String? regularDishesLatitude,
    String? regularDishesLongitude,
    String? name,
    String? phone,
    String? email,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isProcessingOrder: isProcessingOrder ?? this.isProcessingOrder,
      cateringAddress: cateringAddress ?? this.cateringAddress,
      regularAddress: regularAddress ?? this.regularAddress,
      mealSubscriptionAddress:
          mealSubscriptionAddress ?? this.mealSubscriptionAddress,
      cateringLatitude: cateringLatitude ?? this.cateringLatitude,
      cateringLongitude: cateringLongitude ?? this.cateringLongitude,
      mealSubscriptionLatitude:
          mealSubscriptionLatitude ?? this.mealSubscriptionLatitude,
      mealSubscriptionLongitude:
          mealSubscriptionLongitude ?? this.mealSubscriptionLongitude,
      regularDishesLatitude:
          regularDishesLatitude ?? this.regularDishesLatitude,
      regularDishesLongitude:
          regularDishesLongitude ?? this.regularDishesLongitude,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

@riverpod
class Checkout extends _$Checkout {
  @override
  CheckoutState build() {
    return CheckoutState();
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setPaymentMethod(int method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessingOrder: processing);
  }

  void updateLocation({
    String? type,
    required String address,
    required String latitude,
    required String longitude,
  }) {
    switch (type?.toLowerCase()) {
      case 'catering':
        state = state.copyWith(
          cateringAddress: address,
          cateringLatitude: latitude,
          cateringLongitude: longitude,
        );
        break;
      case 'regular':
        state = state.copyWith(
          regularAddress: address,
          regularDishesLatitude: latitude,
          regularDishesLongitude: longitude,
        );
        break;
      case 'mealsubscription':
        state = state.copyWith(
          mealSubscriptionAddress: address,
          mealSubscriptionLatitude: latitude,
          mealSubscriptionLongitude: longitude,
        );
        break;
    }
  }

  void updateUserData({String? name, String? phone, String? email}) {
    state = state.copyWith(
      name: name ?? state.name,
      phone: phone ?? state.phone,
      email: email ?? state.email,
    );
  }
}
