// test/blocs/car_list_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:krentals/core/errors/failures.dart';
import 'package:krentals/data/models/car_model.dart';
import 'package:krentals/data/repositories/car_repository.dart';
import 'package:krentals/presentation/blocs/car_list/car_list_bloc.dart';


class MockCarRepository extends Mock implements CarRepository {}

void main() {
  late MockCarRepository mockRepo;

  final testCars = [
    const Car(
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
      features: ['Autopilot'],
      blockedDates: [],
    ),
    const Car(
      id: 'car_002',
      name: 'Range Rover',
      brand: 'Land Rover',
      pricePerDay: 220,
      location: 'Abuja',
      isAvailable: true,
      imageUrls: ['https://example.com/car2.jpg'],
      description: 'Test SUV',
      category: 'SUV',
      seats: 7,
      transmission: 'Auto',
      rating: 4.7,
      reviewCount: 80,
      features: ['4WD'],
      blockedDates: [],
    ),
  ];

  setUp(() {
    mockRepo = MockCarRepository();
  });

  group('CarListBloc', () {
    blocTest<CarListBloc, CarListState>(
      'emits [Loading, Loaded] when load succeeds',
      build: () {
        when(() => mockRepo.getCars()).thenAnswer((_) async => testCars);
        return CarListBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CarListLoadRequested()),
      expect: () => [
        const CarListLoading(),
        isA<CarListLoaded>()
            .having((s) => s.cars.length, 'car count', 2)
            .having((s) => s.filteredCars.length, 'filtered count', 2),
      ],
    );

    blocTest<CarListBloc, CarListState>(
      'emits [Loading, Empty] when no cars returned',
      build: () {
        when(() => mockRepo.getCars()).thenAnswer((_) async => []);
        return CarListBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CarListLoadRequested()),
      expect: () => [
        const CarListLoading(),
        const CarListEmpty(),
      ],
    );

    blocTest<CarListBloc, CarListState>(
      'emits [Loading, Error] on NetworkFailure',
      build: () {
        when(() => mockRepo.getCars()).thenThrow(const NetworkFailure());
        return CarListBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CarListLoadRequested()),
      expect: () => [
        const CarListLoading(),
        isA<CarListError>()
            .having((s) => s.isNetworkError, 'isNetworkError', true),
      ],
    );

    blocTest<CarListBloc, CarListState>(
      'emits [Loading, Error] on ServerFailure',
      build: () {
        when(() => mockRepo.getCars())
            .thenThrow(const ServerFailure('Server error'));
        return CarListBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CarListLoadRequested()),
      expect: () => [
        const CarListLoading(),
        isA<CarListError>()
            .having((s) => s.isNetworkError, 'isNetworkError', false),
      ],
    );

    blocTest<CarListBloc, CarListState>(
      'filters cars by category correctly',
      build: () {
        when(() => mockRepo.getCars()).thenAnswer((_) async => testCars);
        return CarListBloc(repository: mockRepo);
      },
      seed: () => CarListLoaded(
        cars: testCars,
        filteredCars: testCars,
      ),
      act: (bloc) =>
          bloc.add(const CarListFilterChanged(category: 'SUV')),
      expect: () => [
        isA<CarListLoaded>()
            .having((s) => s.filteredCars.length, 'filtered to SUV only', 1)
            .having(
                (s) => s.filteredCars.first.category, 'is SUV', 'SUV'),
      ],
    );

    blocTest<CarListBloc, CarListState>(
      'refresh preserves current data while loading',
      build: () {
        when(() => mockRepo.getCars()).thenAnswer((_) async => testCars);
        return CarListBloc(repository: mockRepo);
      },
      seed: () => CarListLoaded(cars: testCars, filteredCars: testCars),
      act: (bloc) => bloc.add(const CarListRefreshRequested()),
      expect: () => [
        isA<CarListRefreshing>()
            .having((s) => s.currentCars, 'preserves data', testCars),
        isA<CarListLoaded>(),
      ],
    );
  });
}
