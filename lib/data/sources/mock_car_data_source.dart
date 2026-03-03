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
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800', // Front
        'https://images.unsplash.com/photo-1617788138021-36fdb31a9412?w=800', // Side
        'https://images.unsplash.com/photo-1617650637118-245f3c9ea565?w=800', // Interior/Rear
      ],
      'description':
          'Experience the pinnacle of electric performance. The Tesla Model S Plaid accelerates from 0-60 mph in under 2 seconds, offering a range of 396 miles. Premium autopilot, minimalist interior, and over-the-air updates included.',
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
        'Wi-Fi Hotspot',
      ],
      'blockedDates': [
        {'start': '2026-03-05T00:00:00.000', 'end': '2026-03-09T00:00:00.000'},
        {'start': '2026-03-18T00:00:00.000', 'end': '2026-03-22T00:00:00.000'},
      ],
    },
    {
      'id': 'car_002',
      'name': 'Range Rover Sport',
      'brand': 'Land Rover',
      'pricePerDay': 220.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800', // Front
        'https://images.unsplash.com/photo-1519702213-912fc996d741?w=800', // Side
        'https://images.unsplash.com/photo-1521743603403-f36894c264b4?w=800', // Detail
      ],
      'description':
          'Commanding luxury and unstoppable capability. The Range Rover Sport combines breathtaking performance with refined British craftsmanship. Ideal for city driving or off-road adventures across any terrain.',
      'category': 'SUV',
      'seats': 7,
      'transmission': 'Automatic',
      'rating': 4.8,
      'reviewCount': 198,
      'features': [
        '4WD',
        'Panoramic Roof',
        'Meridian Sound',
        'Air Suspension',
        'Off-Road Mode',
      ],
      'blockedDates': [
        {'start': '2026-03-10T00:00:00.000', 'end': '2026-03-14T00:00:00.000'},
      ],
    },
    {
      'id': 'car_003',
      'name': '911 Carrera S',
      'brand': 'Porsche',
      'pricePerDay': 350.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800', // Front 3/4
        'https://images.unsplash.com/photo-1542362567-b05500269774?w=800', // Side Profile
        'https://images.unsplash.com/photo-1534093607318-f025413f49cb?w=800', // Rear/Detail
      ],
      'description':
          'Pure driving nirvana. The Porsche 911 Carrera S is a sports car perfected over 60 years. With 443 hp, rear-wheel steering, and PASM sport suspension, every drive is an event. Manual or PDK available.',
      'category': 'Sports',
      'seats': 2,
      'transmission': 'PDK',
      'rating': 4.95,
      'reviewCount': 87,
      'features': [
        'Sport Chrono',
        'PASM',
        'Bose Sound',
        'Sport Exhaust',
        'Launch Control',
      ],
      'blockedDates': [
        {'start': '2026-03-01T00:00:00.000', 'end': '2026-03-03T00:00:00.000'},
        {'start': '2026-03-25T00:00:00.000', 'end': '2026-03-31T00:00:00.000'},
      ],
    },
    {
      'id': 'car_004',
      'name': 'G-Wagon AMG',
      'brand': 'Mercedes-Benz',
      'pricePerDay': 290.0,
      'location': 'Port Harcourt, Nigeria',
      'isAvailable': false,
      'imageUrls': [
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=800', // Front 3/4
        'https://images.unsplash.com/photo-1589148625905-0196e8557b6f?w=800', // Side Profile
        'https://images.unsplash.com/photo-1596707323531-e94ade50f001?w=800', // Interior
      ],
      'description':
          'Icon. Legend. G-Class. The Mercedes-AMG G 63 is the definitive luxury off-roader. With its hand-built 4.0L V8 biturbo engine producing 577 hp, it dominates every environment - urban jungle or mountain trail.',
      'category': 'SUV',
      'seats': 5,
      'transmission': 'AMG Speedshift',
      'rating': 4.85,
      'reviewCount': 143,
      'features': [
        'AMG Performance',
        '3 Locking Diffs',
        'Burmester Sound',
        'Heated Seats',
        'Night Package',
      ],
      'blockedDates': [
        {'start': '2026-02-28T00:00:00.000', 'end': '2026-03-30T00:00:00.000'},
      ],
    },
    {
      'id': 'car_005',
      'name': 'Cayenne Turbo',
      'brand': 'Porsche',
      'pricePerDay': 265.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800', // Front
        'https://images.unsplash.com/photo-1610443916035-7c010c73229b?w=800', // Rear 3/4
        'https://images.unsplash.com/photo-1614162692292-7ac56d77771e?w=800', // Interior
      ],
      'description':
          'Where sports performance meets everyday versatility. The Cayenne Turbo puts 541 hp through all four wheels while wrapping you and your passengers in unrivaled Porsche luxury. Family car by day, sports car by night.',
      'category': 'SUV',
      'seats': 5,
      'transmission': 'Tiptronic S',
      'rating': 4.7,
      'reviewCount': 221,
      'features': [
        'Turbo Engine',
        'Air Suspension',
        'Panoramic Roof',
        'PASM',
        'Rear-Wheel Steering',
      ],
      'blockedDates': [
        {'start': '2026-03-07T00:00:00.000', 'end': '2026-03-11T00:00:00.000'},
      ],
    },
    {
      'id': 'car_006',
      'name': 'EQS 580',
      'brand': 'Mercedes-Benz',
      'pricePerDay': 195.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800', // Front
        'https://images.unsplash.com/photo-1617469614457-37dfd08006e2?w=800', // Side
        'https://images.unsplash.com/photo-1617469651910-449e75528825?w=800', // Interior
      ],
      'description':
          'The future of luxury is electric. The Mercedes EQS 580 features the world\'s largest automotive display - the MBUX Hyperscreen - spanning the entire dashboard. 516 hp, 350-mile range, and pampering at every turn.',
      'category': 'Sedan',
      'seats': 5,
      'transmission': 'Automatic',
      'rating': 4.75,
      'reviewCount': 94,
      'features': [
        'MBUX Hyperscreen',
        'Air Suspension',
        'Burmester 3D',
        'HEPA Filter',
        'Rear Axle Steering',
      ],
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
