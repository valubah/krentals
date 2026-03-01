// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment was declined. Please try again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class BookingConflictFailure extends Failure {
  const BookingConflictFailure([super.message = 'Selected dates are no longer available.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
