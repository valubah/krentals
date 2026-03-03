// lib/data/sources/mock_car_data_source.dart
/*
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
      'name': 'i4 eDrive35',
      'brand': 'BMW',
      'pricePerDay': 145.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
        'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
      ],
      'description':
      'Experience the future of driving with the BMW i4. This all-electric Gran Coupe combines emission-free driving with dynamic performance and luxury.',
      'category': 'Electric',
      'seats': 5,
      'transmission': 'Single Speed',
      'rating': 4.9,
      'reviewCount': 124,
      'features': [
        'Electric Drivetrain',
        'iDrive 8.5',
        'Heated Seats',
        'Curved Display',
      ],
      'blockedDates': [],
    },
    {
      'id': 'car_002',
      'name': 'Corvette Stingray',
      'brand': 'Chevrolet',
      'pricePerDay': 280.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
        'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',
      ],
      'description':
      'The mid-engine masterpiece that redefined the American supercar. Unmatched performance, sharp handling, and a cockpit designed for the driver.',
      'category': 'Sports',
      'seats': 2,
      'transmission': '8-Speed Dual-Clutch',
      'rating': 4.95,
      'reviewCount': 89,
      'features': ['V8 Engine', 'Bose Performance Series', 'Z51 Package'],
      'blockedDates': [],
    },
    {
      'id': 'car_003',
      'name': 'Santa Fe Sport',
      'brand': 'Hyundai',
      'pricePerDay': 85.0,
      'location': 'Port Harcourt, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800&q=80',
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80',
        'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800&q=80',
      ],
      'description':
      'A versatile and reliable SUV perfect for family trips or city commutes. Offers a spacious interior and smooth ride quality.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '6-Speed Automatic',
      'rating': 4.7,
      'reviewCount': 156,
      'features': ['Cargo Space', 'Rearview Camera', 'Blind Spot Detection'],
      'blockedDates': [],
    },
    {
      'id': 'car_004',
      'name': 'Corolla LE 2025',
      'brand': 'Toyota',
      'pricePerDay': 65.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&q=80',
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80',
      ],
      'description':
      'Efficiency meets reliability in the 2025 Corolla LE. A perfect choice for daily driving with advanced safety features and modern tech.',
      'category': 'Sedan',
      'seats': 5,
      'transmission': 'CVT',
      'rating': 4.8,
      'reviewCount': 210,
      'features': ['Toyota Safety Sense', 'Apple CarPlay', 'Fuel Efficient'],
      'blockedDates': [],
    },
    {
      'id': 'car_005',
      'name': 'Tucson 2019',
      'brand': 'Hyundai',
      'pricePerDay': 75.0,
      'location': 'Ibadan, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=80',
        'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&q=80',
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800&q=80',
      ],
      'description':
      'Comfortable, quiet, and packed with value. The 2019 Tucson remains a top choice for those seeking a dependable compact SUV.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '6-Speed Automatic',
      'rating': 4.6,
      'reviewCount': 178,
      'features': ['Lane Keep Assist', 'Forward Collision Warning', 'Spacious'],
      'blockedDates': [],
    },
    {
      'id': 'car_006',
      'name': 'GV70 2.5T 2024',
      'brand': 'Genesis',
      'pricePerDay': 160.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80',
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&q=80',
        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800&q=80',
      ],
      'description':
      'Luxury redefined in SUV form. The GV70 offers a stunning exterior, a world-class interior, and punchy performance from its turbo engine.',
      'category': 'Luxury SUV',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 4.9,
      'reviewCount': 67,
      'features': ['14.5" Navigation', 'AWD', 'Heated Seats', 'Premium Audio'],
      'blockedDates': [],
    },
    {
      'id': 'car_007',
      'name': 'Mustang EcoBoost 2023',
      'brand': 'Ford',
      'pricePerDay': 150.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1547744152-14d985cb937f?w=800&q=80',
        'https://images.unsplash.com/photo-1612544448445-b8232cff3b6c?w=800&q=80',
        'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&q=80',
      ],
      'description':
      'The iconic American pony car. The EcoBoost Premium offers the perfect balance of Mustang style and turbocharged efficiency.',
      'category': 'Sports',
      'seats': 4,
      'transmission': '10-Speed Automatic',
      'rating': 4.85,
      'reviewCount': 112,
      'features': ['Turbocharged', 'Premium Interior', 'Track Apps', 'SYNC 3'],
      'blockedDates': [],
    },
    {
      'id': 'car_008',
      'name': 'Bentayga Azure 2023',
      'brand': 'Bentley',
      'pricePerDay': 850.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=800&q=80',
        'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?w=800&q=80',
        'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?w=800&q=80',
      ],
      'description':
      'Experience the absolute peak of SUV luxury. Hand-crafted in Crewe, the Bentayga Azure offers effortless performance and unparalleled refinement.',
      'category': 'Ultra Luxury',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 5.0,
      'reviewCount': 34,
      'features': [
        'V8 Engine',
        'Mulliner Spec',
        'Wellness Seats',
        'Naim Audio',
      ],
      'blockedDates': [],
    },
    {
      'id': 'car_009',
      'name': 'Atlas Cross Sport SE 2026',
      'brand': 'Volkswagen',
      'pricePerDay': 110.0,
      'location': 'Kano, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80',
        'https://images.unsplash.com/photo-1546614042-7df3c24c9e5d?w=800&q=80',
        'https://images.unsplash.com/photo-1490902931801-d6f80ca94fe4?w=800&q=80',
      ],
      'description':
      'Stylish and spacious with a bold, coupe-like profile. The 2026 Atlas Cross Sport delivers modern tech and versatility for any adventure.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 4.75,
      'reviewCount': 45,
      'features': [
        'IQ.DRIVE',
        'Wireless Charging',
        '12" Display',
        'V-Tex Seats',
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

 */

// lib/data/sources/mock_car_data_source.dart

import 'dart:async';
import 'dart:math';
import '../models/car_model.dart';

class MockCarDataSource {
  final Random _random = Random();

  Future<void> _delay([int ms = 800]) =>
      Future.delayed(Duration(milliseconds: ms));

  static final List<Map<String, dynamic>> _carsJson = [
    {
      'id': 'car_001',
      'name': 'i4 eDrive35',
      'brand': 'BMW',
      'pricePerDay': 145.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_001_1.png',
        'assets/images/cars/car_001_2.png',
        'assets/images/cars/car_001_3.png',
      ],
      'description':
          'Experience the future of driving with the BMW i4. This all-electric Gran Coupe combines emission-free driving with dynamic performance and luxury.',
      'category': 'Electric',
      'seats': 5,
      'transmission': 'Single Speed',
      'rating': 4.9,
      'reviewCount': 124,
      'features': [
        'Electric Drivetrain',
        'iDrive 8.5',
        'Heated Seats',
        'Curved Display',
      ],
      'blockedDates': [],
    },
    {
      'id': 'car_002',
      'name': 'Corvette Stingray',
      'brand': 'Chevrolet',
      'pricePerDay': 280.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_002_1.png',
        'assets/images/cars/car_002_2.png',
        'assets/images/cars/car_002_3.png',
      ],
      'description':
          'The mid-engine masterpiece that redefined the American supercar. Unmatched performance, sharp handling, and a cockpit designed for the driver.',
      'category': 'Sports',
      'seats': 2,
      'transmission': '8-Speed Dual-Clutch',
      'rating': 4.95,
      'reviewCount': 89,
      'features': ['V8 Engine', 'Bose Performance Series', 'Z51 Package'],
      'blockedDates': [],
    },
    {
      'id': 'car_003',
      'name': 'Santa Fe Sport',
      'brand': 'Hyundai',
      'pricePerDay': 85.0,
      'location': 'Port Harcourt, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_003_1.png',
        'assets/images/cars/car_003_2.png',
        'assets/images/cars/car_003_3.png',
      ],
      'description':
          'A versatile and reliable SUV perfect for family trips or city commutes. Offers a spacious interior and smooth ride quality.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '6-Speed Automatic',
      'rating': 4.7,
      'reviewCount': 156,
      'features': ['Cargo Space', 'Rearview Camera', 'Blind Spot Detection'],
      'blockedDates': [],
    },
    {
      'id': 'car_004',
      'name': 'Corolla LE 2025',
      'brand': 'Toyota',
      'pricePerDay': 65.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_004_1.png',
        'assets/images/cars/car_004_2.png',
        'assets/images/cars/car_004_3.png',
      ],
      'description':
          'Efficiency meets reliability in the 2025 Corolla LE. A perfect choice for daily driving with advanced safety features and modern tech.',
      'category': 'Sedan',
      'seats': 5,
      'transmission': 'CVT',
      'rating': 4.8,
      'reviewCount': 210,
      'features': ['Toyota Safety Sense', 'Apple CarPlay', 'Fuel Efficient'],
      'blockedDates': [],
    },
    {
      'id': 'car_005',
      'name': 'Tucson 2019',
      'brand': 'Hyundai',
      'pricePerDay': 75.0,
      'location': 'Ibadan, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_005_1.png',
        'assets/images/cars/car_005_2.png',
        'assets/images/cars/car_005_3.png',
      ],
      'description':
          'Comfortable, quiet, and packed with value. The 2019 Tucson remains a top choice for those seeking a dependable compact SUV.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '6-Speed Automatic',
      'rating': 4.6,
      'reviewCount': 178,
      'features': ['Lane Keep Assist', 'Forward Collision Warning', 'Spacious'],
      'blockedDates': [],
    },
    {
      'id': 'car_006',
      'name': 'GV70 2.5T 2024',
      'brand': 'Genesis',
      'pricePerDay': 160.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_006_1.png',
        'assets/images/cars/car_006_2.png',
        'assets/images/cars/car_006_3.png',
      ],
      'description':
          'Luxury redefined in SUV form. The GV70 offers a stunning exterior, a world-class interior, and punchy performance from its turbo engine.',
      'category': 'Luxury SUV',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 4.9,
      'reviewCount': 67,
      'features': ['14.5" Navigation', 'AWD', 'Heated Seats', 'Premium Audio'],
      'blockedDates': [],
    },
    {
      'id': 'car_007',
      'name': 'Mustang EcoBoost 2023',
      'brand': 'Ford',
      'pricePerDay': 150.0,
      'location': 'Abuja, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_007_1.png',
        'assets/images/cars/car_007_2.png',
        'assets/images/cars/car_007_3.png',
      ],
      'description':
          'The iconic American pony car. The EcoBoost Premium offers the perfect balance of Mustang style and turbocharged efficiency.',
      'category': 'Sports',
      'seats': 4,
      'transmission': '10-Speed Automatic',
      'rating': 4.85,
      'reviewCount': 112,
      'features': ['Turbocharged', 'Premium Interior', 'Track Apps', 'SYNC 3'],
      'blockedDates': [],
    },
    {
      'id': 'car_008',
      'name': 'Bentayga Azure 2023',
      'brand': 'Bentley',
      'pricePerDay': 850.0,
      'location': 'Lagos, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_008_1.png',
        'assets/images/cars/car_008_2.png',
        'assets/images/cars/car_008_3.png',
      ],
      'description':
          'Experience the absolute peak of SUV luxury. Hand-crafted in Crewe, the Bentayga Azure offers effortless performance and unparalleled refinement.',
      'category': 'Ultra Luxury',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 5.0,
      'reviewCount': 34,
      'features': [
        'V8 Engine',
        'Mulliner Spec',
        'Wellness Seats',
        'Naim Audio',
      ],
      'blockedDates': [],
    },
    {
      'id': 'car_009',
      'name': 'Atlas Cross Sport SE 2026',
      'brand': 'Volkswagen',
      'pricePerDay': 110.0,
      'location': 'Kano, Nigeria',
      'isAvailable': true,
      'imageUrls': [
        'assets/images/cars/car_009_1.png',
        'assets/images/cars/car_009_2.png',
        'assets/images/cars/car_009_3.png',
      ],
      'description':
          'Stylish and spacious with a bold, coupe-like profile. The 2026 Atlas Cross Sport delivers modern tech and versatility for any adventure.',
      'category': 'SUV',
      'seats': 5,
      'transmission': '8-Speed Automatic',
      'rating': 4.75,
      'reviewCount': 45,
      'features': [
        'IQ.DRIVE',
        'Wireless Charging',
        '12" Display',
        'V-Tex Seats',
      ],
      'blockedDates': [],
    },
  ];

  Future<List<Car>> getCars() async {
    await _delay(1200);
    // Reduced to 2% chance to avoid frequent interruptions
    if (_random.nextInt(50) == 0) {
      throw const ServerException('The connection is unstable.');
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

  Future<PaymentResult> processPayment({
    required String bookingId,
    required double amount,
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _delay(2000);
    final shouldFail = _random.nextDouble() < 0.3;
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
