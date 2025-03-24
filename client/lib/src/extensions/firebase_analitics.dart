import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive analytics service for tracking user behavior and app events
/// using Firebase Analytics with GA4 best practices.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  /// Singleton instance of the analytics service
  static AnalyticsService get instance => _instance;
  
  /// Firebase Analytics instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Debug mode flag
  bool _debugMode = false;

  /// Private constructor
  AnalyticsService._internal();
  
  /// Initialize the analytics service
  Future<void> init({bool debugMode = false}) async {
    _debugMode = debugMode;
    
    if (_debugMode) {
      // Enable debug logging in debug mode
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setSessionTimeoutDuration(const Duration(minutes: 30));
      
      if (!kIsWeb) {
        await _analytics.logAppOpen();
      }
      
      debugPrint('📊 AnalyticsService initialized in debug mode');
    }
  }
  
  /// Log debug message if debug mode is enabled
  void _logDebug(String message) {
    if (_debugMode) {
      debugPrint('📊 Analytics: $message');
    }
  }

  //===========================================================================
  // USER PROPERTIES
  //===========================================================================
  
  /// Set a user property
  /// 
  /// Use user properties to describe segments of your user base, such as
  /// language preference, membership status, or geographic location.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _logDebug('Set user property: $name = $value');
    } catch (e) {
      debugPrint('❌ Failed to set user property: $e');
    }
  }
  
  /// Set user ID
  /// 
  /// Sets the user ID property. This feature must be used in accordance with
  /// Google's Privacy Policy.
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logDebug('Set user ID: $userId');
    } catch (e) {
      debugPrint('❌ Failed to set user ID: $e');
    }
  }
  
  //===========================================================================
  // STANDARD E-COMMERCE EVENTS
  //===========================================================================
  
  /// Log when a user views an item
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required double price,
    String? currency = 'USD',
    String? itemCategory,
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics.logViewItem(
        currency: currency,
        value: price,
        items: items ?? [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
            price: price,
          ),
        ],
      );
      _logDebug('Logged view_item: $itemName');
    } catch (e) {
      debugPrint('❌ Failed to log view_item: $e');
    }
  }
  
  /// Log when a user views an item list
  Future<void> logViewItemList({
    required String listId,
    required String listName,
    required List<AnalyticsEventItem> items,
  }) async {
    try {
      await _analytics.logViewItemList(
        itemListId: listId,
        itemListName: listName,
        items: items,
      );
      _logDebug('Logged view_item_list: $listName');
    } catch (e) {
      debugPrint('❌ Failed to log view_item_list: $e');
    }
  }
  
  /// Log when a user selects an item from a list
  Future<void> logSelectItem({
    required String itemListId,
    required String itemListName,
    required List<AnalyticsEventItem> items,
  }) async {
    try {
      await _analytics.logSelectItem(
        itemListId: itemListId,
        itemListName: itemListName,
        items: items,
      );
      _logDebug('Logged select_item: from list $itemListName');
    } catch (e) {
      debugPrint('❌ Failed to log select_item: $e');
    }
  }
  
  /// Log when a user adds an item to their cart
  Future<void> logAddToCart({
    required List<AnalyticsEventItem> items,
    double? value,
    String? currency = 'USD',
  }) async {
    try {
      await _analytics.logAddToCart(
        items: items,
        value: value,
        currency: currency,
      );
      _logDebug('Logged add_to_cart: ${items.length} items');
    } catch (e) {
      debugPrint('❌ Failed to log add_to_cart: $e');
    }
  }
  
  /// Log when a user removes an item from their cart
  Future<void> logRemoveFromCart({
    required List<AnalyticsEventItem> items,
    double? value,
    String? currency = 'USD',
  }) async {
    try {
      await _analytics.logRemoveFromCart(
        items: items,
        value: value,
        currency: currency,
      );
      _logDebug('Logged remove_from_cart: ${items.length} items');
    } catch (e) {
      debugPrint('❌ Failed to log remove_from_cart: $e');
    }
  }
  
  /// Log when a user begins the checkout process
  Future<void> logBeginCheckout({
    required List<AnalyticsEventItem> items,
    double? value,
    String? currency = 'USD',
    String? coupon,
  }) async {
    try {
      await _analytics.logBeginCheckout(
        items: items,
        value: value,
        currency: currency,
        coupon: coupon,
      );
      _logDebug('Logged begin_checkout: \$${value?.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Failed to log begin_checkout: $e');
    }
  }
  
  /// Log when a user adds shipping info during checkout
  Future<void> logAddShippingInfo({
    required List<AnalyticsEventItem> items,
    String? coupon,
    double? value,
    String? currency = 'USD',
    String? shippingTier,
  }) async {
    try {
      await _analytics.logAddShippingInfo(
        items: items,
        coupon: coupon,
        value: value,
        currency: currency,
        shippingTier: shippingTier,
      );
      _logDebug('Logged add_shipping_info: $shippingTier');
    } catch (e) {
      debugPrint('❌ Failed to log add_shipping_info: $e');
    }
  }
  
  /// Log when a user adds payment information during checkout
  Future<void> logAddPaymentInfo({
    required List<AnalyticsEventItem> items,
    String? coupon,
    double? value,
    String? currency = 'USD',
    String? paymentType,
  }) async {
    try {
      await _analytics.logAddPaymentInfo(
        items: items,
        coupon: coupon,
        value: value,
        currency: currency,
        paymentType: paymentType,
      );
      _logDebug('Logged add_payment_info: $paymentType');
    } catch (e) {
      debugPrint('❌ Failed to log add_payment_info: $e');
    }
  }
  
  /// Log when a user makes a purchase
  Future<void> logPurchase({
    required String transactionId,
    required List<AnalyticsEventItem> items,
    required double value,
    String? currency = 'USD',
    String? coupon,
    double? tax,
    double? shipping,
  }) async {
    try {
      await _analytics.logPurchase(
        transactionId: transactionId,
        items: items,
        value: value,
        currency: currency,
        coupon: coupon,
        tax: tax,
        shipping: shipping,
      );
      _logDebug('Logged purchase: $transactionId \$${value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Failed to log purchase: $e');
    }
  }
  
  /// Log when a user requests a refund
  Future<void> logRefund({
    required String transactionId,
    required double value,
    String currency = 'USD',
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics.logRefund(
        transactionId: transactionId,
        value: value,
        currency: currency,
        items: items,
      );
      _logDebug('Logged refund: $transactionId \$${value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Failed to log refund: $e');
    }
  }
  
  //===========================================================================
  // RESTAURANT-SPECIFIC EVENTS
  //===========================================================================
  
  /// Log when a user views a menu
  Future<void> logViewMenu({
    required String menuId,
    required String menuName,
    String? restaurantId,
    String? restaurantName,
    String? menuCategory,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'view_menu',
        parameters: {
          'menu_id': menuId,
          'menu_name': menuName,
          if (restaurantId != null) 'restaurant_id': restaurantId,
          if (restaurantName != null) 'restaurant_name': restaurantName,
          if (menuCategory != null) 'menu_category': menuCategory,
        },
      );
      _logDebug('Logged view_menu: $menuName');
    } catch (e) {
      debugPrint('❌ Failed to log view_menu: $e');
    }
  }
  
  /// Log when a user places a food order
  Future<void> logOrderFood({
    required String orderId,
    required List<AnalyticsEventItem> items,
    required double value,
    String? currency = 'USD',
    String? restaurantId,
    String? restaurantName,
    String? deliveryMethod, // 'pickup', 'delivery', 'dine_in'
    DateTime? scheduledTime,
    String? coupon,
    String? specialInstructions,
  }) async {
    try {
      final parameters = {
        'order_id': orderId,
        'value': value,
        'currency': currency,
        'items': items.map((item) => item.asMap()).toList(),
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'delivery_method': deliveryMethod,
        'coupon': coupon,
        'special_instructions': specialInstructions,
      };
      
      if (scheduledTime != null) {
        parameters['scheduled_time'] = scheduledTime.toIso8601String();
      }
      
      await _analytics.logEvent(
        name: 'food_order',
        parameters: Map<String, Object>.from(parameters),
      );
      _logDebug('Logged food_order: $orderId \$${value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Failed to log food_order: $e');
    }
  }
  
  /// Log when a user rates their dining experience
  Future<void> logRateExperience({
    required String orderId,
    required int rating, // Typically 1-5
    required String experienceType, // 'food', 'service', 'delivery', 'overall'
    String? comment,
    String? restaurantId,
    String? restaurantName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'rate_experience',
        parameters: {
          'order_id': orderId,
          'rating': rating,
          'experience_type': experienceType,
          if (comment != null) 'comment': comment,
          if (restaurantId != null) 'restaurant_id': restaurantId,
          if (restaurantName != null) 'restaurant_name': restaurantName,
        },
      );
      _logDebug('Logged rate_experience: $experienceType rating $rating');
    } catch (e) {
      debugPrint('❌ Failed to log rate_experience: $e');
    }
  }
  
  /// Log when a user makes a reservation
  Future<void> logReservation({
    required String reservationId,
    required DateTime reservationTime,
    required int partySize,
    String? restaurantId,
    String? restaurantName,
    String? specialRequests,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'reservation',
        parameters: {
          'reservation_id': reservationId,
          'reservation_time': reservationTime.toIso8601String(),
          'party_size': partySize,
          if (restaurantId != null) 'restaurant_id': restaurantId,
          if (restaurantName != null) 'restaurant_name': restaurantName,
          if (specialRequests != null) 'special_requests': specialRequests,
        },
      );
      _logDebug('Logged reservation: $reservationId for $partySize people');
    } catch (e) {
      debugPrint('❌ Failed to log reservation: $e');
    }
  }
  
  /// Log when a user subscribes to a meal plan
  Future<void> logSubscribeMealPlan({
    required String subscriptionId,
    required String planType,
    required int numberOfMeals,
    required double value,
    String? currency = 'USD',
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includedCategories,
    List<AnalyticsEventItem>? sampleItems,
  }) async {
    try {
      final parameters = {
        'subscription_id': subscriptionId,
        'plan_type': planType,
        'number_of_meals': numberOfMeals,
        'value': value,
        'currency': currency,
      };
      
      if (startDate != null) {
        parameters['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        parameters['end_date'] = endDate.toIso8601String();
      }
      
      if (includedCategories != null) {
        parameters['included_categories'] = includedCategories;
      }
      
      if (sampleItems != null) {
        parameters['sample_items'] = sampleItems.map((item) => item.asMap()).toList();
      }
      
      await _analytics.logEvent(
        name: 'subscribe_meal_plan',
        parameters: Map<String, Object>.from(parameters),
      );
      _logDebug('Logged subscribe_meal_plan: $planType \$${value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Failed to log subscribe_meal_plan: $e');
    }
  }
  
  //===========================================================================
  // ENGAGEMENT EVENTS
  //===========================================================================
  
  /// Log when a user searches for something
  Future<void> logSearch({
    required String searchTerm,
    String? searchType,
    int? itemCount,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
      );
      _logDebug('Logged search: $searchTerm');
    } catch (e) {
      debugPrint('❌ Failed to log search: $e');
    }
  }
  
  /// Log when a user selects content
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
      _logDebug('Logged select_content: $contentType - $itemId');
    } catch (e) {
      debugPrint('❌ Failed to log select_content: $e');
    }
  }
  
  /// Log when a user shares content
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method ?? 'unknown',
      );
      _logDebug('Logged share: $contentType - $itemId via $method');
    } catch (e) {
      debugPrint('❌ Failed to log share: $e');
    }
  }
  
  /// Log when a user signs up
  Future<void> logSignUp({
    required String method,
  }) async {
    try {
      await _analytics.logSignUp(
        signUpMethod: method,
      );
      _logDebug('Logged sign_up: via $method');
    } catch (e) {
      debugPrint('❌ Failed to log sign_up: $e');
    }
  }
  
  /// Log when a user logs in
  Future<void> logLogin({
    required String method,
  }) async {
    try {
      await _analytics.logLogin(
        loginMethod: method,
      );
      _logDebug('Logged login: via $method');
    } catch (e) {
      debugPrint('❌ Failed to log login: $e');
    }
  }
  
  //===========================================================================
  // CUSTOM EVENTS
  //===========================================================================
  
  /// Log a custom CTA event
  Future<void> logCTAEvent({
    required String ctaLabel,
    required String screenName,
    String? ctaType,
    String? destination,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final parameters = {
        'cta_label': ctaLabel,
        'screen_name': screenName,
        'cta_type': ctaType,
        'destination': destination,
      };
      
      if (additionalParams != null) {
        parameters.addAll(Map<String, String?>.from(additionalParams));
      }
      
      await _analytics.logEvent(
        name: 'cta_tap',
        parameters: Map<String, Object>.from(parameters),
      );
      _logDebug('Logged cta_tap: $ctaLabel on $screenName');
    } catch (e) {
      debugPrint('❌ Failed to log cta_tap: $e');
    }
  }
  
  /// Log order status update
  Future<void> logOrderStatusUpdate({
    required String orderId,
    required String status, // 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'canceled'
    DateTime? timestamp,
    String? updatedBy,
    double? estimatedDeliveryTime, // In minutes
  }) async {
    try {
      final parameters = {
        'order_id': orderId,
        'status': status,
        'updated_by': updatedBy,
      };
      
      if (timestamp != null) {
        parameters['timestamp'] = timestamp.toIso8601String();
      }
      
      if (estimatedDeliveryTime != null) {
        parameters['estimated_delivery_time'] = estimatedDeliveryTime.toString();
      }
      
      await _analytics.logEvent(
        name: 'order_status_update',
        parameters: Map<String, Object>.from(parameters),
      );
      _logDebug('Logged order_status_update: $orderId to $status');
    } catch (e) {
      debugPrint('❌ Failed to log order_status_update: $e');
    }
  }
  
  /// Log any custom event
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters != null ? Map<String, Object>.from(parameters) : null,
      );
      _logDebug('Logged custom event: $eventName');
    } catch (e) {
      debugPrint('❌ Failed to log custom event: $e');
    }
  }
}

/// Extension to convert AnalyticsEventItem to Map for custom events
extension AnalyticsEventItemExtension on AnalyticsEventItem {
  Map<String, dynamic> asMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'item_category': itemCategory,
      'item_variant': itemVariant,
      'item_brand': itemBrand,
      'price': price,
      'quantity': quantity,
    };
  }
}