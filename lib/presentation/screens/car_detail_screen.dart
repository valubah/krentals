// lib/presentation/screens/car_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_scroll_behavior.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/car_model.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/app_widgets.dart';
import 'booking_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;
  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final _pageController = PageController();
  bool _descriptionExpanded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              // ── Image Carousel App Bar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: isDesktop ? 500 : 300,
                pinned: true,
                backgroundColor: AppTheme.cardBg,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Hero(
                        tag: 'car_${car.id}',
                        child: PageView.builder(
                          controller: _pageController,
                          scrollBehavior: AppScrollBehavior(),
                          itemCount: car.imageUrls.length,
                          itemBuilder: (context, i) {
                            return Stack(
                              children: [
                                SizedBox.expand(
                                  child: Image.asset(
                                    car.imageUrls[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.directions_car_rounded,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // Gradient overlay
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.4),
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Angle Label Badge (Turo-style)
                                Positioned(
                                  bottom: 24,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _getAngleLabel(i),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Page indicator
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: car.imageUrls.length,
                            effect: WormEffect(
                              dotWidth: 8,
                              dotHeight: 8,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      // Photo count badge
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${car.imageUrls.length} photos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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

              // ── Content ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.brand,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accent,
                                        letterSpacing: 1,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  car.name,
                                  style: isDesktop
                                      ? Theme.of(
                                          context,
                                        ).textTheme.displayMedium
                                      : Theme.of(
                                          context,
                                        ).textTheme.displaySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PriceTag(
                                price: car.pricePerDay,
                                fontSize: isDesktop ? 28 : 22,
                              ),
                              const SizedBox(height: 8),
                              AvailabilityBadge(isAvailable: car.isAvailable),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Rating & location
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${car.rating}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${car.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 20),

                      // Specs row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SpecItem(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: car.category,
                          ),
                          _SpecItem(
                            icon: Icons.people_outline,
                            label: 'Seats',
                            value: '${car.seats} people',
                          ),
                          _SpecItem(
                            icon: Icons.settings_outlined,
                            label: 'Gearbox',
                            value: car.transmission,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      const SectionHeader(title: 'About this car'),
                      const SizedBox(height: 10),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _descriptionExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          car.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          car.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => _descriptionExpanded = !_descriptionExpanded,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: AppTheme.accent,
                        ),
                        child: Text(
                          _descriptionExpanded ? 'Show less' : 'Read more',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Features
                      const SectionHeader(title: 'Features'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: car.features
                            .map((f) => _FeatureChip(feature: f))
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      // Availability calendar hint
                      _AvailabilitySection(car: car),

                      const SizedBox(height: 100), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Book Button ────────────────────────────────────────────────────
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : double.infinity,
          ),
          child: _BookingBar(car: car),
        ),
      ),
    );
  }

  String _getAngleLabel(int index) {
    switch (index) {
      case 0:
        return 'FRONT';
      case 1:
        return 'SIDE';
      case 2:
        return 'INTERIOR';
      default:
        return 'REAR';
    }
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String feature;
  const _FeatureChip({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppTheme.success,
          ),
          const SizedBox(width: 6),
          Text(
            feature,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  final Car car;
  const _AvailabilitySection({required this.car});

  @override
  Widget build(BuildContext context) {
    if (car.blockedDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: AppTheme.success,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Fully available — no blocked dates',
              style: TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Unavailable Dates'),
        const SizedBox(height: 10),
        ...car.blockedDates.map(
          (b) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_busy_rounded,
                  color: AppTheme.error,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  '${BookingDateUtils.toDisplay(b.start)}  →  ${BookingDateUtils.toDisplay(b.end)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingBar extends StatelessWidget {
  final Car car;
  const _BookingBar({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting from',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              PriceTag(price: car.pricePerDay, fontSize: 20),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FilledButton(
              onPressed: car.isAvailable
                  ? () {
                      context.read<BookingBloc>().add(BookingCarSelected(car));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<BookingBloc>(),
                            child: const BookingScreen(),
                          ),
                        ),
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text(
                car.isAvailable
                    ? 'Select Dates & Book'
                    : 'Currently Unavailable',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
