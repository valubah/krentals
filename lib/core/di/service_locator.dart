// lib/core/di/service_locator.dart

import '../services/connectivity_service.dart';
import '../../data/sources/mock_car_data_source.dart';
import '../../data/repositories/car_repository.dart';

class ServiceLocator {
  static late final CarRepository carRepository;
  static late final BookingRepository bookingRepository;

  static void setup() {
    final connectivity = ConnectivityServiceImpl();
    final dataSource = MockCarDataSource();

    carRepository = CarRepositoryImpl(
      dataSource: dataSource,
      connectivity: connectivity,
    );

    bookingRepository = BookingRepositoryImpl(
      dataSource: dataSource,
      connectivity: connectivity,
    );
  }
}
