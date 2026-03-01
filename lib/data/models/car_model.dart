// lib/data/models/car_model.dart

import 'package:equatable/equatable.dart';

class Car extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double pricePerDay;
  final String location;
  final bool isAvailable;
  final List<String> imageUrls;
  final String description;
  final String category; // SUV, Sedan, Sports, etc.
  final int seats;
  final String transmission;
  final double rating;
  final int reviewCount;
  final List<String> features;
  final List<BlockedDateRange> blockedDates;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.location,
    required this.isAvailable,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.seats,
    required this.transmission,
    required this.rating,
    required this.reviewCount,
    required this.features,
    required this.blockedDates,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String,
    pricePerDay: (json['pricePerDay'] as num).toDouble(),
    location: json['location'] as String,
    isAvailable: json['isAvailable'] as bool,
    imageUrls: List<String>.from(json['imageUrls'] as List),
    description: json['description'] as String,
    category: json['category'] as String,
    seats: json['seats'] as int,
    transmission: json['transmission'] as String,
    rating: (json['rating'] as num).toDouble(),
    reviewCount: json['reviewCount'] as int,
    features: List<String>.from(json['features'] as List),
    blockedDates: (json['blockedDates'] as List)
        .map((e) => BlockedDateRange.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'pricePerDay': pricePerDay,
    'location': location,
    'isAvailable': isAvailable,
    'imageUrls': imageUrls,
    'description': description,
    'category': category,
    'seats': seats,
    'transmission': transmission,
    'rating': rating,
    'reviewCount': reviewCount,
    'features': features,
    'blockedDates': blockedDates.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [id];
}

class BlockedDateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const BlockedDateRange({required this.start, required this.end});

  factory BlockedDateRange.fromJson(Map<String, dynamic> json) =>
      BlockedDateRange(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  @override
  List<Object?> get props => [start, end];
}
