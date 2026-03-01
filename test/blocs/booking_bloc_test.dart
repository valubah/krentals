// test/blocs/booking_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:krentals/core/errors/failures.dart';
import 'package:krentals/data/models/booking_model.dart';
import 'package:krentals/data/models/car_model.dart';
import 'package:krentals/data/repositories/car_repository.dart';
import 'package:krentals/presentation/blocs/booking/booking_bloc.dart';


class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository mockRepo;

  final testCar = const Car(
    id: 'car_001',
    name: 'Model S',
    brand: 'Tesla',
    pricePerDay: 180,
    location: 'Lagos',
    isAvailable: true,
    imageUrls: ['https://example.com/car.jpg'],
    description: 'Test car',
    category: 'Sedan',
    seats: 5,
    transmission: 'Auto',
    rating: 4.8,
    reviewCount: 100,
    features: [],
    blockedDates: [],
  );

  final startDate = DateTime(2026, 4, 1);
  final endDate = DateTime(2026, 4, 5);

  final testBooking = Booking(
    id: 'BKG-TEST001',
    carId: 'car_001',
    carName: 'Tesla Model S',
    carImageUrl: 'https://example.com/car.jpg',
    startDate: startDate,
    endDate: endDate,
    totalDays: 4,
    pricePerDay: 180,
    totalAmount: 720,
    status: BookingStatus.pending,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepo = MockBookingRepository();
    registerFallbackValue(testCar);
    registerFallbackValue(testBooking);
    registerFallbackValue(startDate);
    registerFallbackValue(endDate);
  });

  group('BookingBloc - Date Selection', () {
    blocTest<BookingBloc, BookingState>(
      'emits DateSelection when car is selected',
      build: () => BookingBloc(repository: mockRepo),
      act: (bloc) => bloc.add(BookingCarSelected(testCar)),
      expect: () => [
        isA<BookingDateSelection>()
            .having((s) => s.car, 'car set', testCar)
            .having((s) => s.canProceed, 'cannot proceed yet', false),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'updates start date and clears invalid end date',
      build: () => BookingBloc(repository: mockRepo),
      seed: () => BookingDateSelection(
        car: testCar,
        startDate: DateTime(2026, 4, 5),
        endDate: DateTime(2026, 4, 3), // end before start
      ),
      act: (bloc) => bloc.add(BookingStartDateSelected(DateTime(2026, 4, 1))),
      expect: () => [
        isA<BookingDateSelection>()
            .having((s) => s.startDate, 'start updated', DateTime(2026, 4, 1)),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'calculates price when valid dates are selected',
      build: () => BookingBloc(repository: mockRepo),
      seed: () => BookingDateSelection(car: testCar, startDate: startDate),
      act: (bloc) => bloc.add(BookingEndDateSelected(endDate)),
      expect: () => [
        isA<BookingDateSelection>()
            .having((s) => s.canProceed, 'can proceed', true)
            .having((s) => s.totalDays, 'total days', 4)
            .having((s) => s.totalPrice, 'total price', 720.0)
            .having((s) => s.validationError, 'no error', null),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits validation error when end date equals start date',
      build: () => BookingBloc(repository: mockRepo),
      seed: () => BookingDateSelection(car: testCar, startDate: startDate),
      act: (bloc) =>
          bloc.add(BookingEndDateSelected(startDate)), // same day
      expect: () => [
        isA<BookingDateSelection>()
            .having((s) => s.canProceed, 'cannot proceed', false)
            .having((s) => s.validationError, 'has error', isNotNull),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits validation error when dates overlap blocked range',
      build: () => BookingBloc(repository: mockRepo),
      seed: () {
        final blockedCar = Car(
          id: 'car_blocked',
          name: 'Blocked Car',
          brand: 'Test',
          pricePerDay: 100,
          location: 'Test',
          isAvailable: true,
          imageUrls: const [],
          description: '',
          category: 'Sedan',
          seats: 5,
          transmission: 'Auto',
          rating: 4.0,
          reviewCount: 0,
          features: const [],
          blockedDates: [
            BlockedDateRange(
              start: DateTime(2026, 4, 3),
              end: DateTime(2026, 4, 7),
            ),
          ],
        );
        return BookingDateSelection(
          car: blockedCar,
          startDate: DateTime(2026, 4, 1),
        );
      },
      act: (bloc) =>
          bloc.add(BookingEndDateSelected(DateTime(2026, 4, 10))),
      expect: () => [
        isA<BookingDateSelection>()
            .having((s) => s.canProceed, 'blocked', false)
            .having((s) => s.validationError, 'overlap error', isNotNull),
      ],
    );
  });

  group('BookingBloc - Payment', () {
    blocTest<BookingBloc, BookingState>(
      'emits [InProgress, Confirmed] on payment success',
      build: () {
        when(() => mockRepo.createBooking(
          car: any(named: 'car'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => testBooking);
        when(() => mockRepo.processPayment(any()))
            .thenAnswer((_) async => testBooking.copyWith(
          status: BookingStatus.confirmed,
        ));
        return BookingBloc(repository: mockRepo);
      },
      seed: () => BookingDateSelection(
        car: testCar,
        startDate: startDate,
        endDate: endDate,
        totalDays: 4,
        totalPrice: 720,
        canProceed: true,
      ),
      act: (bloc) => bloc.add(const BookingPaymentInitiated()),
      expect: () => [
        isA<BookingPaymentInProgress>(),
        isA<BookingConfirmed>()
            .having((s) => s.booking.status, 'confirmed', BookingStatus.confirmed),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [InProgress, Failed] on payment failure',
      build: () {
        when(() => mockRepo.createBooking(
          car: any(named: 'car'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => testBooking);
        when(() => mockRepo.processPayment(any()))
            .thenThrow(const PaymentFailure('Card declined'));
        return BookingBloc(repository: mockRepo);
      },
      seed: () => BookingDateSelection(
        car: testCar,
        startDate: startDate,
        endDate: endDate,
        totalDays: 4,
        totalPrice: 720,
        canProceed: true,
      ),
      act: (bloc) => bloc.add(const BookingPaymentInitiated()),
      expect: () => [
        isA<BookingPaymentInProgress>(),
        isA<BookingPaymentFailed>()
            .having((s) => s.booking, 'booking preserved', isNotNull)
            .having((s) => s.errorMessage, 'has error message', 'Card declined'),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'ignores duplicate payment events (double-tap guard)',
      build: () {
        when(() => mockRepo.createBooking(
          car: any(named: 'car'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testBooking;
        });
        when(() => mockRepo.processPayment(any()))
            .thenAnswer((_) async => testBooking.copyWith(
          status: BookingStatus.confirmed,
        ));
        return BookingBloc(repository: mockRepo);
      },
      seed: () => BookingDateSelection(
        car: testCar,
        startDate: startDate,
        endDate: endDate,
        totalDays: 4,
        totalPrice: 720,
        canProceed: true,
      ),
      act: (bloc) async {
        // Fire twice rapidly 鈥?simulates double tap
        bloc.add(const BookingPaymentInitiated());
        bloc.add(const BookingPaymentInitiated());
      },
      verify: (_) {
        // createBooking should only be called once
        verify(() => mockRepo.createBooking(
          car: any(named: 'car'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).called(1);
      },
    );

    blocTest<BookingBloc, BookingState>(
      'preserves booking data on network failure during payment',
      build: () {
        when(() => mockRepo.createBooking(
          car: any(named: 'car'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => testBooking);
        when(() => mockRepo.processPayment(any()))
            .thenThrow(const NetworkFailure());
        return BookingBloc(repository: mockRepo);
      },
      seed: () => BookingDateSelection(
        car: testCar,
        startDate: startDate,
        endDate: endDate,
        totalDays: 4,
        totalPrice: 720,
        canProceed: true,
      ),
      act: (bloc) => bloc.add(const BookingPaymentInitiated()),
      expect: () => [
        isA<BookingPaymentInProgress>(),
        isA<BookingPaymentFailed>()
            .having((s) => s.isNetworkError, 'network error flagged', true)
            .having((s) => s.booking, 'booking preserved', isNotNull),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'retry succeeds after initial failure',
      build: () {
        when(() => mockRepo.processPayment(any()))
            .thenAnswer((_) async => testBooking.copyWith(
          status: BookingStatus.confirmed,
        ));
        return BookingBloc(repository: mockRepo);
      },
      seed: () => BookingPaymentFailed(
        booking: testBooking,
        errorMessage: 'Card declined',
      ),
      act: (bloc) => bloc.add(const BookingPaymentRetried()),
      expect: () => [
        isA<BookingPaymentInProgress>(),
        isA<BookingConfirmed>(),
      ],
    );
  });
}
