// lib/presentation/screens/confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/booking_model.dart';
import '../widgets/app_widgets.dart';

class ConfirmationScreen extends StatefulWidget {
  final Booking booking;
  const ConfirmationScreen({super.key, required this.booking});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _contentController;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    );

    _checkController.forward().then((_) => _contentController.forward());
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return PopScope(
      canPop: false, // Prevent back - booking is confirmed
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // --- Success Animation ---
                        ScaleTransition(
                          scale: _checkScale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            children: [
                              Text(
                                'Booking Confirmed! 🎉',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your car has been successfully reserved.\nHave a great trip!',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Booking Card ---
                        FadeTransition(
                          opacity: _contentFade,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Booking ID header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Booking Details',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    StatusBadge.confirmed(),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    color: AppTheme.divider,
                                    height: 1,
                                  ),
                                ),

                                // Booking ID with copy
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Booking ID',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(fontSize: 11),
                                          ),
                                          Text(
                                            booking.id,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppTheme.primary,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy_outlined,
                                        size: 18,
                                        color: AppTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: booking.id),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Booking ID copied!'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),
                                InfoRow(
                                  icon: Icons.directions_car_outlined,
                                  label: 'Vehicle',
                                  value: booking.carName,
                                ),
                                const SizedBox(height: 10),
                                InfoRow(
                                  icon: Icons.today_outlined,
                                  label: 'Pick-up',
                                  value: BookingDateUtils.toDisplay(
                                    booking.startDate,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InfoRow(
                                  icon: Icons.event_outlined,
                                  label: 'Return',
                                  value: BookingDateUtils.toDisplay(
                                    booking.endDate,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InfoRow(
                                  icon: Icons.schedule_outlined,
                                  label: 'Duration',
                                  value:
                                      '${booking.totalDays} day${booking.totalDays > 1 ? 's' : ''}',
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    color: AppTheme.divider,
                                    height: 1,
                                  ),
                                ),

                                // Total
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Charged',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '\$${booking.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.success,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tip
                        FadeTransition(
                          opacity: _contentFade,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.tips_and_updates_outlined,
                                  size: 18,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Show this booking ID at pick-up. Keep it safe!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primary.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Back to Home ---
                FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: () {
                          // Pop all screens back to listing
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: const Text('Back to Listings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
