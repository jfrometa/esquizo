import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

/// Payment method enum
enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  digitalWallet,
  mealPlan,
  other,
}

/// Service type enum
enum ServiceType {
  dineIn,
  takeout,
  delivery,
  pickup,
}

/// Tax type enum
enum TaxType {
  percentage,
  fixed,
  compound,
}

/// Distribution method enum
enum DistributionMethod {
  equalSplit,
  percentageBased,
  roleBased,
  manual,
  pointsSystem,
}

/// Reimbursement status enum
enum ReimbursementStatus {
  requested,
  approved,
  rejected,
  completed,
  cancelled,
}

/// Discount type enum
enum DiscountType {
  percentage,
  fixed,
  coupon,
  bogo,
  freeItem,
}

/// Staff role enum
enum StaffRole {
  waiter,
  cook,
  chef,
  bartender,
  busser,
  host,
  manager,
  cashier,
  other,
}

/// Offer type enum
enum OfferType {
  percentage,
  fixedAmount,
  bogo,
  freeItem,
  other,
}

/// Main payment model
class Payment {
  final String id;
  final String orderId;
  final String userId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final PaymentMethod method;
  final PaymentStatus status;
  final double baseAmount;
  final double taxAmount;
  final double tipAmount;
  final double serviceCharge;
  final double discountAmount;
  final double finalAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final Map<String, dynamic>? metadata;
  final List<Discount> appliedDiscounts;
  final List<String> appliedCouponCodes;
  final PaymentProof? proof;
  final List<PaymentProof> proofs;
  final ServiceType? serviceType;
  final String? serverId;
  final String? serverName;
  final String? tableNumber;
  final bool isRefundable;
  final double refundedAmount;
  final List<String> refundIds;
  // Added fields for payment service compatibility
  final double? amount;
  final double? subtotal;
  final double? deliveryFee;
  final List<Discount>? discounts;
  final String? receiptNumber;
  final ServiceTracking? serviceTracking;
  final List<TaxConfiguration>? appliedTaxes;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.method,
    required this.status,
    required this.baseAmount,
    required this.taxAmount,
    required this.tipAmount,
    this.serviceCharge = 0.0,
    required this.discountAmount,
    required this.finalAmount,
    this.currency = 'USD',
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.metadata,
    this.appliedDiscounts = const [],
    this.appliedCouponCodes = const [],
    this.proof,
    this.proofs = const [],
    this.serviceType,
    this.serverId,
    this.serverName,
    this.tableNumber,
    this.isRefundable = true,
    this.refundedAmount = 0.0,
    this.refundIds = const [],
    // Initialize new fields
    this.amount,
    this.subtotal,
    this.deliveryFee,
    this.discounts,
    this.receiptNumber,
    this.serviceTracking,
    this.appliedTaxes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.other,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      baseAmount: (json['baseAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      tipAmount: (json['tipAmount'] ?? 0).toDouble(),
      serviceCharge: (json['serviceCharge'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      transactionId: json['transactionId'],
      metadata: json['metadata'],
      appliedDiscounts: (json['appliedDiscounts'] as List<dynamic>?)
              ?.map((d) => Discount.fromJson(d))
              .toList() ??
          [],
      appliedCouponCodes:
          List<String>.from(json['appliedCouponCodes'] ?? []),
      proof: json['proof'] != null
          ? PaymentProof.fromJson(json['proof'])
          : null,
      proofs: (json['proofs'] as List<dynamic>?)
              ?.map((p) => PaymentProof.fromJson(p))
              .toList() ??
          [],
      serviceType: json['serviceType'] != null
          ? ServiceType.values.firstWhere(
              (e) => e.name == json['serviceType'],
              orElse: () => ServiceType.dineIn,
            )
          : null,
      serverId: json['serverId'],
      serverName: json['serverName'],
      tableNumber: json['tableNumber'],
      isRefundable: json['isRefundable'] ?? true,
      refundedAmount: (json['refundedAmount'] ?? 0).toDouble(),
      refundIds: List<String>.from(json['refundIds'] ?? []),
      // Parse new fields
      amount: (json['amount'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discounts: (json['discounts'] as List<dynamic>?)
          ?.map((d) => Discount.fromJson(d))
          .toList(),
      receiptNumber: json['receiptNumber'],
      serviceTracking: json['serviceTracking'] != null
          ? ServiceTracking.fromJson(
              json['serviceTracking'] as Map<String, dynamic>)
          : null,
      appliedTaxes: (json['appliedTaxes'] as List<dynamic>?)
          ?.map((t) => TaxConfiguration.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'method': method.name,
      'status': status.name,
      'baseAmount': baseAmount,
      'taxAmount': taxAmount,
      'tipAmount': tipAmount,
      'serviceCharge': serviceCharge,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'transactionId': transactionId,
      'metadata': metadata,
      'appliedDiscounts':
          appliedDiscounts.map((d) => d.toJson()).toList(),
      'appliedCouponCodes': appliedCouponCodes,
      'proof': proof?.toJson(),
      'proofs': proofs.map((p) => p.toJson()).toList(),
      'serviceType': serviceType?.name,
      'serverId': serverId,
      'serverName': serverName,
      'tableNumber': tableNumber,
      'isRefundable': isRefundable,
      'refundedAmount': refundedAmount,
      'refundIds': refundIds,
      // Serialize new fields
      'amount': amount,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discounts': discounts?.map((d) => d.toJson()).toList(),
      'receiptNumber': receiptNumber,
      'serviceTracking': serviceTracking?.toJson(),
      'appliedTaxes': appliedTaxes?.map((t) => t.toJson()).toList(),
    };
  }

  Payment copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    PaymentMethod? method,
    PaymentStatus? status,
    double? baseAmount,
    double? taxAmount,
    double? tipAmount,
    double? serviceCharge,
    double? discountAmount,
    double? finalAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionId,
    Map<String, dynamic>? metadata,
    List<Discount>? appliedDiscounts,
    List<String>? appliedCouponCodes,
    PaymentProof? proof,
    List<PaymentProof>? proofs,
    ServiceType? serviceType,
    String? serverId,
    String? serverName,
    String? tableNumber,
    bool? isRefundable,
    double? refundedAmount,
    List<String>? refundIds,
    double? amount,
    double? subtotal,
    double? deliveryFee,
    List<Discount>? discounts,
    String? receiptNumber,
    ServiceTracking? serviceTracking,
    List<TaxConfiguration>? appliedTaxes,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      method: method ?? this.method,
      status: status ?? this.status,
      baseAmount: baseAmount ?? this.baseAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      appliedCouponCodes: appliedCouponCodes ?? this.appliedCouponCodes,
      proof: proof ?? this.proof,
      proofs: proofs ?? this.proofs,
      serviceType: serviceType ?? this.serviceType,
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      tableNumber: tableNumber ?? this.tableNumber,
      isRefundable: isRefundable ?? this.isRefundable,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundIds: refundIds ?? this.refundIds,
      // Initialize new fields
      amount: amount ?? this.amount,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discounts: discounts ?? this.discounts,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      serviceTracking: serviceTracking ?? this.serviceTracking,
      appliedTaxes: appliedTaxes ?? this.appliedTaxes,
    );
  }

}

/// Discount model
class Discount {
  final String id;
  final String code;
  final String type; // percentage, fixed, bogo
  final double value;
  final double amountApplied;
  final String? description;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final int? maxUses;
  final int currentUses;
  final double? minimumOrderAmount;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;

  Discount({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.amountApplied,
    this.description,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    this.maxUses,
    this.currentUses = 0,
    this.minimumOrderAmount,
    this.applicableCategories,
    this.applicableProducts,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      code: json['code'],
      type: json['type'],
      value: (json['value'] ?? 0).toDouble(),
      amountApplied: (json['amountApplied'] ?? 0).toDouble(),
      description: json['description'],
      validFrom: json['validFrom'] != null
          ? (json['validFrom'] as Timestamp).toDate()
          : null,
      validUntil: json['validUntil'] != null
          ? (json['validUntil'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] ?? true,
      maxUses: json['maxUses'],
      currentUses: json['currentUses'] ?? 0,
      minimumOrderAmount: json['minimumOrderAmount']?.toDouble(),
      applicableCategories:
          List<String>.from(json['applicableCategories'] ?? []),
      applicableProducts:
          List<String>.from(json['applicableProducts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'amountApplied': amountApplied,
      'description': description,
      'validFrom': validFrom != null
          ? Timestamp.fromDate(validFrom!)
          : null,
      'validUntil': validUntil != null
          ? Timestamp.fromDate(validUntil!)
          : null,
      'isActive': isActive,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'minimumOrderAmount': minimumOrderAmount,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
    };
  }
}

/// Payment proof model
class PaymentProof {
  final String type; // screenshot, receipt, bankTransfer
  final String? imageUrl;
  final String? referenceNumber;
  final DateTime uploadedAt;
  final String uploadedBy;
  final Map<String, dynamic>? metadata;

  PaymentProof({
    required this.type,
    this.imageUrl,
    this.referenceNumber,
    required this.uploadedAt,
    required this.uploadedBy,
    this.metadata,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    return PaymentProof(
      type: json['type'],
      imageUrl: json['imageUrl'],
      referenceNumber: json['referenceNumber'],
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      uploadedBy: json['uploadedBy'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imageUrl': imageUrl,
      'referenceNumber': referenceNumber,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
      'metadata': metadata,
    };
  }
}

/// Reimbursement model
class Reimbursement {
  final String id;
  final String paymentId;
  final String orderId;
  final String userId;
  final double amount;
  final String reason;
  final String status; // pending, approved, rejected, completed
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? notes;
  final List<String>? itemIds;
  final Map<String, dynamic>? metadata;
  // Added fields for payment service compatibility
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? completedAt;

  Reimbursement({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
    this.notes,
    this.itemIds,
    this.metadata,
    // Added fields
    this.approvedAt,
    this.approvedBy,
    this.completedAt,
  });

  factory Reimbursement.fromJson(Map<String, dynamic> json) {
    return Reimbursement(
      id: json['id'],
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: (json['amount'] ?? 0).toDouble(),
      reason: json['reason'],
      status: json['status'],
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      processedAt: json['processedAt'] != null
          ? (json['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: json['processedBy'],
      notes: json['notes'],
      itemIds: List<String>.from(json['itemIds'] ?? []),
      metadata: json['metadata'],
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: json['approvedBy'],
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'processedBy': processedBy,
      'notes': notes,
      'itemIds': itemIds,
      'metadata': metadata,
      'approvedAt': approvedAt != null
          ? Timestamp.fromDate(approvedAt!)
          : null,
      'approvedBy': approvedBy,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  Reimbursement copyWith({
    String? id,
    String? paymentId,
    String? orderId,
    String? userId,
    double? amount,
    String? reason,
    String? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? processedBy,
    String? notes,
    List<String>? itemIds,
    Map<String, dynamic>? metadata,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? completedAt,
  }) {
    return Reimbursement(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
      itemIds: itemIds ?? this.itemIds,
      metadata: metadata ?? this.metadata,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Payment summary model
class PaymentSummary {
  // For date range summary
  final DateTime? startDate;
  final DateTime? endDate;
  // For business/day summary
  final String? businessId;
  final DateTime? date;
  // Common fields
  final double totalRevenue;
  final double totalDiscounts;
  final double totalReimbursements;
  final double netRevenue;
  final int totalTransactions;
  final int? successfulTransactions;
  final int? failedTransactions;
  final Map<String, int> transactionsByMethod;
  final Map<String, double> revenueByMethod;
  final Map<String, double> discountsByType;
  final Map<String, dynamic>? metadata;

  PaymentSummary({
    this.startDate,
    this.endDate,
    this.businessId,
    this.date,
    required this.totalRevenue,
    required this.totalDiscounts,
    required this.totalReimbursements,
    required this.netRevenue,
    required this.totalTransactions,
    this.successfulTransactions,
    this.failedTransactions,
    required this.transactionsByMethod,
    required this.revenueByMethod,
    required this.discountsByType,
    this.metadata,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      startDate: json['startDate'] != null ? (json['startDate'] as Timestamp).toDate() : null,
      endDate: json['endDate'] != null ? (json['endDate'] as Timestamp).toDate() : null,
      businessId: json['businessId'],
      date: json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalDiscounts: (json['totalDiscounts'] ?? 0).toDouble(),
      totalReimbursements: (json['totalReimbursements'] ?? 0).toDouble(),
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      successfulTransactions: json['successfulTransactions'],
      failedTransactions: json['failedTransactions'],
      transactionsByMethod: Map<String, int>.from(json['transactionsByMethod'] ?? {}),
      revenueByMethod: Map<String, double>.from(json['revenueByMethod'] ?? {}),
      discountsByType: Map<String, double>.from(json['discountsByType'] ?? {}),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (businessId != null) 'businessId': businessId,
      if (date != null) 'date': Timestamp.fromDate(date!),
      'totalRevenue': totalRevenue,
      'totalDiscounts': totalDiscounts,
      'totalReimbursements': totalReimbursements,
      'netRevenue': netRevenue,
      'totalTransactions': totalTransactions,
      if (successfulTransactions != null) 'successfulTransactions': successfulTransactions,
      if (failedTransactions != null) 'failedTransactions': failedTransactions,
      'transactionsByMethod': transactionsByMethod,
      'revenueByMethod': revenueByMethod,
      'discountsByType': discountsByType,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Payment with service tracking and tip management
class PaymentWithService {
  final Payment payment;
  final ServiceTracking serviceTracking;
  final TipDistribution? tipDistribution;

  PaymentWithService({
    required this.payment,
    required this.serviceTracking,
    this.tipDistribution,
  });

  factory PaymentWithService.fromJson(Map<String, dynamic> json) {
    return PaymentWithService(
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      serviceTracking: ServiceTracking.fromJson(
          json['serviceTracking'] as Map<String, dynamic>),
      tipDistribution: json['tipDistribution'] != null
          ? TipDistribution.fromJson(
              json['tipDistribution'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment': payment.toJson(),
      'serviceTracking': serviceTracking.toJson(),
      'tipDistribution': tipDistribution?.toJson(),
    };
  }
}

/// Tip distribution model
class TipDistribution {
  final String id;
  final String paymentId;
  final String orderId;
  final double totalTipAmount;
  final DateTime distributedAt;
  final String distributedBy;
  final List<StaffTipAllocation> allocations;
  final String? notes;
  final DistributionMethod method;
  final Map<String, dynamic>? metadata;

  TipDistribution({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.totalTipAmount,
    required this.distributedAt,
    required this.distributedBy,
    required this.allocations,
    this.notes,
    required this.method,
    this.metadata,
  });

  factory TipDistribution.fromJson(Map<String, dynamic> json) {
    return TipDistribution(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      orderId: json['orderId'] as String,
      totalTipAmount: (json['totalTipAmount'] ?? 0).toDouble(),
      distributedAt: (json['distributedAt'] as Timestamp).toDate(),
      distributedBy: json['distributedBy'] as String,
      allocations: (json['allocations'] as List<dynamic>)
          .map((e) => StaffTipAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'],
      method: DistributionMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => DistributionMethod.manual,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'orderId': orderId,
      'totalTipAmount': totalTipAmount,
      'distributedAt': Timestamp.fromDate(distributedAt),
      'distributedBy': distributedBy,
      'allocations': allocations.map((e) => e.toJson()).toList(),
      'notes': notes,
      'method': method.name,
      'metadata': metadata,
    };
  }
}

/// Staff tip allocation model
class StaffTipAllocation {
  final String staffId;
  final String staffName;
  final StaffRole role;
  final double amount;
  final double percentage;
  final String? notes;

  StaffTipAllocation({
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.amount,
    required this.percentage,
    this.notes,
  });

  factory StaffTipAllocation.fromJson(Map<String, dynamic> json) {
    return StaffTipAllocation(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.other,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'role': role.name,
      'amount': amount,
      'percentage': percentage,
      'notes': notes,
    };
  }
}

/// Service tracking model for tracking staff service
class ServiceTracking {
  final String orderId;
  final ServiceType serviceType;
  final String? tableId;
  final String? tableNumber;
  final String? serverId;
  final String? serverName;
  final DateTime serviceStartTime;
  final DateTime? serviceEndTime;
  final List<ServiceEvent> events;
  final Map<String, StaffContribution> staffContributions;
  final bool isActive;
  final DateTime? startTime;
  final DateTime? endTime;

  ServiceTracking({
    required this.orderId,
    required this.serviceType,
    this.tableId,
    this.tableNumber,
    this.serverId,
    this.serverName,
    required this.serviceStartTime,
    this.serviceEndTime,
    required this.events,
    required this.staffContributions,
    this.isActive = true,
    this.startTime,
    this.endTime,
  });

  factory ServiceTracking.fromJson(Map<String, dynamic> json) {
    return ServiceTracking(
      orderId: json['orderId'] as String,
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.dineIn,
      ),
      tableId: json['tableId'],
      tableNumber: json['tableNumber'],
      serverId: json['serverId'],
      serverName: json['serverName'],
      serviceStartTime: (json['serviceStartTime'] as Timestamp?)?.toDate() ??
          (json['startTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      serviceEndTime: (json['serviceEndTime'] as Timestamp?)?.toDate() ??
          (json['endTime'] as Timestamp?)?.toDate(),
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ServiceEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staffContributions: Map<String, StaffContribution>.from(
        (json['staffContributions'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                StaffContribution.fromJson(value as Map<String, dynamic>),
              ),
            ) ??
            {},
      ),
      isActive: json['isActive'] ?? true,
      startTime: (json['startTime'] as Timestamp?)?.toDate(),
      endTime: (json['endTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'serviceType': serviceType.name,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'serverId': serverId,
      'serverName': serverName,
      'serviceStartTime': Timestamp.fromDate(serviceStartTime),
      'serviceEndTime':
          serviceEndTime != null ? Timestamp.fromDate(serviceEndTime!) : null,
      'events': events.map((e) => e.toJson()).toList(),
      'staffContributions': staffContributions
          .map((key, value) => MapEntry(key, value.toJson())),
      'isActive': isActive,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }
}

/// Service event model
class ServiceEvent {
  final String eventType;
  final DateTime timestamp;
  final String staffId;
  final String staffName;
  final String? description;
  final Map<String, dynamic>? data;

  ServiceEvent({
    required this.eventType,
    required this.timestamp,
    required this.staffId,
    required this.staffName,
    this.description,
    this.data,
  });

  factory ServiceEvent.fromJson(Map<String, dynamic> json) {
    return ServiceEvent(
      eventType: json['eventType'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      description: json['description'],
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'timestamp': Timestamp.fromDate(timestamp),
      'staffId': staffId,
      'staffName': staffName,
      'description': description,
      'data': data,
    };
  }
}

/// Staff contribution model
class StaffContribution {
  final String staffId;
  final String staffName;
  final StaffRole role;
  final double contributionPercentage;
  final List<String> tasks;
  final DateTime startTime;
  final DateTime? endTime;

  StaffContribution({
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.contributionPercentage,
    required this.tasks,
    required this.startTime,
    this.endTime,
  });

  factory StaffContribution.fromJson(Map<String, dynamic> json) {
    return StaffContribution(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.other,
      ),
      contributionPercentage: (json['contributionPercentage'] ?? 0).toDouble(),
      tasks: List<String>.from(json['tasks'] ?? []),
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'role': role.name,
      'contributionPercentage': contributionPercentage,
      'tasks': tasks,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }
}

/// Tax configuration model
class TaxConfiguration {
  final String id;
  final String businessId;
  final String name;
  final double rate;
  final TaxType type;
  final ServiceType? applicableServiceType;
  final DateTime validFrom;
  final DateTime? validUntil;
  final String? description;
  final bool isActive;
  final Map<String, dynamic>? conditions;
  final Map<String, dynamic>? metadata;

  TaxConfiguration({
    required this.id,
    required this.businessId,
    required this.name,
    required this.rate,
    required this.type,
    this.applicableServiceType,
    required this.validFrom,
    this.validUntil,
    this.description,
    this.isActive = true,
    this.conditions,
    this.metadata,
  });

  factory TaxConfiguration.fromJson(Map<String, dynamic> json) {
    return TaxConfiguration(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      rate: (json['rate'] ?? 0).toDouble(),
      type: TaxType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaxType.percentage,
      ),
      applicableServiceType: json['applicableServiceType'] != null
          ? ServiceType.values.firstWhere(
              (e) => e.name == json['applicableServiceType'],
              orElse: () => ServiceType.dineIn,
            )
          : null,
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp?)?.toDate(),
      description: json['description'],
      isActive: json['isActive'] ?? true,
      conditions: json['conditions'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'rate': rate,
      'type': type.name,
      'applicableServiceType': applicableServiceType?.name,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'description': description,
      'isActive': isActive,
      'conditions': conditions,
      'metadata': metadata,
    };
  }
}

/// Coupon model for discount coupons
class Coupon {
  final String id;
  final String code;
  final DiscountType type;
  final double value;
  final String? description;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final int maxUses;
  final int currentUses;
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;
  final Map<String, dynamic>? metadata;

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.description,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.maxUses = 0,
    this.currentUses = 0,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.applicableCategories,
    this.applicableProducts,
    this.metadata,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      type: DiscountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DiscountType.percentage,
      ),
      value: (json['value'] ?? 0).toDouble(),
      description: json['description'],
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      maxUses: json['maxUses'] ?? 0,
      currentUses: json['currentUses'] ?? 0,
      minimumOrderAmount: json['minimumOrderAmount']?.toDouble(),
      maximumDiscountAmount: json['maximumDiscountAmount']?.toDouble(),
      applicableCategories: List<String>.from(json['applicableCategories'] ?? []),
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type.name,
      'value': value,
      'description': description,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscountAmount': maximumDiscountAmount,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'metadata': metadata,
    };
  }
}

/// Special offer model
class SpecialOffer {
  final String id;
  final String title;
  final String description;
  final OfferType type;
  final double value;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? imageUrl;
  final List<String>? applicableProducts;
  final List<String>? applicableCategories;
  final double? minimumOrderAmount;
  final int? maxRedemptions;
  final int currentRedemptions;
  final Map<String, dynamic>? metadata;

  SpecialOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.imageUrl,
    this.applicableProducts,
    this.applicableCategories,
    this.minimumOrderAmount,
    this.maxRedemptions,
    this.currentRedemptions = 0,
    this.metadata,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: OfferType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfferType.percentage,
      ),
      value: (json['value'] ?? 0).toDouble(),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      applicableCategories: List<String>.from(json['applicableCategories'] ?? []),
      minimumOrderAmount: json['minimumOrderAmount']?.toDouble(),
      maxRedemptions: json['maxRedemptions'],
      currentRedemptions: json['currentRedemptions'] ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'value': value,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'minimumOrderAmount': minimumOrderAmount,
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
      'metadata': metadata,
    };
  }
}

/// Bundle model for product bundles
class Bundle {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final List<BundleItem> items;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? imageUrl;
  final int? maxRedemptions;
  final int currentRedemptions;
  final Map<String, dynamic>? metadata;

  Bundle({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.items,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.imageUrl,
    this.maxRedemptions,
    this.currentRedemptions = 0,
    this.metadata,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => BundleItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
      maxRedemptions: json['maxRedemptions'],
      currentRedemptions: json['currentRedemptions'] ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'items': items.map((item) => item.toJson()).toList(),
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
      'metadata': metadata,
    };
  }
}

/// Bundle item model
class BundleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double originalPrice;
  final double bundlePrice;
  final bool isOptional;

  BundleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    required this.bundlePrice,
    this.isOptional = false,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) {
    return BundleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      bundlePrice: (json['bundlePrice'] ?? 0).toDouble(),
      isOptional: json['isOptional'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'originalPrice': originalPrice,
      'bundlePrice': bundlePrice,
      'isOptional': isOptional,
    };
  }
}
