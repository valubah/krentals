// lib/presentation/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/car_model.dart';
import '../../data/models/booking_model.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/app_widgets.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingConfirmed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmationScreen(booking: state.booking),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingInitial) {
          // Should not happen in normal flow
          return const Scaffold(body: Center(child: Text('No car selected.')));
        }

        return PopScope(
          // Handle back press during payment
          canPop: state is! BookingPaymentInProgress,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state is BookingPaymentInProgress) {
              _showBackDuringPaymentWarning(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Book Car'),
              leading: state is BookingPaymentInProgress
                  ? const SizedBox.shrink()
                  : null,
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BookingState state) {
    if (state is BookingDateSelection) {
      return _DateSelectionBody(state: state);
    }
    if (state is BookingPaymentInProgress) {
      return _PaymentLoadingBody(booking: state.booking);
    }
    if (state is BookingPaymentFailed) {
      return _PaymentFailedBody(state: state);
    }
    return const SizedBox.shrink();
  }

  void _showBackDuringPaymentWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment in Progress'),
        content: const Text(
          'Your payment is being processed. Please wait and do not navigate away. '
          'Leaving now may result in a charge without a confirmed booking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wait'),
          ),
        ],
      ),
    );
  }
}

// 鈹€鈹€鈹€ Date Selection 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

class _DateSelectionBody extends StatelessWidget {
  final BookingDateSelection state;
  const _DateSelectionBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car summary
                _CarSummaryCard(car: state.car),

                const SizedBox(height: 24),

                // Date pickers
                const SectionHeader(title: 'Select Dates'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _DatePickerCard(
                        label: 'Pick-up Date',
                        icon: Icons.flight_takeoff_rounded,
                        date: state.startDate,
                        onTap: () => _selectDate(
                          context,
                          isStart: true,
                          initialDate: state.startDate,
                          car: state.car,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: _DatePickerCard(
                        label: 'Return Date',
                        icon: Icons.flight_land_rounded,
                        date: state.endDate,
                        onTap: state.startDate != null
                            ? () => _selectDate(
                                context,
                                isStart: false,
                                initialDate: state.endDate,
                                car: state.car,
                                minDate: state.startDate!.add(
                                  const Duration(days: 1),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),

                // Validation error
                if (state.validationError != null) ...[
                  const SizedBox(height: 12),
                  _ValidationError(message: state.validationError!),
                ],

                // Price breakdown
                if (state.canProceed) ...[
                  const SizedBox(height: 24),
                  _PriceBreakdown(state: state),
                ],

                const SizedBox(height: 24),

                // Blocked dates reminder
                if (state.car.blockedDates.isNotEmpty)
                  _BlockedDatesReminder(car: state.car),
              ],
            ),
          ),
        ),

        // Bottom CTA
        _BookingBottomBar(state: state),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
    required Car car,
    DateTime? initialDate,
    DateTime? minDate,
  }) async {
    final now = DateTime.now();
    final first = minDate ?? now;
    final last = DateTime(now.year + 1, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? first,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.cardBg,
          ),
        ),
        child: child!,
      ),
      selectableDayPredicate: (day) {
        // Disable individual blocked days
        final ranges = car.blockedDates
            .map((b) => DateRange(start: b.start, end: b.end))
            .toList();
        return !BookingDateUtils.isDateBlocked(day, ranges);
      },
    );

    if (picked == null || !context.mounted) return;

    if (isStart) {
      context.read<BookingBloc>().add(BookingStartDateSelected(picked));
    } else {
      context.read<BookingBloc>().add(BookingEndDateSelected(picked));
    }
  }
}

class _CarSummaryCard extends StatelessWidget {
  final Car car;
  const _CarSummaryCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              car.imageUrls.first,
              width: 72,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 56,
                color: Colors.grey.shade100,
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  car.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          PriceTag(price: car.pricePerDay, fontSize: 16),
        ],
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? date;
  final VoidCallback? onTap;

  const _DatePickerCard({
    required this.label,
    required this.icon,
    this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDate
              ? AppTheme.primary.withValues(alpha: 0.04)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate ? AppTheme.primary : AppTheme.divider,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: hasDate ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: hasDate ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasDate
                  ? DateFormat('MMM dd, yyyy').format(date!)
                  : 'Tap to select',
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                color: hasDate ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationError extends StatelessWidget {
  final String message;
  const _ValidationError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final BookingDateSelection state;
  const _PriceBreakdown({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.today_outlined,
            label: 'Duration',
            value: '${state.totalDays} day${state.totalDays > 1 ? 's' : ''}',
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.attach_money_rounded,
            label: 'Price per day',
            value: '\$${state.car.pricePerDay.toStringAsFixed(0)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '\$${state.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockedDatesReminder extends StatelessWidget {
  final Car car;
  const _BlockedDatesReminder({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.orange.shade700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Note: Some dates are blocked',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Blocked dates will appear greyed out in the calendar.',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  final BookingDateSelection state;
  const _BookingBottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.canProceed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total amount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '\$${state.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          if (state.canProceed) const SizedBox(height: 10),
          FilledButton(
            onPressed: state.canProceed
                ? () => context.read<BookingBloc>().add(
                    const BookingPaymentInitiated(),
                  )
                : null,
            child: Text(
              state.canProceed
                  ? 'Confirm & Pay'
                  : state.startDate == null
                  ? 'Select Pick-up Date'
                  : state.endDate == null
                  ? 'Select Return Date'
                  : 'Fix Date Issues',
            ),
          ),
        ],
      ),
    );
  }
}

// 鈹€鈹€鈹€ Payment Loading 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

class _PaymentLoadingBody extends StatelessWidget {
  final Booking booking;
  const _PaymentLoadingBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Processing Payment',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait and do not close the app.\nThis usually takes a few seconds.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Booking summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Booking ID',
                    value: booking.id,
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.attach_money_rounded,
                    label: 'Amount',
                    value: '\$${booking.totalAmount.toStringAsFixed(2)}',
                    valueColor: AppTheme.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 鈹€鈹€鈹€ Payment Failed 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

class _PaymentFailedBody extends StatelessWidget {
  final BookingPaymentFailed state;
  const _PaymentFailedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Error icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payment_rounded,
                      color: AppTheme.error,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Failed',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage,
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Preserved booking details
                  Text(
                    'Your booking details are saved',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can retry the payment below without re-entering your dates.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.directions_car_outlined,
                          label: 'Car',
                          value: state.booking.carName,
                        ),
                        const SizedBox(height: 10),
                        InfoRow(
                          icon: Icons.today_outlined,
                          label: 'Pick-up',
                          value: BookingDateUtils.toDisplay(
                            state.booking.startDate,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InfoRow(
                          icon: Icons.event_outlined,
                          label: 'Return',
                          value: BookingDateUtils.toDisplay(
                            state.booking.endDate,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InfoRow(
                          icon: Icons.attach_money_rounded,
                          label: 'Total',
                          value:
                              '\$${state.booking.totalAmount.toStringAsFixed(2)}',
                          valueColor: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Retry + Change dates buttons
          Column(
            children: [
              FilledButton.icon(
                onPressed: () => context.read<BookingBloc>().add(
                  const BookingPaymentRetried(),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Payment'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.read<BookingBloc>().add(
                  BookingCarSelected(
                    // We need to re-enter date selection
                    // In a real app you'd cache the Car; for now use bloc state
                    // This is a UX fallback
                    context.read<BookingBloc>().state is BookingPaymentFailed
                        ? _extractCarFromState(context)
                        : _extractCarFromState(context),
                  ),
                ),
                child: const Text('Change Dates'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Car _extractCarFromState(BuildContext context) {
    // In production, Car would be stored in BookingPaymentFailed state or a separate cubit.
    // Here we navigate back and let user restart 鈥?practical for the mock.
    Navigator.pop(context);
    // Return a placeholder (navigator.pop handles it)
    throw StateError('Navigation handled');
  }
}
