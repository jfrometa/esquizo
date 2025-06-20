import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

/// Provider for managing payment processing
class PaymentProcessor extends StateNotifier<AsyncValue<Payment?>> {
  final Ref ref;

  PaymentProcessor(this.ref) : super(const AsyncValue.data(null));

  /// Process a payment for an order
  Future<void> processOrderPayment({
    required Order order,
    required PaymentMethod method,
    List<String>? couponCodes,
    double? tipAmount,
    PaymentProof? proof,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // Create payment
      var payment = await paymentService.createPayment(
        order: order,
        method: method,
        appliedCouponCodes: couponCodes,
        tipAmount: tipAmount,
      );

      // Process payment
      if (proof != null) {
        payment = await paymentService.processPayment(
          paymentId: payment.id,
          proof: proof,
        );
      }

      // Auto-complete for cash payments
      if (method == PaymentMethod.cash) {
        payment = await paymentService.completePayment(payment.id);
      }

      state = AsyncValue.data(payment);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add payment proof to existing payment
  Future<void> addProof({
    required String paymentId,
    required PaymentProof proof,
  }) async {
    try {
      final paymentService = ref.read(paymentServiceProvider);
      await paymentService.addPaymentProof(
        paymentId: paymentId,
        proof: proof,
      );

      // Refresh payment
      final updatedPayment =
          await paymentService.getPaymentByOrderId(paymentId);
      state = AsyncValue.data(updatedPayment);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final paymentProcessorProvider =
    StateNotifierProvider<PaymentProcessor, AsyncValue<Payment?>>((ref) {
  return PaymentProcessor(ref);
});

/// Provider for managing reimbursements
class ReimbursementManager
    extends StateNotifier<AsyncValue<List<Reimbursement>>> {
  final Ref ref;

  ReimbursementManager(this.ref) : super(const AsyncValue.data([]));

  /// Request a new reimbursement
  Future<void> requestReimbursement({
    required String paymentId,
    required String orderId,
    required String userId,
    required double amount,
    required String reason,
    List<String>? itemIds,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final reimbursement = await paymentService.requestReimbursement(
        paymentId: paymentId,
        orderId: orderId,
        userId: userId,
        amount: amount,
        reason: reason,
        itemIds: itemIds,
      );

      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, reimbursement]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Process a reimbursement request
  Future<void> processReimbursement({
    required String reimbursementId,
    required bool approved,
    required String processedBy,
    String? notes,
  }) async {
    try {
      final paymentService = ref.read(paymentServiceProvider);
      final updatedReimbursement = await paymentService.processReimbursement(
        reimbursementId: reimbursementId,
        approved: approved,
        processedBy: processedBy,
        notes: notes,
      );

      final currentList = state.value ?? [];
      final updatedList = currentList.map((r) {
        return r.id == reimbursementId ? updatedReimbursement : r;
      }).toList();

      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final reimbursementManagerProvider = StateNotifierProvider<ReimbursementManager,
    AsyncValue<List<Reimbursement>>>((ref) {
  return ReimbursementManager(ref);
});

/// Provider for coupon validation
class CouponValidator extends StateNotifier<AsyncValue<Discount?>> {
  final Ref ref;

  CouponValidator(this.ref) : super(const AsyncValue.data(null));

  /// Validate a coupon code
  Future<void> validateCoupon(String code, Order order) async {
    state = const AsyncValue.loading();

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final discount = await paymentService.validateCoupon(code, order);

      if (discount == null) {
        state =
            AsyncValue.error('Invalid or expired coupon', StackTrace.current);
      } else {
        state = AsyncValue.data(discount);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Clear validated coupon
  void clear() {
    state = const AsyncValue.data(null);
  }
}

final couponValidatorProvider =
    StateNotifierProvider<CouponValidator, AsyncValue<Discount?>>((ref) {
  return CouponValidator(ref);
});

/// Provider for managing applied discounts
class AppliedDiscounts extends StateNotifier<List<Discount>> {
  AppliedDiscounts() : super([]);

  /// Add a discount
  void addDiscount(Discount discount) {
    // Check if discount is already applied
    if (!state.any((d) => d.id == discount.id)) {
      state = [...state, discount];
    }
  }

  /// Remove a discount
  void removeDiscount(String discountId) {
    state = state.where((d) => d.id != discountId).toList();
  }

  /// Clear all discounts
  void clear() {
    state = [];
  }

  /// Calculate total discount amount
  double get totalDiscountAmount {
    return state.fold(0, (sum, discount) => sum + discount.amountApplied);
  }
}

final appliedDiscountsProvider =
    StateNotifierProvider<AppliedDiscounts, List<Discount>>((ref) {
  return AppliedDiscounts();
});

/// Payment statistics provider
final paymentStatisticsProvider = FutureProvider.family<Map<String, dynamic>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentStatistics(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Service statistics provider
final serviceStatisticsProvider = FutureProvider.family<Map<String, dynamic>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getServiceStatistics(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for pending reimbursements
final pendingReimbursementsProvider = StreamProvider<List<Reimbursement>>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPendingReimbursementsStream();
});

/// Provider for tax configurations
final taxConfigurationsProvider = StreamProvider<List<TaxConfiguration>>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getActiveTaxConfigurations().asStream();
});

/// Provider for staff tip distributions
final staffTipDistributionsProvider = FutureProvider.family<List<TipDistribution>, 
    ({String staffId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getTipDistributions(
    staffId: params.staffId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for daily service summary
final dailyServiceSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getDailyServiceSummary();
});

/// Provider for payment by order ID
final paymentByOrderIdProvider = FutureProvider.family<Payment?, String>((ref, orderId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentByOrderId(orderId);
});

/// Provider for active tables (mock for now)
final activeTablesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // TODO: Implement actual active tables stream from order service
  return Stream.value([
    {
      'number': '1',
      'serverName': 'John Doe',
      'orderAmount': 45.50,
      'duration': 25,
      'status': 'eating',
    },
    {
      'number': '3',
      'serverName': 'Jane Smith',
      'orderAmount': 78.00,
      'duration': 15,
      'status': 'ordering',
    },
    {
      'number': '5',
      'serverName': 'Mike Johnson',
      'orderAmount': 120.25,
      'duration': 45,
      'status': 'payment',
    },
  ]);
});
      .snapshots()
      .map((doc) => doc.exists 
          ? ServiceTracking.fromJson(doc.data() as Map<String, dynamic>)
          : null);
});

/// Provider for tip distributions by staff
final staffTipDistributionsProvider = FutureProvider.family<List<TipDistribution>, 
    ({String staffId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getTipDistributions(
    startDate: params.startDate,
    endDate: params.endDate,
    staffId: params.staffId,
  );
});

/// Provider for managing tip distribution
class TipDistributionManager extends StateNotifier<AsyncValue<TipDistribution?>> {
  final Ref ref;
  
  TipDistributionManager(this.ref) : super(const AsyncValue.data(null));

  /// Calculate and distribute tips
  Future<void> distributeTips({
    required String paymentId,
    required String orderId,
    required double totalTipAmount,
    required DistributionMethod method,
    Map<String, double>? customPercentages,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final paymentService = ref.read(paymentServiceProvider);
      
      // Get service tracking to determine staff involved
      final serviceTracking = await paymentService._serviceTrackingCollection
          .doc(orderId)
          .get();
      
      if (!serviceTracking.exists) {
        throw Exception('Service tracking not found for order');
      }
      
      final tracking = ServiceTracking.fromJson(
          serviceTracking.data() as Map<String, dynamic>);
      
      // Calculate percentages based on method
      Map<String, double> percentages = {};
      Map<String, StaffRole> roles = {};
      
      if (method == DistributionMethod.manual && customPercentages != null) {
        percentages = customPercentages;
      } else if (method == DistributionMethod.equalSplit) {
        final staffCount = tracking.staffContributions.length;
        tracking.staffContributions.forEach((staffId, contribution) {
          percentages[staffId] = 100.0 / staffCount;
          roles[staffId] = contribution.role;
        });
      } else if (method == DistributionMethod.roleBased) {
        // Define role-based percentages
        const rolePercentages = {
          StaffRole.waiter: 50.0,
          StaffRole.cook: 30.0,
          StaffRole.busser: 10.0,
          StaffRole.host: 10.0,
        };
        
        double totalPercentage = 0;
        tracking.staffContributions.forEach((staffId, contribution) {
          final rolePercentage = rolePercentages[contribution.role] ?? 0;
          percentages[staffId] = rolePercentage;
          roles[staffId] = contribution.role;
          totalPercentage += rolePercentage;
        });
        
        // Normalize to 100%
        if (totalPercentage > 0) {
          percentages.updateAll((key, value) => value * 100 / totalPercentage);
        }
      }
      
      final distribution = await paymentService.distributeTips(
        paymentId: paymentId,
        orderId: orderId,
        totalTipAmount: totalTipAmount,
        method: method,
        staffPercentages: percentages,
        staffRoles: roles,
      );
      
      state = AsyncValue.data(distribution);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tipDistributionManagerProvider = 
    StateNotifierProvider<TipDistributionManager, AsyncValue<TipDistribution?>>((ref) {
  return TipDistributionManager(ref);
});

/// Provider for daily service summary
final dailyServiceSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  final stats = await ref.watch(serviceStatisticsProvider((
    startDate: startOfDay,
    endDate: endOfDay,
  )).future);
  
  return stats;
});

/// Provider for server performance metrics
final serverPerformanceProvider = FutureProvider.family<Map<String, dynamic>, 
    ({String serverId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  
  // Get all payments for this server
  final payments = await paymentService._paymentsCollection
      .where('serverId', isEqualTo: params.serverId)
      .where('createdAt', isGreaterThanOrEqualTo: params.startDate)
      .where('createdAt', isLessThanOrEqualTo: params.endDate)
      .get();
  
  double totalRevenue = 0;
  double totalTips = 0;
  int orderCount = 0;
  Map<String, int> serviceTypeCounts = {};
  
  for (final doc in payments.docs) {
    final payment = Payment.fromJson(doc.data() as Map<String, dynamic>);
    totalRevenue += payment.finalAmount;
    totalTips += payment.tipAmount;
    orderCount++;
    
    final serviceType = payment.serviceType?.name ?? 'unknown';
    serviceTypeCounts[serviceType] = (serviceTypeCounts[serviceType] ?? 0) + 1;
  }
  
  // Get tip distributions
  final tipDists = await ref.watch(staffTipDistributionsProvider((
    staffId: params.serverId,
    startDate: params.startDate,
    endDate: params.endDate,
  )).future);
  
  double totalTipReceived = 0;
  for (final dist in tipDists) {
    final allocation = dist.allocations.firstWhere(
      (a) => a.staffId == params.serverId,
      orElse: () => StaffTipAllocation(
        staffId: params.serverId,
        staffName: '',
        role: StaffRole.waiter,
        amount: 0,
        percentage: 0,
      ),
    );
    totalTipReceived += allocation.amount;
  }
  
  return {
    'totalRevenue': totalRevenue,
    'totalTips': totalTips,
    'totalTipReceived': totalTipReceived,
    'orderCount': orderCount,
    'averageOrderValue': orderCount > 0 ? totalRevenue / orderCount : 0,
    'averageTipPerOrder': orderCount > 0 ? totalTips / orderCount : 0,
    'serviceTypeCounts': serviceTypeCounts,
  };
});
