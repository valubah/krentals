// lib/data/models/booking_model.dart

import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, failed, cancelled }

class Booking extends Equatable {
  final String id;
  final String carId;
  final String carName;
  final String carImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double pricePerDay;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImageUrl,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Booking copyWith({
    String? id,
    String? carId,
    String? carName,
    String? carImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    double? pricePerDay,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
  }) =>
      Booking(
        id: id ?? this.id,
        carId: carId ?? this.carId,
        carName: carName ?? this.carName,
        carImageUrl: carImageUrl ?? this.carImageUrl,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        totalDays: totalDays ?? this.totalDays,
        pricePerDay: pricePerDay ?? this.pricePerDay,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id];
}
