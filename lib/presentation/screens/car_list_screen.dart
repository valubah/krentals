// lib/presentation/screens/car_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/car_model.dart';
import '../blocs/car_list/car_list_bloc.dart';
import '../widgets/app_widgets.dart';
import 'car_detail_screen.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  static const _categories = ['All', 'SUV', 'Sedan', 'Sports'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DriveEase',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.accent,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Premium car rentals',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ],
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<CarListBloc, CarListState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async {
              context
                  .read<CarListBloc>()
                  .add(const CarListRefreshRequested());
              // Wait for the refresh to complete
              await context.read<CarListBloc>().stream.firstWhere(
                    (s) => s is CarListLoaded || s is CarListError || s is CarListEmpty,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Category chips
                SliverToBoxAdapter(
                  child: _CategoryFilter(
                    categories: _categories,
                    activeCategory: state is CarListLoaded
                        ? (state.activeCategory ?? 'All')
                        : 'All',
                    onCategoryChanged: (cat) {
                      context.read<CarListBloc>().add(
                        CarListFilterChanged(
                          category: cat == 'All' ? null : cat,
                        ),
                      );
                    },
                  ),
                ),

                // Content
                if (state is CarListLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (_, __) => const CarCardShimmer(),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (state is CarListError)
                  SliverFillRemaining(
                    child: ErrorState(
                      message: state.message,
                      isNetworkError: state.isNetworkError,
                      onRetry: () => context
                          .read<CarListBloc>()
                          .add(const CarListLoadRequested()),
                    ),
                  )
                else if (state is CarListEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.directions_car_outlined,
                        title: 'No Cars Found',
                        subtitle:
                        'There are no cars available at the moment. Check back soon.',
                        onAction: () => context
                            .read<CarListBloc>()
                            .add(const CarListLoadRequested()),
                      ),
                    )
                  else if (state is CarListLoaded || state is CarListRefreshing)
                      _CarGrid(
                        cars: state is CarListLoaded
                            ? state.filteredCars
                            : (state as CarListRefreshing).currentCars,
                      )
                    else
                      SliverFillRemaining(
                        child: EmptyState(
                          icon: Icons.directions_car_outlined,
                          title: 'Welcome to DriveEase',
                          subtitle: 'Pull down to load available cars.',
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CategoryFilter({
    required this.categories,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isActive = cat == activeCategory;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              label: Text(cat),
              selected: isActive,
              onSelected: (_) => onCategoryChanged(cat),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isActive ? AppTheme.primary : AppTheme.divider,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }
}

class _CarGrid extends StatelessWidget {
  final List<Car> cars;
  const _CarGrid({required this.cars});

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.filter_list_off_rounded,
          title: 'No matches',
          subtitle: 'No cars found for this filter. Try a different category.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) => _CarCard(car: cars[i]),
          childCount: cars.length,
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CarListBloc>(),
            child: CarDetailScreen(car: car),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image
            Hero(
              tag: 'car_${car.id}',
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: car.imageUrls.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.brand,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              car.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AvailabilityBadge(isAvailable: car.isAvailable),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        car.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star_rounded,
                          size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      Text(
                        car.rating.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _SpecChip(
                            icon: Icons.people_outline,
                            label: '${car.seats} seats',
                          ),
                          const SizedBox(width: 8),
                          _SpecChip(
                            icon: Icons.settings_outlined,
                            label: car.transmission,
                          ),
                        ],
                      ),
                      PriceTag(price: car.pricePerDay),
                    ],
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

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
