import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

@freezed
class RideModel with _$RideModel {
  const factory RideModel({
    required String id,
    required String driverId,
    required String driverName,
    String? driverPhotoUrl,
    @Default(5.0) double driverRating,
    required String fromLocation,
    required String toLocation,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
    required DateTime departureDatetime,
    required int availableSeats,
    required int totalSeats,
    required double pricePerSeat,
    String? vehicleInfo,
    String? vehicleType,
    String? description,
    
    // Virtual field for pro-rata price based on search
    double? segmentPrice,
    
    // Route points stored as list of {lat, lng} maps
    @JsonKey(name: 'route_points') List<Map<String, dynamic>>? routePointsJson,
    
    // Extra Trip Details
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'duration_mins') int? durationMins,
    
    // Trip Rules / Preferences
    @Default(false) bool ruleNoSmoking,
    @Default(false) bool ruleNoMusic,
    @Default(false) bool ruleNoHeavyLuggage,
    @Default(false) bool ruleNoPets,
    @Default(false) bool ruleNegotiation,
    
    @Default('active') String status,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _RideModel;

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);

  const RideModel._();

  bool get isActive => status == 'active';
  bool get isFull => availableSeats == 0;
  bool get isCompleted => status == 'completed' || _isActuallyOver;
  bool get isCancelled => status == 'cancelled';

  bool get _isActuallyOver {
    // If it's already marked as completed/cancelled, no need to check time
    if (status == 'completed' || status == 'cancelled') return false;
    
    // Safety check: if departure is more than 24 hours ago, it's definitely over
    // or if duration is known, use that.
    final arrivalTime = departureDatetime.add(Duration(minutes: durationMins ?? 120)); // Default 2h if unknown
    return DateTime.now().isAfter(arrivalTime);
  }

  String get computedStatus {
    if (isCancelled) return 'cancelled';
    if (isCompleted) return 'completed';
    return status;
  }

  String get formattedPrice => '₹${(segmentPrice ?? pricePerSeat).toStringAsFixed(0)}';

  String get seatsText => '$availableSeats of $totalSeats seats available';

  bool get canBook => isActive && availableSeats > 0 && !isBookingClosed;

  Duration get timeUntilDeparture => departureDatetime.difference(DateTime.now());
  
  bool get isBookingClosed => timeUntilDeparture < const Duration(minutes: 5);

  bool get isUpcoming => departureDatetime.isAfter(DateTime.now());
  bool get isInPast => departureDatetime.isBefore(DateTime.now());

  String get timeUntilDepartureText {
    if (!isUpcoming) return 'Departed';

    final hours = timeUntilDeparture.inHours;
    final minutes = timeUntilDeparture.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''} left';
    } else if (minutes > 0) {
      return '$minutes min left';
    } else {
      return 'Departing soon';
    }
  }
}
