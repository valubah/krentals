// lib/data/repositories/car_repository.dart

import '../models/car_model.dart';
import '../models/booking_model.dart';
import '../sources/mock_car_data_source.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import 'package:uuid/uuid.dart';

/// Abstract contract - allows mocking in tests and swapping implementations.
abstract class CarRepository {
  Future<List<Car>> getCars();
  Future<Car> getCarById(String id);
}

abstract class BookingRepository {
  Future<Booking> createBooking({
    required Car car,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Booking> processPayment(Booking booking);
}

class CarRepositoryImpl implements CarRepository {
  final MockCarDataSource _dataSource;
  final ConnectivityService _connectivity;

  CarRepositoryImpl({
    required MockCarDataSource dataSource,
    required ConnectivityService connectivity,
  }) : _dataSource = dataSource,
       _connectivity = connectivity;

  @override
  Future<List<Car>> getCars() async {
    if (!await _connectivity.isConnected) {
      throw const NetworkFailure();
    }
    try {
      return await _dataSource.getCars();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<Car> getCarById(String id) async {
    if (!await _connectivity.isConnected) {
      throw const NetworkFailure();
    }
    try {
      return await _dataSource.getCarById(id);
    } on NotFoundException catch (e) {
      throw ServerFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}

class BookingRepositoryImpl implements BookingRepository {
  final MockCarDataSource _dataSource;
  final ConnectivityService _connectivity;
  final Uuid _uuid;

  BookingRepositoryImpl({
    required MockCarDataSource dataSource,
    required ConnectivityService connectivity,
    Uuid? uuid,
  }) : _dataSource = dataSource,
       _connectivity = connectivity,
       _uuid = uuid ?? const Uuid();

  @override
  Future<Booking> createBooking({
    required Car car,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final days = endDate.difference(startDate).inDays;
    if (days <= 0) {
      throw const ValidationFailure('End date must be after start date.');
    }

    final bookingId = 'BKG-${_uuid.v4().substring(0, 8).toUpperCase()}';

    return Booking(
      id: bookingId,
      carId: car.id,
      carName: '${car.brand} ${car.name}',
      carImageUrl: car.imageUrls.first,
      startDate: startDate,
      endDate: endDate,
      totalDays: days,
      pricePerDay: car.pricePerDay,
      totalAmount: car.pricePerDay * days,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Booking> processPayment(Booking booking) async {
    if (!await _connectivity.isConnected) {
      // Preserve booking data, just throw network failure
      throw const NetworkFailure(
        'No internet. Your booking details are saved - try again when connected.',
      );
    }

    try {
      final result = await _dataSource.processPayment(
        bookingId: booking.id,
        amount: booking.totalAmount,
        carId: booking.carId,
        startDate: booking.startDate,
        endDate: booking.endDate,
      );

      // Return confirmed booking with transaction reference
      return booking.copyWith(
        id: result.bookingId,
        status: BookingStatus.confirmed,
      );
    } on PaymentException catch (e) {
      throw PaymentFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnknownFailure('Payment failed. Please try again.');
    }
  }
}
