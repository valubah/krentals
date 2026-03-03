// lib/main.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';
import 'presentation/blocs/car_list/car_list_bloc.dart';
import 'presentation/blocs/booking/booking_bloc.dart';
import 'presentation/screens/car_list_screen.dart';
import 'core/utils/app_scroll_behavior.dart';


/*
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BLoC observer for logging/debugging
  Bloc.observer = AppBlocObserver();

  // Initialize dependency injection
  ServiceLocator.setup();

  runApp(const KRentalsApp());
}

 */


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch ALL silent Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FLUTTER ERROR: ${details.exceptionAsString()}');
    debugPrint('🔴 LIBRARY: ${details.library}');
    debugPrint('🔴 STACK:\n${details.stack}');
  };

  // Catch errors outside Flutter framework (async, isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PLATFORM ERROR: $error');
    debugPrint('🔴 STACK:\n$stack');
    return true;
  };

  Bloc.observer = AppBlocObserver();
  ServiceLocator.setup();
  runApp(const KRentalsApp());
}

class KRentalsApp extends StatelessWidget {
  const KRentalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CarListBloc>(
          create: (_) =>
              CarListBloc(repository: ServiceLocator.carRepository)
                ..add(const CarListLoadRequested()),
        ),
        BlocProvider<BookingBloc>(
          create: (_) =>
              BookingBloc(repository: ServiceLocator.bookingRepository),
        ),
      ],
      child: MaterialApp(
        title: 'K Rentals',
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        theme: AppTheme.light,
        home: const CarListScreen(),
      ),
    );
  }
}
