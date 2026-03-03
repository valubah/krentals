// lib/presentation/blocs/booking/booking_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/car_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/date_utils.dart';

// --- Events ---
abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class BookingCarSelected extends BookingEvent {
  final Car car;
  const BookingCarSelected(this.car);
  @override
  List<Object?> get props => [car];
}

class BookingStartDateSelected extends BookingEvent {
  final DateTime date;
  const BookingStartDateSelected(this.date);
  @override
  List<Object?> get props => [date];
}

class BookingEndDateSelected extends BookingEvent {
  final DateTime date;
  const BookingEndDateSelected(this.date);
  @override
  List<Object?> get props => [date];
}

class BookingDateRangeCleared extends BookingEvent {
  const BookingDateRangeCleared();
}

/// User taps "Confirm & Pay"
class BookingPaymentInitiated extends BookingEvent {
  const BookingPaymentInitiated();
}

/// User retries after payment failure
class BookingPaymentRetried extends BookingEvent {
  const BookingPaymentRetried();
}

/// Reset the entire booking flow
class BookingReset extends BookingEvent {
  const BookingReset();
}

// --- States ---
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Dates are being selected / validated
class BookingDateSelection extends BookingState {
  final Car car;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalPrice;
  final int totalDays;
  final String? validationError;
  final bool canProceed;

  const BookingDateSelection({
    required this.car,
    this.startDate,
    this.endDate,
    this.totalPrice = 0,
    this.totalDays = 0,
    this.validationError,
    this.canProceed = false,
  });

  BookingDateSelection copyWith({
    Car? car,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    int? totalDays,
    String? validationError,
    bool clearValidationError = false,
    bool? canProceed,
  }) => BookingDateSelection(
    car: car ?? this.car,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    totalPrice: totalPrice ?? this.totalPrice,
    totalDays: totalDays ?? this.totalDays,
    validationError: clearValidationError
        ? null
        : (validationError ?? this.validationError),
    canProceed: canProceed ?? this.canProceed,
  );

  @override
  List<Object?> get props => [
    car,
    startDate,
    endDate,
    totalPrice,
    totalDays,
    validationError,
    canProceed,
  ];
}

/// Payment is in progress - UI should disable Pay button to prevent double tap
class BookingPaymentInProgress extends BookingState {
  final Booking booking;
  const BookingPaymentInProgress(this.booking);
  @override
  List<Object?> get props => [booking];
}

/// Payment succeeded
class BookingConfirmed extends BookingState {
  final Booking booking;
  const BookingConfirmed(this.booking);
  @override
  List<Object?> get props => [booking];
}

/// Payment failed - booking data preserved for retry
class BookingPaymentFailed extends BookingState {
  final Booking booking; // preserved
  final String errorMessage;
  final bool isNetworkError;

  const BookingPaymentFailed({
    required this.booking,
    required this.errorMessage,
    this.isNetworkError = false,
  });

  @override
  List<Object?> get props => [booking, errorMessage, isNetworkError];
}

// --- BLoC ---
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repository;
  bool _isPaymentInFlight = false; // Guard against double-tap

  BookingBloc({required BookingRepository repository})
    : _repository = repository,
      super(const BookingInitial()) {
    on<BookingCarSelected>(_onCarSelected);
    on<BookingStartDateSelected>(_onStartDateSelected);
    on<BookingEndDateSelected>(_onEndDateSelected);
    on<BookingDateRangeCleared>(_onDateRangeCleared);
    on<BookingPaymentInitiated>(_onPaymentInitiated);
    on<BookingPaymentRetried>(_onPaymentRetried);
    on<BookingReset>(_onReset);
  }

  void _onCarSelected(BookingCarSelected event, Emitter<BookingState> emit) {
    emit(BookingDateSelection(car: event.car));
  }

  void _onStartDateSelected(
    BookingStartDateSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is! BookingDateSelection) return;
    final current = state as BookingDateSelection;

    // Clear end date if it's before the new start
    final newEnd =
        current.endDate != null && current.endDate!.isAfter(event.date)
        ? current.endDate
        : null;

    emit(
      current.copyWith(
        startDate: event.date,
        endDate: newEnd,
        clearValidationError: true,
        canProceed: false,
      ),
    );
  }

  void _onEndDateSelected(
    BookingEndDateSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is! BookingDateSelection) return;
    final current = state as BookingDateSelection;

    // Validate
    final validationError = _validateDates(
      car: current.car,
      startDate: current.startDate,
      endDate: event.date,
    );

    if (validationError != null) {
      emit(
        current.copyWith(
          endDate: event.date,
          validationError: validationError,
          canProceed: false,
        ),
      );
      return;
    }

    final days = BookingDateUtils.daysBetween(current.startDate!, event.date);
    final total = days * current.car.pricePerDay;

    emit(
      current.copyWith(
        endDate: event.date,
        totalDays: days,
        totalPrice: total,
        clearValidationError: true,
        canProceed: true,
      ),
    );
  }

  void _onDateRangeCleared(
    BookingDateRangeCleared event,
    Emitter<BookingState> emit,
  ) {
    if (state is! BookingDateSelection) return;
    final current = state as BookingDateSelection;
    emit(BookingDateSelection(car: current.car));
  }

  Future<void> _onPaymentInitiated(
    BookingPaymentInitiated event,
    Emitter<BookingState> emit,
  ) async {
    // --- Double-tap guard ---
    if (_isPaymentInFlight) return;

    if (state is! BookingDateSelection) return;
    final dateState = state as BookingDateSelection;
    if (!dateState.canProceed) return;

    _isPaymentInFlight = true;

    try {
      final booking = await _repository.createBooking(
        car: dateState.car,
        startDate: dateState.startDate!,
        endDate: dateState.endDate!,
      );

      emit(BookingPaymentInProgress(booking));

      final confirmed = await _repository.processPayment(booking);
      emit(BookingConfirmed(confirmed));
    } on ValidationFailure catch (e) {
      // Revert to date selection with error
      emit(dateState.copyWith(validationError: e.message, canProceed: false));
    } on NetworkFailure catch (e) {
      // Get the in-progress booking if it was created
      final failedBooking = _getInProgressBooking();
      if (failedBooking != null) {
        emit(
          BookingPaymentFailed(
            booking: failedBooking,
            errorMessage: e.message,
            isNetworkError: true,
          ),
        );
      } else {
        emit(dateState.copyWith(validationError: e.message, canProceed: false));
      }
    } on PaymentFailure catch (e) {
      final failedBooking = _getInProgressBooking();
      emit(
        BookingPaymentFailed(booking: failedBooking!, errorMessage: e.message),
      );
    } on Failure catch (e) {
      final failedBooking = _getInProgressBooking();
      if (failedBooking != null) {
        emit(
          BookingPaymentFailed(booking: failedBooking, errorMessage: e.message),
        );
      }
    } finally {
      _isPaymentInFlight = false;
    }
  }

  Future<void> _onPaymentRetried(
    BookingPaymentRetried event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingPaymentFailed) return;
    if (_isPaymentInFlight) return;

    _isPaymentInFlight = true;
    final failedState = state as BookingPaymentFailed;

    emit(BookingPaymentInProgress(failedState.booking));

    try {
      final confirmed = await _repository.processPayment(failedState.booking);
      emit(BookingConfirmed(confirmed));
    } on NetworkFailure catch (e) {
      emit(
        BookingPaymentFailed(
          booking: failedState.booking,
          errorMessage: e.message,
          isNetworkError: true,
        ),
      );
    } on PaymentFailure catch (e) {
      emit(
        BookingPaymentFailed(
          booking: failedState.booking,
          errorMessage: e.message,
        ),
      );
    } on Failure catch (e) {
      emit(
        BookingPaymentFailed(
          booking: failedState.booking,
          errorMessage: e.message,
        ),
      );
    } finally {
      _isPaymentInFlight = false;
    }
  }

  void _onReset(BookingReset event, Emitter<BookingState> emit) {
    _isPaymentInFlight = false;
    emit(const BookingInitial());
  }

  // --- Helpers ---
  Booking? _getInProgressBooking() {
    if (state is BookingPaymentInProgress) {
      return (state as BookingPaymentInProgress).booking;
    }
    return null;
  }

  String? _validateDates({
    required Car car,
    required DateTime? startDate,
    required DateTime endDate,
  }) {
    if (startDate == null) return 'Please select a start date first.';
    if (!endDate.isAfter(startDate)) {
      return 'End date must be after start date.';
    }

    final blockedRanges = car.blockedDates
        .map((b) => DateRange(start: b.start, end: b.end))
        .toList();

    if (BookingDateUtils.doesRangeOverlapBlocked(
      startDate,
      endDate,
      blockedRanges,
    )) {
      return 'Your selected dates include unavailable periods. Please choose different dates.';
    }

    return null;
  }
}
