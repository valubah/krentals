// lib/data/sources/mock_car_data_source.dart

import 'dart:async';
import 'dart:math';
import '../models/car_model.dart';

/// Simulates a remote API. In production, replace with an HTTP client (Dio/http).
/// All methods throw typed exceptions that the repository layer converts to Failures.
class MockCarDataSource {
  final Random _random = Random();

  // Simulate network latency
  Future<void> _delay([int ms = 800]) =>
      Future.delayed(Duration(milliseconds: ms));

  static final List<Map<String, dynamic>> _carsJson = [
    {
      'id': 'car_001',
      'name': 'Model S Plaid',
      'brand': 'Tesla',
      'pricePerDay': 180.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_001_1.png',
        'assets/images/cars/car_001_2.png',
        'assets/images/cars/car_001_3.png',
      ],
      'description':
          'Experience the pinnacle of electric performance. The Tesla Model S Plaid accelerates from 0-60 mph in under 2 seconds. Featuring a tri-motor setup, it offers unrivaled acceleration and range.',
      'category': 'Sedan',
      'seats': 5,
      'transmission': 'Automatic',
      'rating': 4.9,
      'reviewCount': 312,
      'features': [
        'Autopilot',
        'Heated Seats',
        'Premium Sound',
        'Fast Charging',
      ],
      'blockedDates': [],
    },
    {
      'id': 'car_002',
      'name': 'S-Class',
      'brand': 'Mercedes-Benz',
      'pricePerDay': 220.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_002_1.jpg',
        'assets/images/cars/car_002_1.jpg',
        'assets/images/cars/car_002_1.jpg',
      ],
      'description':
          'The definition of automotive luxury. The Mercedes-Benz S-Class has long been the standard by which all other luxury sedans are measured. Unmatched comfort and safety.',
      'category': 'Sedan',
      'seats': 5,
      'transmission': 'Automatic',
      'rating': 4.8,
      'reviewCount': 198,
      'features': ['Executive Rear Seats', 'Massage Seats', 'Burmester Sound'],
      'blockedDates': [],
    },
    {
      'id': 'car_003',
      'name': '911 Carrera S',
      'brand': 'Porsche',
      'pricePerDay': 350.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_003_1.jpg',
        'assets/images/cars/car_003_1.jpg',
        'assets/images/cars/car_003_1.jpg',
      ],
      'description':
          'Pure driving nirvana. The Porsche 911 Carrera S is a sports car perfected over 60 years. With its rear-engine layout and iconic silhouette, it delivers an unmatched driving experience.',
      'category': 'Sports',
      'seats': 2,
      'transmission': 'PDK',
      'rating': 4.95,
      'reviewCount': 87,
      'features': ['Sport Chrono', 'PASM', 'Bose Sound'],
      'blockedDates': [],
    },
    {
      'id': 'car_004',
      'name': 'Range Rover Vogue',
      'brand': 'Land Rover',
      'pricePerDay': 260.0,
      'location': 'Port Harcourt, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_004_1.jpg',
        'assets/images/cars/car_004_1.jpg',
        'assets/images/cars/car_004_1.jpg',
      ],
      'description':
          'The ultimate luxury SUV. Combining legendary off-road capability with refined comfort and status. The Range Rover Vogue is at home anywhere from the city to the wild.',
      'category': 'SUV',
      'seats': 5,
      'transmission': 'Automatic',
      'rating': 4.85,
      'reviewCount': 143,
      'features': ['4WD', 'Panoramic Roof', 'Meridian Sound'],
      'blockedDates': [],
    },
    {
      'id': 'car_005',
      'name': 'M4 Competition',
      'brand': 'BMW',
      'pricePerDay': 210.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_005_1.jpg',
        'assets/images/cars/car_005_1.jpg',
        'assets/images/cars/car_005_1.jpg',
      ],
      'description':
          'The ultimate driving machine. The BMW M4 Competition combines track-ready performance with daily usability. Its inline-6 engine produces exhilarating power.',
      'category': 'Sports',
      'seats': 4,
      'transmission': 'M Steptronic',
      'rating': 4.7,
      'reviewCount': 221,
      'features': ['M Performance', 'Carbon Roof', 'Harman Kardon'],
      'blockedDates': [],
    },
    {
      'id': 'car_006',
      'name': 'R8 V10 Performance',
      'brand': 'Audi',
      'pricePerDay': 380.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_006_1.jpg',
        'assets/images/cars/car_006_1.jpg',
        'assets/images/cars/car_006_1.jpg',
      ],
      'description':
          'A supercar for every day. The Audi R8 V10 shares its DNA with the Lamborghini Huracán, offering a naturally aspirated V10 symphony and legendary Quattro grip.',
      'category': 'Sports',
      'seats': 2,
      'transmission': 'S Tronic',
      'rating': 4.9,
      'reviewCount': 94,
      'features': ['V10 Engine', 'Quattro', 'Virtual Cockpit'],
      'blockedDates': [],
    },
  ];

  Future<List<Car>> getCars() async {
    await _delay(1200);

    // Simulate occasional server error (~10% chance)
    if (_random.nextInt(10) == 0) {
      throw ServerException('Failed to load cars. Server returned 500.');
    }

    return _carsJson.map((json) => Car.fromJson(json)).toList();
  }

  Future<Car> getCarById(String id) async {
    await _delay(600);

    final json = _carsJson.firstWhere(
      (c) => c['id'] == id,
      orElse: () => throw NotFoundException('Car with id $id not found.'),
    );
    return Car.fromJson(json);
  }

  /// Simulates payment processing with 30% failure rate.
  /// In production: call Stripe/Paystack API here.
  Future<PaymentResult> processPayment({
    required String bookingId,
    required double amount,
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _delay(2000); // Simulate payment gateway latency

    final shouldFail = _random.nextDouble() < 0.3; // 30% failure

    if (shouldFail) {
      throw PaymentException(
        _randomPaymentErrorMessage(),
        code: 'PAYMENT_DECLINED',
      );
    }

    return PaymentResult(
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }

  String _randomPaymentErrorMessage() {
    const messages = [
      'Card declined by issuing bank.',
      'Insufficient funds.',
      'Transaction limit exceeded.',
      'Payment gateway timeout.',
    ];
    return messages[_random.nextInt(messages.length)];
  }
}

// --- Typed Exceptions (repository converts to Failures) ---
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}

class PaymentException implements Exception {
  final String message;
  final String code;
  const PaymentException(this.message, {required this.code});
}

// --- Result types ---
class PaymentResult {
  final String transactionId;
  final String bookingId;
  final double amount;
  final DateTime timestamp;

  const PaymentResult({
    required this.transactionId,
    required this.bookingId,
    required this.amount,
    required this.timestamp,
  });
}
