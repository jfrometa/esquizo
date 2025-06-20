import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:uuid/uuid.dart';

/// Unified payment service for handling all payment operations
class PaymentService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  final _uuid = const Uuid();

  PaymentService({
    FirebaseFirestore? firestore,
    required String businessId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _businessId = businessId;

  // Collection references
  CollectionReference get _paymentsCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('payments');

  CollectionReference get _couponsCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('coupons');

  CollectionReference get _specialOffersCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('special_offers');

  CollectionReference get _bundlesCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('bundles');

  CollectionReference get _reimbursementsCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('reimbursements');

  CollectionReference get _taxConfigCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('tax_configurations');

  CollectionReference get _serviceTrackingCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('service_tracking');

  CollectionReference get _tipDistributionsCollection => _firestore
      .collection('businesses')
      .doc(_businessId)
      .collection('tip_distributions');

  // ===== PAYMENT OPERATIONS =====

  /// Create a new payment for an order
  Future<Payment> createPayment({
    required Order order,
    required PaymentMethod method,
    List<String>? appliedCouponCodes,
    double? tipAmount,
    Map<String, dynamic>? metadata,
    ServiceType? serviceType,
    ServiceTracking? serviceTracking,
  }) async {
    try {
      // Calculate discounts
      final discounts = await _calculateDiscounts(order, appliedCouponCodes);
      final discountAmount = discounts.fold<double>(
        0,
        (sum, discount) => sum + discount.amountApplied,
      );

      // Calculate final amount
      final subtotal = order.subtotal ?? 0;
      final tax = order.tax ?? 0;
      final deliveryFee = order.deliveryFee ?? 0;
      final tip = tipAmount ?? order.tipAmount ?? 0;
      final finalAmount = subtotal + tax + deliveryFee + tip - discountAmount;

      // Get applicable taxes based on service type
      List<TaxConfiguration> applicableTaxes = [];
      double additionalTax = 0;

      if (serviceType != null) {
        applicableTaxes = await getApplicableTaxes(serviceType);
        for (final tax in applicableTaxes) {
          if (tax.type == TaxType.percentage) {
            additionalTax += subtotal * (tax.rate / 100);
          } else {
            additionalTax += tax.rate;
          }
        }
      }

      final payment = Payment(
        id: _uuid.v4(),
        orderId: order.id,
        userId: order.userId,
        status: PaymentStatus.pending,
        method: method,
        amount: order.total ?? finalAmount,
        subtotal: subtotal,
        taxAmount: tax + additionalTax,
        tipAmount: tip,
        deliveryFee: deliveryFee,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
        createdAt: DateTime.now(),
        customerName: order.customerName,
        customerEmail: order.email,
        customerPhone: order.userPhone,
        discounts: discounts,
        metadata: metadata,
        receiptNumber: _generateReceiptNumber(),
        serviceType: serviceType,
        serviceTracking: serviceTracking,
        serverId: serviceTracking?.serverId,
        serverName: serviceTracking?.serverName,
        appliedTaxes: applicableTaxes,
      );

      // Save to Firestore
      await _paymentsCollection.doc(payment.id).set(payment.toJson());

      // Update coupon usage
      for (final discount in discounts) {
        if (discount.type == DiscountType.coupon) {
          await _updateCouponUsage(discount.code);
        }
      }

      return payment;
    } catch (e) {
      debugPrint('Error creating payment: $e');
      rethrow;
    }
  }

  /// Process a payment
  Future<Payment> processPayment({
    required String paymentId,
    String? transactionId,
    PaymentProof? proof,
  }) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) throw Exception('Payment not found');

      final payment = Payment.fromJson(doc.data() as Map<String, dynamic>);

      final updatedProofs = [...payment.proofs];
      if (proof != null) {
        updatedProofs.add(proof);
      }

      final updatedPayment = payment.copyWith(
        status: PaymentStatus.processing,
        transactionId: transactionId,
        proofs: updatedProofs,
      );

      await _paymentsCollection.doc(paymentId).update(updatedPayment.toJson());
      return updatedPayment;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      rethrow;
    }
  }

  /// Complete a payment
  Future<Payment> completePayment(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) throw Exception('Payment not found');

      final payment = Payment.fromJson(doc.data() as Map<String, dynamic>);
      final updatedPayment = payment.copyWith(
        status: PaymentStatus.completed,
        completedAt: DateTime.now(),
      );

      await _paymentsCollection.doc(paymentId).update(updatedPayment.toJson());

      // Create payment summary for analytics
      await _updatePaymentSummary(updatedPayment);

      return updatedPayment;
    } catch (e) {
      debugPrint('Error completing payment: $e');
      rethrow;
    }
  }

  /// Add payment proof (e.g., bank transfer receipt)
  Future<void> addPaymentProof({
    required String paymentId,
    required PaymentProof proof,
  }) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'proofs': FieldValue.arrayUnion([proof.toJson()]),
      });
    } catch (e) {
      debugPrint('Error adding payment proof: $e');
      rethrow;
    }
  }

  // ===== REIMBURSEMENT OPERATIONS =====

  /// Request a reimbursement
  Future<Reimbursement> requestReimbursement({
    required String paymentId,
    required String orderId,
    required String userId,
    required double amount,
    required String reason,
    List<String>? itemIds,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final reimbursement = Reimbursement(
        id: _uuid.v4(),
        paymentId: paymentId,
        orderId: orderId,
        userId: userId,
        amount: amount,
        reason: reason,
        status: ReimbursementStatus.requested,
        requestedAt: DateTime.now(),
        itemIds: itemIds ?? [],
        metadata: metadata,
      );

      await _reimbursementsCollection
          .doc(reimbursement.id)
          .set(reimbursement.toJson());
      return reimbursement;
    } catch (e) {
      debugPrint('Error requesting reimbursement: $e');
      rethrow;
    }
  }

  /// Process a reimbursement
  Future<Reimbursement> processReimbursement({
    required String reimbursementId,
    required bool approved,
    required String processedBy,
    String? notes,
  }) async {
    try {
      final doc = await _reimbursementsCollection.doc(reimbursementId).get();
      if (!doc.exists) throw Exception('Reimbursement not found');

      final reimbursement =
          Reimbursement.fromJson(doc.data() as Map<String, dynamic>);

      final updatedReimbursement = reimbursement.copyWith(
        status: approved
            ? ReimbursementStatus.approved
            : ReimbursementStatus.rejected,
        approvedAt: approved ? DateTime.now() : null,
        approvedBy: approved ? processedBy : null,
        notes: notes,
      );

      await _reimbursementsCollection
          .doc(reimbursementId)
          .update(updatedReimbursement.toJson());

      // Update payment status if approved
      if (approved) {
        await _updatePaymentForReimbursement(
            reimbursement.paymentId, reimbursement.amount);
      }

      return updatedReimbursement;
    } catch (e) {
      debugPrint('Error processing reimbursement: $e');
      rethrow;
    }
  }

  // ===== DISCOUNT OPERATIONS =====

  /// Validate and apply a coupon
  Future<Discount?> validateCoupon(String code, Order order) async {
    try {
      final query = await _couponsCollection
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final coupon =
          Coupon.fromJson(query.docs.first.data() as Map<String, dynamic>);

      // Validate coupon
      final now = DateTime.now();
      if (now.isBefore(coupon.validFrom) || now.isAfter(coupon.validUntil)) {
        return null;
      }

      if (coupon.maxUses > 0 && coupon.currentUses >= coupon.maxUses) {
        return null;
      }

      if (coupon.minimumOrderAmount != null &&
          (order.subtotal ?? 0) < coupon.minimumOrderAmount!) {
        return null;
      }

      // Calculate discount amount
      double discountAmount = 0;
      if (coupon.type == DiscountType.percentage) {
        discountAmount = (order.subtotal ?? 0) * (coupon.value / 100);
        if (coupon.maximumDiscountAmount != null) {
          discountAmount =
              discountAmount.clamp(0, coupon.maximumDiscountAmount!);
        }
      } else {
        discountAmount = coupon.value;
      }

      return Discount(
        id: coupon.id,
        type: coupon.type,
        code: coupon.code,
        value: coupon.value,
        amountApplied: discountAmount,
        description: coupon.description,
      );
    } catch (e) {
      debugPrint('Error validating coupon: $e');
      return null;
    }
  }

  /// Get active special offers
  Stream<List<SpecialOffer>> getActiveSpecialOffers() {
    final now = DateTime.now();
    return _specialOffersCollection
        .where('isActive', isEqualTo: true)
        .where('validFrom', isLessThanOrEqualTo: now)
        .where('validUntil', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SpecialOffer.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  /// Get active bundles
  Stream<List<Bundle>> getActiveBundles() {
    final now = DateTime.now();
    return _bundlesCollection
        .where('isActive', isEqualTo: true)
        .where('validFrom', isLessThanOrEqualTo: now)
        .where('validUntil', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bundle.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  // ===== QUERY OPERATIONS =====

  /// Get payment by order ID
  Future<Payment?> getPaymentByOrderId(String orderId) async {
    try {
      final query = await _paymentsCollection
          .where('orderId', isEqualTo: orderId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return Payment.fromJson(query.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting payment by order ID: $e');
      return null;
    }
  }

  /// Get payments for a user
  Stream<List<Payment>> getUserPayments(String userId) {
    return _paymentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get payment summary for a date range
  Future<PaymentSummary?> getPaymentSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final payments = await _paymentsCollection
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .where('status', isEqualTo: PaymentStatus.completed.name)
          .get();

      if (payments.docs.isEmpty) return null;

      // Calculate summary
      double totalRevenue = 0;
      double totalDiscounts = 0;
      double totalReimbursements = 0;
      int totalTransactions = payments.docs.length;
      Map<String, double> revenueByMethod = {};
      Map<String, int> transactionsByMethod = {};
      Map<String, double> discountsByType = {};

      for (final doc in payments.docs) {
        final payment = Payment.fromJson(doc.data() as Map<String, dynamic>);

        totalRevenue += payment.finalAmount;
        totalDiscounts += payment.discountAmount;

        // Revenue by method
        final methodName = payment.method.name;
        revenueByMethod[methodName] =
            (revenueByMethod[methodName] ?? 0) + payment.finalAmount;
        transactionsByMethod[methodName] =
            (transactionsByMethod[methodName] ?? 0) + 1;

        // Discounts by type
        for (final discount in payment.appliedDiscounts) {
          final typeName = discount.type.name;
          discountsByType[typeName] =
              (discountsByType[typeName] ?? 0) + discount.amountApplied;
        }
      }

      // Get reimbursements
      final reimbursements = await _reimbursementsCollection
          .where('completedAt', isGreaterThanOrEqualTo: startDate)
          .where('completedAt', isLessThanOrEqualTo: endDate)
          .where('status', isEqualTo: ReimbursementStatus.completed.name)
          .get();

      for (final doc in reimbursements.docs) {
        final reimbursement =
            Reimbursement.fromJson(doc.data() as Map<String, dynamic>);
        totalReimbursements += reimbursement.amount;
      }

      return PaymentSummary(
        businessId: _businessId,
        date: DateTime.now(),
        totalRevenue: totalRevenue,
        totalDiscounts: totalDiscounts,
        totalReimbursements: totalReimbursements,
        netRevenue: totalRevenue - totalReimbursements,
        totalTransactions: totalTransactions,
        successfulTransactions: totalTransactions,
        failedTransactions: 0,
        revenueByMethod: revenueByMethod,
        transactionsByMethod: transactionsByMethod,
        discountsByType: discountsByType,
      );
    } catch (e) {
      debugPrint('Error getting payment summary: $e');
      return null;
    }
  }

  /// Get stream of pending reimbursements
  Stream<List<Reimbursement>> getPendingReimbursementsStream() {
    return _reimbursementsCollection
        .where('status', isEqualTo: ReimbursementStatus.requested.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Reimbursement.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ===== SERVICE TRACKING OPERATIONS =====

  /// Track service for an order
  Future<ServiceTracking> createServiceTracking({
    required Order order,
    required ServiceType serviceType,
    String? tableId,
    int? tableNumber,
    String? serverId,
    String? serverName,
  }) async {
    try {
      final tracking = ServiceTracking(
        orderId: order.id,
        serviceType: serviceType,
        tableId: tableId,
        tableNumber: tableNumber,
        serverId: serverId,
        serverName: serverName,
        serviceStartTime: DateTime.now(),
        events: [],
        staffContributions: {},
      );

      await _serviceTrackingCollection.doc(order.id).set(tracking.toJson());
      return tracking;
    } catch (e) {
      debugPrint('Error creating service tracking: $e');
      rethrow;
    }
  }

  /// Add service event
  Future<void> addServiceEvent({
    required String orderId,
    required String eventType,
    required String staffId,
    required String staffName,
    String? description,
    Map<String, dynamic>? data,
  }) async {
    try {
      final event = ServiceEvent(
        eventType: eventType,
        timestamp: DateTime.now(),
        staffId: staffId,
        staffName: staffName,
        description: description,
        data: data,
      );

      await _serviceTrackingCollection.doc(orderId).update({
        'events': FieldValue.arrayUnion([event.toJson()]),
      });
    } catch (e) {
      debugPrint('Error adding service event: $e');
      rethrow;
    }
  }

  /// Add or update staff contribution
  Future<void> updateStaffContribution({
    required String orderId,
    required String staffId,
    required String staffName,
    required StaffRole role,
    required double contributionPercentage,
    required List<String> tasks,
  }) async {
    try {
      final contribution = StaffContribution(
        staffId: staffId,
        staffName: staffName,
        role: role,
        contributionPercentage: contributionPercentage,
        tasks: tasks,
        startTime: DateTime.now(),
      );

      await _serviceTrackingCollection.doc(orderId).update({
        'staffContributions.$staffId': contribution.toJson(),
      });
    } catch (e) {
      debugPrint('Error updating staff contribution: $e');
      rethrow;
    }
  }

  // ===== TAX CONFIGURATION OPERATIONS =====

  /// Create tax configuration
  Future<TaxConfiguration> createTaxConfiguration({
    required String name,
    required double rate,
    required TaxType type,
    ServiceType? applicableServiceType,
    String? description,
    Map<String, dynamic>? conditions,
  }) async {
    try {
      final taxConfig = TaxConfiguration(
        id: _uuid.v4(),
        businessId: _businessId,
        name: name,
        rate: rate,
        type: type,
        applicableServiceType: applicableServiceType,
        validFrom: DateTime.now(),
        description: description,
        conditions: conditions,
      );

      await _taxConfigCollection.doc(taxConfig.id).set(taxConfig.toJson());
      return taxConfig;
    } catch (e) {
      debugPrint('Error creating tax configuration: $e');
      rethrow;
    }
  }

  /// Get applicable taxes for service type
  Future<List<TaxConfiguration>> getApplicableTaxes(ServiceType serviceType) async {
    try {
      final query = await _taxConfigCollection
          .where('isActive', isEqualTo: true)
          .where('applicableServiceType', whereIn: [serviceType.name, null])
          .get();

      final now = DateTime.now();
      return query.docs
          .map((doc) => TaxConfiguration.fromJson(doc.data() as Map<String, dynamic>))
          .where((tax) => 
              tax.validFrom.isBefore(now) && 
              (tax.validUntil == null || tax.validUntil!.isAfter(now)))
          .toList();
    } catch (e) {
      debugPrint('Error getting applicable taxes: $e');
      return [];
    }
  }

  // ===== TIP DISTRIBUTION OPERATIONS =====

  /// Distribute tips among staff
  Future<TipDistribution> distributeTips({
    required String paymentId,
    required String orderId,
    required double totalTipAmount,
    required DistributionMethod method,
    required Map<String, double> staffPercentages,
    required Map<String, StaffRole> staffRoles,
    String? notes,
  }) async {
    try {
      final allocations = <StaffTipAllocation>[];
      
      staffPercentages.forEach((staffId, percentage) {
        final amount = totalTipAmount * (percentage / 100);
        allocations.add(StaffTipAllocation(
          staffId: staffId,
          staffName: '', // This should be fetched from staff service
          role: staffRoles[staffId] ?? StaffRole.other,
          amount: amount,
          percentage: percentage,
        ));
      });

      final distribution = TipDistribution(
        id: _uuid.v4(),
        paymentId: paymentId,
        orderId: orderId,
        totalTipAmount: totalTipAmount,
        distributedAt: DateTime.now(),
        distributedBy: 'system', // This should be the current user
        allocations: allocations,
        method: method,
        notes: notes,
      );

      await _tipDistributionsCollection.doc(distribution.id).set(distribution.toJson());
      return distribution;
    } catch (e) {
      debugPrint('Error distributing tips: $e');
      rethrow;
    }
  }

  // Get service statistics
  Future<Map<String, dynamic>> getServiceStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all payments in date range
      final payments = await _paymentsCollection
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .where('status', isEqualTo: PaymentStatus.completed.name)
          .get();

      double dineInRevenue = 0;
      double takeoutRevenue = 0;
      double deliveryRevenue = 0;
      double totalTips = 0;
      double totalServiceCharges = 0;
      int dineInCount = 0;
      int takeoutCount = 0;
      int deliveryCount = 0;
      Map<String, double> serverRevenue = {};
      Map<String, int> serverOrderCount = {};

      for (final doc in payments.docs) {
        final payment = Payment.fromJson(doc.data() as Map<String, dynamic>);
        
        // Revenue by service type
        switch (payment.serviceType) {
          case ServiceType.dineIn:
            dineInRevenue += payment.finalAmount;
            dineInCount++;
            break;
          case ServiceType.takeout:
            takeoutRevenue += payment.finalAmount;
            takeoutCount++;
            break;
          case ServiceType.delivery:
            deliveryRevenue += payment.finalAmount;
            deliveryCount++;
            break;
          default:
            break;
        }

        // Tips and service charges
        totalTips += payment.tipAmount;
        totalServiceCharges += payment.serviceCharge ?? 0;

        // Server statistics
        if (payment.serverId != null) {
          serverRevenue[payment.serverId!] = 
              (serverRevenue[payment.serverId!] ?? 0) + payment.finalAmount;
          serverOrderCount[payment.serverId!] = 
              (serverOrderCount[payment.serverId!] ?? 0) + 1;
        }
      }

      // Get tip distributions
      final tipDistributions = await getTipDistributions(
        startDate: startDate,
        endDate: endDate,
      );

      Map<String, double> staffTipTotals = {};
      for (final dist in tipDistributions) {
        for (final alloc in dist.allocations) {
          staffTipTotals[alloc.staffId] = 
              (staffTipTotals[alloc.staffId] ?? 0) + alloc.amount;
        }
      }

      // Get service tracking data
      final serviceTracking = await _serviceTrackingCollection
          .where('isActive', isEqualTo: true)
          .where('startTime', isGreaterThanOrEqualTo: startDate)
          .where('startTime', isLessThanOrEqualTo: endDate)
          .get();

      int completedServices = 0;
      int totalServiceTime = 0;

      for (final doc in serviceTracking.docs) {
        final tracking = ServiceTracking.fromJson(doc.data() as Map<String, dynamic>);
        if (tracking.endTime != null) {
          completedServices++;
          totalServiceTime += tracking.endTime!.difference(tracking.startTime).inMinutes;
        }
      }

      return {
        'serviceTypeRevenue': {
          'dineIn': dineInRevenue,
          'takeout': takeoutRevenue,
          'delivery': deliveryRevenue,
        },
        'serviceTypeCounts': {
          'dineIn': dineInCount,
          'takeout': takeoutCount,
          'delivery': deliveryCount,
        },
        'serviceTypeCharges': {
          'totalTips': totalTips,
          'totalServiceCharges': totalServiceCharges,
        },
        'serverStatistics': {
          'revenue': serverRevenue,
          'orderCount': serverOrderCount,
          'tips': serverTips,
        },
        'totalTips': totalTips,
        'staffTipTotals': staffTipTotals,
        'averageServiceTime': completedServices > 0 ? totalServiceTime ~/ completedServices : 0,
        'totalTablesServed': serviceTracking.docs.length,
        'averageTableTurnover': completedServices > 0 ? serviceTracking.docs.length / completedServices : 0.0,
        'peakServiceHours': await _calculatePeakHours(serviceTracking.docs),
      };
    } catch (e) {
      debugPrint('Error getting service statistics: $e');
      return {};
    }
  }

  // Get tip distributions
  Future<List<TipDistribution>> getTipDistributions({
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
  }) async {
    Query<Map<String, dynamic>> query = _tipDistributionsCollection;
    
    if (startDate != null) {
      query = query.where('distributedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('distributedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    final querySnapshot = await query.get();
    
    var distributions = querySnapshot.docs
        .map((doc) => TipDistribution.fromJson(doc.data()))
        .toList();
    
    // Filter by staff if specified
    if (staffId != null && staffId.isNotEmpty) {
      distributions = distributions.where((dist) => 
        dist.allocations.any((alloc) => alloc.staffId == staffId)
      ).toList();
    }
    
    return distributions;
  }

  // Add staff contribution to service
  Future<void> addStaffContribution({
    required String orderId,
    required String staffId,
    required String staffName,
    required StaffRole role,
    required double contributionPercentage,
  }) async {
    final contribution = StaffContribution(
      staffId: staffId,
      staffName: staffName,
      role: role,
      startTime: DateTime.now(),
      contributionPercentage: contributionPercentage,
    );
    
    await _serviceTrackingCollection.doc(orderId).update({
      'staffContributions.$staffId': contribution.toJson(),
    });
  }

  // Calculate peak service hours
  Future<Map<String, dynamic>> _calculatePeakHours(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    Map<int, int> hourCounts = {};
    
    for (final doc in docs) {
      final tracking = ServiceTracking.fromJson(doc.data());
      final hour = (tracking.startTime ?? tracking.serviceStartTime).hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    // Find peak hours
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'peakHour': sortedHours.isNotEmpty ? sortedHours.first.key : 0,
      'peakCount': sortedHours.isNotEmpty ? sortedHours.first.value : 0,
      'hourlyDistribution': hourCounts,
    };
  }

  // Get payment method from order type
  ServiceType? _getServiceType(Order order) {
    if (order.isDineIn == true || order.serviceType == 'dine-in') {
      return ServiceType.dineIn;
    } else if (order.isDelivery == true || order.serviceType == 'delivery') {
      return ServiceType.delivery;
    } else if (order.serviceType == 'takeout') {
      return ServiceType.takeout;
    } else if (order.serviceType == 'pickup') {
      return ServiceType.pickup;
    }
    return null;
  }

  // Update payment status
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    await _paymentsCollection.doc(paymentId).update({
      'status': status.name,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get active tax configurations
  Future<List<TaxConfiguration>> getActiveTaxConfigurations() async {
    final querySnapshot = await _taxConfigCollection
        .where('isActive', isEqualTo: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => TaxConfiguration.fromJson(doc.data()))
        .toList();
  }

  // Toggle tax configuration status
  Future<void> toggleTaxConfiguration(String taxId, bool isActive) async {
    await _taxConfigCollection.doc(taxId).update({
      'isActive': isActive,
      'modifiedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update tax configuration
  Future<void> updateTaxConfiguration(TaxConfiguration config) async {
    await _taxConfigCollection.doc(config.id).update({
      ...config.toJson(),
      'modifiedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final payments = await _paymentsCollection
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    double totalRevenue = 0;
    double totalDiscounts = 0;
    double totalReimbursements = 0;
    int totalTransactions = 0;
    Map<String, double> revenueByMethod = {};
    Map<String, int> transactionsByMethod = {};
    double averageTransactionValue = 0;
    
    for (final doc in payments.docs) {
      final payment = Payment.fromJson(doc.data());
      
      if (payment.status == PaymentStatus.completed) {
        totalRevenue += payment.finalAmount;
        totalDiscounts += payment.discountAmount;
        totalReimbursements += payment.refundedAmount;
        totalTransactions++;
        
        // Track by payment method
        final methodName = payment.method.name;
        revenueByMethod[methodName] = (revenueByMethod[methodName] ?? 0) + payment.finalAmount;
        transactionsByMethod[methodName] = (transactionsByMethod[methodName] ?? 0) + 1;
      }
    }
    
    if (totalTransactions > 0) {
      averageTransactionValue = totalRevenue / totalTransactions;
    }
    
    return {
      'totalRevenue': totalRevenue,
      'totalDiscounts': totalDiscounts,
      'totalReimbursements': totalReimbursements,
      'totalTransactions': totalTransactions,
      'averageTransactionValue': averageTransactionValue,
      'revenueByMethod': revenueByMethod,
      'transactionsByMethod': transactionsByMethod,
    };
  }

  // Get daily service summary
  Future<Map<String, dynamic>> getDailyServiceSummary() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Get today's payments
    final payments = await _paymentsCollection
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: PaymentStatus.completed.name)
        .get();
    
    double totalTips = 0;
    Map<String, double> staffTipTotals = {};
    
    for (final doc in payments.docs) {
      final payment = Payment.fromJson(doc.data());
      totalTips += payment.tipAmount;
      
      if (payment.serverName != null) {
        staffTipTotals[payment.serverName!] = 
            (staffTipTotals[payment.serverName!] ?? 0) + payment.tipAmount;
      }
    }
    
    return {
      'totalTips': totalTips,
      'staffTipTotals': staffTipTotals,
    };
  }
}
