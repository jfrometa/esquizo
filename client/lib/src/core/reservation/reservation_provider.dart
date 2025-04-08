import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart'; 
import 'reservation_service.dart';

// Provider for reservation service
final reservationServiceProvider = Provider<ReservationService>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  return ReservationService(businessId: businessId);
});

// Provider for user reservations
final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final reservationService = ref.watch(reservationServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user.value?.uid == null) {
    return Stream.value([]);
  }
  
  return reservationService.getUserReservations(user.value!.uid);
});

// Provider for reservations by date
final reservationsByDateProvider = FutureProvider.family<List<Reservation>, DateTime>((ref, date) {
  final reservationService = ref.watch(reservationServiceProvider);
  return reservationService.getReservationsByDate(date);
});

// Provider for resource reservations
final resourceReservationsProvider = StreamProvider.family<List<Reservation>, String>((ref, resourceId) {
  final reservationService = ref.watch(reservationServiceProvider);
  return reservationService.getReservationsForResource(resourceId);
});

// Provider for available time slots
final availableTimeSlotsProvider = FutureProvider.family<List<String>, ({String resourceId, DateTime date})>((ref, params) {
  final reservationService = ref.watch(reservationServiceProvider);
  return reservationService.getAvailableTimeSlots(params.resourceId, params.date);
});

// Provider for selected reservation date
final selectedReservationDateProvider = StateProvider<DateTime>((ref) {
  // Default to tomorrow
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1);
});

// Provider for selected time slot
final selectedTimeSlotProvider = StateProvider<String?>((ref) => null);

// Provider for selected party size
final selectedPartySizeProvider = StateProvider<int>((ref) => 2);