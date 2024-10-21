import 'package:firebase_analytics/firebase_analytics.dart';

enum AnalyticsEventType {
  PRODUCT,
  CTA,
  ORDER,
  CUSTOM,
  CATERING_ORDER,
  CUSTOMER_SATISFACTION,
  PREPARATION_TIME,
  DELIVERY_TIME,
  DISH_ORDER,
  MEAL_SUBSCRIPTION,
}

class AnalyticsLogger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log Product-related analytics
  static Future<void> logProductEvent({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    int quantity = 1,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'product_event',
        parameters: {
          'product_id': productId,
          'product_name': productName,
          'price': price,
          'currency': currency,
          'quantity': quantity,
        },
      );
    } catch (e) {
      throw Exception("Failed to log product event: $e");
    }
  }

  // Log CTA-related analytics
  static Future<void> logCTAEvent({
    required String ctaLabel,
    required String screenName,
    String? additionalInfo,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cta_event',
        parameters: {
          'cta_label': ctaLabel,
          'screen_name': screenName,
          'additional_info': additionalInfo ?? 'no aditional info',
        },
      );
    } catch (e) {
      throw Exception("Failed to log CTA event: $e");
    }
  }

  // Log Order-related analytics
  static Future<void> logOrderEvent({
    required String orderId,
    required double orderValue,
    required String currency,
    required String status,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'order_event',
        parameters: {
          'order_id': orderId,
          'order_value': orderValue,
          'currency': currency,
          'status': status,
        },
      );
    } catch (e) {
      throw Exception("Failed to log order event: $e");
    }
  }

  // Log Catering Order-related analytics with an array of catering items
  static Future<void> logCateringOrder({
    required String cateringId,
    required int numberOfPeople,
    required double orderValue,
    required String currency,
    required String menuType,
    required DateTime deliveryTime,
    required List<Map<String, Object?>> cateringItems,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'catering_order_event',
        parameters: {
          'catering_id': cateringId,
          'number_of_people': numberOfPeople,
          'order_value': orderValue,
          'currency': currency,
          'menu_type': menuType,
          'delivery_time': deliveryTime.toIso8601String(),
          'catering_items': cateringItems,
        },
      );
    } catch (e) {
      throw Exception("Failed to log catering order event: $e");
    }
  }

  // Log Customer Satisfaction-related analytics
  static Future<void> logCustomerSatisfaction({
    required String orderId,
    required int satisfactionRating, // e.g., rating out of 5
    String? additionalFeedback,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'customer_satisfaction_event',
        parameters: {
          'order_id': orderId,
          'satisfaction_rating': satisfactionRating,
          'additional_feedback': additionalFeedback ?? 'no aditional feedback',
        },
      );
    } catch (e) {
      throw Exception("Failed to log customer satisfaction event: $e");
    }
  }

  // Log Order Preparation Time-related analytics
  static Future<void> logPreparationTime({
    required String orderId,
    required Duration preparationTime,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'preparation_time_event',
        parameters: {
          'order_id': orderId,
          'preparation_time_seconds': preparationTime.inSeconds,
        },
      );
    } catch (e) {
      throw Exception("Failed to log preparation time event: $e");
    }
  }

  // Log Delivery Time-related analytics
  static Future<void> logDeliveryTime({
    required String orderId,
    required Duration deliveryTime,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'delivery_time_event',
        parameters: {
          'order_id': orderId,
          'delivery_time_seconds': deliveryTime.inSeconds,
        },
      );
    } catch (e) {
      throw Exception("Failed to log delivery time event: $e");
    }
  }

  // Log Dish Order with multiple dishes
  static Future<void> logDishOrder({
    required String orderId,
    required List<Map<String, Object?>> dishes, // List of dishes in the order
    required DateTime orderTime,
    String? specialInstructions,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'dish_order_event',
        parameters: {
          'order_id': orderId,
          'dishes': dishes, // List of dishes with details
          'order_time': orderTime.toIso8601String(),
          'special_instructions': specialInstructions ?? 'no special instructions', // Ensure specialInstructions is not null
        },
      );
    } catch (e) {
      throw Exception("Failed to log dish order event: $e");
    }
  }

  // Log Meal Subscription with an array of dishes
  static Future<void> logMealSubscription({
    required String subscriptionId,
    required String planType, // e.g., Basic, Standard, Premium
    required int numberOfMeals,
    required double subscriptionValue,
    required String currency,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, Object?>> dishes, // List of dishes included in the subscription
  }) async {
    try {
      await _analytics.logEvent(
        name: 'meal_subscription_event',
        parameters: {
          'subscription_id': subscriptionId,
          'plan_type': planType,
          'number_of_meals': numberOfMeals,
          'subscription_value': subscriptionValue,
          'currency': currency,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'dishes': dishes, // List of dishes in the subscription
        },
      );
    } catch (e) {
      throw Exception("Failed to log meal subscription event: $e");
    }
  }

  // Generic method for custom events
  static Future<void> logCustomEvent({
    required String eventName,
    required Map<String, Object?> parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters as Map<String, Object>,
      );
    } catch (e) {
      throw Exception("Failed to log custom event: $e");
    }
  }
}