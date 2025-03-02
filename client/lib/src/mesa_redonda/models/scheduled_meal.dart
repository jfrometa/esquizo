class ScheduledMeal {
  final String id;
  final DateTime deliveryDate;
  final String notes;
  final bool isActive;

  ScheduledMeal({
    required this.id,
    required this.deliveryDate,
    this.notes = '',
    this.isActive = true,
  });

  ScheduledMeal copyWith({
    String? id,
    DateTime? deliveryDate,
    String? notes,
    bool? isActive,
  }) {
    return ScheduledMeal(
      id: id ?? this.id,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}