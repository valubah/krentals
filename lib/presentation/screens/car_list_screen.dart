// lib/presentation/screens/car_list_screen.dart


/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/car_model.dart';
import '../blocs/car_list/car_list_bloc.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/app_widgets.dart';
import 'car_detail_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  static const _categories = ['All', 'SUV', 'Sedan', 'Sports'];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search brand, model, or city...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          onChanged: (value) {
            final state = context.read<CarListBloc>().state;
            final category = state is CarListLoaded
                ? state.activeCategory
                : null;
            context.read<CarListBloc>().add(
              CarListFilterChanged(
                category: category,
                searchQuery: value,
              ),
            );
          },
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'K Rentals',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.accent,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Premium car rentals',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  final state = context.read<CarListBloc>().state;
                  final category = state is CarListLoaded
                      ? state.activeCategory
                      : null;
                  context.read<CarListBloc>().add(
                    CarListFilterChanged(category: category, searchQuery: ''),
                  );
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<CarListBloc, CarListState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async {
              context.read<CarListBloc>().add(const CarListRefreshRequested());
              await context.read<CarListBloc>().stream.firstWhere(
                    (s) =>
                s is CarListLoaded ||
                    s is CarListError ||
                    s is CarListEmpty,
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
                      onRetry: () => context.read<CarListBloc>().add(
                        const CarListLoadRequested(),
                      ),
                    ),
                  )
                else if (state is CarListEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.directions_car_outlined,
                        title: 'No Cars Found',
                        subtitle:
                        'There are no cars available at the moment. Check back soon.',
                        onAction: () => context.read<CarListBloc>().add(
                          const CarListLoadRequested(),
                        ),
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
                          title: 'Welcome to K Rentals',
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
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.filter_list_off_rounded,
          title: 'No matches',
          subtitle: 'No cars found for this filter. Try a different category.',
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    if (isDesktop) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 450,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, i) => _CarCard(car: cars[i]),
            childCount: cars.length,
          ),
        ),
      );
    }

    if (isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, i) => _CarCard(car: cars[i]),
            childCount: cars.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      onTap: () {
        // Capture both blocs before entering the new route —
        // the new MaterialPageRoute creates a fresh widget tree
        // that loses access to ancestor providers.
        final carListBloc = context.read<CarListBloc>();
        final bookingBloc = context.read<BookingBloc>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: carListBloc),
                BlocProvider.value(value: bookingBloc),
              ],
              child: CarDetailScreen(car: car),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppImage(
                    path: car.imageUrls.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                              style: Theme.of(context).textTheme.bodyMedium
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
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        car.location,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber.shade600,
                      ),
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

 */

// lib/presentation/screens/car_list_screen.dart



// lib/presentation/screens/car_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_scroll_behavior.dart';
import '../../data/models/car_model.dart';
import '../blocs/car_list/car_list_bloc.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/app_widgets.dart';
import 'booking_screen.dart';

// ═══════════════════════════════════════════════════════════════════
//  CAR LIST SCREEN
// ═══════════════════════════════════════════════════════════════════

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});
  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  static const _categories = ['All', 'SUV', 'Sedan', 'Sports'];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search brand, model, or city...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          onChanged: (value) {
            final state = context.read<CarListBloc>().state;
            final category = state is CarListLoaded ? state.activeCategory : null;
            context.read<CarListBloc>().add(CarListFilterChanged(category: category, searchQuery: value));
          },
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('K Rentals',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accent, letterSpacing: -1)),
            Text('Premium car rentals',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  final state = context.read<CarListBloc>().state;
                  final category = state is CarListLoaded ? state.activeCategory : null;
                  context.read<CarListBloc>().add(CarListFilterChanged(category: category, searchQuery: ''));
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<CarListBloc, CarListState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async {
              context.read<CarListBloc>().add(const CarListRefreshRequested());
              await context.read<CarListBloc>().stream.firstWhere(
                      (s) => s is CarListLoaded || s is CarListError || s is CarListEmpty);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _CategoryFilter(
                    categories: _categories,
                    activeCategory: state is CarListLoaded ? (state.activeCategory ?? 'All') : 'All',
                    onCategoryChanged: (cat) {
                      context.read<CarListBloc>().add(CarListFilterChanged(category: cat == 'All' ? null : cat));
                    },
                  ),
                ),
                if (state is CarListLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((_, __) => const CarCardShimmer(), childCount: 4),
                    ),
                  )
                else if (state is CarListError)
                  SliverFillRemaining(
                    child: ErrorState(message: state.message, isNetworkError: state.isNetworkError,
                        onRetry: () => context.read<CarListBloc>().add(const CarListLoadRequested())),
                  )
                else if (state is CarListEmpty)
                    SliverFillRemaining(
                      child: EmptyState(icon: Icons.directions_car_outlined, title: 'No Cars Found',
                          subtitle: 'There are no cars available at the moment. Check back soon.',
                          onAction: () => context.read<CarListBloc>().add(const CarListLoadRequested())),
                    )
                  else if (state is CarListLoaded || state is CarListRefreshing)
                      _CarGrid(cars: state is CarListLoaded ? state.filteredCars : (state as CarListRefreshing).currentCars)
                    else
                      SliverFillRemaining(
                        child: EmptyState(icon: Icons.directions_car_outlined,
                            title: 'Welcome to K Rentals', subtitle: 'Pull down to load available cars.'),
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
  const _CategoryFilter({required this.categories, required this.activeCategory, required this.onCategoryChanged});

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
          return FilterChip(
            label: Text(cat),
            selected: isActive,
            onSelected: (_) => onCategoryChanged(cat),
            backgroundColor: Colors.white,
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(color: isActive ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            side: BorderSide(color: isActive ? AppTheme.primary : AppTheme.divider),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
      return const SliverFillRemaining(
        child: EmptyState(icon: Icons.filter_list_off_rounded, title: 'No matches',
            subtitle: 'No cars found for this filter. Try a different category.'),
      );
    }
    final width = MediaQuery.of(context).size.width;
    if (width > 900) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 450, mainAxisSpacing: 32, crossAxisSpacing: 32, childAspectRatio: 0.9),
          delegate: SliverChildBuilderDelegate((context, i) => _CarCard(car: cars[i]), childCount: cars.length),
        ),
      );
    }
    if (width > 600) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 1.0),
          delegate: SliverChildBuilderDelegate((context, i) => _CarCard(car: cars[i]), childCount: cars.length),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) => _CarCard(car: cars[i]), childCount: cars.length),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final carListBloc = context.read<CarListBloc>();
    final bookingBloc = context.read<BookingBloc>();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, PageRouteBuilder(
              pageBuilder: (ctx, animation, _) => MultiBlocProvider(
                providers: [BlocProvider.value(value: carListBloc), BlocProvider.value(value: bookingBloc)],
                child: CarDetailScreen(car: car),
              ),
              transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 250),
            ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(aspectRatio: 16 / 9,
                    child: AppImage(path: car.imageUrls.first, width: double.infinity, fit: BoxFit.cover)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(car.brand, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 12)),
                      Text(car.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                    ])),
                    AvailabilityBadge(isAvailable: car.isAvailable),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(car.location, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text(car.rating.toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      _SpecChip(icon: Icons.people_outline, label: '${car.seats} seats'),
                      const SizedBox(width: 8),
                      _SpecChip(icon: Icons.settings_outlined, label: car.transmission),
                    ]),
                    PriceTag(price: car.pricePerDay),
                  ]),
                ]),
              ),
            ],
          ),
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
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CAR DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════

class CarDetailScreen extends StatefulWidget {
  final Car car;
  const CarDetailScreen({super.key, required this.car});
  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final _pageController = PageController();
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    debugPrint('=== CarDetailScreen.initState() car=${widget.car.id}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== CarDetailScreen.build() car=${widget.car.id}');
    final car = widget.car;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      // ── Use a regular AppBar + body instead of SliverAppBar ──────
      // SliverAppBar + FlexibleSpaceBar was causing blank renders.
      // This plain layout is guaranteed to show content.
      body: Column(
        children: [
          // ── Image carousel (fixed height, not a sliver) ──────────
          SizedBox(
            height: isDesktop ? 500 : 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollBehavior: AppScrollBehavior(),
                  itemCount: car.imageUrls.length,
                  itemBuilder: (_, i) => Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(path: car.imageUrls[i], fit: BoxFit.cover),
                      // gradient
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      // angle label
                      Positioned(
                        bottom: 40,
                        left: 20,
                        child: _badge(_angleLabel(i)),
                      ),
                    ],
                  ),
                ),
                // back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: _circleBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
                ),
                // share button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: _circleBtn(Icons.share_outlined, () {}),
                ),
                // page indicator
                Positioned(
                  bottom: 44,
                  right: 20,
                  child: _SafeIndicator(controller: _pageController, count: car.imageUrls.length),
                ),
              ],
            ),
          ),

          // ── Scrollable content ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(car.name,
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1)),
                            const SizedBox(height: 4),
                            Text('${car.brand} • ${car.category}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(car.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          ]),
                          Text('${car.reviewCount} reviews', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ]),
                      ]),

                      const SizedBox(height: 28),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 28),

                      // Specs row
                      Row(children: [
                        _specItem(Icons.people_outline_rounded, 'SEATS', '${car.seats} seats'),
                        const SizedBox(width: 24),
                        _specItem(Icons.settings_outlined, 'GEARBOX', car.transmission),
                        const SizedBox(width: 24),
                        _specItem(Icons.category_outlined, 'CATEGORY', car.category),
                      ]),

                      const SizedBox(height: 28),

                      // Host card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.divider)),
                        child: Row(children: [
                          CircleAvatar(radius: 28, backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                              child: const Icon(Icons.directions_car_rounded, color: AppTheme.accent, size: 32)),
                          const SizedBox(width: 16),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Hosted by K Rentals', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                            SizedBox(height: 2),
                            Text('All-Star Host • 4.98 Rating', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                          ])),
                          const Icon(Icons.verified_rounded, color: AppTheme.accent, size: 24),
                        ]),
                      ),

                      const SizedBox(height: 28),

                      // Description
                      const SectionHeader(title: 'DESCRIPTION'),
                      const SizedBox(height: 12),
                      Text(car.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                          maxLines: _expanded ? null : 4,
                          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis),
                      TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppTheme.accent),
                        child: Text(_expanded ? 'Read less' : 'Read more', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),

                      const SizedBox(height: 28),

                      // Features
                      const SectionHeader(title: 'FEATURES'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: car.features.map((f) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check_rounded, color: AppTheme.success, size: 16),
                            const SizedBox(width: 8),
                            Text(f, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ]),
                        )).toList(),
                      ),

                      const SizedBox(height: 28),

                      // Location
                      const SectionHeader(title: 'LOCATION'),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(car.location,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
                      ]),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom booking bar ─────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppTheme.divider)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Starting from', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            PriceTag(price: car.pricePerDay, fontSize: 24),
          ]),
          const Spacer(),
          SizedBox(
            height: 56,
            width: 200,
            child: FilledButton(
              onPressed: car.isAvailable ? () {
                context.read<BookingBloc>().add(BookingCarSelected(car));
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(value: context.read<BookingBloc>(), child: const BookingScreen()),
                ));
              } : null,
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(car.isAvailable ? 'Check availability' : 'Unavailable',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ]),
      ),
    );
  }

  String _angleLabel(int i) {
    const l = ['FRONT EXTERIOR', 'INTERIOR COCKPIT', 'REAR VIEW'];
    return i < l.length ? l[i] : 'DETAILED VIEW';
  }

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
  );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    ),
  );

  Widget _specItem(IconData icon, String label, String value) => Expanded(
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.08), shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.accent, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );
}

class _SafeIndicator extends StatefulWidget {
  final PageController controller;
  final int count;
  const _SafeIndicator({required this.controller, required this.count});
  @override
  State<_SafeIndicator> createState() => _SafeIndicatorState();
}

class _SafeIndicatorState extends State<_SafeIndicator> {
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _ready = true); });
  }
  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return SmoothPageIndicator(
      controller: widget.controller,
      count: widget.count,
      effect: ExpandingDotsEffect(
        dotWidth: 8, dotHeight: 8,
        activeDotColor: Colors.white,
        dotColor: Colors.white.withValues(alpha: 0.4),
        expansionFactor: 3, spacing: 6,
      ),
    );
  }
}