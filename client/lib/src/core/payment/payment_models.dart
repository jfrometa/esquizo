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
  final ServiceType? serviceType;
  final String? serverId;
  final String? serverName;
  final String? tableNumber;
  final bool isRefundable;
  final double refundedAmount;
  final List<String> refundIds;

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
    this.serviceType,
    this.serverId,
    this.serverName,
    this.tableNumber,
    this.isRefundable = true,
    this.refundedAmount = 0.0,
    this.refundIds = const [],
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
      'serviceType': serviceType?.name,
      'serverId': serverId,
      'serverName': serverName,
      'tableNumber': tableNumber,
      'isRefundable': isRefundable,
      'refundedAmount': refundedAmount,
      'refundIds': refundIds,
    };
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
    };
  }
}

/// Payment summary model
class PaymentSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalDiscounts;
  final double totalReimbursements;
  final double netRevenue;
  final int totalTransactions;
  final Map<String, int> transactionsByMethod;
  final Map<String, double> revenueByMethod;
  final Map<String, double> discountsByType;

  PaymentSummary({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalDiscounts,
    required this.totalReimbursements,
    required this.netRevenue,
    required this.totalTransactions,
    required this.transactionsByMethod,
    required this.revenueByMethod,
    required this.discountsByType,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalDiscounts: (json['totalDiscounts'] ?? 0).toDouble(),
      totalReimbursements: (json['totalReimbursements'] ?? 0).toDouble(),
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      transactionsByMethod:
          Map<String, int>.from(json['transactionsByMethod'] ?? {}),
      revenueByMethod:
          Map<String, double>.from(json['revenueByMethod'] ?? {}),
      discountsByType:
          Map<String, double>.from(json['discountsByType'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalRevenue': totalRevenue,
      'totalDiscounts': totalDiscounts,
      'totalReimbursements': totalReimbursements,
      'netRevenue': netRevenue,
      'totalTransactions': totalTransactions,
      'transactionsByMethod': transactionsByMethod,
      'revenueByMethod': revenueByMethod,
      'discountsByType': discountsByType,
    };
  }
}

/// Tax configuration model
class TaxConfiguration {
  final String id;
  final String name;
  final double rate;
  final TaxType type;
  final ServiceType? applicableServiceType;
  final bool isActive;
  final String? description;
  final DateTime createdAt;
  final DateTime? modifiedAt;

  TaxConfiguration({
    required this.id,
    required this.name,
    required this.rate,
    required this.type,
    this.applicableServiceType,
    required this.isActive,
    this.description,
    required this.createdAt,
    this.modifiedAt,
  });

  factory TaxConfiguration.fromJson(Map<String, dynamic> json) {
    return TaxConfiguration(
      id: json['id'],
      name: json['name'],
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
      isActive: json['isActive'] ?? true,
      description: json['description'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      modifiedAt: json['modifiedAt'] != null
          ? (json['modifiedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'type': type.name,
      'applicableServiceType': applicableServiceType?.name,
      'isActive': isActive,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': modifiedAt != null
          ? Timestamp.fromDate(modifiedAt!)
          : null,
    };
  }
}

/// Service tracking model
class ServiceTracking {
  final String orderId;
  final DateTime startTime;
  final DateTime? endTime;
  final ServiceType serviceType;
  final String? tableNumber;
  final Map<String, StaffContribution> staffContributions;
  final List<ServiceEvent> events;
  final double? serviceCharge;
  final bool isActive;

  ServiceTracking({
    required this.orderId,
    required this.startTime,
    this.endTime,
    required this.serviceType,
    this.tableNumber,
    required this.staffContributions,
    required this.events,
    this.serviceCharge,
    required this.isActive,
  });

  factory ServiceTracking.fromJson(Map<String, dynamic> json) {
    return ServiceTracking(
      orderId: json['orderId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.dineIn,
      ),
      tableNumber: json['tableNumber'],
      staffContributions: (json['staffContributions'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              key, StaffContribution.fromJson(value))),
      events: (json['events'] as List<dynamic>)
          .map((e) => ServiceEvent.fromJson(e))
          .toList(),
      serviceCharge: json['serviceCharge']?.toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'serviceType': serviceType.name,
      'tableNumber': tableNumber,
      'staffContributions': staffContributions
          .map((key, value) => MapEntry(key, value.toJson())),
      'events': events.map((e) => e.toJson()).toList(),
      'serviceCharge': serviceCharge,
      'isActive': isActive,
    };
  }
}

/// Staff contribution model
class StaffContribution {
  final String staffId;
  final String staffName;
  final StaffRole role;
  final DateTime startTime;
  final DateTime? endTime;
  final double contributionPercentage;

  StaffContribution({
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.startTime,
    this.endTime,
    required this.contributionPercentage,
  });

  factory StaffContribution.fromJson(Map<String, dynamic> json) {
    return StaffContribution(
      staffId: json['staffId'],
      staffName: json['staffName'],
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.other,
      ),
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      contributionPercentage:
          (json['contributionPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'role': role.name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'contributionPercentage': contributionPercentage,
    };
  }
}

/// Service event model
class ServiceEvent {
  final String type; // order_placed, food_ready, payment_requested, etc.
  final DateTime timestamp;
  final String? staffId;
  final String? staffName;
  final Map<String, dynamic>? metadata;

  ServiceEvent({
    required this.type,
    required this.timestamp,
    this.staffId,
    this.staffName,
    this.metadata,
  });

  factory ServiceEvent.fromJson(Map<String, dynamic> json) {
    return ServiceEvent(
      type: json['type'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      staffId: json['staffId'],
      staffName: json['staffName'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'staffId': staffId,
      'staffName': staffName,
      'metadata': metadata,
    };
  }
}

/// Tip distribution model
class TipDistribution {
  final String id;
  final String paymentId;
  final String orderId;
  final double totalTipAmount;
  final DistributionMethod method;
  final List<StaffTipAllocation> allocations;
  final DateTime distributedAt;
  final String distributedBy;
  final String? notes;

  TipDistribution({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.totalTipAmount,
    required this.method,
    required this.allocations,
    required this.distributedAt,
    required this.distributedBy,
    this.notes,
  });

  factory TipDistribution.fromJson(Map<String, dynamic> json) {
    return TipDistribution(
      id: json['id'],
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      totalTipAmount: (json['totalTipAmount'] ?? 0).toDouble(),
      method: DistributionMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => DistributionMethod.manual,
      ),
      allocations: (json['allocations'] as List<dynamic>)
          .map((a) => StaffTipAllocation.fromJson(a))
          .toList(),
      distributedAt: (json['distributedAt'] as Timestamp).toDate(),
      distributedBy: json['distributedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'orderId': orderId,
      'totalTipAmount': totalTipAmount,
      'method': method.name,
      'allocations': allocations.map((a) => a.toJson()).toList(),
      'distributedAt': Timestamp.fromDate(distributedAt),
      'distributedBy': distributedBy,
      'notes': notes,
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

  StaffTipAllocation({
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.amount,
    required this.percentage,
  });

  factory StaffTipAllocation.fromJson(Map<String, dynamic> json) {
    return StaffTipAllocation(
      staffId: json['staffId'],
      staffName: json['staffName'],
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.other,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'role': role.name,
      'amount': amount,
      'percentage': percentage,
    };
  }
}
    required this.name,
    required this.description,
    required this.type,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.conditions = const [],
    this.rewards = const [],
    this.currentUses = 0,
    this.maxUses,
    this.isAutoApplied = false,
    this.imageUrl,
    this.metadata,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: OfferType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfferType.other,
      ),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => OfferCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => OfferReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentUses: json['currentUses'] ?? 0,
      maxUses: json['maxUses'],
      isAutoApplied: json['isAutoApplied'] ?? false,
      imageUrl: json['imageUrl'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'description': description,
      'type': type.name,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'conditions': conditions.map((e) => e.toJson()).toList(),
      'rewards': rewards.map((e) => e.toJson()).toList(),
      'currentUses': currentUses,
      'maxUses': maxUses,
      'isAutoApplied': isAutoApplied,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

/// Offer condition model
class OfferCondition {
  final String type;
  final Map<String, dynamic> parameters;

  OfferCondition({
    required this.type,
    required this.parameters,
  });

  factory OfferCondition.fromJson(Map<String, dynamic> json) {
    return OfferCondition(
      type: json['type'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parameters': parameters,
    };
  }
}

/// Offer reward model
class OfferReward {
  final String type;
  final Map<String, dynamic> parameters;

  OfferReward({
    required this.type,
    required this.parameters,
  });

  factory OfferReward.fromJson(Map<String, dynamic> json) {
    return OfferReward(
      type: json['type'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parameters': parameters,
    };
  }
}

/// Bundle model
class Bundle {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final double originalPrice;
  final double bundlePrice;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final List<BundleItem> items;
  final int maxQuantity;
  final int currentSales;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  Bundle({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.bundlePrice,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.items = const [],
    this.maxQuantity = 0,
    this.currentSales = 0,
    this.imageUrl,
    this.metadata,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      bundlePrice: (json['bundlePrice'] ?? 0).toDouble(),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BundleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      maxQuantity: json['maxQuantity'] ?? 0,
      currentSales: json['currentSales'] ?? 0,
      imageUrl: json['imageUrl'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'description': description,
      'originalPrice': originalPrice,
      'bundlePrice': bundlePrice,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'items': items.map((e) => e.toJson()).toList(),
      'maxQuantity': maxQuantity,
      'currentSales': currentSales,
      'imageUrl': imageUrl,
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
  final String? notes;

  BundleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    this.notes,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) {
    return BundleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'originalPrice': originalPrice,
      'notes': notes,
    };
  }
}

/// Payment summary model
class PaymentSummary {
  final String businessId;
  final DateTime date;
  final double totalRevenue;
  final double totalDiscounts;
  final double totalReimbursements;
  final double netRevenue;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final Map<String, double> revenueByMethod;
  final Map<String, int> transactionsByMethod;
  final Map<String, double> discountsByType;
  final Map<String, dynamic>? metadata;

  PaymentSummary({
    required this.businessId,
    required this.date,
    required this.totalRevenue,
    required this.totalDiscounts,
    required this.totalReimbursements,
    required this.netRevenue,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.revenueByMethod,
    required this.transactionsByMethod,
    required this.discountsByType,
    this.metadata,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      businessId: json['businessId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalDiscounts: (json['totalDiscounts'] ?? 0).toDouble(),
      totalReimbursements: (json['totalReimbursements'] ?? 0).toDouble(),
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      successfulTransactions: json['successfulTransactions'] ?? 0,
      failedTransactions: json['failedTransactions'] ?? 0,
      revenueByMethod: Map<String, double>.from(json['revenueByMethod'] ?? {}),
      transactionsByMethod:
          Map<String, int>.from(json['transactionsByMethod'] ?? {}),
      discountsByType: Map<String, double>.from(json['discountsByType'] ?? {}),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'date': Timestamp.fromDate(date),
      'totalRevenue': totalRevenue,
      'totalDiscounts': totalDiscounts,
      'totalReimbursements': totalReimbursements,
      'netRevenue': netRevenue,
      'totalTransactions': totalTransactions,
      'successfulTransactions': successfulTransactions,
      'failedTransactions': failedTransactions,
      'revenueByMethod': revenueByMethod,
      'transactionsByMethod': transactionsByMethod,
      'discountsByType': discountsByType,
      'metadata': metadata,
    };
  }
}

/// Service tracking model
class ServiceTracking {
  final String orderId;
  final ServiceType serviceType;
  final String? tableId;
  final int? tableNumber;
  final String? serverId;
  final String? serverName;
  final DateTime serviceStartTime;
  final DateTime? serviceEndTime;
  final List<ServiceEvent> events;
  final Map<String, StaffContribution> staffContributions;
  final ServiceQuality? serviceQuality;
  final Map<String, dynamic>? metadata;

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
    this.serviceQuality,
    this.metadata,
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
      serviceStartTime: (json['serviceStartTime'] as Timestamp).toDate(),
      serviceEndTime: json['serviceEndTime'] != null
          ? (json['serviceEndTime'] as Timestamp).toDate()
          : null,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ServiceEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staffContributions: (json['staffContributions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(
                  k, StaffContribution.fromJson(v as Map<String, dynamic>))) ??
          {},
      serviceQuality: json['serviceQuality'] != null
          ? ServiceQuality.fromJson(
              json['serviceQuality'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      'staffContributions':
          staffContributions.map((k, v) => MapEntry(k, v.toJson())),
      'serviceQuality': serviceQuality?.toJson(),
      'metadata': metadata,
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
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
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

/// Distribution method enum
enum DistributionMethod {
  equalSplit,
  percentageBased,
  roleBased,
  manual,
  pointsSystem,
}

/// Service quality model
class ServiceQuality {
  final double rating;
  final String? feedback;
  final Map<String, double> aspectRatings;
  final DateTime ratedAt;
  final String? customerId;

  ServiceQuality({
    required this.rating,
    this.feedback,
    required this.aspectRatings,
    required this.ratedAt,
    this.customerId,
  });

  factory ServiceQuality.fromJson(Map<String, dynamic> json) {
    return ServiceQuality(
      rating: (json['rating'] ?? 0).toDouble(),
      feedback: json['feedback'],
      aspectRatings: Map<String, double>.from(json['aspectRatings'] ?? {}),
      ratedAt: (json['ratedAt'] as Timestamp).toDate(),
      customerId: json['customerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'feedback': feedback,
      'aspectRatings': aspectRatings,
      'ratedAt': Timestamp.fromDate(ratedAt),
      'customerId': customerId,
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
  final bool isActive;
  final DateTime validFrom;
  final DateTime? validUntil;
  final String? description;
  final Map<String, dynamic>? conditions;

  TaxConfiguration({
    required this.id,
    required this.businessId,
    required this.name,
    required this.rate,
    required this.type,
    this.applicableServiceType,
    this.isActive = true,
    required this.validFrom,
    this.validUntil,
    this.description,
    this.conditions,
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
      isActive: json['isActive'] ?? true,
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: json['validUntil'] != null
          ? (json['validUntil'] as Timestamp).toDate()
          : null,
      description: json['description'],
      conditions: json['conditions'] as Map<String, dynamic>?,
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
      'isActive': isActive,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'description': description,
      'conditions': conditions,
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
