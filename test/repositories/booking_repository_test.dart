// test/repositories/booking_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:krentals/core/errors/failures.dart';
import 'package:krentals/data/models/booking_model.dart';
import 'package:krentals/data/models/car_model.dart';
import 'package:krentals/data/repositories/car_repository.dart';
import 'package:krentals/data/sources/mock_car_data_source.dart';
import 'package:krentals/core/services/connectivity_service.dart';

class MockDataSource extends Mock implements MockCarDataSource {}

class MockConnectivity extends Mock implements ConnectivityService {}

void main() {
  late MockDataSource mockDataSource;
  late MockConnectivity mockConnectivity;
  late BookingRepositoryImpl repository;

  final testCar = const Car(
    id: 'car_001',
    name: 'Model S',
    brand: 'Tesla',
    pricePerDay: 180,
    location: 'Lagos',
    isAvailable: true,
    imageUrls: ['https://example.com/car.jpg'],
    description: 'Test',
    category: 'Sedan',
    seats: 5,
    transmission: 'Auto',
    rating: 4.8,
    reviewCount: 100,
    features: [],
    blockedDates: [],
  );

  setUp(() {
    mockDataSource = MockDataSource();
    mockConnectivity = MockConnectivity();
    repository = BookingRepositoryImpl(
      dataSource: mockDataSource,
      connectivity: mockConnectivity,
      uuid: const Uuid(),
    );
  });

  group('BookingRepository.createBooking()', () {
    test('creates booking with correct price calculation', () async {
      final start = DateTime(2026, 4, 1);
      final end = DateTime(2026, 4, 5); // 4 days

      final booking = await repository.createBooking(
        car: testCar,
        startDate: start,
        endDate: end,
      );

      expect(booking.totalDays, 4);
      expect(booking.totalAmount, 720.0); // 4 * 180
      expect(booking.status, BookingStatus.pending);
      expect(booking.id, startsWith('BKG-'));
    });

    test(
      'throws ValidationFailure when end date is not after start date',
      () async {
        final start = DateTime(2026, 4, 5);
        final end = DateTime(2026, 4, 3); // before start

        expect(
          () => repository.createBooking(
            car: testCar,
            startDate: start,
            endDate: end,
          ),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('throws ValidationFailure when start == end date', () async {
      final date = DateTime(2026, 4, 5);

      expect(
        () => repository.createBooking(
          car: testCar,
          startDate: date,
          endDate: date,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('BookingRepository.processPayment()', () {
    final testBooking = Booking(
      id: 'BKG-TEST001',
      carId: 'car_001',
      carName: 'Tesla Model S',
      carImageUrl: 'https://example.com/car.jpg',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 5),
      totalDays: 4,
      pricePerDay: 180,
      totalAmount: 720,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    test('throws NetworkFailure when offline', () async {
      when(() => mockConnectivity.isConnected).thenAnswer((_) async => false);

      expect(
        () => repository.processPayment(testBooking),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('returns confirmed booking on payment success', () async {
      when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
      when(
        () => mockDataSource.processPayment(
          bookingId: any(named: 'bookingId'),
          amount: any(named: 'amount'),
          carId: any(named: 'carId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => PaymentResult(
          transactionId: 'TXN_001',
          bookingId: testBooking.id,
          amount: testBooking.totalAmount,
          timestamp: DateTime.now(),
        ),
      );

      final result = await repository.processPayment(testBooking);

      expect(result.status, BookingStatus.confirmed);
    });

    test('throws PaymentFailure on payment decline', () async {
      when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
      when(
        () => mockDataSource.processPayment(
          bookingId: any(named: 'bookingId'),
          amount: any(named: 'amount'),
          carId: any(named: 'carId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenThrow(
        const PaymentException('Card declined', code: 'PAYMENT_DECLINED'),
      );

      expect(
        () => repository.processPayment(testBooking),
        throwsA(isA<PaymentFailure>()),
      );
    });
  });
}
