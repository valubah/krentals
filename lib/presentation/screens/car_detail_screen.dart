// lib/presentation/screens/car_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_scroll_behavior.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final url in widget.car.imageUrls) {
      precacheImage(AssetImage(url), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getAngleLabel(int index) {
    const labels = ['FRONT EXTERIOR', 'INTERIOR COCKPIT', 'REAR VIEW'];
    if (index < labels.length) return labels[index];
    return 'DETAILED VIEW';
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image Carousel App Bar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: isDesktop ? 600 : 380,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.cardBg,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _CircleButton(icon: Icons.share_outlined, onTap: () {}),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollBehavior: AppScrollBehavior(),
                    itemCount: car.imageUrls.length,
                    itemBuilder: (context, i) {
                      final imageWidget = AppImage(
                        path: car.imageUrls[i],
                        fit: BoxFit.cover,
                      );

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (i == 0)
                            Hero(
                              tag: 'car_${car.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: imageWidget,
                              ),
                            )
                          else
                            imageWidget,
                          // Subtle bottom gradient
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                          // Angle Label Badge
                          Positioned(
                            bottom: 40,
                            left: 20,
                            child: _GlassBadge(text: _getAngleLabel(i)),
                          ),
                        ],
                      );
                    },
                  ),
                  // Custom Indicators
                  Positioned(
                    bottom: 44,
                    right: 20,
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: car.imageUrls.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.4),
                        expansionFactor: 3,
                        spacing: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Main Content Body ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1000 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car Identity
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${car.brand} • ${car.category}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _RatingBadge(
                            rating: car.rating,
                            count: car.reviewCount,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 32),

                      // Specs Grid
                      _SpecsGrid(car: car),

                      const SizedBox(height: 40),

                      // Hosted By Section
                      const _HostedBySection(),

                      const SizedBox(height: 40),

                      // Description
                      const SectionHeader(title: 'DESCRIPTION'),
                      const SizedBox(height: 12),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _descriptionExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          car.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.6),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          car.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.6),
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
                          _descriptionExpanded ? 'Read less' : 'Read more',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Features
                      const SectionHeader(title: 'FEATURES'),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: car.features
                            .map((f) => _FeatureTile(feature: f))
                            .toList(),
                      ),

                      const SizedBox(height: 40),

                      // Location
                      const SectionHeader(title: 'LOCATION'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            car.location,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 120), // Whitespace for bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBookingBar(car: car),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String text;
  const _GlassBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingBadge({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          ],
        ),
        Text(
          '$count reviews',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final Car car;
  const _SpecsGrid({required this.car});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 2.2,
          children: [
            _SpecTile(
              icon: Icons.people_outline_rounded,
              label: 'SEATS',
              value: '${car.seats} seats',
            ),
            _SpecTile(
              icon: Icons.settings_outlined,
              label: 'GEARBOX',
              value: car.transmission,
            ),
            _SpecTile(
              icon: Icons.category_outlined,
              label: 'CATEGORY',
              value: car.category,
            ),
          ],
        );
      },
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class _HostedBySection extends StatelessWidget {
  const _HostedBySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accent.withOpacity(0.1),
            child: const Icon(
              Icons.directions_car_rounded,
              color: AppTheme.accent,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hosted by K Rentals',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                SizedBox(height: 2),
                Text(
                  'All-Star Host • 4.98 Rating',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: AppTheme.accent, size: 24),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: AppTheme.success, size: 16),
          const SizedBox(width: 8),
          Text(
            feature,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  final Car car;
  const _BottomBookingBar({required this.car});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : double.infinity,
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starting from',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PriceTag(price: car.pricePerDay, fontSize: 24),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                width: isDesktop ? 300 : 200,
                child: FilledButton(
                  onPressed: car.isAvailable
                      ? () {
                          context.read<BookingBloc>().add(
                            BookingCarSelected(car),
                          );
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
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    car.isAvailable ? 'Check availability' : 'Unavailable',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
