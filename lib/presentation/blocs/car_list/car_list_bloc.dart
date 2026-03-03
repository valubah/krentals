// lib/presentation/blocs/car_list/car_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/car_model.dart';
import '../../../data/repositories/car_repository.dart';
import '../../../core/errors/failures.dart';

// --- Events ---
abstract class CarListEvent extends Equatable {
  const CarListEvent();
  @override
  List<Object?> get props => [];
}

class CarListLoadRequested extends CarListEvent {
  const CarListLoadRequested();
}

class CarListRefreshRequested extends CarListEvent {
  const CarListRefreshRequested();
}

class CarListFilterChanged extends CarListEvent {
  final String? category;
  final String? searchQuery;
  const CarListFilterChanged({this.category, this.searchQuery});
  @override
  List<Object?> get props => [category, searchQuery];
}

// --- States ---
abstract class CarListState extends Equatable {
  const CarListState();
  @override
  List<Object?> get props => [];
}

class CarListInitial extends CarListState {
  const CarListInitial();
}

class CarListLoading extends CarListState {
  const CarListLoading();
}

class CarListRefreshing extends CarListState {
  final List<Car> currentCars;
  const CarListRefreshing(this.currentCars);
  @override
  List<Object?> get props => [currentCars];
}

class CarListLoaded extends CarListState {
  final List<Car> cars;
  final List<Car> filteredCars;
  final String? activeCategory;
  final String? activeSearchQuery;

  const CarListLoaded({
    required this.cars,
    required this.filteredCars,
    this.activeCategory,
    this.activeSearchQuery,
  });

  @override
  List<Object?> get props => [
    cars,
    filteredCars,
    activeCategory,
    activeSearchQuery,
  ];
}

class CarListEmpty extends CarListState {
  const CarListEmpty();
}

class CarListError extends CarListState {
  final String message;
  final bool isNetworkError;
  const CarListError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

// --- BLoC ---
class CarListBloc extends Bloc<CarListEvent, CarListState> {
  final CarRepository _repository;

  CarListBloc({required CarRepository repository})
    : _repository = repository,
      super(const CarListInitial()) {
    on<CarListLoadRequested>(_onLoad);
    on<CarListRefreshRequested>(_onRefresh);
    on<CarListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoad(
    CarListLoadRequested event,
    Emitter<CarListState> emit,
  ) async {
    emit(const CarListLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    CarListRefreshRequested event,
    Emitter<CarListState> emit,
  ) async {
    // Show current data while refreshing
    final current = state is CarListLoaded
        ? (state as CarListLoaded).cars
        : <Car>[];
    emit(CarListRefreshing(current));
    await _fetchAndEmit(emit);
  }

  Future<void> _onFilterChanged(
    CarListFilterChanged event,
    Emitter<CarListState> emit,
  ) async {
    if (state is! CarListLoaded) return;

    final current = state as CarListLoaded;
    final filtered = _applyFilters(
      current.cars,
      category: event.category,
      searchQuery: event.searchQuery,
    );

    emit(
      CarListLoaded(
        cars: current.cars,
        filteredCars: filtered,
        activeCategory: event.category,
        activeSearchQuery: event.searchQuery,
      ),
    );
  }

  Future<void> _fetchAndEmit(Emitter<CarListState> emit) async {
    try {
      final cars = await _repository.getCars();

      if (cars.isEmpty) {
        emit(const CarListEmpty());
        return;
      }

      // Preserve active filters if any
      final currentLoaded = state is CarListLoaded
          ? (state as CarListLoaded)
          : null;
      final activeCategory = currentLoaded?.activeCategory;
      final activeSearchQuery = currentLoaded?.activeSearchQuery;

      emit(
        CarListLoaded(
          cars: cars,
          filteredCars: _applyFilters(
            cars,
            category: activeCategory,
            searchQuery: activeSearchQuery,
          ),
          activeCategory: activeCategory,
          activeSearchQuery: activeSearchQuery,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(CarListError(message: e.message, isNetworkError: true));
    } on Failure catch (e) {
      emit(CarListError(message: e.message));
    }
  }

  List<Car> _applyFilters(
    List<Car> cars, {
    String? category,
    String? searchQuery,
  }) {
    var filtered = cars;
    if (category != null && category != 'All') {
      filtered = filtered.where((c) => c.category == category).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.brand.toLowerCase().contains(query) ||
                c.name.toLowerCase().contains(query) ||
                c.location.toLowerCase().contains(query),
          )
          .toList();
    }
    return filtered;
  }
}
